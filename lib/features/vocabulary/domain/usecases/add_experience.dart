import '../repositories/user_stats_repository.dart';

class AddExperienceUseCase {
  final UserStatsRepository repository;

  AddExperienceUseCase({required this.repository});

  Future<void> call({
    required int correctAnswers,
    bool lessonCompleted = false,
  }) async {
    // ⭐ LOGIC MỚI:
    // - 1 câu đúng = 1 EXP (cập nhật ngay lập tức)
    // - Chỉ update STREAK khi hoàn thành bài (lessonCompleted=true)

    int exp = 0;

    // 1 EXP cho mỗi câu trả lời đúng
    if (correctAnswers > 0) {
      exp = correctAnswers; // 1 câu = 1 EXP
      await repository.addExp(exp);
      print('💰 EXP +$exp | Total: ...');
    }

    // Chỉ update streak khi hoàn thành bài
    if (lessonCompleted) {
      try {
        await repository.updateStreak();
        print('🔥 Streak updated');
      } catch (e) {
        print('❌ Error updating streak: $e');
      }
    }
  }
}
