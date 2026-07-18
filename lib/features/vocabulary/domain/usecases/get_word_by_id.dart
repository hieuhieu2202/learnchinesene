import 'package:chinese_master/core/usecase/usecase.dart';

import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWordByIdVer1Ne extends UseCaseVer1Ne<Word?, int> {
  GetWordByIdVer1Ne(this.repository);

  final WordRepository repository;

  @override
  Future<Word?> call(int params) {
    return repository.getWordById(params);
  }
}

@Deprecated('Use GetWordByIdVer1Ne')
typedef GetWordById = GetWordByIdVer1Ne;
