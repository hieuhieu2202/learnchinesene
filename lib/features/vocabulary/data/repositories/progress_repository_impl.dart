import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';
import '../models/progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this.localDataSource);

  final ProgressLocalDataSource localDataSource;

  @override
  Future<Progress?> getProgressForWord(int wordId) {
    return localDataSource.getProgressForWord(wordId);
  }

  @override
  Future<Map<int, Progress>> getProgressForSection(int sectionId) async {
    final map = await localDataSource.getProgressForSection(sectionId);
    return map.map((key, value) => MapEntry(key, value));
  }

  @override
  Future<void> upsertProgress(Progress progress) {
    return localDataSource.upsertProgress(_toModel(progress));
  }

  @override
  Future<List<int>> getWordsToReviewToday(DateTime today) {
    return localDataSource.getWordsToReviewToday(today);
  }

  ProgressModel _toModel(Progress progress) {
    return ProgressModel(
      wordId: progress.wordId,
      correctCount: progress.correctCount,
      wrongCount: progress.wrongCount,
      lastPractice: progress.lastPractice,
      level: progress.level,
      mastered: progress.mastered,
    );
  }
}
