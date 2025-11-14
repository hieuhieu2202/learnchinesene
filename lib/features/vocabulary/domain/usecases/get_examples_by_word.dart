import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/example_sentence.dart';
import '../repositories/example_repository.dart';

class GetExamplesByWord extends UseCase<List<ExampleSentence>, int> {
  GetExamplesByWord(this.repository);

  final ExampleRepository repository;

  @override
  Future<List<ExampleSentence>> call(int wordId) {
    return repository.getExamplesByWord(wordId);
  }
}
