# 🔥 Cập nhật: Tăng Streak Khi Hoàn Thành Từ Vựng

## 📝 Tóm tắt

Khi người dùng **hoàn thành (mastered) ít nhất 1 từ vựng** trong ngày (level đạt 5+), số ngày học liên tiếp (**streak**) sẽ tự động tăng lên 1 (nếu đã học những ngày trước).

---

## 🔧 Thay đổi kỹ thuật

### 1. **PracticeSessionController** (`practice_session_controller.dart`)

**Thêm:**
- Import `UserStatsRepository`
- Constructor parameter: `required this.userStatsRepository`
- Method `_updateStreakOnWordMastered()` gọi `userStatsRepository.updateStreak()`
- Gọi `_updateStreakOnWordMastered()` khi từ vựng được mastered (level từ < 5 → >= 5)

**Code:**
```dart
import '../../domain/repositories/user_stats_repository.dart';

class PracticeSessionController extends GetxController {
  PracticeSessionController({
    // ...
    required this.userStatsRepository,
  });

  final UserStatsRepository userStatsRepository;

  // Trong _finalizeExercise():
  final isMastered = updatedLevel >= 5;
  final wasMastered = progress.mastered;
  
  // ⭐ Nếu vừa mastered từ (chưa mastered trước) → Cập nhật streak
  if (isMastered && !wasMastered) {
    _updateStreakOnWordMastered();
  }

  /// ⭐ Cập nhật streak khi người dùng hoàn thành 1 từ vựng (mastered)
  Future<void> _updateStreakOnWordMastered() async {
    try {
      await userStatsRepository.updateStreak();
      print('🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật');
    } catch (e) {
      print('❌ [PRACTICE] Lỗi cập nhật streak: $e');
    }
  }
}
```

### 2. **AppPages** (`app_pages.dart`)

**Thêm:**
```dart
Get.put(PracticeSessionController(
  words: words,
  getExamplesByWord: Get.find(),
  getProgressForWord: Get.find(),
  updateProgressAfterQuiz: Get.find(),
  addExperienceUseCase: Get.find(),
  userStatsRepository: Get.find(), // ⭐ Inject repository
));
```

---

## 📊 Logic Chi Tiết

Hàm `updateStreak()` từ `UserStatsRepository`:

```
1. Lấy lastStudyDate từ database
2. So sánh với hôm nay:
   - Cách 0 ngày: Đã học hôm nay → Không cập nhật
   - Cách 1 ngày: Học hôm nay sau hôm qua → Streak tăng 1
   - Cách > 1 ngày: Quá lâu không học → Reset streak = 1
3. Cập nhật lastStudyDate = hôm nay
```

---

## 🎯 Luồng hoạt động

```
1. User mở PracticeSessionPage (luyện tập từ vựng)
   ↓
2. PracticeSessionController xử lý từng câu trả lời
   ↓
3. Khi câu trả lời đúng, cập nhật level từ vựng
   ↓
4. Nếu level từ < 5 → >= 5 (vừa mastered):
   ├─ Gọi _updateStreakOnWordMastered()
   └─ Cập nhật streak
   ↓
5. Nếu đã mastered trước: Không cập nhật
```

---

## ✅ Test

### Test Case 1: Hoàn thành từ vựng hôm nay lần đầu
- **Precondition**: lastStudyDate = hôm qua, currentStreak = 5, word.level = 4
- **Action**: Luyện tập và hoàn thành từ (level → 5)
- **Expected**: currentStreak = 6, lastStudyDate = hôm nay

### Test Case 2: Hoàn thành từ vựng nhưng đã mastered trước
- **Precondition**: lastStudyDate = hôm nay, currentStreak = 5, word.mastered = true
- **Action**: Luyện tập từ mastered
- **Expected**: currentStreak = 5 (không thay đổi)

### Test Case 3: Quá lâu không học, rồi hoàn thành từ
- **Precondition**: lastStudyDate = 3 ngày trước, currentStreak = 5, word.level = 4
- **Action**: Luyện tập và hoàn thành từ (level → 5)
- **Expected**: currentStreak = 1, lastStudyDate = hôm nay

### Test Case 4: Chưa hoàn thành từ
- **Precondition**: lastStudyDate = hôm qua, currentStreak = 5, word.level = 3
- **Action**: Luyện tập nhưng level chỉ lên 4
- **Expected**: currentStreak = 5 (không thay đổi)

---

## 🐛 Debug

Kiểm tra console log:
```
🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật
```

hoặc

```
❌ [PRACTICE] Lỗi cập nhật streak: [error message]
```

Kiểm tra database:
```sql
SELECT currentStreak, lastStudyDate FROM user_stats WHERE id = 1;
SELECT id, level, mastered FROM progress WHERE id = [word_id];
```

---

## 📌 Ghi chú

- Hàm `updateStreak()` được gọi **async** nhưng không block UI (fire & forget)
- Nếu có lỗi, ứng dụng vẫn hoạt động bình thường
- lastStudyDate được so sánh chỉ ngày (không giờ)

Xong! 🎉

