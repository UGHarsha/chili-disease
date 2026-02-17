class DiseaseInfo {
  const DiseaseInfo({
    required this.name,
    required this.overview,
    required this.symptoms,
    required this.management,
  });

  final String name;
  final String overview;
  final List<String> symptoms;
  final List<String> management;
}
