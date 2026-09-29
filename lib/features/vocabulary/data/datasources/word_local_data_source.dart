import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/word_model.dart';

abstract class WordLocalDataSource {
  Future<List<int>> getSections();
  Future<String> getSectionTitle(int sectionId);
  Future<List<WordModel>> getWordsBySection(int sectionId);
  Future<WordModel?> getWordById(int wordId);
}

class WordLocalDataSourceImpl implements WordLocalDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<int>> getSections() async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_hsk_levels')
          .select('id')
          .order('sort_order')
          .order('id'),
    );
    return rows
        .map((row) => (row['id'] as num?)?.toInt())
        .whereType<int>()
        .toList();
  }

  @override
  Future<String> getSectionTitle(int sectionId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_hsk_levels')
          .select('name')
          .eq('id', sectionId)
          .limit(1),
    );
    return rows.isEmpty ? '' : (rows.first['name'] ?? '').toString();
  }

  @override
  Future<List<WordModel>> getWordsBySection(int sectionId) async {
    final title = await getSectionTitle(sectionId);
    final rows = <Map<String, dynamic>>[];
    var from = 0;

    while (true) {
      final page = List<Map<String, dynamic>>.from(
        await _client
            .from('lexicon_words')
            .select('id, word, pinyin, meaning_vi, tts_url, hsk_level_id')
            .eq('hsk_level_id', sectionId)
            .order('id')
            .range(from, from + 999),
      );
      rows.addAll(page);
      if (page.length < 1000) break;
      from += 1000;
    }

    return rows.map((row) => _fromCloud(row, title)).toList();
  }

  @override
  Future<WordModel?> getWordById(int wordId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_words')
          .select('id, word, pinyin, meaning_vi, tts_url, hsk_level_id')
          .eq('id', wordId)
          .limit(1),
    );
    if (rows.isEmpty) return null;
    final sectionId = (rows.first['hsk_level_id'] as num?)?.toInt() ?? 0;
    final title = await getSectionTitle(sectionId);
    return _fromCloud(rows.first, title);
  }

  WordModel _fromCloud(Map<String, dynamic> row, String title) {
    return WordModel.fromMap({
      'id': (row['id'] as num?)?.toInt() ?? 0,
      'section_id': (row['hsk_level_id'] as num?)?.toInt() ?? 0,
      'section_title': title,
      'group_subtitle': '',
      'word': row['word']?.toString() ?? '',
      'translation': row['meaning_vi']?.toString() ?? '',
      'transliteration': row['pinyin']?.toString() ?? '',
      'tts_url': row['tts_url']?.toString() ?? '',
    });
  }
}
