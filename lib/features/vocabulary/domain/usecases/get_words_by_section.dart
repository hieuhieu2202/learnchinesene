import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWordsBySectionVer1Ne extends UseCaseVer1Ne<List<Word>, int> {
  GetWordsBySectionVer1Ne(this.repository);

  final WordRepository repository;

  @override
  Future<List<Word>> call(int sectionId) {
    return repository.getWordsBySection(sectionId);
  }
}

@Deprecated('Use GetWordsBySectionVer1Ne')
typedef GetWordsBySection = GetWordsBySectionVer1Ne;
