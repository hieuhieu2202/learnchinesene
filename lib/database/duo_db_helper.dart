import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/duo_flashcard.dart';
import '../models/duo_challenge.dart';

class DuoDbHelper {
  DuoDbHelper._();
  static final DuoDbHelper instance = DuoDbHelper._();
  
  static const String _dbFileName = 'app_chinese_ordered.db';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbFileName);

    if (!await File(dbPath).exists()) {
      await _copyBundledDb(dbPath);
    }

    final db = await openDatabase(dbPath);
    await _initGameDatabase(db);
    return db;
  }

  Future<void> _copyBundledDb(String dbPath) async {
    final data = await rootBundle.load('assets/database/$_dbFileName');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  // --- MIGRATION: KHỞI TẠO BẢNG CHƠI GAME CENTER DỰA TRÊN SESSIONS ---
  Future<void> _initGameDatabase(Database db) async {
    // Xóa các bảng cũ để tạo lại theo kiến trúc Tree Map mới (Section > Unit > Level)
    try {
      await db.execute('DROP TABLE IF EXISTS game_levels');
      await db.execute('DROP TABLE IF EXISTS game_progress');
      await db.execute('DROP TABLE IF EXISTS game_sessions');
    } catch (_) {}

    // 1. Định nghĩa game
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_definitions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_code TEXT NOT NULL UNIQUE,
          name_vi TEXT NOT NULL,
          description_vi TEXT,
          icon TEXT,
          game_order INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 2. Lưu tiến trình chơi
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          level_id TEXT NOT NULL,
          attempts INTEGER DEFAULT 0,
          total_questions INTEGER DEFAULT 0,
          correct_count INTEGER DEFAULT 0,
          wrong_count INTEGER DEFAULT 0,
          best_score INTEGER DEFAULT 0,
          stars INTEGER DEFAULT 0,
          is_unlocked INTEGER DEFAULT 0,
          is_completed INTEGER DEFAULT 0,
          last_played_at TEXT,
          completed_at TEXT,
          UNIQUE(game_id, level_id),
          FOREIGN KEY(game_id) REFERENCES game_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(level_id) REFERENCES levels(id) ON DELETE CASCADE
      );
    ''');

    // 3. Lưu Session làm dở
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          level_id TEXT NOT NULL,
          current_index INTEGER DEFAULT 0,
          score INTEGER DEFAULT 0,
          correct_count INTEGER DEFAULT 0,
          wrong_count INTEGER DEFAULT 0,
          started_at TEXT,
          completed_at TEXT,
          status TEXT DEFAULT 'active'
      );
    ''');

    // Chèn 10 game định nghĩa
    final gamesData = [
      ['learn_words', 'Học từ mới', 'Học và ghi nhớ từ vựng', 'brain', 1],
      ['word_connect', 'Nối chữ', 'Ghép từ tiếng Trung với nghĩa', 'link', 2],
      ['select_answer', 'Chọn đáp án', 'Chọn đáp án chính xác', 'target', 3],
      ['listen_select', 'Nghe và chọn', 'Nghe tiếng Trung và chọn đáp án', 'headphones', 4],
      ['translate', 'Dịch câu', 'Dịch câu tiếng Trung', 'translate', 5],
      ['gap_fill', 'Điền từ', 'Điền từ phù hợp vào câu', 'edit', 6],
      ['tap_complete', 'Hoàn thành câu', 'Hoàn thành câu bằng cách chọn từ', 'puzzle', 7],
      ['dialogue', 'Hội thoại', 'Luyện phản xạ hội thoại', 'chat', 8],
      ['sentence_order', 'Sắp xếp câu', 'Sắp xếp từ thành câu đúng', 'shuffle', 9],
      ['speaking', 'Luyện phát âm', 'Nghe và nói lại tiếng Trung', 'mic', 10],
    ];

    for (var g in gamesData) {
      await db.execute('''
        INSERT OR IGNORE INTO game_definitions (game_code, name_vi, description_vi, icon, game_order)
        VALUES (?, ?, ?, ?, ?)
      ''', g);
    }

    // Lấy các game_id
    final List<Map<String, dynamic>> games = await db.query('game_definitions');

    // Mở khóa Level đầu tiên cho mỗi game
    // Truy vấn level đầu tiên của toàn bộ cây
    final List<Map<String, dynamic>> firstLevel = await db.rawQuery('''
      SELECT l.id FROM levels l
      JOIN units u ON u.id = l.unit_id
      JOIN sections s ON s.id = u.section_id
      ORDER BY s.section_number ASC, u.unit_number ASC, l.level_index ASC
      LIMIT 1
    ''');

    if (firstLevel.isNotEmpty) {
      final String firstLevelId = firstLevel.first['id'];
      for (var game in games) {
        final gameId = game['id'] as int;
        await db.execute('''
          INSERT OR IGNORE INTO game_progress (game_id, level_id, is_unlocked)
          VALUES (?, ?, 1)
        ''', [gameId, firstLevelId]);
      }
    }
  }

  // --- TRUY VẤN GAME CENTER ---
  Future<List<Map<String, dynamic>>> getGamesForCenter() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
          g.id,
          g.game_code,
          g.name_vi,
          g.description_vi,
          g.icon,
          g.game_order,
          (SELECT COUNT(*) FROM levels) AS total_levels,
          COUNT(CASE WHEN gp.is_completed = 1 THEN 1 END) AS completed_levels,
          MAX(gp.stars) AS best_stars
      FROM game_definitions g
      LEFT JOIN game_progress gp ON gp.game_id = g.id
      GROUP BY g.id, g.game_code, g.name_vi, g.description_vi, g.icon, g.game_order
      ORDER BY g.game_order;
    ''');
  }

  // --- TRUY VẤN LỘ TRÌNH (PATH) CỦA MỘT GAME ---
  Future<List<Map<String, dynamic>>> getGamePath(int gameId, String gameCode) async {
    final db = await database;

    // Lọc theo loại game để biết level nào có challenges
    String filter = '';
    if (gameCode == 'select_answer' || gameCode == 'learn_words' || gameCode == 'word_connect') {
      filter = "type IN ('select', 'assist', 'match')";
    } else if (gameCode == 'listen_select') {
      filter = "type = 'listenTap'";
    } else if (gameCode == 'translate') {
      filter = "type = 'translate'";
    } else if (gameCode == 'gap_fill') {
      filter = "type = 'gapFill'";
    } else if (gameCode == 'tap_complete') {
      filter = "type = 'tapComplete'";
    } else if (gameCode == 'dialogue') {
      filter = "type = 'dialogue'";
    } else if (gameCode == 'sentence_order') {
      filter = "type = 'orderTapComplete'";
    } else if (gameCode == 'speaking') {
      filter = "prompt IS NOT NULL AND TRIM(prompt) != ''";
    }

    return await db.rawQuery('''
      SELECT
          l.id AS level_id,
          sec.section_number,
          sec.title AS section_title,
          u.unit_number,
          u.title AS unit_title,
          l.level_index,
          COALESCE(gp.attempts, 0) AS attempts,
          COALESCE(gp.best_score, 0) AS best_score,
          COALESCE(gp.stars, 0) AS stars,
          COALESCE(gp.is_unlocked, 0) AS is_unlocked,
          COALESCE(gp.is_completed, 0) AS is_completed,
          (
            SELECT COUNT(*) FROM challenges c
            JOIN sessions s_in ON s_in.id = c.session_id
            WHERE s_in.level_id = l.id AND $filter
          ) AS challenge_count
      FROM levels l
      JOIN units u ON u.id = l.unit_id
      JOIN sections sec ON sec.id = u.section_id
      LEFT JOIN game_progress gp ON gp.game_id = ? AND gp.level_id = l.id
      ORDER BY sec.section_number ASC, u.unit_number ASC, l.level_index ASC;
    ''', [gameId]);
  }

  // --- CẬP NHẬT TIẾN TRÌNH LEVEL ---
  Future<void> saveLevelProgress(int gameId, String levelId, int score, int stars, bool passed) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // 1. Kiểm tra nếu chưa có thì Insert, nếu có thì Update
    final List<Map<String, dynamic>> existing = await db.query(
      'game_progress',
      where: 'game_id = ? AND level_id = ?',
      whereArgs: [gameId, levelId],
    );

    if (existing.isEmpty) {
      await db.insert('game_progress', {
        'game_id': gameId,
        'level_id': levelId,
        'attempts': 1,
        'best_score': score,
        'stars': stars,
        'is_completed': passed ? 1 : 0,
        'is_unlocked': 1,
        'completed_at': passed ? now : null,
        'last_played_at': now,
      });
    } else {
      await db.rawUpdate('''
        UPDATE game_progress
        SET 
            attempts = attempts + 1,
            best_score = MAX(best_score, ?),
            stars = MAX(stars, ?),
            is_completed = CASE WHEN ? = 1 THEN 1 ELSE is_completed END,
            completed_at = CASE WHEN ? = 1 AND is_completed = 0 THEN ? ELSE completed_at END,
            last_played_at = ?
        WHERE game_id = ? AND level_id = ?
      ''', [score, stars, passed ? 1 : 0, passed ? 1 : 0, now, now, gameId, levelId]);
    }

    // 2. Mở khóa Level tiếp theo (có challenge_count > 0)
    if (passed) {
      // Để lấy next_level_id, ta dựa vào getGamePath (hoặc query từ Dart cho tiện,
      // việc unlock sẽ được thực hiện ở Controller). Controller sẽ gọi phương thức unlock riêng.
    }
  }

  // Mở khóa một level cụ thể
  Future<void> unlockLevel(int gameId, String levelId) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'game_progress',
      where: 'game_id = ? AND level_id = ?',
      whereArgs: [gameId, levelId],
    );
    if (existing.isEmpty) {
      await db.insert('game_progress', {
        'game_id': gameId,
        'level_id': levelId,
        'is_unlocked': 1,
      });
    } else {
      await db.update(
        'game_progress',
        {'is_unlocked': 1},
        where: 'game_id = ? AND level_id = ?',
        whereArgs: [gameId, levelId],
      );
    }
  }

  // --- LẤY DỮ LIỆU CỦA GAME THEO LEVEL_ID ---
  Future<List<DuoChallenge>> getChallengesForGameLevel(String levelId, String gameCode, {int limit = 10}) async {
    final db = await database;
    // Tìm tất cả challenges thuộc các session của level_id này
    String query = 'SELECT c.* FROM challenges c JOIN sessions s ON s.id = c.session_id WHERE s.level_id = ?';
    
    String filter = '';
    if (gameCode == 'select_answer') {
      filter = " AND type IN ('select', 'assist')";
    } else if (gameCode == 'listen_select') {
      filter = " AND type = 'listenTap'";
    } else if (gameCode == 'translate') {
      filter = " AND type = 'translate'";
    } else if (gameCode == 'gap_fill') {
      filter = " AND type = 'gapFill'";
    } else if (gameCode == 'tap_complete') {
      filter = " AND type = 'tapComplete'";
    } else if (gameCode == 'dialogue') {
      filter = " AND type = 'dialogue'";
    } else if (gameCode == 'sentence_order') {
      filter = " AND type = 'orderTapComplete'";
    } else if (gameCode == 'word_connect' || gameCode == 'learn_words') {
      filter = " AND type IN ('select', 'assist', 'match')";
    }

    final List<Map<String, dynamic>> rawMaps = await db.rawQuery(
      '$query$filter ORDER BY RANDOM() LIMIT ?',
      [levelId, limit],
    );

    return rawMaps.map((m) => DuoChallenge.fromMap(m)).toList();
  }

  // Lấy chi tiết flashcard cho game học từ
  Future<List<DuoFlashcard>> getFlashcardsForWords(List<String> words) async {
    final db = await database;
    if (words.isEmpty) return [];
    
    final placeholders = List.filled(words.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT id, word, pinyin, meaning, tts_url FROM flashcards WHERE word IN ($placeholders)',
      words,
    );
    return maps.map((map) => DuoFlashcard.fromMap(map)).toList();
  }

  // --- TRẠNG THÁI SESSION HỌC DỞ ---
  Future<Map<String, dynamic>?> getActiveSession(int gameId, String levelId) async {
    final db = await database;
    final rows = await db.query(
      'game_sessions',
      where: 'game_id = ? AND level_id = ? AND status = "active"',
      whereArgs: [gameId, levelId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> saveActiveSession(int gameId, String levelId, int currentIndex, int score, int correct, int wrong) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final existing = await getActiveSession(gameId, levelId);
    if (existing == null) {
      await db.insert('game_sessions', {
        'game_id': gameId,
        'level_id': levelId,
        'current_index': currentIndex,
        'score': score,
        'correct_count': correct,
        'wrong_count': wrong,
        'started_at': now,
        'status': 'active',
      });
    } else {
      await db.update(
        'game_sessions',
        {
          'current_index': currentIndex,
          'score': score,
          'correct_count': correct,
          'wrong_count': wrong,
        },
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
    }
  }

  Future<void> clearActiveSession(int gameId, String levelId) async {
    final db = await database;
    await db.delete(
      'game_sessions',
      where: 'game_id = ? AND level_id = ?',
      whereArgs: [gameId, levelId],
    );
  }

  // --- FLASHCARDS ---
  Future<List<DuoFlashcard>> getRandomFlashcards({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return maps.map((map) => DuoFlashcard.fromMap(map)).toList();
  }
}
