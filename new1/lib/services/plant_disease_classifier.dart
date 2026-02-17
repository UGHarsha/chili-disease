import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/disease_details.dart';
import '../models/disease_prediction.dart';

class PlantDiseaseClassifier {
  PlantDiseaseClassifier({
    this.modelAssetPath = 'assets/model/chilli_disease_model.tflite',
    this.labelsAssetPath = 'assets/data/labels.txt',
  });

  final String modelAssetPath;
  final String labelsAssetPath;

  Interpreter? _interpreter;
  late List<String> _labels;
  late List<int> _inputShape;
  late List<int> _outputShape;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _labels = await _loadLabels();

    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter =
          await Interpreter.fromAsset(modelAssetPath, options: options);
    } on Exception catch (e) {
      throw PlantModelLoadException(
        'Unable to load the TensorFlow Lite model from "$modelAssetPath". '
        'Original error: $e',
      );
    }

    final inputTensor = _interpreter!.getInputTensor(0);
    _inputShape = inputTensor.shape; // e.g. [1, 224, 224, 3]

    final outputTensor = _interpreter!.getOutputTensor(0);
    _outputShape = outputTensor.shape; // e.g. [1, 6]

    if (outputTensor.shape.last != _labels.length) {
      throw PlantModelLoadException(
        'Model output dimension (${outputTensor.shape.last}) does not match '
        'label count (${_labels.length}). Fix labels.txt.',
      );
    }
    _isLoaded = true;
  }

  /// Run inference and return a prediction with top-3 alternatives.
  Future<DiseasePrediction> predict(File imageFile) async {
    if (!_isLoaded) {
      throw StateError('Call load() before predict().');
    }
    if (!await imageFile.exists()) {
      throw ArgumentError('Image file not found: ${imageFile.path}');
    }

    final rawBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw PlantModelLoadException('Failed to decode the selected image.');
    }

    final input = _buildInputTensor(decoded);
    final output = _createOutputBuffer();

    _interpreter!.run(input, output);

    final scores = output[0]; // already probabilities from the model

    // Pair each label with its score.
    final entries = <MapEntry<String, double>>[];
    for (var i = 0; i < _labels.length && i < scores.length; i++) {
      entries.add(MapEntry(_labels[i], scores[i]));
    }
    if (entries.isEmpty) {
      throw PlantModelLoadException('Model produced no scores.');
    }

    // Sort descending by confidence.
    entries.sort((a, b) => b.value.compareTo(a.value));
    final k = min(3, entries.length);

    final topPredictions = <DiseasePrediction>[];
    for (var i = 0; i < k; i++) {
      final label = entries[i].key;
      topPredictions.add(DiseasePrediction(
        label: label,
        confidence: entries[i].value,
        info: kDiseaseDetails[label],
      ));
    }

    return DiseasePrediction(
      label: topPredictions.first.label,
      confidence: topPredictions.first.confidence,
      info: topPredictions.first.info,
      alternatives:
          topPredictions.length > 1 ? topPredictions.sublist(1) : null,
    );
  }

  // ─── Labels ──────────────────────────────────────────────────────────

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(labelsAssetPath);
    final lines = raw.split('\n');
    final labels = <String>[];
    // Teachable Machine format: "0 ClassName"
    final pattern = RegExp(r'^(\d+)\s+(.+)$');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = pattern.firstMatch(trimmed);
      labels.add(match != null ? match.group(2)! : trimmed);
    }
    if (labels.isEmpty) {
      throw PlantModelLoadException('No labels found in $labelsAssetPath');
    }
    return labels;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }

  // ─── Image → Tensor ─────────────────────────────────────────────────
  //
  // Teachable Machine (model_unquant.tflite) preprocessing:
  //   1. Bake EXIF orientation so phone-camera rotation is handled.
  //   2. Center-crop to a square (matching TM's cropTo() function).
  //   3. Resize to model input size (224×224).
  //   4. Normalise to [-1, 1] using the official TM formula:
  //        (pixel / 127.5) - 1.0
  //      Source: https://github.com/googlecreativelab/teachablemachine-community
  //        libraries/image/src/utils/tf.ts  →  capture()
  //        snippets/converter/image/test/test-image-tflite.py
  //        snippets/markdown/image/tensorflow/keras.md

  List<List<List<List<double>>>> _buildInputTensor(img.Image image) {
    final targetH = _inputShape[1]; // typically 224
    final targetW = _inputShape[2]; // typically 224

    // ── Step 1: Bake EXIF orientation ──
    // Phone cameras write rotation as EXIF metadata rather than rotating
    // pixels. bakeOrientation applies the rotation so the model sees
    // the image the way the user sees it.
    final oriented = img.bakeOrientation(image);

    // ── Step 2: Center-crop to square ──
    final srcW = oriented.width;
    final srcH = oriented.height;
    final cropSize = min(srcW, srcH);
    final offsetX = (srcW - cropSize) ~/ 2;
    final offsetY = (srcH - cropSize) ~/ 2;
    final cropped = img.copyCrop(
      oriented,
      offsetX,
      offsetY,
      cropSize,
      cropSize,
    );

    // ── Step 3: Resize to model input size ──
    final resized = img.copyResize(
      cropped,
      width: targetW,
      height: targetH,
      interpolation: img.Interpolation.linear,
    );

    // ── Step 4: Build float32 tensor with [-1, 1] normalisation ──
    // Official Teachable Machine formula: (pixel / 127.5) - 1.0
    final tensor = List<List<List<double>>>.generate(targetH, (y) {
      return List<List<double>>.generate(targetW, (x) {
        final pixel = resized.getPixel(x, y);
        final r = (img.getRed(pixel).toDouble() / 127.5) - 1.0;
        final g = (img.getGreen(pixel).toDouble() / 127.5) - 1.0;
        final b = (img.getBlue(pixel).toDouble() / 127.5) - 1.0;
        return [r, g, b];
      });
    });

    return [tensor]; // shape: [1, targetH, targetW, 3]
  }

  // ─── Output buffer ──────────────────────────────────────────────────

  List<List<double>> _createOutputBuffer() {
    final classCount = _outputShape.last;
    return [List<double>.filled(classCount, 0.0)];
  }

  // NOTE: We do NOT apply softmax here. Teachable Machine unquant models
  // already output softmax probabilities. Applying softmax a second time
  // would distort the distribution and flip prediction rankings.
}

class PlantModelLoadException implements Exception {
  PlantModelLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
