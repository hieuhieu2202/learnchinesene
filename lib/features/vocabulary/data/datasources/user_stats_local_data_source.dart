import 'package:sqflite/sqflite.dart';

import '../models/user_stats_model.dart';
import '../../../../core/db/database_helper.dart';

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
  @override
  Future<UserStats> getUserStats() async {
    final db = await DatabaseHelper.database;
    final result = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);

    if (result.isEmpty) {
      // ⭐ Initialize lastStudyDate = hôm qua để có thể cập nhật streak lần đầu
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final defaultStats = UserStats(
        id: 1,
        totalExp: 0,
        currentStreak: 0,
        lastStudyDate: yesterday,
        totalWordsMastered: 0,
        totalFavorites: 0,
      );
      await db.insert('user_stats', defaultStats.toMap());
      return defaultStats;
    }

    return UserStats.fromMap(result.first);
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    print('✅ [DATABASE] updateUserStats saved successfully');
  }

  @override
  Future<void> addExp(int exp) async {
    try {
      final stats = await getUserStats();
      final oldExp = stats.totalExp;
      final newStats = stats.copyWith(totalExp: stats.totalExp + exp);
      await updateUserStats(newStats);

      print('💾 [DATABASE] Cập nhật EXP:');
      print('   📊 EXP cũ: $oldExp');
      print('   ➕ Thêm: $exp');
      print('   ✅ EXP mới: ${newStats.totalExp}');
    } catch (e) {
      print('❌ [DATABASE] Lỗi addExp: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStreak() async {
    try {
      final db = await DatabaseHelper.database;  // ⭐ Get database reference
      final stats = await getUserStats();
      final today = DateTime.now();
      final lastStudy = stats.lastStudyDate;

      // So sánh chỉ ngày, không giờ
      final lastStudyDate = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      final difference = todayDate.difference(lastStudyDate).inDays;

      print('🔥 [STREAK] Kiểm tra:');
      print('   📅 Hôm nay: $todayDate');
      print('   📅 Lần cuối: $lastStudyDate');
      print('   📊 Cách: $difference ngày');
      print('   🔥 Streak hiện tại: ${stats.currentStreak}');

      if (difference == 0) {
        // ⭐ Nếu streak == 0 (lần đầu học), cho phép update streak = 1
        if (stats.currentStreak == 0) {
          print('   ⚠️ Lần đầu học hôm nay (streak = 0) → Bắt đầu streak');
          final newStats = stats.copyWith(
            currentStreak: 1,
            lastStudyDate: today,
          );
          await updateUserStats(newStats);
          print('   ⬆️ Streak bắt đầu: 0 → 1');
          print('   ✅ Streak đã lưu vào database');
          _printDatabaseContent(db);
          return;
        }
        // Nếu streak > 0, đã học hôm nay rồi
        print('   ✅ Đã học hôm nay → Không cập nhật');
        return;
      }

      if (difference == 1) {
        // Tiếp tục streak (học hôm nay sau hôm qua)
        final newStats = stats.copyWith(
          currentStreak: stats.currentStreak + 1,
          lastStudyDate: today,
        );
        await updateUserStats(newStats);
        print('   ⬆️ Streak tăng: ${stats.currentStreak} → ${newStats.currentStreak}');
        print('   ✅ Streak đã lưu vào database');
        // ⭐ In dữ liệu từ database để verify
        _printDatabaseContent(db);
      } else if (difference > 1) {
        // Nếu quá lâu không học: reset streak = 1
        // Nhưng nếu đây là lần đầu (currentStreak = 0): set = 1
        final newStats = stats.copyWith(
          currentStreak: 1,
          lastStudyDate: today,
        );
        await updateUserStats(newStats);
        print('   🔄 Reset/Bắt đầu streak (cách $difference ngày) → 1');
        print('   ✅ Streak đã lưu vào database');
        // ⭐ In dữ liệu từ database để verify
        _printDatabaseContent(db);
      }
    } catch (e) {
      print('❌ [STREAK] Lỗi: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetStreakIfNeeded() async {
    final stats = await getUserStats();
    final today = DateTime.now();
    final lastStudy = stats.lastStudyDate;

    final lastStudyDate = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final difference = todayDate.difference(lastStudyDate).inDays;

    if (difference > 1 && stats.currentStreak > 0) {
      final newStats = stats.copyWith(currentStreak: 0);
      await updateUserStats(newStats);
      print('⚠️ [STREAK] Không học $difference ngày → reset streak về 0');
    }
  }

  @override
  Future<void> updateWordsMastered(int count) async {
    final stats = await getUserStats();
    final newStats = stats.copyWith(totalWordsMastered: count);
    await updateUserStats(newStats);
  }

  @override
  Future<void> updateFavorites(int count) async {
    final stats = await getUserStats();
    final newStats = stats.copyWith(totalFavorites: count);
    await updateUserStats(newStats);
  }

  /// ⭐ Helper method để in dữ liệu từ database
  void _printDatabaseContent(Database db) async {
    try {
      print('\n📊 [DATABASE] Dữ liệu sau update:');
      final result = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
      if (result.isNotEmpty) {
        final row = result.first;
        print('   ID: ${row['id']}');
        print('   currentStreak: ${row['currentStreak']}');
        print('   totalExp: ${row['totalExp']}');
        print('   lastStudyDate: ${row['lastStudyDate']}');
        print('   totalWordsMastered: ${row['totalWordsMastered']}');
        print('✅ Database verified!\n');
      } else {
        print('   ❌ Không tìm thấy user_stats\n');
      }
    } catch (e) {
      print('   ❌ Lỗi khi đọc database: $e\n');
    }
  }
}
