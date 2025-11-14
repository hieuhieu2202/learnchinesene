import 'package:learnchinese/core/usecase/usecase.dart';

import '../repositories/word_repository.dart';

class GetSections extends UseCase<List<int>, NoParams> {
  GetSections(this.repository);

  final WordRepository repository;

  @override
  Future<List<int>> call(NoParams params) {
    return repository.getSections();
  }
}
