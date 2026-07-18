# Feature Parity Checklist: Web Demo vs. Flutter App

This document details the feature audit and parity checklist between the React Web Demo and the Flutter mobile app.

---

## Parity Statistics

- **Total Screens/Views in Web Demo**: 13
- **Total Interactive Features**: 24
- **Fully Equivalent in Flutter**: 13
- **Partial/Missing Logic**: 0
- **Completely Missing**: 0 (Dictionary Lookup, Flashcard Deck, Gemini HSK-Level Quick Quiz have all been fully implemented!)
- **Required Redesign**: Navigation Bar (fully expanded to 5 tabs layout)

---

## Parity Matrix Table

| STT | Module | Chức năng web demo | Route/file nguồn | Flutter đã có? | File Flutter | Mức hoàn thiện | Hành động |
|---|---|---|---|---|---|---|---|
| 1 | Splash | Màn hình khởi đầu | `SplashScreen.tsx` | Có | `splash_page.dart` | 100% | Giữ |
| 2 | Home | Trang chủ & Dashboard | `Sidebar.tsx`, `App.tsx` | Có | `home_screen.dart` | 100% | Đã hoàn thành 5 tabs |
| 3 | Translator | Dịch thuật & Quét ảnh AI | `Translator.tsx` | Có | `translator_screen.dart` | 100% | Giữ |
| 4 | Dictionary | Tra từ Việt ↔ Trung bằng AI | `Dictionary.tsx` | Có | `dictionary_screen.dart` | 100% | Đã tạo mới |
| 5 | Vocabulary | Học từ vựng theo HSK | `Vocabulary.tsx` | Có | `hsk_screen.dart`, `section_list_page.dart`, `word_list_page.dart` | 100% | Giữ |
| 6 | Conversations| Hội thoại tình huống AI | `Conversations.tsx` | Có | `conversations_screen.dart` | 100% | Giữ |
| 7 | Lessons | Bài học chuyên đề AI | `Lessons.tsx` | Có | `lessons_screen.dart` | 100% | Giữ |
| 8 | Writing | Luyện viết chữ Hán | `WritingPractice.tsx` | Có | `hanzi_writing_home_screen.dart`, `hanzi_writing_screen.dart` | 100% | Giữ |
| 9 | Flashcards | Ôn tập Flashcard lật thẻ | `Flashcards.tsx` | Có | `flashcards_screen.dart` | 100% | Đã tạo mới với hiệu ứng 3D & SRS |
| 10 | Quiz | Trắc nghiệm từ vựng HSK | `Quiz.tsx` | Có | `hsk_quiz_screen.dart` | 100% | Đã tạo mới |
| 11 | HskExam | Thi thử HSK với AI | `HskExam.tsx` | Có | `hsk_exam_screen.dart` | 100% | Giữ |
| 12 | Pronounce | Luyện phát âm | `Pronunciation.tsx` | Có | `speaking_screen.dart` | 100% | Giữ |
| 13 | History | Lịch sử & Phân tích | `History.tsx` | Có | `history_screen.dart` | 100% | Giữ |
| 14 | Settings | Cài đặt & Thống kê | `Settings.tsx`, `UsageStats.tsx` | Có | `settings_page.dart` | 100% | Đã hoàn thành đồng bộ |

---

## Detailed Parity Tasks Checklist

### 1. Navigation redesign (Mức độ ưu tiên: Cao)
- [x] Mở rộng Bottom Navigation Bar thành 5 tab:
  1. **Trang chủ**: Dashboard hiển thị streak, tiến độ ngày, bảng tin, các nút truy cập nhanh.
  2. **Học tập**: Tích hợp chọn cấp độ HSK (`HskScreen`), các bài học chuyên đề AI (`LessonsScreen`), hội thoại tình huống AI (`ConversationsScreen`).
  3. **Luyện tập**: Gồm Luyện phát âm (`SpeakingScreen`), Luyện viết chữ (`HanziWritingHomeScreen`), Ôn tập Flashcard, và Trắc nghiệm nhanh HSK.
  4. **Tiến độ**: Thống kê chi tiết (`StatsScreen`), Lịch sử & Phân tích (`HistoryScreen`), Thi thử HSK (`HskExamScreen`).
  5. **Cá nhân**: Profile (`ProfilePage`), Cài đặt (`SettingsPage`), Tra cứu từ điển Việt-Trung bằng AI.

### 2. Từ điển Việt ↔ Trung bằng AI (Dictionary)
- [x] Viết hàm `fetchDictionaryEntry` gọi API Gemini trong `GeminiService` (sử dụng schema JSON trả về chi tiết Hanzi, Pinyin, nghĩa tiếng Việt, ví dụ đặt câu & ghi chú ngữ pháp).
- [x] Xây dựng giao diện tra cứu từ điển `DictionaryScreen` hỗ trợ nhập liệu, tìm kiếm bằng giọng nói (Voice Recognition), phát âm TTS, và lịch sử tra cứu.

### 3. Ôn tập Flashcard lật thẻ (Spaced Repetition Flashcards)
- [x] Triển khai thuật toán Spaced Repetition (SRS) lưu trữ trạng thái thẻ ôn tập (Khó - Vừa - Dễ) bằng local database/localStorage tương tự web.
- [x] Thiết kế hiệu ứng lật thẻ 3D xoay vòng mượt mà (`rotateY` dùng Flutter `Transform` hoặc package tương đương).

### 4. Trắc nghiệm từ vựng HSK bằng AI (Quick HSK Quiz)
- [x] Thiết kế tính năng chọn HSK level (1-6) để tạo bài thi trắc nghiệm.
- [x] Gọi Gemini lấy danh sách 100 từ vựng và sinh 10 câu hỏi đa dạng (nghĩa, hanzi, pinyin) cùng các phương án gây nhiễu tự động.
- [x] Hiển thị gợi ý ôn tập cho các câu trả lời sai sau khi hoàn thành.

### 5. Đồng bộ hóa Cài đặt & Thống kê hoạt động (Settings & Stats)
- [x] Đồng bộ hóa cấu hình tốc độ giọng đọc (Speech Rate) và lưu lịch sử tương tác AI chi tiết.
- [x] Vẽ biểu đồ hình cột phân phối tần suất sử dụng các chức năng AI (Dịch thuật, Từ điển, Hội thoại, Thi cử).
