# 🧪 Hướng dẫn Test Tính năng Kinh nghiệm & Chuỗi ngày học

## Chuẩn bị Test

### 1. Đảm bảo DatabaseHelper khởi tạo đúng
- Khi ứng dụng khởi động lần đầu, bảng `user_stats` sẽ được tạo tự động
- Dữ liệu mặc định: EXP = 0, Streak = 0, ngày học = hôm nay

### 2. Kiểm tra dữ liệu trong Database
```bash
# Kết nối đến database SQLite (sau khi ứng dụng chạy)
# File database nằm tại: /data/data/com.example.learnchinese/databases/chinese.db

# Query kiểm tra dữ liệu
SELECT * FROM user_stats WHERE id = 1;
```

## Test Scenarios

### Test 1: Tính EXP khi hoàn thành câu hỏi ✅

**Các bước:**
1. Mở trang **Review Today**
2. Nhấn nút **"Bắt đầu ôn tập"**
3. Hoàn thành bài luyện tập:
   - Trả lời đúng tối thiểu **5 câu**
   - Hoàn thành hết tất cả bài
4. Xem trang **Profile**

**Kết quả mong đợi:**
- EXP tăng: `5 * 10 + 50 = 100` (5 câu đúng × 10 + 50 bonus)
- Chuỗi ngày học: **1 ngày** (lần đầu học)

**Dữ liệu database:**
```
total_exp: 100
current_streak: 1
last_study_date: 2024-12-08 (hôm nay)
```

---

### Test 2: Tính EXP lần thứ hai (cùng ngày) ✅

**Các bước:**
1. Hoàn thành một bài luyện tập khác ngay trong cùng ngày
2. Trả lời đúng **3 câu**
3. Xem trang Profile

**Kết quả mong đợi:**
- EXP tăng thêm: `3 * 10 + 50 = 80`
- **Tổng EXP**: 100 + 80 = **180**
- Chuỗi ngày học: Vẫn **1 ngày** (vì cùng ngày)

**Dữ liệu database:**
```
total_exp: 180
current_streak: 1 (không tăng vì cùng ngày)
last_study_date: 2024-12-08
```

---

### Test 3: Chuỗi ngày học tăng (ngày tiếp theo) 📅

**Các bước:**
1. Hoàn thành bài luyện tập lần thứ ba (vào ngày 09/12/2024)
2. Trả lời đúng **2 câu**
3. Xem trang Profile

**Kết quả mong đợi:**
- EXP tăng thêm: `2 * 10 + 50 = 70`
- **Tổng EXP**: 180 + 70 = **250**
- Chuỗi ngày học: Tăng thành **2 ngày**

**Dữ liệu database:**
```
total_exp: 250
current_streak: 2 (tăng vì học ngày liên tiếp)
last_study_date: 2024-12-09
```

---

### Test 4: Reset Streak nếu không học quá 1 ngày ❌

**Các bước:**
1. Đợi 2 ngày không luyện tập (ví dụ: từ 09/12 đến 11/12)
2. Hoàn thành bài luyện tập vào ngày 12/12
3. Xem trang Profile

**Kết quả mong đợi:**
- EXP tăng thêm: `1 * 10 + 50 = 60`
- **Tổng EXP**: 250 + 60 = **310**
- Chuỗi ngày học: Reset thành **1 ngày** (vì cách quá 1 ngày)

**Dữ liệu database:**
```
total_exp: 310
current_streak: 1 (reset vì cách hơn 1 ngày)
last_study_date: 2024-12-12
```

---

## Manual Testing Queries

### Xem dữ liệu hiện tại
```sql
SELECT 
    id,
    total_exp,
    current_streak,
    last_study_date,
    total_words_mastered,
    total_favorites
FROM user_stats 
WHERE id = 1;
```

### Update thủ công để test
```sql
-- Reset về trạng thái ban đầu
UPDATE user_stats 
SET total_exp = 0, 
    current_streak = 0, 
    last_study_date = datetime('now')
WHERE id = 1;

-- Giả lập đã học 5 ngày
UPDATE user_stats 
SET current_streak = 5 
WHERE id = 1;

-- Giả lập ngày học cuối là 3 ngày trước
UPDATE user_stats 
SET last_study_date = datetime('now', '-3 days')
WHERE id = 1;
```

---

## Debug Logs

### Kiểm tra logs khi hoàn thành bài
Hãy thêm các log sau vào `_updateExperienceOnFinish()`:

```dart
Future<void> _updateExperienceOnFinish() async {
  try {
    final correctCount = score.value;
    final totalExercises = this.totalExercises;
    
    print('🎯 Hoàn thành bài luyện tập!');
    print('   Câu đúng: $correctCount');
    print('   Tổng câu: $totalExercises');
    
    // Thêm EXP
    await addExperienceUseCase(
      correctAnswers: correctCount,
      lessonCompleted: true,
    );
    
    print('✅ EXP đã được cập nhật');
  } catch (e) {
    print('❌ Lỗi cập nhật EXP: $e');
  }
}
```

### Kiểm tra logs ProfilePage
```dart
FutureBuilder<UserStats>(
  future: _getUserStats(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final userStats = snapshot.data!;
      print('📊 Dữ liệu Profile:');
      print('   EXP: ${userStats.totalExp}');
      print('   Streak: ${userStats.currentStreak}');
      print('   Ngày học: ${userStats.lastStudyDate}');
    }
    // ...
  },
)
```

---

## Mô phỏng tính năng Streak

### Cách 1: Thay đổi hệ thống ngày (Emulator)
1. Vào Settings của Android Emulator
2. Chuyển sang **Developer Mode**
3. Thay đổi date/time trong System settings
4. Chạy ứng dụng lại

### Cách 2: Sử dụng Android Debug Bridge (ADB)
```bash
# Kiểm tra ngày hiện tại
adb shell date

# Thay đổi ngày (cần root/emulator)
adb shell su
date -s YYYYMMDDhhmm
```

---

## Kiểm tra Integration

### ✅ Unit Tests có thể viết thêm

```dart
// test/features/vocabulary/domain/usecases/add_experience_test.dart

void main() {
  group('AddExperienceUseCase', () {
    test('should add 10 EXP per correct answer', () async {
      // Giả lập repository
      final mockRepository = MockUserStatsRepository();
      final useCase = AddExperienceUseCase(repository: mockRepository);
      
      // Gọi use case
      await useCase(correctAnswers: 5, lessonCompleted: false);
      
      // Kiểm tra: 5 * 10 = 50 EXP
      verify(mockRepository.addExp(50)).called(1);
    });

    test('should add bonus 50 EXP when lesson completed', () async {
      final mockRepository = MockUserStatsRepository();
      final useCase = AddExperienceUseCase(repository: mockRepository);
      
      // Gọi use case
      await useCase(correctAnswers: 3, lessonCompleted: true);
      
      // Kiểm tra: 3 * 10 + 50 = 80 EXP
      verify(mockRepository.addExp(80)).called(1);
    });
  });
}
```

---

## Troubleshooting

### Problem 1: EXP không tăng
**Giải pháp:**
- Kiểm tra AddExperienceUseCase có được inject không
- Kiểm tra database có sẵn không (lần chạy đầu tiên)
- Xem logs console có lỗi không

### Problem 2: ProfilePage không cập nhật
**Giải pháp:**
- ProfilePage sử dụng FutureBuilder, có thể chậm tải
- Kiểm tra import `get_user_stats` đúng chưa
- Try hot reload hay restart ứng dụng

### Problem 3: Streak không thay đổi
**Giải pháp:**
- Kiểm tra logic ngày trong `updateStreak()` - chỉ so sánh ngày, không so giờ
- Kiểm tra database `last_study_date` có đúng format ISO8601 không
- Reset database và test lại

---

## Final Checklist ✅

- [ ] Database tạo bảng `user_stats` khi khởi động
- [ ] EXP tính đúng: 10 per answer + 50 bonus
- [ ] Streak tăng khi học ngày liên tiếp
- [ ] Streak reset khi cách quá 1 ngày
- [ ] Profile Page hiển thị dữ liệu từ database
- [ ] Không có lỗi trong logs
- [ ] Dữ liệu persist khi reload ứng dụng

