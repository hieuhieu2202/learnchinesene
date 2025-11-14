import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWordById extends UseCase<Word?, int> {
  GetWordById(this.repository);

  final WordRepository repository;

  @override
  Future<Word?> call(int params) {
    return repository.getWordById(params);
  }
}
