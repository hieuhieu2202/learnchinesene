import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class GetProgressForWord extends UseCase<Progress?, int> {
  GetProgressForWord(this.repository);

  final ProgressRepository repository;

  @override
  Future<Progress?> call(int params) {
    return repository.getProgressForWord(params);
  }
}
