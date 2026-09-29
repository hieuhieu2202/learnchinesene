import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_stats_model.dart';

/// Compatibility name kept for the existing repository layer.
///
/// User statistics are persisted only in Supabase.
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

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Supabase authentication is required.');
    }
    return id;
  }

  @override
  Future<UserStats> getUserStats() async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('app_user_stats')
          .select(
            'total_exp, current_streak, last_study_date, total_words_mastered, total_favorites',
          )
          .eq('user_id', _userId)
          .limit(1),
    );

    if (rows.isNotEmpty) {
      return UserStats.fromMap({...rows.first, 'id': 1});
    }

    final stats = UserStats(
      id: 1,
      totalExp: 0,
      currentStreak: 0,
      lastStudyDate: DateTime.now().subtract(const Duration(days: 1)),
      totalWordsMastered: 0,
      totalFavorites: 0,
    );
    await updateUserStats(stats);
    return stats;
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    await _client.from('app_user_stats').upsert(
      {
        'user_id': _userId,
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
    final stats = await getUserStats();
    await updateUserStats(
      stats.copyWith(totalExp: stats.totalExp + exp.clamp(0, 1000000)),
    );
  }

  @override
  Future<void> updateStreak() async {
    final stats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      stats.lastStudyDate.year,
      stats.lastStudyDate.month,
      stats.lastStudyDate.day,
    );
    final diff = today.difference(last).inDays;

    if (diff == 0) {
      if (stats.currentStreak == 0) {
        await updateUserStats(
          stats.copyWith(currentStreak: 1, lastStudyDate: now),
        );
      }
      return;
    }

    await updateUserStats(
      stats.copyWith(
        currentStreak: diff == 1 ? stats.currentStreak + 1 : 1,
        lastStudyDate: now,
      ),
    );
  }

  @override
  Future<void> resetStreakIfNeeded() async {
    final stats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      stats.lastStudyDate.year,
      stats.lastStudyDate.month,
      stats.lastStudyDate.day,
    );

    if (today.difference(last).inDays > 1 && stats.currentStreak > 0) {
      await updateUserStats(stats.copyWith(currentStreak: 0));
    }
  }

  @override
  Future<void> updateWordsMastered(int count) async {
    final stats = await getUserStats();
    await updateUserStats(stats.copyWith(totalWordsMastered: count));
  }

  @override
  Future<void> updateFavorites(int count) async {
    final stats = await getUserStats();
    await updateUserStats(stats.copyWith(totalFavorites: count));
  }
}
