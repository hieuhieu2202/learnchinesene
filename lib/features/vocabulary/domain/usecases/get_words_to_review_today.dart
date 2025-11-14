import 'package:learnchinese/core/usecase/usecase.dart';

import '../repositories/progress_repository.dart';

class GetWordsToReviewToday extends UseCase<List<int>, DateTime> {
  GetWordsToReviewToday(this.repository);

  final ProgressRepository repository;

  @override
  Future<List<int>> call(DateTime today) {
    return repository.getWordsToReviewToday(today);
  }
}
