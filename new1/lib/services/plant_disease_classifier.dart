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
  late TensorType _inputType;
  late List<int> _inputShape;
  late TensorType _outputType;
  late List<int> _outputShape;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _labels = await _loadLabels();

    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(modelAssetPath, options: options);
    } on Exception catch (e) {
      throw PlantModelLoadException(
        'Unable to load the TensorFlow Lite model from "$modelAssetPath". '
        'Place a valid .tflite file under assets/model/, add it to pubspec.yaml, '
        'and ensure the path matches. Original error: $e',
      );
    }

    final inputTensor = _interpreter!.getInputTensor(0);
    _inputType = inputTensor.type;
    _inputShape = inputTensor.shape;
  if (_inputType != TensorType.float32) {
      throw PlantModelLoadException(
        'Unsupported input tensor type "$_inputType". Only float32 models are supported by the current pipeline.',
      );
    }

    final outputTensor = _interpreter!.getOutputTensor(0);
    _outputType = outputTensor.type;
    _outputShape = outputTensor.shape;
  if (_outputType != TensorType.float32) {
      throw PlantModelLoadException(
        'Unsupported output tensor type "$_outputType". Only float32 outputs are supported by the current pipeline.',
      );
    }
    if (outputTensor.shape.last != _labels.length) {
      throw PlantModelLoadException(
        'Model output dimension (${outputTensor.shape.last}) does not match label count (${_labels.length}). '
        'Regenerate labels.txt or confirm the training pipeline configuration.',
      );
    }
    _isLoaded = true;
  }

  Future<DiseasePrediction> predict(File imageFile) async {
    if (!_isLoaded) {
      throw StateError('The model is not loaded. Call load() before predict().');
    }
    if (!await imageFile.exists()) {
      throw ArgumentError('Image file not found at path: ${imageFile.path}');
    }

    final rawBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(rawBytes);
    if (decodedImage == null) {
      throw PlantModelLoadException('Failed to decode the selected image.');
    }

    final input = _buildInputTensor(decodedImage);
    final output = _createEmptyOutputBuffer();

    _interpreter!.run(input, output);

    final scores = _extractScores(output);
    final labeledProbabilities = <String, double>{};
    for (var i = 0; i < _labels.length && i < scores.length; i++) {
      labeledProbabilities[_labels[i]] = scores[i];
    }

    if (labeledProbabilities.isEmpty) {
      throw PlantModelLoadException('Model produced no scores for the provided image.');
    }

    final topEntry = labeledProbabilities.entries.reduce(
      (currentMax, candidate) => candidate.value > currentMax.value ? candidate : currentMax,
    );

    return DiseasePrediction(
      label: topEntry.key,
      confidence: topEntry.value,
      info: kDiseaseDetails[topEntry.key],
    );
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(labelsAssetPath);
    final lines = raw.split('\n');
    final labels = <String>[];
    final pattern = RegExp(r'^(\d+)\s+(.+)$');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final match = pattern.firstMatch(trimmed);
      if (match != null) {
        labels.add(match.group(2)!);
      } else {
        labels.add(trimmed);
      }
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

  List<List<List<List<double>>>> _buildInputTensor(img.Image image) {
    final height = _inputShape[1];
    final width = _inputShape[2];
    final channels = _inputShape.length > 3 ? _inputShape[3] : 1;

    if (channels != 3) {
      throw PlantModelLoadException(
        'Expected RGB input with 3 channels. The model reports $channels channels.',
      );
    }

    final resized = img.copyResize(image, width: width, height: height);
    final imageTensor = List<List<List<double>>>.generate(height, (y) {
      return List<List<double>>.generate(width, (x) {
        final pixel = resized.getPixel(x, y);
        final r = img.getRed(pixel).toDouble();
        final g = img.getGreen(pixel).toDouble();
        final b = img.getBlue(pixel).toDouble();
        return [
          (r - 127.5) / 127.5,
          (g - 127.5) / 127.5,
          (b - 127.5) / 127.5,
        ];
      });
    });

    return [imageTensor];
  }

  List<List<double>> _createEmptyOutputBuffer() {
    final classCount = _outputShape.last;
    return [List<double>.filled(classCount, 0)];
  }

  List<double> _extractScores(List<List<double>> outputBuffer) {
    final rawScores = outputBuffer.first;
    if (rawScores.isEmpty) {
      return const [];
    }

    // Apply softmax for stability in case the model outputs logits.
    final maxLogit = rawScores.reduce(max);
    double sum = 0;
    final expScores = List<double>.filled(rawScores.length, 0);
    for (var i = 0; i < rawScores.length; i++) {
      final value = rawScores[i];
      final expValue = exp(value - maxLogit);
      expScores[i] = expValue;
      sum += expValue;
    }
    if (sum == 0) {
      return rawScores;
    }
    return expScores.map((value) => value / sum).toList(growable: false);
  }
}

class PlantModelLoadException implements Exception {
  PlantModelLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
