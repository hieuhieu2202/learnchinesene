import '../models/user_stats_model.dart';
import '../datasources/user_stats_local_data_source.dart';
import '../../domain/repositories/user_stats_repository.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final UserStatsLocalDataSource localDataSource;

  UserStatsRepositoryImpl({required this.localDataSource});

  @override
  Future<UserStats> getUserStats() => localDataSource.getUserStats();

  @override
  Future<void> updateUserStats(UserStats stats) => localDataSource.updateUserStats(stats);

  @override
  Future<void> addExp(int exp) => localDataSource.addExp(exp);

  @override
  Future<void> updateStreak() => localDataSource.updateStreak();

  @override
  Future<void> resetStreakIfNeeded() => localDataSource.resetStreakIfNeeded();

  @override
  Future<void> updateWordsMastered(int count) => localDataSource.updateWordsMastered(count);

  @override
  Future<void> updateFavorites(int count) => localDataSource.updateFavorites(count);
}

