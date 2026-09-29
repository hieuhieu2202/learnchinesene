import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_stats_model.dart';

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
  static const _key = 'user_stats_v2';

  @override
  Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      return UserStats.fromMap(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats.toMap()));
  }

  @override
  Future<void> addExp(int exp) async {
    final stats = await getUserStats();
    await updateUserStats(stats.copyWith(totalExp: stats.totalExp + exp));
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
