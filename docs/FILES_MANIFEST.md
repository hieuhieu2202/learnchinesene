# 📋 Danh sách File Được Thêm/Sửa

## 🆕 FILE MỚI TẠOFILE (6 file)

### Data Layer
```
lib/features/vocabulary/data/
├── datasources/
│   └── user_stats_local_data_source.dart
│       - UserStatsLocalDataSource (interface)
│       - UserStatsLocalDataSourceImpl (implementation)
│       - Kết nối trực tiếp với DatabaseHelper
│
├── models/
│   └── user_stats_model.dart
│       - UserStats model
│       - toMap() / fromMap() cho SQLite
│       - copyWith() để immutability
│
└── repositories/
    └── user_stats_repository_impl.dart
        - UserStatsRepositoryImpl
        - Implement domain UserStatsRepository
        - Delegate tới UserStatsLocalDataSource
```

### Domain Layer
```
lib/features/vocabulary/domain/
├── repositories/
│   └── user_stats_repository.dart
│       - UserStatsRepository (abstract interface)
│       - Các method: getUserStats, addExp, updateStreak, etc.
│
└── usecases/
    ├── add_experience.dart
    │   - AddExperienceUseCase
    │   - Tính: 10 EXP/câu đúng + 50 bonus hoàn thành
    │   - Gọi updateStreak() tự động
    │
    └── get_user_stats.dart
        - GetUserStatsUseCase
        - Lấy dữ liệu UserStats từ repository
        - Dùng trong ProfilePage
```

---

## 🔄 FILE ĐƯỢC CẬP NHẬT (4 file)

### 1. lib/core/db/database_helper.dart
```dart
// Thêm hàm mới:
- _createUserStatsTable(Database db)
  • Tạo bảng user_stats nếu chưa có
  • Chèn dữ liệu mặc định (EXP=0, Streak=0)
  
// Sửa hàm:
- _initDB() 
  • Gọi _createUserStatsTable() sau khi mở database
```

### 2. lib/routes/app_pages.dart
```dart
// Thêm imports:
- import user_stats_local_data_source.dart
- import user_stats_repository_impl.dart
- import user_stats_repository.dart
- import add_experience.dart
- import get_user_stats.dart
- import word_repository.dart

// Thêm dependency injection trong AppBindings:
- Get.lazyPut<UserStatsLocalDataSource>()
- Get.lazyPut<UserStatsRepository>()
- Get.lazyPut<GetUserStatsUseCase>()
- Get.lazyPut<AddExperienceUseCase>()

// Cập nhật PracticeSessionController binding:
- Thêm addExperienceUseCase parameter
```

### 3. lib/features/vocabulary/presentation/controllers/practice_session_controller.dart
```dart
// Thêm import:
- import add_experience.dart

// Thêm property:
- final AddExperienceUseCase addExperienceUseCase

// Thêm parameter:
- required this.addExperienceUseCase,

// Thêm phương thức:
- Future<void> _updateExperienceOnFinish()
  • Tính tổng EXP dựa trên score.value
  • Gọi addExperienceUseCase
  • Tự động cập nhật streak

// Sửa phương thức:
- _autoCloseAfterFinish()
  • Gọi _updateExperienceOnFinish() trước khi pop
```

### 4. lib/features/system/presentation/pages/profile_page.dart
```dart
// Từ StatelessWidget → StatefulWidget

// Thêm imports:
- import user_stats_model.dart
- import get_user_stats.dart

// Thêm property:
- late GetUserStatsUseCase _getUserStats

// Thêm initState():
- Gọi Get.find<GetUserStatsUseCase>()

// Sửa build():
- Từ hardcode dữ liệu
- → FutureBuilder<UserStats>
- → Lấy dữ liệu thực từ database

// Cập nhật UI:
- Hiển thị EXP thực
- Hiển thị Streak thực
- Hiển thị Words Mastered thực
- Hiển thị Favorites thực
```

---

## 📊 Database Schema

```sql
CREATE TABLE user_stats (
  id INTEGER PRIMARY KEY,
  total_exp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  last_study_date TEXT NOT NULL,
  total_words_mastered INTEGER DEFAULT 0,
  total_favorites INTEGER DEFAULT 0
);

-- Dữ liệu mặc định:
INSERT INTO user_stats VALUES (
  1,
  0,
  0,
  datetime('now'),
  0,
  0
);
```

---

## 🔗 Dependency Tree

```
ProfilePage
    ↓
GetUserStatsUseCase
    ↓
UserStatsRepository (domain)
    ↓
UserStatsRepositoryImpl
    ↓
UserStatsLocalDataSourceImpl
    ↓
DatabaseHelper.database
    ↓
user_stats table

PracticeSessionController
    ↓
AddExperienceUseCase
    ↓
UserStatsRepository (domain)
    ↓
UserStatsRepositoryImpl
    ↓
UserStatsLocalDataSourceImpl → addExp()
                            → updateStreak()
    ↓
user_stats table
```

---

## 💾 Data Flow

### EXP Flow:
```
1. PracticeSessionPage hoàn thành
   ↓
2. _autoCloseAfterFinish() được gọi
   ↓
3. _updateExperienceOnFinish() được gọi
   ↓
4. AddExperienceUseCase(correctAnswers, lessonCompleted)
   ↓
5. Tính EXP = correctAnswers * 10 + (lessonCompleted ? 50 : 0)
   ↓
6. UserStatsRepository.addExp(exp)
   ↓
7. UserStatsRepositoryImpl.addExp(exp)
   ↓
8. UserStatsLocalDataSourceImpl.addExp(exp)
   ↓
9. UPDATE user_stats SET total_exp = total_exp + ?
   ↓
10. UserStatsRepository.updateStreak()
    ↓
11. Kiểm tra ngày hôm nay vs last_study_date
    ↓
12. UPDATE user_stats SET current_streak = ?, last_study_date = ?
```

### Profile Display Flow:
```
1. ProfilePage initState()
   ↓
2. Get.find<GetUserStatsUseCase>()
   ↓
3. FutureBuilder<UserStats>
   ↓
4. GetUserStatsUseCase()
   ↓
5. UserStatsRepository.getUserStats()
   ↓
6. UserStatsRepositoryImpl.getUserStats()
   ↓
7. UserStatsLocalDataSourceImpl.getUserStats()
   ↓
8. SELECT * FROM user_stats WHERE id = 1
   ↓
9. UserStats.fromMap(result)
   ↓
10. UI hiển thị totalExp, currentStreak, etc.
```

---

## 🧪 Test Cases

### Test 1: EXP được tính
```
Given: Hoàn thành bài với 5 câu đúng
When: Gọi AddExperienceUseCase(5, true)
Then: EXP = 5*10 + 50 = 100
```

### Test 2: Streak tăng
```
Given: Ngày 1: streak = 1, last_study_date = 2024-12-08
When: Ngày 2 hoàn thành bài
Then: streak = 2, last_study_date = 2024-12-09
```

### Test 3: Streak reset
```
Given: Ngày 1-8: streak = 8, last_study_date = 2024-12-08
When: Ngày 10 hoàn thành bài (cách 2 ngày)
Then: streak = 1, last_study_date = 2024-12-10
```

---

## 📈 Các tính năng có thể mở rộng

1. **Level System** (5 levels)
   - Level 1: 0-500 EXP
   - Level 2: 500-1500 EXP
   - ...

2. **Achievements**
   - First 100 EXP
   - Streak of 7 days
   - Master 50 words

3. **Leaderboard**
   - Top EXP users
   - Top Streak users

4. **Daily Challenges**
   - Complete 10 exercises today
   - Maintain streak for 30 days

5. **Statistics**
   - EXP chart (by day/week/month)
   - Streak history
   - Words learned timeline

---

## ✅ Checklist đã hoàn thành

- [x] Tạo UserStats model
- [x] Tạo UserStatsLocalDataSource
- [x] Tạo UserStatsRepository implementation
- [x] Tạo AddExperienceUseCase
- [x] Tạo GetUserStatsUseCase
- [x] Cập nhật DatabaseHelper
- [x] Tích hợp vào PracticeSessionController
- [x] Cập nhật ProfilePage
- [x] Thêm dependency injection
- [x] Sửa tất cả lỗi
- [x] Kiểm tra flutter analyze (clean)
- [x] Tạo documentation

---

**Last Updated**: December 8, 2025
**Status**: ✅ COMPLETE

