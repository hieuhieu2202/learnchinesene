import 'package:learnchinese/core/usecase/usecase.dart';

import '../repositories/progress_repository.dart';

class GetWordsToReviewTodayVer1Ne extends UseCaseVer1Ne<List<int>, DateTime> {
  GetWordsToReviewTodayVer1Ne(this.repository);

  final ProgressRepository repository;

  @override
  Future<List<int>> call(DateTime today) {
    return repository.getWordsToReviewToday(today);
  }
}

@Deprecated('Use GetWordsToReviewTodayVer1Ne')
typedef GetWordsToReviewToday = GetWordsToReviewTodayVer1Ne;
