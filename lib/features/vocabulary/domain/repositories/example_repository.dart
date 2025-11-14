import '../entities/example_sentence.dart';

abstract class ExampleRepository {
  Future<List<ExampleSentence>> getExamplesByWord(int wordId);
}
