import '../../domain/entities/example_sentence.dart';

class ExampleModel extends ExampleSentence {
  const ExampleModel({
    required super.id,
    required super.wordId,
    required super.orderIndex,
    required super.sentenceCn,
    required super.sentencePinyin,
    required super.sentenceVi,
  });

  factory ExampleModel.fromMap(Map<String, Object?> map) {
    return ExampleModel(
      id: map['id'] as int,
      wordId: map['word_id'] as int,
      orderIndex: map['order_index'] as int,
      sentenceCn: map['sentence_cn'] as String? ?? '',
      sentencePinyin: map['sentence_pinyin'] as String? ?? '',
      sentenceVi: map['sentence_vi'] as String? ?? '',
    );
  }
}
