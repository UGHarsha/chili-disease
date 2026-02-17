import 'disease_info.dart';

class DiseasePrediction {
  const DiseasePrediction({
    required this.label,
    required this.confidence,
    this.info,
  });

  final String label;
  final double confidence;
  final DiseaseInfo? info;

  String get confidenceLabel => '${(confidence * 100).toStringAsFixed(1)}%';
}
