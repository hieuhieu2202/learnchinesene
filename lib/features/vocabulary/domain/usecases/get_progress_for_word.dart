import 'package:flash_learn_chinese/core/usecase/usecase.dart';

import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class GetProgressForWordVer1Ne extends UseCaseVer1Ne<Progress?, int> {
  GetProgressForWordVer1Ne(this.repository);

  final ProgressRepository repository;

  @override
  Future<Progress?> call(int params) {
    return repository.getProgressForWord(params);
  }
}

@Deprecated('Use GetProgressForWordVer1Ne')
typedef GetProgressForWord = GetProgressForWordVer1Ne;
