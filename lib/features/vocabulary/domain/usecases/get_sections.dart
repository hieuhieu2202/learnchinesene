import 'package:flash_learn_chinese/core/usecase/usecase.dart';

import '../repositories/word_repository.dart';

class GetSectionsVer1Ne extends UseCaseVer1Ne<List<int>, NoParamsVer1Ne> {
  GetSectionsVer1Ne(this.repository);

  final WordRepository repository;

  @override
  Future<List<int>> call(NoParamsVer1Ne params) {
    return repository.getSections();
  }
}

@Deprecated('Use GetSectionsVer1Ne')
typedef GetSections = GetSectionsVer1Ne;
