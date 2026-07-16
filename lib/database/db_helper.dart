import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/example_sentence.dart';
import '../models/hsk_level.dart';
import '../models/topic.dart';
import '../models/unit_model.dart';
import '../models/word.dart';
import '../models/speaking_practice_item.dart';
import '../models/hanzi_character.dart';
import 'queries.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static const String _dbFileName = 'chinese_v2_sheet1_only.db';
  static const int _dbVersion = 3;

  Database? _database;
  final Map<String, Set<String>> _columnsCache = <String, Set<String>>{};

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

    return openDatabase(
      dbPath,
      version: _dbVersion,
      onOpen: (db) async {
        await _runSafeMigrations(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _runSafeMigrations(db);
      },
    );
  }

  Future<void> _copyBundledDb(String dbPath) async {
    final data = await rootBundle.load(
      'assets/database/chinese_v2_sheet1_only.db',
    );

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  Future<void> _runSafeMigrations(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.userProgress} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER UNIQUE,
        correct_count INTEGER NOT NULL DEFAULT 0,
        wrong_count INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        mastered INTEGER NOT NULL DEFAULT 0,
        last_reviewed_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.speakingPractice} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        example_id INTEGER,
        target_text TEXT,
        recognized_text TEXT,
        score REAL,
        is_correct INTEGER NOT NULL DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.hanziWritingProgress} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character_id INTEGER UNIQUE,
        best_score REAL,
        last_score REAL,
        total_attempts INTEGER DEFAULT 0,
        completed_count INTEGER DEFAULT 0,
        last_completed_at TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await _ensureColumn(db, DbTables.userProgress, 'last_reviewed_at', 'TEXT');
    await _ensureColumn(db, DbTables.userProgress, 'updated_at', 'TEXT');
    await _ensureColumn(
      db,
      DbTables.userProgress,
      'mastered',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureColumn(
      db,
      DbTables.userProgress,
      'correct_count',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureColumn(
      db,
      DbTables.userProgress,
      'wrong_count',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureColumn(
      db,
      DbTables.userProgress,
      'level',
      'INTEGER NOT NULL DEFAULT 1',
    );

    await _ensureColumn(db, DbTables.speakingPractice, 'example_id', 'INTEGER');
    await _ensureColumn(db, DbTables.speakingPractice, 'target_text', 'TEXT');
    await _ensureColumn(
      db,
      DbTables.speakingPractice,
      'recognized_text',
      'TEXT',
    );
    await _ensureColumn(db, DbTables.speakingPractice, 'score', 'REAL');
    await _ensureColumn(
      db,
      DbTables.speakingPractice,
      'is_correct',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureColumn(db, DbTables.speakingPractice, 'created_at', 'TEXT');
  }

  Future<void> _ensureColumn(
    Database db,
    String table,
    String column,
    String typeSql,
  ) async {
    final exists = await _columnExists(db, table, column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $typeSql');
      _columnsCache.remove(table);
    }
  }

  Future<bool> tableExists(String tableName) async {
    final db = await database;
    final res = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ? LIMIT 1",
      <Object?>[tableName],
    );
    return res.isNotEmpty;
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String column,
  ) async {
    if (!await _tableExistsWithDb(db, tableName)) {
      return false;
    }

    final cols = await db.rawQuery('PRAGMA table_info($tableName)');
    return cols.any((e) => '${e['name']}' == column);
  }

  Future<bool> _tableExistsWithDb(Database db, String tableName) async {
    final res = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ? LIMIT 1",
      <Object?>[tableName],
    );
    return res.isNotEmpty;
  }

  Future<Set<String>> getTableColumns(String tableName) async {
    if (_columnsCache.containsKey(tableName)) {
      return _columnsCache[tableName]!;
    }

    final db = await database;
    if (!await _tableExistsWithDb(db, tableName)) {
      _columnsCache[tableName] = <String>{};
      return _columnsCache[tableName]!;
    }

    final cols = await db.rawQuery('PRAGMA table_info($tableName)');
    final names = cols.map((e) => '${e['name']}').toSet();
    _columnsCache[tableName] = names;
    return names;
  }

  Future<List<HskLevel>> getHskLevels() async {
    final db = await database;
    if (await tableExists(DbTables.hskLevels)) {
      final cols = await getTableColumns(DbTables.hskLevels);
      final id = cols.contains('id') ? 'id' : cols.first;
      final titleCol =
          _first(cols, <String>['title', 'name', 'level_name']) ?? id;
      final orderCol =
          _first(cols, <String>['level_order', 'order_index', 'id']) ?? id;
      final rows = await db.rawQuery(
        'SELECT $id AS id, $titleCol AS title, $orderCol AS level_order FROM ${DbTables.hskLevels} ORDER BY $orderCol',
      );
      return rows.map(HskLevel.fromMap).toList();
    }

    // Fallback for databases where levels are encoded in words.section_id.
    final wordCols = await getTableColumns(DbTables.words);
    if (wordCols.contains('section_id')) {
      final title = wordCols.contains('section_title')
          ? 'section_title'
          : 'section_id';
      final rows = await db.rawQuery(
        'SELECT section_id AS id, MIN($title) AS title, section_id AS level_order FROM ${DbTables.words} GROUP BY section_id ORDER BY section_id',
      );
      return rows.map(HskLevel.fromMap).toList();
    }

    return <HskLevel>[];
  }

  Future<List<UnitModel>> getUnitsByLevel(int hskLevelId) async {
    final db = await database;
    if (await tableExists(DbTables.units)) {
      final cols = await getTableColumns(DbTables.units);
      final id = cols.contains('id') ? 'id' : cols.first;
      final title = _first(cols, <String>['title', 'name', 'unit_title']) ?? id;
      final order =
          _first(cols, <String>['unit_order', 'order_index', 'id']) ?? id;
      final rows = await db.rawQuery(
        'SELECT $id AS id, $title AS title, $order AS unit_order FROM ${DbTables.units} WHERE hsk_level_id = ? ORDER BY $order',
        <Object?>[hskLevelId],
      );
      return rows.map(UnitModel.fromMap).toList();
    }

    if (await tableExists(DbTables.wordUnits)) {
      final rows = await db.rawQuery(
        'SELECT DISTINCT unit_id AS id, "Unit " || unit_id AS title, unit_id AS unit_order FROM ${DbTables.wordUnits} ORDER BY unit_id',
      );
      return rows.map(UnitModel.fromMap).toList();
    }

    final wordsCols = await getTableColumns(DbTables.words);
    if (wordsCols.contains('section_id')) {
      final titleExpr = wordsCols.contains('section_title')
          ? 'MIN(section_title)'
          : '"Unit " || section_id';
      final rows = await db.rawQuery(
        'SELECT section_id AS id, $titleExpr AS title, section_id AS unit_order FROM ${DbTables.words} GROUP BY section_id ORDER BY section_id',
      );
      return rows.map(UnitModel.fromMap).toList();
    }

    return <UnitModel>[];
  }

  Future<List<Topic>> getTopicsByUnit(int unitId) async {
    final db = await database;
    if (!await tableExists(DbTables.topics)) return <Topic>[];

    final cols = await getTableColumns(DbTables.topics);
    final id = cols.contains('id') ? 'id' : cols.first;
    final title = _first(cols, <String>['title', 'name', 'topic_title']) ?? id;
    final order =
        _first(cols, <String>['topic_order', 'order_index', 'id']) ?? id;

    final rows = await db.rawQuery(
      'SELECT $id AS id, $title AS title, $order AS topic_order FROM ${DbTables.topics} WHERE unit_id = ? ORDER BY $order',
      <Object?>[unitId],
    );
    return rows.map(Topic.fromMap).toList();
  }

  Future<List<Word>> getWordsByUnit(int unitId) async {
    final db = await database;
    final select = await _wordSelect('w');

    if (await tableExists(DbTables.wordUnits)) {
      final rows = await db.rawQuery(
        'SELECT $select FROM ${DbTables.words} w JOIN ${DbTables.wordUnits} wu ON wu.word_id = w.id WHERE wu.unit_id = ? ORDER BY w.id',
        <Object?>[unitId],
      );
      return rows.map(Word.fromMap).toList();
    }

    final wordsCols = await getTableColumns(DbTables.words);
    if (wordsCols.contains('section_id')) {
      final rows = await db.rawQuery(
        'SELECT $select FROM ${DbTables.words} w WHERE w.section_id = ? ORDER BY w.id',
        <Object?>[unitId],
      );
      return rows.map(Word.fromMap).toList();
    }

    return <Word>[];
  }

  Future<List<Word>> getWordsByIds(List<int> ids) async {
    if (ids.isEmpty) return <Word>[];
    final db = await database;
    final select = await _wordSelect('w');
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT $select FROM ${DbTables.words} w WHERE w.id IN ($placeholders)',
      ids.cast<Object?>(),
    );
    return rows.map(Word.fromMap).toList();
  }

  Future<List<ExampleSentence>> getExamplesByWord(int wordId) async {
    final db = await database;
    if (!await tableExists(DbTables.examples)) return <ExampleSentence>[];

    final cols = await getTableColumns(DbTables.examples);
    final id = cols.contains('id') ? 'id' : cols.first;
    final chinese =
        _pickCol(cols, <String>['sentence_cn', 'chinese_text', 'sentence']) ??
        id;
    final pinyin = _pickCol(cols, <String>['sentence_pinyin', 'pinyin']);
    final vi = _pickCol(cols, <String>[
      'sentence_vi',
      'meaning_vi',
      'translation',
    ]);
    final order = _pickCol(cols, <String>['order_index', 'id']) ?? id;

    final rows = await db.rawQuery(
      'SELECT $id AS id, word_id, ${pinyin != null ? '$pinyin AS pinyin,' : 'NULL AS pinyin,'} $chinese AS chinese, ${vi != null ? '$vi AS vietnamese,' : 'NULL AS vietnamese,'} $order AS order_index FROM ${DbTables.examples} WHERE word_id = ? ORDER BY $order',
      <Object?>[wordId],
    );

    return rows.map(ExampleSentence.fromMap).toList();
  }

  Future<List<Word>> getReviewWords() async {
    final db = await database;
    final select = await _wordSelect('w');

    final rows = await db.rawQuery('''
      SELECT $select, up.correct_count, up.wrong_count
      FROM ${DbTables.words} w
      JOIN ${DbTables.userProgress} up ON up.word_id = w.id
      WHERE up.wrong_count > 0 AND IFNULL(up.mastered, 0) = 0
      ORDER BY up.wrong_count DESC
    ''');

    return rows.map(Word.fromMap).toList();
  }

  Future<void> upsertProgress({
    required int wordId,
    required bool isCorrect,
    int level = 1,
  }) async {
    final db = await database;
    final existing = await db.query(
      DbTables.userProgress,
      where: 'word_id = ?',
      whereArgs: <Object?>[wordId],
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();

    if (existing.isEmpty) {
      await db.insert(DbTables.userProgress, <String, Object?>{
        'word_id': wordId,
        'correct_count': isCorrect ? 1 : 0,
        'wrong_count': isCorrect ? 0 : 1,
        'level': level,
        'mastered': isCorrect ? 1 : 0,
        'last_reviewed_at': now,
        'updated_at': now,
      });
      return;
    }

    final row = existing.first;
    final correctCount =
        (row['correct_count'] as int? ?? 0) + (isCorrect ? 1 : 0);
    final wrongCount = (row['wrong_count'] as int? ?? 0) + (isCorrect ? 0 : 1);
    final mastered = correctCount >= 3 ? 1 : 0;

    await db.update(
      DbTables.userProgress,
      <String, Object?>{
        'correct_count': correctCount,
        'wrong_count': wrongCount,
        'mastered': mastered,
        'level': level,
        'last_reviewed_at': now,
        'updated_at': now,
      },
      where: 'word_id = ?',
      whereArgs: <Object?>[wordId],
    );
  }

  Future<void> markLearned(int wordId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.rawInsert(
      '''
      INSERT INTO ${DbTables.userProgress}
        (word_id, correct_count, wrong_count, level, mastered, last_reviewed_at, updated_at)
      VALUES (?, 1, 0, 1, 1, ?, ?)
      ON CONFLICT(word_id) DO UPDATE SET mastered = 1,
        correct_count = MAX(correct_count, 1),
        last_reviewed_at = excluded.last_reviewed_at,
        updated_at = excluded.updated_at
    ''',
      <Object?>[wordId, now, now],
    );
  }

  Future<Map<String, num>> getStats() async {
    final db = await database;
    final progress = (await db.rawQuery('''
      SELECT COUNT(*) AS learned,
        SUM(CASE WHEN IFNULL(mastered, 0) = 1 THEN 1 ELSE 0 END) AS mastered,
        SUM(IFNULL(correct_count, 0)) AS correct,
        SUM(IFNULL(wrong_count, 0)) AS wrong
      FROM ${DbTables.userProgress}
    ''')).first;
    final speaking = (await db.rawQuery(
      'SELECT COUNT(*) AS attempts, AVG(score) AS average FROM ${DbTables.speakingPractice}',
    )).first;
    return <String, num>{
      'learned': (progress['learned'] as num?) ?? 0,
      'mastered': (progress['mastered'] as num?) ?? 0,
      'correct': (progress['correct'] as num?) ?? 0,
      'wrong': (progress['wrong'] as num?) ?? 0,
      'speakingAttempts': (speaking['attempts'] as num?) ?? 0,
      'speakingAverage': (speaking['average'] as num?) ?? 0,
    };
  }

  Future<Map<String, int>> getUnitMetrics(int unitId) async {
    final db = await database;
    final row = (await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT wu.word_id) AS words,
        COUNT(DISTINCT CASE WHEN up.word_id IS NOT NULL THEN wu.word_id END) AS learned,
        COUNT(DISTINCT e.id) AS examples
      FROM ${DbTables.wordUnits} wu
      LEFT JOIN ${DbTables.userProgress} up ON up.word_id = wu.word_id
      LEFT JOIN ${DbTables.examples} e ON e.word_id = wu.word_id
      WHERE wu.unit_id = ?
    ''',
      <Object?>[unitId],
    )).first;
    return row.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );
  }

  Future<int> getUnitCountForLevel(int levelId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DbTables.units} WHERE hsk_level_id = ?',
      <Object?>[levelId],
    );
    return (rows.first['count'] as num?)?.toInt() ?? 0;
  }

  Future<double> getLevelProgress(int levelId) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT wu.word_id) AS total,
        COUNT(DISTINCT CASE WHEN up.word_id IS NOT NULL THEN wu.word_id END) AS learned
      FROM ${DbTables.units} u
      JOIN ${DbTables.wordUnits} wu ON wu.unit_id = u.id
      LEFT JOIN ${DbTables.userProgress} up ON up.word_id = wu.word_id
      WHERE u.hsk_level_id = ?
    ''',
      <Object?>[levelId],
    );
    final total = (rows.first['total'] as num?)?.toInt() ?? 0;
    final learned = (rows.first['learned'] as num?)?.toInt() ?? 0;
    return total == 0 ? 0 : learned / total;
  }

  Future<SpeakingPracticeItem?> getSpeakingItemByWordId(int wordId) async {
    final db = await database;
    final select = await _wordSelect('w');
    final rows = await db.rawQuery(
      'SELECT $select FROM ${DbTables.words} w WHERE w.id = ? LIMIT 1',
      <Object?>[wordId],
    );
    if (rows.isEmpty) return null;
    return SpeakingPracticeItem.fromMap(rows.first);
  }

  Future<SpeakingPracticeItem?> getSpeakingItemByExampleId(int exampleId) async {
    final db = await database;
    final wordsCols = await getTableColumns(DbTables.words);
    final ttsUrl = _pickCol(wordsCols, ['tts_url']) ?? 'NULL';
    
    final cols = await getTableColumns(DbTables.examples);
    final chinese = _pickCol(cols, <String>['sentence_cn', 'chinese_text', 'sentence']) ?? 'NULL';
    final pinyin = _pickCol(cols, <String>['sentence_pinyin', 'pinyin']) ?? 'NULL';
    final vi = _pickCol(cols, <String>['sentence_vi', 'meaning_vi', 'translation']) ?? 'NULL';
    
    final rows = await db.rawQuery(
      '''
      SELECT 
        e.id AS example_id,
        e.word_id,
        e.$chinese AS sentence_cn,
        e.$pinyin AS sentence_pinyin,
        e.$vi AS sentence_vi,
        w.$ttsUrl AS tts_url
      FROM ${DbTables.examples} e
      LEFT JOIN ${DbTables.words} w ON w.id = e.word_id
      WHERE e.id = ? LIMIT 1
      ''',
      <Object?>[exampleId],
    );
    if (rows.isEmpty) return null;
    return SpeakingPracticeItem.fromMap(rows.first);
  }

  Future<List<SpeakingPracticeItem>> getSpeakingItemsByUnitId(int unitId) async {
    final words = await getWordsByUnit(unitId);
    return words.map((w) => SpeakingPracticeItem(
      wordId: w.id,
      targetText: w.chinese,
      pinyin: w.pinyin,
      meaning: w.vietnamese,
      audioUrl: w.ttsUrl,
    )).toList();
  }

  Future<List<SpeakingPracticeItem>> getRandomSpeakingItems({int limit = 20}) async {
    final db = await database;
    final select = await _wordSelect('w');
    final chineseCol = _pickCol(await getTableColumns(DbTables.words), ['word', 'chinese', 'hanzi']) ?? 'id';
    final rows = await db.rawQuery(
      'SELECT $select FROM ${DbTables.words} w WHERE w.$chineseCol IS NOT NULL AND TRIM(w.$chineseCol) != "" ORDER BY RANDOM() LIMIT ?',
      <Object?>[limit],
    );
    return rows.map((r) => SpeakingPracticeItem.fromMap(r)).toList();
  }

  Future<void> saveSpeakingPractice({
    required int wordId,
    int? exampleId,
    required String targetText,
    required String recognizedText,
    required double score,
    required bool isCorrect,
  }) async {
    final db = await database;
    await db.insert(DbTables.speakingPractice, <String, Object?>{
      'word_id': wordId,
      'example_id': exampleId,
      'target_text': targetText,
      'recognized_text': recognizedText,
      'score': score,
      'is_correct': isCorrect ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String> _wordSelect(String alias) async {
    final cols = await getTableColumns(DbTables.words);

    String pick(List<String> candidates, String outAlias) {
      final c = _pickCol(cols, candidates);
      if (c == null) return 'NULL AS $outAlias';
      return '$alias.$c AS $outAlias';
    }

    return <String>[
      '$alias.id AS id',
      pick(<String>['word', 'chinese', 'hanzi'], 'chinese'),
      pick(<String>['transliteration', 'pinyin'], 'pinyin'),
      pick(<String>[
        'translation',
        'meaning_vi',
        'vietnamese_meaning',
      ], 'vietnamese'),
      pick(<String>['english_translation', 'meaning_en'], 'english'),
      pick(<String>['tts_url'], 'tts_url'),
      pick(<String>['section_id', 'hsk_level_id'], 'hsk_level_id'),
      pick(<String>['section_title'], 'section_title'),
      pick(<String>['group_subtitle'], 'group_subtitle'),
    ].join(', ');
  }

  static String? _pickCol(Set<String> cols, List<String> candidates) {
    for (final c in candidates) {
      if (cols.contains(c)) return c;
    }
    return null;
  }

  static String? _first(Set<String> cols, List<String> candidates) =>
      _pickCol(cols, candidates);

  Future<List<HanziCharacter>> getCharactersForWriting({
    String? keyword,
    int? hskLevel,
  }) async {
    final db = await database;
    String whereClause = '';
    List<Object?> whereArgs = [];
    
    if (keyword != null && keyword.trim().isNotEmpty) {
      final kw = '%${keyword.trim()}%';
      whereClause += '(c.character LIKE ? OR w1.pinyin LIKE ? OR w2.pinyin LIKE ? OR w1.meaning_vi LIKE ? OR w2.meaning_vi LIKE ?)';
      whereArgs.addAll([kw, kw, kw, kw, kw]);
    }
    
    if (hskLevel != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(w1.hsk_level_id = ? OR w2.hsk_level_id = ?)';
      whereArgs.addAll([hskLevel, hskLevel]);
    }
    
    final query = '''
      SELECT c.id, c.character, c.stroke_count, c.stroke_width, c.stroke_height,
             COALESCE(w1.pinyin, w2.pinyin) as pinyin,
             COALESCE(w1.meaning_vi, w2.meaning_vi) as meaning,
             COALESCE(w1.hsk_level_id, w2.hsk_level_id) as hsk_level_id,
             '' as stroke_paths
      FROM characters c
      LEFT JOIN words w1 ON w1.word = c.character
      LEFT JOIN words w2 ON w2.id = (
          SELECT id FROM words 
          WHERE main_character_id = c.id 
          LIMIT 1
      )
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      GROUP BY c.id
      ORDER BY c.id
    ''';
    
    final rows = await db.rawQuery(query, whereArgs);
    return rows.map(HanziCharacter.fromMap).toList();
  }

  Future<HanziCharacter?> getCharacterForWritingById(int characterId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.character, c.stroke_count, c.stroke_width, c.stroke_height, c.stroke_paths,
             COALESCE(w1.pinyin, w2.pinyin) as pinyin,
             COALESCE(w1.meaning_vi, w2.meaning_vi) as meaning,
             COALESCE(w1.hsk_level_id, w2.hsk_level_id) as hsk_level_id
      FROM characters c
      LEFT JOIN words w1 ON w1.word = c.character
      LEFT JOIN words w2 ON w2.id = (
          SELECT id FROM words 
          WHERE main_character_id = c.id 
          LIMIT 1
      )
      WHERE c.id = ?
      GROUP BY c.id
      LIMIT 1
    ''', [characterId]);
    
    if (rows.isEmpty) return null;
    return HanziCharacter.fromMap(rows.first);
  }

  Future<int?> getCharacterIdByCharString(String charStr) async {
    if (charStr.isEmpty) return null;
    final db = await database;
    // Try exact match first
    var rows = await db.query(
      'characters',
      columns: ['id'],
      where: 'character = ? AND stroke_count > 0',
      whereArgs: [charStr],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int?;
    
    // Fallback to first character of multi-char words
    final firstChar = charStr.substring(0, 1);
    rows = await db.query(
      'characters',
      columns: ['id'],
      where: 'character = ? AND stroke_count > 0',
      whereArgs: [firstChar],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int?;
    
    return null;
  }

  Future<void> saveHanziWritingProgress({
    required int characterId,
    required double score,
    required int attempts,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, Object?>> existing = await db.query(
      DbTables.hanziWritingProgress,
      where: 'character_id = ?',
      whereArgs: [characterId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      await db.insert(DbTables.hanziWritingProgress, {
        'character_id': characterId,
        'best_score': score,
        'last_score': score,
        'total_attempts': attempts,
        'completed_count': 1,
        'last_completed_at': now,
        'created_at': now,
        'updated_at': now,
      });
    } else {
      final row = existing.first;
      final currentBest = (row['best_score'] as num?)?.toDouble() ?? 0.0;
      final newBest = max(currentBest, score);
      final totalAttempts = ((row['total_attempts'] as num?)?.toInt() ?? 0) + attempts;
      final completedCount = ((row['completed_count'] as num?)?.toInt() ?? 0) + 1;
      
      await db.update(
        DbTables.hanziWritingProgress,
        {
          'best_score': newBest,
          'last_score': score,
          'total_attempts': totalAttempts,
          'completed_count': completedCount,
          'last_completed_at': now,
          'updated_at': now,
        },
        where: 'character_id = ?',
        whereArgs: [characterId],
      );
    }
  }
}
