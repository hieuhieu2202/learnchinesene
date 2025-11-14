import 'package:sqflite/sqflite.dart';

import '../../../../core/db/database_helper.dart';
import '../models/progress_model.dart';

abstract class ProgressLocalDataSource {
  Future<ProgressModel?> getProgressForWord(int wordId);
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId);
  Future<void> upsertProgress(ProgressModel progress);
  Future<List<int>> getWordsToReviewToday(DateTime today);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  Future<Database> get _db async => DatabaseHelper.database;

  @override
  Future<ProgressModel?> getProgressForWord(int wordId) async {
    final db = await _db;
    final result = await db.query(
      'progress',
      where: 'word_id = ?',
      whereArgs: [wordId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ProgressModel.fromMap(Map<String, Object?>.from(result.first));
  }

  @override
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId) async {
    final db = await _db;
    final result = await db.rawQuery('''
        SELECT p.* FROM progress p
        INNER JOIN words w ON p.word_id = w.id
        WHERE w.section_id = ?
      ''', [sectionId]);
    return {
      for (final row in result)
        row['word_id'] as int:
            ProgressModel.fromMap(Map<String, Object?>.from(row)),
    };
  }

  @override
  Future<void> upsertProgress(ProgressModel progress) async {
    final db = await _db;
    await db.insert(
      'progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<int>> getWordsToReviewToday(DateTime today) async {
    final db = await _db;
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final result = await db.rawQuery('''
        SELECT word_id FROM progress
        WHERE mastered = 0
          AND (last_practice IS NULL OR last_practice < ?)
        ORDER BY CASE WHEN last_practice IS NULL THEN 0 ELSE 1 END,
                 last_practice ASC
      ''', [todayStr]);
    return result.map((row) => row['word_id'] as int).toList();
  }
}
