import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/example_model.dart';

abstract class ExampleLocalDataSource {
  Future<List<ExampleModel>> getExamplesByWord(int wordId);
}

class ExampleLocalDataSourceImpl implements ExampleLocalDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<ExampleModel>> getExamplesByWord(int wordId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_examples')
          .select(
            'id, word_id, example_order, sentence_cn, sentence_pinyin, sentence_vi',
          )
          .eq('word_id', wordId)
          .order('example_order')
          .order('id'),
    );

    return rows
        .map(
          (row) => ExampleModel.fromMap({
            'id': (row['id'] as num?)?.toInt() ?? 0,
            'word_id': (row['word_id'] as num?)?.toInt() ?? 0,
            'order_index':
                (row['example_order'] as num?)?.toInt() ??
                    (row['id'] as num?)?.toInt() ??
                    0,
            'sentence_cn': row['sentence_cn']?.toString() ?? '',
            'sentence_pinyin': row['sentence_pinyin']?.toString() ?? '',
            'sentence_vi': row['sentence_vi']?.toString() ?? '',
          }),
        )
        .toList();
  }
}
