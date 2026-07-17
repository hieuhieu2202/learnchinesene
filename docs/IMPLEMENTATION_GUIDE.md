# Hướng dẫn sử dụng tính năng Kinh nghiệm & Chuỗi ngày học

## 📋 Tính năng đã thêm

### 1. **Kinh nghiệm (EXP)**
- Người dùng tích lũy điểm kinh nghiệm dựa trên:
  - **10 EXP** cho mỗi câu trả lời đúng
  - **50 EXP bonus** khi hoàn thành một bài học

### 2. **Chuỗi ngày học (Learning Streak)**
- Theo dõi số ngày liên tiếp học tập
- Tự động tăng khi học hàng ngày
- Tự động reset nếu không học hơn 1 ngày

### 3. **Thống kê người dùng**
- Tổng từ vựng đã thuần thục
- Tổng câu ví dụ yêu thích
- Ngày học cuối cùng

---

## 🛠️ Cách tích hợp vào các màn hình khác

### Thêm EXP sau khi trả lời đúng

Tại file `practice_session_page.dart` hoặc `review_today_page.dart`, sau khi người dùng hoàn thành câu hỏi:

```dart
import 'package:get/get.dart';
import 'package:chinese_master/features/vocabulary/domain/usecases/add_experience.dart';

// Trong Controller hoặc Page
final addExpUseCase = Get.find<AddExperienceUseCase>();

// Sau khi kiểm tra câu trả lời
if (isAnswerCorrect) {
  // Thêm EXP cho câu trả lời đúng
  await addExpUseCase(correctAnswers: 1, lessonCompleted: false);
}

// Khi hoàn thành toàn bộ bài học
if (quizCompleted) {
  final correctCount = /* số câu đúng */;
  await addExpUseCase(
    correctAnswers: correctCount,
    lessonCompleted: true, // 50 EXP bonus
  );
}
```

### Lấy dữ liệu UserStats

```dart
import 'package:get/get.dart';
import 'package:chinese_master/features/vocabulary/domain/usecases/get_user_stats.dart';

final getUserStats = Get.find<GetUserStatsUseCase>();
final userStats = await getUserStats();

print('EXP: ${userStats.totalExp}');
print('Streak: ${userStats.currentStreak} ngày');
print('Words Mastered: ${userStats.totalWordsMastered}');
```

### Cập nhật số từ thuần thục

Khi một từ đạt mức "mastered" (10 lần trả lời đúng), hãy cập nhật thống kê:

```dart
import 'package:get/get.dart';
import 'package:chinese_master/features/vocabulary/domain/repositories/user_stats_repository.dart';

final userStatsRepo = Get.find<UserStatsRepository>();

// Tính tổng số từ thuần thục từ database
final masterCount = await progressRepository.getCountMasteredWords();
await userStatsRepo.updateWordsMastered(masterCount);
```

---

## 🔄 Chu trình tự động

### Khi ứng dụng khởi động
1. DatabaseHelper tự động tạo bảng `user_stats` nếu chưa có
2. Khởi tạo dữ liệu mặc định (EXP = 0, Streak = 0)

### Khi người dùng hoàn thành bài học
1. Gọi `AddExperienceUseCase`
2. Cập nhật `totalExp` trong database
3. Gọi `updateStreak()` để cập nhật chuỗi ngày
4. Trang Profile sẽ tự động hiển thị dữ liệu mới (do sử dụng FutureBuilder)

---

## 📱 Các file đã tạo/cập nhật

### File mới tạo:
1. `lib/features/vocabulary/data/models/user_stats_model.dart` - Model UserStats
2. `lib/features/vocabulary/data/datasources/user_stats_local_data_source.dart` - DataSource
3. `lib/features/vocabulary/data/repositories/user_stats_repository_impl.dart` - Repository impl
4. `lib/features/vocabulary/domain/repositories/user_stats_repository.dart` - Domain repository
5. `lib/features/vocabulary/domain/usecases/add_experience.dart` - UseCase thêm EXP
6. `lib/features/vocabulary/domain/usecases/get_user_stats.dart` - UseCase lấy thống kê

### File đã cập nhật:
1. `lib/core/db/database_helper.dart` - Thêm hàm tạo bảng user_stats
2. `lib/routes/app_pages.dart` - Thêm dependency injection
3. `lib/features/system/presentation/pages/profile_page.dart` - Cập nhật để lấy dữ liệu thực

---

## 🗄️ Schema Database

```sql
CREATE TABLE user_stats (
  id INTEGER PRIMARY KEY,
  total_exp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  last_study_date TEXT NOT NULL,
  total_words_mastered INTEGER DEFAULT 0,
  total_favorites INTEGER DEFAULT 0
);
```

---

## ⚠️ Lưu ý quan trọng

1. **DatabaseHelper sử dụng Static Methods**: Không cần inject DatabaseHelper, chỉ gọi `DatabaseHelper.database`

2. **Streak Logic**: So sánh ngày dựa trên ngày hôm nay, không xét giờ. Nếu cùng ngày, không tăng streak.

3. **Reset Streak**: Tự động reset thành 0 nếu không học hơn 1 ngày (nhưng vẫn có thể tiếp tục streak nếu học hôm nay)

4. **FutureBuilder**: ProfilePage sử dụng FutureBuilder để hiển thị dữ liệu. Mỗi lần người dùng quay lại trang Profile, dữ liệu sẽ được tải lại từ database.

---

## 🧪 Cách test

1. Mở ứng dụng, vào trang Profile
2. Hoàn thành một bài quizz với các câu trả lời đúng
3. Quay lại trang Profile, xem dữ liệu cập nhật
4. Hoàn thành bài quizz ngày hôm sau để thấy Streak tăng

---

## 🚀 Các tính năng có thể mở rộng

1. **Level System**: Thêm bảng `levels` để xác định cấp độ dựa trên EXP
2. **Achievements/Badges**: Thêm các huy hiệu khi đạt mốc nhất định
3. **Leaderboard**: So sánh EXP giữa các người dùng
4. **Daily Challenges**: Thêm các thách thức hàng ngày để khuyến khích người dùng học
5. **Statistics Chart**: Biểu đồ tiến độ học tập theo ngày/tuần/tháng

