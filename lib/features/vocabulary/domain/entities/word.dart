class Word {
  final int id;
  final int sectionId;
  final String sectionTitle;
  final String groupSubtitle;
  final String word;
  final String translation;
  final String transliteration;
  final String ttsUrl;
  final bool mastered;

  const Word({
    required this.id,
    required this.sectionId,
    required this.sectionTitle,
    required this.groupSubtitle,
    required this.word,
    required this.translation,
    required this.transliteration,
    required this.ttsUrl,
    required this.mastered,
  });
}
