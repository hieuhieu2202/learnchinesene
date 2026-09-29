class BossBattleQuestion {
  const BossBattleQuestion({
    required this.id,
    required this.prompt,
    required this.answers,
    required this.correctAnswer,
  });

  final String id;
  final String prompt;
  final List<String> answers;
  final String correctAnswer;

  BossBattleQuestion copyWith({
    List<String>? answers,
  }) {
    return BossBattleQuestion(
      id: id,
      prompt: prompt,
      answers: answers ?? this.answers,
      correctAnswer: correctAnswer,
    );
  }
}
