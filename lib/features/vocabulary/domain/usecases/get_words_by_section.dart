import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWordsBySection extends UseCase<List<Word>, int> {
  GetWordsBySection(this.repository);

  final WordRepository repository;

  @override
  Future<List<Word>> call(int sectionId) {
    return repository.getWordsBySection(sectionId);
  }
}
