import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    required super.id,
    required super.sectionId,
    required super.sectionTitle,
    required super.groupSubtitle,
    required super.word,
    required super.translation,
    required super.transliteration,
    required super.ttsUrl,
    required super.mastered,
  });

  factory WordModel.fromMap(Map<String, dynamic> map, {bool mastered = false}) {
    return WordModel(
      id: map['id'] as int,
      sectionId: map['section_id'] as int,
      sectionTitle: (map['section_title'] ?? '') as String,
      groupSubtitle: (map['group_subtitle'] ?? '') as String,
      word: (map['word'] ?? '') as String,
      translation: (map['translation'] ?? '') as String,
      transliteration: (map['transliteration'] ?? '') as String,
      ttsUrl: (map['tts_url'] ?? '') as String,
      mastered: mastered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'section_title': sectionTitle,
      'group_subtitle': groupSubtitle,
      'word': word,
      'translation': translation,
      'transliteration': transliteration,
      'tts_url': ttsUrl,
      'mastered': mastered ? 1 : 0,
    };
  }
}
