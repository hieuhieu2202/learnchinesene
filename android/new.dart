// practice_models.dart

class BaseSentence {
  const BaseSentence({
    required this.id,
    required this.wordId,
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
  });

  final int id;
  final int wordId;
  final String chinese;
  final String pinyin;
  final String vietnamese;
}

class PracticeSentence {
  const PracticeSentence({
    required this.id,
    this.baseExampleId,
    required this.mainWordId,
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
    required this.isFromAI,
  });

  final String id;
  final int? baseExampleId;
  final int mainWordId;
  final String chinese;
  final String pinyin;
  final String vietnamese;
  final bool isFromAI;
}

enum ExerciseType {
  typeFromVietnamese,
  typeFromPinyin,
  typeMissingWord,
  typeFullSentenceCopy,
  typeArrangeSentence,
  typeTransformed,
}

// Lớp cơ sở trừu tượng cho mọi bài tập.
abstract class Exercise {
  const Exercise({
    required this.type,
    required this.sentence,
    required this.correctAnswer,
    this.userAnswer,
  });

  final ExerciseType type;
  final PracticeSentence sentence;
  final String correctAnswer;
  final dynamic userAnswer; // 'dynamic' vì câu trả lời có thể là String, List<String>,...
}

// Lớp này đại diện cho một bài tập chung liên quan đến câu.
// Các loại bài tập cụ thể hơn có thể kế thừa từ đây nếu cần.
class SentenceExercise extends Exercise {
  const SentenceExercise({
    required super.type,
    required super.sentence,
    required super.correctAnswer,
    super.userAnswer,
    this.hiddenWord,
    this.arrangeSegments,
    this.arrangeOptions,
  });

  // Từ bị ẩn (dùng cho bài tập điền từ)
  final String? hiddenWord;

  // Các mảnh câu đã được xáo trộn (dùng cho bài tập sắp xếp câu)
  final List<String>? arrangeSegments;

  // Các lựa chọn cho người dùng (có thể dùng cho điền từ hoặc sắp xếp)
  final List<String>? arrangeOptions;

  // Thêm hàm copyWith để dễ dàng cập nhật trạng thái
  SentenceExercise copyWith({
    dynamic userAnswer,
  }) {
    return SentenceExercise(
      type: type,
      sentence: sentence,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      hiddenWord: hiddenWord,
      arrangeSegments: arrangeSegments,
      arrangeOptions: arrangeOptions,
    );
  }
}

// Lớp này đã được tích hợp vào SentenceExercise, bạn có thể xóa đi
// hoặc giữ lại nếu muốn có một lớp chuyên biệt rõ ràng hơn.
// Nếu giữ lại, nó nên trông như thế này:
class MissingWordExercise extends SentenceExercise {
  const MissingWordExercise({
    required super.sentence,
    required super.correctAnswer,
    required String hiddenWord, // Đã có trong SentenceExercise
    super.userAnswer,
    super.arrangeOptions,
  }) : super(
    type: ExerciseType.typeMissingWord,
    hiddenWord: hiddenWord,
  );
}

class UnitPracticeProcess {
  const UnitPracticeProcess({
    required this.sectionId,
    required this.wordIds,
    required this.exercises,
  });

  final int sectionId;
  final List<int> wordIds;
  final List<SentenceExercise> exercises;
}

class ExerciseResult {
  const ExerciseResult({
    required this.exercise,
    required this.userInput,
    required this.isCorrect,
    required this.doneAt,
  });

  final SentenceExercise exercise;
  final String userInput; // Hoặc có thể là 'dynamic' tùy vào loại bài tập
  final bool isCorrect;
  final DateTime doneAt;
}
