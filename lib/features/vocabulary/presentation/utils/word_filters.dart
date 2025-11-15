import '../../domain/entities/example_sentence.dart';
import '../../domain/entities/word.dart';

typedef ExampleLoader = Future<List<ExampleSentence>> Function(int wordId);

Future<List<Word>> dedupeWordsByExample({
  required List<Word> words,
  required ExampleLoader loadExamples,
}) async {
  if (words.isEmpty) {
    return const <Word>[];
  }

  final deduped = <Word>[];
  final seenKeys = <String>{};

  for (final word in words) {
    final trimmedWord = word.word.trim();
    if (trimmedWord.isEmpty) {
      deduped.add(word);
      continue;
    }

    final examples = await loadExamples(word.id);
    final primaryExample = examples.isEmpty
        ? null
        : examples.first.sentenceCn.trim();

    if (primaryExample == null || primaryExample.isEmpty) {
      deduped.add(word);
      continue;
    }

    final key = '${trimmedWord.toLowerCase()}::${primaryExample.toLowerCase()}';
    if (seenKeys.add(key)) {
      deduped.add(word);
    }
  }

  return deduped;
}
