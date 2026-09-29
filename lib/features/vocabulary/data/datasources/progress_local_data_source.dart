import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/progress_model.dart';

/// Compatibility name kept to avoid a broad presentation-layer rewrite.
///
/// Despite the historical "Local" name, this data source is cloud-only and
/// stores learning progress in Supabase.
abstract class ProgressLocalDataSource {
  Future<ProgressModel?> getProgressForWord(int wordId);
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId);
  Future<void> upsertProgress(ProgressModel progress);
  Future<List<int>> getWordsToReviewToday(DateTime today);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Supabase authentication is required.');
    }
    return id;
  }

  @override
  Future<ProgressModel?> getProgressForWord(int wordId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_user_progress')
          .select(
            'word_id, correct_count, wrong_count, level, mastered, last_review_at',
          )
          .eq('user_id', _userId)
          .eq('word_id', wordId)
          .limit(1),
    );

    return rows.isEmpty ? null : ProgressModel.fromMap(rows.first);
  }

  @override
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId) async {
    final wordIds = await _wordIdsForSection(sectionId);
    if (wordIds.isEmpty) return <int, ProgressModel>{};

    final result = <int, ProgressModel>{};
    for (var i = 0; i < wordIds.length; i += 200) {
      final end = i + 200 < wordIds.length ? i + 200 : wordIds.length;
      final chunk = wordIds.sublist(i, end);
      final rows = List<Map<String, dynamic>>.from(
        await _client
            .from('lexicon_user_progress')
            .select(
              'word_id, correct_count, wrong_count, level, mastered, last_review_at',
            )
            .eq('user_id', _userId)
            .inFilter('word_id', chunk),
      );

      for (final row in rows) {
        final progress = ProgressModel.fromMap(row);
        result[progress.wordId] = progress;
      }
    }
    return result;
  }

  @override
  Future<void> upsertProgress(ProgressModel progress) async {
    await _client.from('lexicon_user_progress').upsert(
      {
        'user_id': _userId,
        'word_id': progress.wordId,
        'correct_count': progress.correctCount,
        'wrong_count': progress.wrongCount,
        'level': progress.level,
        'mastered': progress.mastered,
        'last_review_at': progress.lastPractice?.toUtc().toIso8601String(),
        'next_review_at': progress.mastered
            ? DateTime.now()
                .toUtc()
                .add(const Duration(days: 7))
                .toIso8601String()
            : DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,word_id',
    );
  }

  @override
  Future<List<int>> getWordsToReviewToday(DateTime today) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_user_progress')
          .select('word_id, mastered, next_review_at, last_review_at')
          .eq('user_id', _userId)
          .eq('mastered', false)
          .order('next_review_at')
          .order('last_review_at'),
    );

    final endOfToday = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
      999,
    ).toUtc();

    return rows
        .where((row) {
          final raw = row['next_review_at']?.toString();
          if (raw == null || raw.isEmpty) return true;
          final next = DateTime.tryParse(raw);
          return next == null || !next.toUtc().isAfter(endOfToday);
        })
        .map((row) => (row['word_id'] as num?)?.toInt())
        .whereType<int>()
        .toList();
  }

  Future<List<int>> _wordIdsForSection(int sectionId) async {
    final ids = <int>[];
    var from = 0;

    while (true) {
      final page = List<Map<String, dynamic>>.from(
        await _client
            .from('lexicon_words')
            .select('id')
            .eq('hsk_level_id', sectionId)
            .order('id')
            .range(from, from + 999),
      );

      ids.addAll(
        page
            .map((row) => (row['id'] as num?)?.toInt())
            .whereType<int>(),
      );

      if (page.length < 1000) break;
      from += 1000;
    }

    return ids;
  }
}
