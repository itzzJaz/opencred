class TrustScoreAssessment {
  const TrustScoreAssessment({
    required this.status,
    required this.modelVersion,
    this.score,
    this.probability,
    required this.presentFeatures,
    required this.limitation,
    this.positiveFactors = const [],
    this.negativeFactors = const [],
    this.runScores = const [],
    this.judgeExplanation = '',
  });

  final String status;
  final String modelVersion;
  final int? score;
  final double? probability;
  final int presentFeatures;
  final String limitation;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final List<int> runScores;
  final String judgeExplanation;

  bool get hasScore => status == 'scored' && score != null;
  bool get isOllama => hasScore && modelVersion.startsWith('ollama/');
}
