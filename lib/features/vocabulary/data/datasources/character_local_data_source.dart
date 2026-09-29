import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/character_model.dart';

abstract class CharacterLocalDataSource {
  Future<CharacterModel?> getCharacterById(int id);
}

class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<CharacterModel?> getCharacterById(int id) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('lexicon_characters')
          .select('id, character, stroke_width, stroke_height, stroke_paths')
          .eq('id', id)
          .limit(1),
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    return CharacterModel.fromMap({
      'id': (row['id'] as num?)?.toInt() ?? 0,
      'character': row['character']?.toString() ?? '',
      'stroke_width': (row['stroke_width'] as num?)?.round() ?? 0,
      'stroke_height': (row['stroke_height'] as num?)?.round() ?? 0,
      'stroke_paths': row['stroke_paths']?.toString() ?? '',
    });
  }
}
