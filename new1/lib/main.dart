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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
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
      setState(() => _errorMessage = 'Unexpected error loading model: $e');
    } finally {
      if (mounted) setState(() => _loadingModel = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_loadingModel || !_classifier.isLoaded) return;
    try {
      // Use max image quality to preserve detail for the model.
      final selected = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (selected == null) return;
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
      setState(() => _errorMessage = 'Classification failed: $e');
    } finally {
      if (mounted) setState(() => _runningInference = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌶️ Chilli Plant Doctor'),
        centerTitle: true,
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_runningInference)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Analysing image…'),
                        ],
                      ),
                    ),
                  if (_errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  if (_prediction != null)
                    PredictionResultCard(prediction: _prediction!),
                  if (_prediction == null &&
                      _errorMessage == null &&
                      !_runningInference)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.eco_outlined,
                                size: 48, color: Colors.green),
                            SizedBox(height: 12),
                            Text(
                              'Take a close-up photo of a chilli leaf or fruit\nto diagnose potential diseases.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Image Preview
// ═══════════════════════════════════════════════════════════════════════

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
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No image selected'),
                  ],
                )
              : Image.file(File(image!.path), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Prediction Result Card
// ═══════════════════════════════════════════════════════════════════════

class PredictionResultCard extends StatelessWidget {
  const PredictionResultCard({super.key, required this.prediction});
  final DiseasePrediction prediction;

  Color _confidenceColor(double c) {
    if (c >= 0.80) return Colors.green;
    if (c >= 0.50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final info = prediction.info;
    final alternatives = prediction.alternatives ?? const [];
    final confColor = _confidenceColor(prediction.confidence);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Disease name ──
            Text(
              info?.name ?? prediction.label,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ── Confidence bar ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: prediction.confidence,
                      minHeight: 10,
                      backgroundColor: confColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(confColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  prediction.confidenceLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: confColor),
                ),
              ],
            ),

            // ── Low confidence warning ──
            if (prediction.confidence < 0.60) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low confidence — try a clearer, close-up photo of the affected area in good lighting.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Disease details ──
            if (info != null) ...[
              const SizedBox(height: 16),
              Text(info.overview, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 16),
              if (info.symptoms.isNotEmpty)
                _SectionList(
                    title: '🔍 Symptoms', items: info.symptoms),
              if (info.management.isNotEmpty)
                _SectionList(
                    title: '💊 Management', items: info.management),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                    'No detailed information available for this class.'),
              ),

            // ── Alternative predictions ──
            if (alternatives.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Other possible diagnoses',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...alternatives.map((alt) {
                final altColor = _confidenceColor(alt.confidence);
                return InkWell(
                  onTap: () => _showDiseaseDialog(context, alt),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            alt.info?.name ?? alt.label,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: altColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alt.confidenceLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: altColor),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _showDiseaseDialog(BuildContext context, DiseasePrediction alt) {
    final info = alt.info;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(info?.name ?? alt.label),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Confidence: ${alt.confidenceLabel}'),
              const SizedBox(height: 12),
              if (info != null) ...[
                Text(info.overview, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 12),
                if (info.symptoms.isNotEmpty)
                  _SectionList(title: '🔍 Symptoms', items: info.symptoms),
                if (info.management.isNotEmpty)
                  _SectionList(
                      title: '💊 Management', items: info.management),
              ] else
                const Text('No additional details available.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Bullet-point section list
// ═══════════════════════════════════════════════════════════════════════

class _SectionList extends StatelessWidget {
  const _SectionList({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('  •  '),
                  Expanded(
                      child: Text(item,
                          style: const TextStyle(height: 1.4))),
                ],
              ),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
