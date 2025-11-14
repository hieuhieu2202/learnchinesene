import 'package:sqflite/sqflite.dart';

import '../../../../core/db/database_helper.dart';
import '../models/character_model.dart';

abstract class CharacterLocalDataSource {
  Future<CharacterModel?> getCharacterById(int id);
}

class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  Future<Database> get _db async => DatabaseHelper.database;

  @override
  Future<CharacterModel?> getCharacterById(int id) async {
    final db = await _db;
    final result = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return CharacterModel.fromMap(Map<String, Object?>.from(result.first));
  }
}
