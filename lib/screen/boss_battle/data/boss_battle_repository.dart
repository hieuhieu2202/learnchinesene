import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/boss_battle_question.dart';

abstract class BossBattleQuestionSource {
  Future<List<BossBattleQuestion>> loadQuestionSeeds({int limit = 36});

  Future<void> close();
}

class BossBattleRepository implements BossBattleQuestionSource {
  static const _assetPath = 'assets/database/app_chinese_ordered.db';
  static const _fileName = 'app_chinese_ordered.db';

  Database? _database;

  Future<Database> _openDatabase() async {
    if (_database != null) return _database!;

    final supportDir = await getApplicationSupportDirectory();
    final contentDir = Directory(p.join(supportDir.path, 'learning_content'));
    if (!await contentDir.exists()) {
      await contentDir.create(recursive: true);
    }

    final databasePath = p.join(contentDir.path, _fileName);
    final dbFile = File(databasePath);

    if (!await dbFile.exists()) {
      final data = await rootBundle.load(_assetPath);
      await dbFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    _database = await openDatabase(
      databasePath,
      readOnly: true,
      singleInstance: true,
    );
    return _database!;
  }

  @override
  Future<List<BossBattleQuestion>> loadQuestionSeeds({
    int limit = 36,
  }) async {
    final db = await _openDatabase();

    final rows = await db.rawQuery(
      '''
      SELECT id, prompt, choices_text, choices_correct
      FROM challenges
      WHERE type = 'select'
        AND prompt IS NOT NULL
        AND TRIM(prompt) != ''
        AND choices_text IS NOT NULL
        AND choices_correct IS NOT NULL
      ORDER BY RANDOM()
      LIMIT ?
      ''',
      <Object?>[limit],
    );

    final questions = <BossBattleQuestion>[];

    for (final row in rows) {
      final id = '${row['id'] ?? ''}'.trim();
      final prompt = '${row['prompt'] ?? ''}'.trim();
      final rawChoices = '${row['choices_text'] ?? ''}';
      final rawCorrect = '${row['choices_correct'] ?? ''}';

      if (id.isEmpty || prompt.isEmpty) continue;

      try {
        final decodedChoices = jsonDecode(rawChoices);
        final decodedCorrect = jsonDecode(rawCorrect);

        if (decodedChoices is! List || decodedCorrect is! List) continue;
        if (decodedChoices.length != decodedCorrect.length) continue;

        final answers = <String>[];
        String? correctAnswer;

        for (var i = 0; i < decodedChoices.length; i++) {
          final answer = '${decodedChoices[i]}'.trim();
          if (answer.isEmpty || answers.contains(answer)) continue;

          answers.add(answer);

          final flag = decodedCorrect[i];
          final isCorrect = flag == true ||
              (flag is num && flag.toInt() == 1) ||
              '$flag' == '1';

          if (isCorrect) {
            correctAnswer = answer;
          }
        }

        if (answers.length < 2 ||
            correctAnswer == null ||
            !answers.contains(correctAnswer)) {
          continue;
        }

        questions.add(
          BossBattleQuestion(
            id: id,
            prompt: prompt,
            answers: answers,
            correctAnswer: correctAnswer,
          ),
        );
      } catch (_) {
        // Malformed rows are skipped. The bundled content database stays read-only.
      }
    }

    return questions;
  }

  @override
  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) {
      await db.close();
    }
  }
}
