import 'dart:convert';

class GameQuestion {
  final String id;
  final String type;
  final String? prompt;
  final String? tts;
  final String? slowTts;
  final List<String> choices;
  final List<int> correctIndices;
  final String? solutionText;
  final List<String> tokens;
  final List<String> hints;
  final List<String> images;
  final Map<String, dynamic> metadata;

  GameQuestion({
    required this.id,
    required this.type,
    this.prompt,
    this.tts,
    this.slowTts,
    this.choices = const [],
    this.correctIndices = const [],
    this.solutionText,
    this.tokens = const [],
    this.hints = const [],
    this.images = const [],
    this.metadata = const {},
  });

  factory GameQuestion.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) {
        if (raw.trim().isEmpty) return [];
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) return parsed.map((e) => e.toString()).toList();
        } catch (_) {
          return [raw];
        }
      }
      return [];
    }

    List<int> parseIntList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => int.tryParse(e.toString()) ?? 0).toList();
      }
      if (raw is String) {
        if (raw.trim().isEmpty) return [];
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) {
            return parsed.map((e) => int.tryParse(e.toString()) ?? 0).toList();
          }
        } catch (_) {}
      }
      return [];
    }

    String? parseSolution(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) {
        if (raw.startsWith('[') || raw.startsWith('{')) {
          try {
            final parsed = jsonDecode(raw);
            if (parsed is List && parsed.isNotEmpty) {
              return parsed.first.toString();
            }
          } catch (_) {}
        }
        return raw;
      }
      if (raw is List && raw.isNotEmpty) return raw.first.toString();
      return raw.toString();
    }

    return GameQuestion(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      prompt: map['prompt']?.toString(),
      tts: map['tts']?.toString(),
      slowTts: map['slow_tts']?.toString(),
      choices: parseStringList(map['choices_text']),
      correctIndices: parseIntList(map['choices_correct']),
      solutionText: parseSolution(map['solutions']),
      tokens: parseStringList(map['tokens_text']),
      hints: parseStringList(map['tokens_hints']),
      images: parseStringList(map['choices_image']),
      metadata: map['metadata'] is String
          ? (jsonDecode(map['metadata'] ?? '{}') as Map<String, dynamic>? ?? {})
          : (map['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }
}
