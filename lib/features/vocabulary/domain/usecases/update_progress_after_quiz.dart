import 'package:flash_learn_chinese/core/usecase/usecase.dart';

import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class UpdateProgressAfterQuizVer1Ne
    extends UseCaseVer1Ne<void, UpdateProgressParams> {
  UpdateProgressAfterQuizVer1Ne(this.repository);

  final ProgressRepository repository;

  @override
  Future<void> call(UpdateProgressParams params) {
    final updated = params.progress.copyWith(
      correctCount: params.correctCount ?? params.progress.correctCount,
      wrongCount: params.wrongCount ?? params.progress.wrongCount,
      lastPractice: params.lastPractice ?? DateTime.now(),
      level: params.level ?? params.progress.level,
      mastered: params.mastered ?? params.progress.mastered,
    );
    return repository.upsertProgress(updated);
  }
}

@Deprecated('Use UpdateProgressAfterQuizVer1Ne')
typedef UpdateProgressAfterQuiz = UpdateProgressAfterQuizVer1Ne;

class UpdateProgressParams {
  UpdateProgressParams({
    required this.progress,
    this.correctCount,
    this.wrongCount,
    this.lastPractice,
    this.level,
    this.mastered,
  });

  final Progress progress;
  final int? correctCount;
  final int? wrongCount;
  final DateTime? lastPractice;
  final int? level;
  final bool? mastered;
}
