import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/progress_model.dart';

abstract class ProgressLocalDataSource {
  Future<ProgressModel?> getProgressForWord(int wordId);
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId);
  Future<void> upsertProgress(ProgressModel progress);
  Future<List<int>> getWordsToReviewToday(DateTime today);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  static const _prefix = 'v1_progress_v2_';

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<ProgressModel?> getProgressForWord(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$wordId');
    if (raw == null) return null;
    return _decode(raw);
  }

  @override
  Future<Map<int, ProgressModel>> getProgressForSection(int sectionId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_words')
          .select('id')
          .eq('hsk_level_id', sectionId)
          .order('id')
          .range(0, 999),
    );
    final prefs = await SharedPreferences.getInstance();
    final result = <int, ProgressModel>{};

    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id == null) continue;
      final raw = prefs.getString('$_prefix$id');
      if (raw == null) continue;
      result[id] = _decode(raw);
    }
    return result;
  }

  @override
  Future<void> upsertProgress(ProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${progress.wordId}',
      jsonEncode(progress.toMap()),
    );
  }

  @override
  Future<List<int>> getWordsToReviewToday(DateTime today) async {
    final prefs = await SharedPreferences.getInstance();
    final boundary = DateTime(today.year, today.month, today.day);
    final result = <MapEntry<int, ProgressModel>>[];

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_prefix)) continue;
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final progress = _decode(raw);
      if (progress.mastered) continue;

      final last = progress.lastPractice;
      if (last == null || last.isBefore(boundary)) {
        final id = int.tryParse(key.substring(_prefix.length));
        if (id != null) result.add(MapEntry(id, progress));
      }
    }

    result.sort((a, b) {
      final aa = a.value.lastPractice;
      final bb = b.value.lastPractice;
      if (aa == null && bb == null) return 0;
      if (aa == null) return -1;
      if (bb == null) return 1;
      return aa.compareTo(bb);
    });

    return result.map((entry) => entry.key).toList();
  }

  ProgressModel _decode(String raw) {
    final data = Map<String, Object?>.from(jsonDecode(raw) as Map);
    final mastered = data['mastered'];
    if (mastered is bool) {
      data['mastered'] = mastered ? 1 : 0;
    }
    return ProgressModel.fromMap(data);
  }
}
