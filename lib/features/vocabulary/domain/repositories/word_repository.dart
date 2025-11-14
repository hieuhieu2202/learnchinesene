import '../entities/word.dart';

abstract class WordRepository {
  Future<List<int>> getSections();
  Future<String> getSectionTitle(int sectionId);
  Future<List<Word>> getWordsBySection(int sectionId);
  Future<Word?> getWordById(int wordId);
}
