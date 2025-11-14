import 'package:sqflite/sqflite.dart';

import '../../../../core/db/database_helper.dart';
import '../models/word_model.dart';

abstract class WordLocalDataSource {
  Future<List<int>> getSections();
  Future<String> getSectionTitle(int sectionId);
  Future<List<WordModel>> getWordsBySection(int sectionId);
  Future<WordModel?> getWordById(int wordId);
}

class WordLocalDataSourceImpl implements WordLocalDataSource {
  Future<Database> get _db async => DatabaseHelper.database;

  @override
  Future<List<int>> getSections() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT DISTINCT section_id FROM words ORDER BY section_id ASC',
    );
    return result.map((e) => e['section_id'] as int).toList();
  }

  @override
  Future<String> getSectionTitle(int sectionId) async {
    final db = await _db;
    final result = await db.query(
      'words',
      columns: ['section_title'],
      where: 'section_id = ?',
      whereArgs: [sectionId],
      limit: 1,
    );
    if (result.isEmpty) return '';
    return (result.first['section_title'] ?? '') as String;
  }

  @override
  Future<List<WordModel>> getWordsBySection(int sectionId) async {
    final db = await _db;
    final result = await db.query(
      'words',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'id ASC',
    );
    return result.map(WordModel.fromMap).toList();
  }

  @override
  Future<WordModel?> getWordById(int wordId) async {
    final db = await _db;
    final result = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [wordId],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return WordModel.fromMap(result.first);
  }
}
