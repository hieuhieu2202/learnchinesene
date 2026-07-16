import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperVer1Ne {
  static const _dbName = 'chinese.db';
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, _dbName);

    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/db/$_dbName');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path);
    await _createUserStatsTable(db);
    return db;
  }

  static Future<void> _createUserStatsTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_stats (
          id INTEGER PRIMARY KEY,
          total_exp INTEGER DEFAULT 0,
          current_streak INTEGER DEFAULT 0,
          last_study_date TEXT NOT NULL,
          total_words_mastered INTEGER DEFAULT 0,
          total_favorites INTEGER DEFAULT 0
        )
      ''');

      // Chèn dữ liệu mặc định nếu chưa có
      final result = await db.query(
        'user_stats',
        where: 'id = ?',
        whereArgs: [1],
      );
      if (result.isEmpty) {
        await db.insert('user_stats', {
          'id': 1,
          'total_exp': 0,
          'current_streak': 0,
          'last_study_date': DateTime.now().toIso8601String(),
          'total_words_mastered': 0,
          'total_favorites': 0,
        });
      }
    } catch (e) {
      // Log error silently - user_stats table might already exist
    }
  }
}

@Deprecated('Use DatabaseHelperVer1Ne')
typedef DatabaseHelper = DatabaseHelperVer1Ne;
