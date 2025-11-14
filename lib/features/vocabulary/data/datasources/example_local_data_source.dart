import 'package:sqflite/sqflite.dart';

import '../../../../core/db/database_helper.dart';
import '../models/example_model.dart';

abstract class ExampleLocalDataSource {
  Future<List<ExampleModel>> getExamplesByWord(int wordId);
}

class ExampleLocalDataSourceImpl implements ExampleLocalDataSource {
  Future<Database> get _db async => DatabaseHelper.database;

  @override
  Future<List<ExampleModel>> getExamplesByWord(int wordId) async {
    final db = await _db;
    final result = await db.query(
      'examples',
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'order_index ASC',
    );
    return result.map(ExampleModel.fromMap).toList();
  }
}
