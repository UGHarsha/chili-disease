import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/disease_prediction.dart';
import 'services/plant_disease_classifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chilli Plant Doctor',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const PlantDoctorHome(),
    );
  }
}

class PlantDoctorHome extends StatefulWidget {
  const PlantDoctorHome({super.key});

  @override
  State<PlantDoctorHome> createState() => _PlantDoctorHomeState();
}

class _PlantDoctorHomeState extends State<PlantDoctorHome> {
  final ImagePicker _picker = ImagePicker();
  final PlantDiseaseClassifier _classifier = PlantDiseaseClassifier();

  XFile? _selectedImage;
  DiseasePrediction? _prediction;
  bool _loadingModel = true;
  bool _runningInference = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialiseModel();
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  Future<void> _initialiseModel() async {
    try {
      await _classifier.load();
    } on PlantModelLoadException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error while loading the model: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingModel = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_loadingModel) {
      return;
    }
    if (!_classifier.isLoaded) {
      setState(() {
        _errorMessage ??= 'Model is still unavailable. Check the .tflite asset path and restart the app.';
      });
      return;
    }

    try {
      final selected = await _picker.pickImage(source: source, imageQuality: 90);
      if (selected == null) {
        return;
      }

      setState(() {
        _selectedImage = selected;
        _prediction = null;
        _errorMessage = null;
      });

      await _runInference(File(selected.path));
    } catch (e) {
      setState(() => _errorMessage = 'Failed to pick image: $e');
    }
  }

  Future<void> _runInference(File imageFile) async {
    setState(() => _runningInference = true);

    try {
      final prediction = await _classifier.predict(imageFile);
      setState(() => _prediction = prediction);
    } on PlantModelLoadException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Unable to classify the image: $e');
    } finally {
      if (mounted) {
        setState(() => _runningInference = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chilli Plant Doctor'),
      ),
      body: _loadingModel
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImagePreview(image: _selectedImage),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Pick from Gallery'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Capture Photo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_runningInference) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                  ],
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  if (_prediction != null)
                    PredictionResultCard(prediction: _prediction!),
                  if (_prediction == null && _errorMessage == null && !_runningInference)
                    const Text(
                      'Select a chilli plant leaf or fruit photo to diagnose potential diseases.',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image});

  final XFile? image;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No image selected'),
                  ],
                )
              : Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}

class PredictionResultCard extends StatelessWidget {
  const PredictionResultCard({super.key, required this.prediction});

  final DiseasePrediction prediction;

  @override
  Widget build(BuildContext context) {
    final info = prediction.info;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prediction.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('Confidence: ${prediction.confidenceLabel}'),
            if (info != null) ...[
              const SizedBox(height: 16),
              Text(info.overview),
              const SizedBox(height: 16),
              if (info.symptoms.isNotEmpty)
                _SectionList(
                  title: 'Key symptoms',
                  items: info.symptoms,
                ),
              if (info.management.isNotEmpty)
                _SectionList(
                  title: 'Management tips',
                  items: info.management,
                ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Add more agronomy details for this disease in lib/data/disease_details.dart.'),
              ),
          ],
        ),
      ),
    );
  }


}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
