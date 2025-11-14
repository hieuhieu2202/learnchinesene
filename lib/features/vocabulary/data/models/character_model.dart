import '../../domain/entities/character_entity.dart';

class CharacterModel extends CharacterEntity {
  const CharacterModel({
    required super.id,
    required super.character,
    required super.strokeWidth,
    required super.strokeHeight,
    required super.strokePaths,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] as int,
      character: (map['character'] ?? '') as String,
      strokeWidth: (map['stroke_width'] ?? 0) as int,
      strokeHeight: (map['stroke_height'] ?? 0) as int,
      strokePaths: (map['stroke_paths'] ?? '') as String,
    );
  }
}
