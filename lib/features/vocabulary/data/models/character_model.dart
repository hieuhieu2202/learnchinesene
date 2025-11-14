import '../../domain/entities/character_entity.dart';

class CharacterModel extends CharacterEntity {
  const CharacterModel({
    required super.id,
    required super.character,
    required super.strokeWidth,
    required super.strokeHeight,
    required super.strokePaths,
  });

  factory CharacterModel.fromMap(Map<String, Object?> map) {
    return CharacterModel(
      id: map['id'] as int,
      character: map['character'] as String? ?? '',
      strokeWidth: map['stroke_width'] as int? ?? 0,
      strokeHeight: map['stroke_height'] as int? ?? 0,
      strokePaths: map['stroke_paths'] as String? ?? '',
    );
  }
}
