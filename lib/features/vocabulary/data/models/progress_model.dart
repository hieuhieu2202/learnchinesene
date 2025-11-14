import '../../domain/entities/progress_entity.dart';

class ProgressModel extends Progress {
  const ProgressModel({
    required super.wordId,
    required super.correctCount,
    required super.wrongCount,
    required super.lastPractice,
    required super.level,
    required super.mastered,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      wordId: map['word_id'] as int,
      correctCount: (map['correct_count'] ?? 0) as int,
      wrongCount: (map['wrong_count'] ?? 0) as int,
      lastPractice: map['last_practice'] == null
          ? null
          : DateTime.tryParse(map['last_practice'] as String),
      level: (map['level'] ?? 0) as int,
      mastered: (map['mastered'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word_id': wordId,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'last_practice': lastPractice?.toIso8601String(),
      'level': level,
      'mastered': mastered ? 1 : 0,
    };
  }
}
