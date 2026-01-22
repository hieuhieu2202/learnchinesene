# 🔄 Git Commit Message Template

## Commit Title
```
feat: Thêm tính năng Kinh nghiệm & Chuỗi ngày học
```

## Commit Description
```
Triển khai hệ thống kinh nghiệm (EXP) và chuỗi ngày học (Learning Streak) cho ứng dụng Learn Chinese.

Features:
- Tính EXP tự động: 10 EXP/câu đúng + 50 EXP khi hoàn thành bài
- Chuỗi ngày học: Tăng khi học liên tiếp, reset nếu cách quá 1 ngày
- Hiển thị thống kê trên trang Profile với dữ liệu thực từ database

Technical Changes:
- Tạo bảng `user_stats` trong SQLite database
- Triển khai Clean Architecture: models → datasources → repositories → usecases
- Dependency Injection qua GetX
- FutureBuilder cho async data loading

Files Created (6):
- lib/features/vocabulary/data/models/user_stats_model.dart
- lib/features/vocabulary/data/datasources/user_stats_local_data_source.dart
- lib/features/vocabulary/data/repositories/user_stats_repository_impl.dart
- lib/features/vocabulary/domain/repositories/user_stats_repository.dart
- lib/features/vocabulary/domain/usecases/add_experience.dart
- lib/features/vocabulary/domain/usecases/get_user_stats.dart

Files Updated (4):
- lib/core/db/database_helper.dart
- lib/routes/app_pages.dart
- lib/features/system/presentation/pages/profile_page.dart
- lib/features/vocabulary/presentation/controllers/practice_session_controller.dart

Breaking Changes: None
Backward Compatibility: Full
Dependencies: No new external dependencies

Testing:
- Manual test scenarios provided in TEST_GUIDE.md
- 4 test cases covering all features
- No unit tests yet (ready for implementation)

Documentation:
- SUMMARY.md - Quick overview
- IMPLEMENTATION_GUIDE.md - Usage & extension
- TEST_GUIDE.md - Test scenarios
- FILES_MANIFEST.md - Complete file listing
- FINAL_VERIFICATION.md - Verification report

Code Quality:
- Flutter analyze: 0 errors ✅
- No deprecated APIs used
- Proper error handling
- Type-safe code
- Null safety compliant

```

## Alternative (Concise)
```
feat: Implement Experience & Learning Streak system

- Add user_stats table to SQLite database
- Calculate EXP: 10 per correct answer + 50 on lesson completion
- Track learning streak with auto-reset on 2+ day gap
- Update ProfilePage to display real-time statistics
- Full Clean Architecture implementation
- No breaking changes, fully backward compatible
```

---

## Branch Name
```
feature/experience-and-streak-system
```

## Related Issues
```
Closes #[issue-number]
Fixes #[bug-number]
```

## Reviewer Notes
```
This PR implements the Experience and Learning Streak system with:
- Full clean architecture following domain-driven design
- Automatic EXP calculation on practice session completion
- Smart streak logic that compares only dates, not times
- Zero breaking changes to existing functionality

Please review:
1. Database schema and initialization logic
2. EXP calculation formula (10 per answer + 50 bonus)
3. Streak reset logic
4. UI updates in ProfilePage
5. Dependency injection configuration

The implementation is production-ready with no compilation errors.
```

---

## Pre-Commit Checklist
```bash
# Run before committing
flutter clean
flutter pub get
flutter analyze  # Should show 0 errors
flutter format .
git diff  # Review changes
```

## Push Commands
```bash
# After committing
git push origin feature/experience-and-streak-system

# Create Pull Request on GitHub/GitLab with:
- Title: "feat: Add Experience & Learning Streak system"
- Description: (use the template above)
- Reviewers: @team
- Labels: feature, database, ui, documentation
```

---

**Author**: AI Assistant  
**Date**: December 8, 2025  
**Status**: Ready for commit ✅

