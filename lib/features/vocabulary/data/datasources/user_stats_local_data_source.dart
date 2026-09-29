import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_stats_model.dart';

/// Compatibility name kept for the existing repository layer.
///
/// User statistics are persisted in Supabase only for authenticated users.
/// Guest mode returns zero/default statistics and never blocks app startup.
abstract class UserStatsLocalDataSource {
  Future<UserStats> getUserStats();
  Future<void> updateUserStats(UserStats stats);
  Future<void> addExp(int exp);
  Future<void> updateStreak();
  Future<void> resetStreakIfNeeded();
  Future<void> updateWordsMastered(int count);
  Future<void> updateFavorites(int count);
}

class UserStatsLocalDataSourceImpl implements UserStatsLocalDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  UserStats _guestStats() => UserStats(
        id: 1,
        totalExp: 0,
        currentStreak: 0,
        lastStudyDate: DateTime.now().subtract(const Duration(days: 1)),
        totalWordsMastered: 0,
        totalFavorites: 0,
      );

  @override
  Future<UserStats> getUserStats() async {
    final userId = _userId;
    if (userId == null) return _guestStats();

    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('app_user_stats')
          .select(
            'total_exp, current_streak, last_study_date, total_words_mastered, total_favorites',
          )
          .eq('user_id', userId)
          .limit(1),
    );

    if (rows.isNotEmpty) {
      return UserStats.fromMap({...rows.first, 'id': 1});
    }

    final userStats = _guestStats();
    await updateUserStats(userStats);
    return userStats;
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('app_user_stats').upsert(
      {
        'user_id': userId,
        'total_exp': stats.totalExp,
        'current_streak': stats.currentStreak,
        'last_study_date': stats.lastStudyDate.toUtc().toIso8601String(),
        'total_words_mastered': stats.totalWordsMastered,
        'total_favorites': stats.totalFavorites,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> addExp(int exp) async {
    if (_userId == null) return;
    final userStats = await getUserStats();
    await updateUserStats(
      userStats.copyWith(totalExp: userStats.totalExp + exp.clamp(0, 1000000)),
    );
  }

  @override
  Future<void> updateStreak() async {
    if (_userId == null) return;
    final userStats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      userStats.lastStudyDate.year,
      userStats.lastStudyDate.month,
      userStats.lastStudyDate.day,
    );
    final diff = today.difference(last).inDays;

    if (diff == 0) {
      if (userStats.currentStreak == 0) {
        await updateUserStats(
          userStats.copyWith(currentStreak: 1, lastStudyDate: now),
        );
      }
      return;
    }

    await updateUserStats(
      userStats.copyWith(
        currentStreak: diff == 1 ? userStats.currentStreak + 1 : 1,
        lastStudyDate: now,
      ),
    );
  }

  @override
  Future<void> resetStreakIfNeeded() async {
    if (_userId == null) return;
    final userStats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      userStats.lastStudyDate.year,
      userStats.lastStudyDate.month,
      userStats.lastStudyDate.day,
    );

    if (today.difference(last).inDays > 1 && userStats.currentStreak > 0) {
      await updateUserStats(userStats.copyWith(currentStreak: 0));
    }
  }

  @override
  Future<void> updateWordsMastered(int count) async {
    if (_userId == null) return;
    final userStats = await getUserStats();
    await updateUserStats(userStats.copyWith(totalWordsMastered: count));
  }

  @override
  Future<void> updateFavorites(int count) async {
    if (_userId == null) return;
    final userStats = await getUserStats();
    await updateUserStats(userStats.copyWith(totalFavorites: count));
  }
}
