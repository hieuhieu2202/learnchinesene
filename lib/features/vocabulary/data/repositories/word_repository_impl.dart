import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/progress_local_data_source.dart';
import '../datasources/word_local_data_source.dart';

class WordRepositoryImpl implements WordRepository {
  WordRepositoryImpl(this.wordLocalDataSource, this.progressLocalDataSource);

  final WordLocalDataSource wordLocalDataSource;
  final ProgressLocalDataSource progressLocalDataSource;

  @override
  Future<List<int>> getSections() {
    return wordLocalDataSource.getSections();
  }

  @override
  Future<String> getSectionTitle(int sectionId) {
    return wordLocalDataSource.getSectionTitle(sectionId);
  }

  @override
  Future<List<Word>> getWordsBySection(int sectionId) async {
    final words = await wordLocalDataSource.getWordsBySection(sectionId);
    final progressMap = await progressLocalDataSource.getProgressForSection(sectionId);

    return [
      for (final word in words)
        Word(
          id: word.id,
          sectionId: word.sectionId,
          sectionTitle: word.sectionTitle,
          groupSubtitle: word.groupSubtitle,
          word: word.word,
          translation: word.translation,
          transliteration: word.transliteration,
          ttsUrl: word.ttsUrl,
          mastered: progressMap[word.id]?.mastered ?? false,
        ),
    ];
  }

  @override
  Future<Word?> getWordById(int wordId) async {
    final word = await wordLocalDataSource.getWordById(wordId);
    if (word == null) return null;
    final progress = await progressLocalDataSource.getProgressForWord(wordId);
    return Word(
      id: word.id,
      sectionId: word.sectionId,
      sectionTitle: word.sectionTitle,
      groupSubtitle: word.groupSubtitle,
      word: word.word,
      translation: word.translation,
      transliteration: word.transliteration,
      ttsUrl: word.ttsUrl,
      mastered: progress?.mastered ?? false,
    );
  }
}
