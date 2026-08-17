import 'dart:convert';

class DuoChallenge {
  final String id;
  final String type;
  final String? prompt;
  final String? tts;
  final String? slowTts;
  
  // Các mảng "ăn sẵn" đã được xáo trộn trong DB
  final List<String>? choicesText;
  final List<String>? choicesTts;
  final List<String>? choicesImage;
  
  // Dành cho gapFill
  final List<String>? tokensText;
  final List<String>? tokensTts;
  final List<String>? tokensHints;
  
  // Mảng ID thứ tự (VD: [0, 2, 1, 3, 4, 0])
  final List<int>? choicesCorrect;
  
  // Chuỗi đáp án hoàn chỉnh
  final String? solutions;

  DuoChallenge({
    required this.id,
    required this.type,
    this.prompt,
    this.tts,
    this.slowTts,
    this.choicesText,
    this.choicesTts,
    this.choicesImage,
    this.tokensText,
    this.tokensTts,
    this.tokensHints,
    this.choicesCorrect,
    this.solutions,
  });

  factory DuoChallenge.fromMap(Map<String, dynamic> map) {
    List<String>? parseStringList(String? jsonStr) {
      if (jsonStr == null) return null;
      try {
        final decoded = jsonDecode(jsonStr) as List;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return null;
      }
    }

    List<int>? parseIntList(String? jsonStr) {
      if (jsonStr == null) return null;
      try {
        final decoded = jsonDecode(jsonStr) as List;
        return decoded.map((e) => int.parse(e.toString())).toList();
      } catch (e) {
        return null;
      }
    }

    return DuoChallenge(
      id: map['id'] as String,
      type: map['type'] as String,
      prompt: map['prompt'] as String?,
      tts: map['tts'] as String?,
      slowTts: map['slow_tts'] as String?,
      choicesText: parseStringList(map['choices_text'] as String?),
      choicesTts: parseStringList(map['choices_tts'] as String?),
      choicesImage: parseStringList(map['choices_image'] as String?),
      tokensText: parseStringList(map['tokens_text'] as String?),
      tokensTts: parseStringList(map['tokens_tts'] as String?),
      tokensHints: parseStringList(map['tokens_hints'] as String?),
      choicesCorrect: parseIntList(map['choices_correct'] as String?),
      solutions: map['solutions'] as String?,
    );
  }
}
