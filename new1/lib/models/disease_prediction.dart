import 'disease_info.dart';

class DiseasePrediction {
  const DiseasePrediction({
    required this.label,
    required this.confidence,
    this.info,
    this.alternatives,
  });

  final String label;
  final double confidence;
  final DiseaseInfo? info;

  // Optional list of alternative predictions (e.g. top-3 other matches).
  final List<DiseasePrediction>? alternatives;

  String get confidenceLabel => '${(confidence * 100).toStringAsFixed(1)}%';
}
