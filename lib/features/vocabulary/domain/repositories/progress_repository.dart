import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  Future<Progress?> getProgressForWord(int wordId);
  Future<Map<int, Progress>> getProgressForSection(int sectionId);
  Future<void> upsertProgress(Progress progress);
  Future<List<int>> getWordsToReviewToday(DateTime today);
}
