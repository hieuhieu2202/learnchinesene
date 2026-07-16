class SpeakingResultModel {
  const SpeakingResultModel({
    required this.targetText,
    required this.recognizedText,
    required this.score,
    required this.isCorrect,
  });
  final String targetText;
  final String recognizedText;
  final double score;
  final bool isCorrect;
}
