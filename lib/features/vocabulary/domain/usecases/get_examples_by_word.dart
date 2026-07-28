import 'package:flash_learn_chinese/core/usecase/usecase.dart';

import '../entities/example_sentence.dart';
import '../repositories/example_repository.dart';

class GetExamplesByWordVer1Ne
    extends UseCaseVer1Ne<List<ExampleSentence>, int> {
  GetExamplesByWordVer1Ne(this.repository);

  final ExampleRepository repository;

  @override
  Future<List<ExampleSentence>> call(int wordId) {
    return repository.getExamplesByWord(wordId);
  }
}

@Deprecated('Use GetExamplesByWordVer1Ne')
typedef GetExamplesByWord = GetExamplesByWordVer1Ne;
