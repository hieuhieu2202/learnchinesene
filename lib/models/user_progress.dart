class UserProgress {
  final int wordId;
  final int correctCount;
  final int wrongCount;
  final int level;
  final bool mastered;
  final String? lastReviewedAt;
  final String? updatedAt;

  const UserProgress({
    required this.wordId,
    required this.correctCount,
    required this.wrongCount,
    required this.level,
    required this.mastered,
    this.lastReviewedAt,
    this.updatedAt,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      wordId: (map['word_id'] as num?)?.toInt() ?? 0,
      correctCount: (map['correct_count'] as num?)?.toInt() ?? 0,
      wrongCount: (map['wrong_count'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      mastered: ((map['mastered'] as num?)?.toInt() ?? 0) == 1,
      lastReviewedAt: map['last_reviewed_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }
}
