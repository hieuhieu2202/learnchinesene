# ✅ STREAK DEBUG CHECKLIST

## 🎯 Test từng bước theo thứ tự

### ✅ Step 1: Chuẩn bị
- [ ] Xóa app cache hoặc uninstall + reinstall
- [ ] Xóa database

### ✅ Step 2: Khởi động App
- [ ] App khởi động không lỗi
- [ ] Không có red error screen

### ✅ Step 3: Vào Profile - Kiểm tra Log
```
Tìm dòng:
📊 [PROFILE] Dữ liệu từ database:
   🔥 currentStreak: 0
   📅 lastStudyDate: [hôm qua]  ⭐ PHẢI LÀ HÔM QUA!
```

- [ ] currentStreak = 0
- [ ] lastStudyDate = hôm qua (NOT hôm nay!)

**❌ Nếu lastStudyDate = hôm nay → LỖI INITIALIZATION**

---

### ✅ Step 4: Vào Practice - Luyện Tập

**Chọn 1 từ, trả lời ≥7 câu đúng:**

Console log sẽ hiển thị:
```
📝 [PRACTICE] Cập nhật progress:
   correctCount cũ: 0
   correctCount mới: 7  ⭐ PHẢI ≥7
   Level mới: 5  ⭐ PHẢI ≥5

🎯 [PRACTICE] Kiểm tra mastery:
   ✨ isMastered: true  ⭐ PHẢI true
   ✨ wasMastered: false  ⭐ PHẢI false
   🔥 Sẽ cập nhật streak? true  ⭐ PHẢI true
```

Kiểm tra:
- [ ] isMastered = true
- [ ] wasMastered = false
- [ ] "Sẽ cập nhật streak? true"

**❌ Nếu không thấy, hãy check:**
- Có trả lời ≥7 câu đúng không?
- Level có đạt 5 không?
- Word có phải mastered lần đầu không?

---

### ✅ Step 5: Tiếp tục - Kiểm tra Streak Update Log

```
🔥 [PRACTICE] Từ vừa được mastered, cập nhật streak...
🔥 [STREAK] Kiểm tra:
   📊 Cách: 1 ngày  ⭐ PHẢI 1 NGÀY
   🔥 Streak hiện tại: 0
   ⬆️ Streak tăng: 0 → 1  ⭐ CẬP NHẬT THÀNH CÔNG
   ✅ Streak đã lưu vào database
```

Kiểm tra:
- [ ] "Cách: 1 ngày"
- [ ] "⬆️ Streak tăng: 0 → 1"
- [ ] "✅ Streak đã lưu vào database"

**❌ Nếu thấy "Đã học hôm nay → Không cập nhật":**
- → Vấn đề: `difference == 0`
- → Kiểm tra lại Step 3: lastStudyDate phải là hôm qua!

---

### ✅ Step 6: Back Profile - UI Update

```
👁️ [PROFILE] didPopNext
🔄 [PROFILE] _refreshStats()
📊 [PROFILE] Dữ liệu từ database:
   🔥 currentStreak: 1  ⭐ CẬP NHẬT TỪ 0 → 1
```

Kiểm tra:
- [ ] didPopNext trigger
- [ ] currentStreak = 1

**Kiểm tra UI:**
- [ ] "Chuỗi ngày học" hiển thị: **1 ngày** (NOT 0 ngày!)

---

## 🚨 Troubleshooting

### ❌ currentStreak vẫn = 0 dù log hiển thị "Streak tăng 0 → 1"

**Nguyên nhân**: Database chưa save

**Giải pháp**:
```bash
# Check database
adb shell
sqlite3 /data/data/com.example.learnchinese/databases/chinese.db
SELECT currentStreak, lastStudyDate FROM user_stats;
```

### ❌ didPopNext không trigger

**Nguyên nhân**: RouteObserver không hoạt động

**Giải pháp**:
```dart
// main.dart
// Kiểm tra onReady() có run không
print('onReady() called - RouteObserver registered');
```

### ❌ "Đã học hôm nay → Không cập nhật"

**Nguyên nhân**: lastStudyDate = hôm nay, difference = 0

**Giải pháp**:
- Xóa database
- Check initialization: lastStudyDate phải set = hôm qua

---

## 📸 Expected Console Log (Success Case)

```
// Step 3: Vào Profile
🔄 [PROFILE] _refreshStats() được gọi
📊 [PROFILE] Dữ liệu từ database:
   💰 totalExp: 0
   🔥 currentStreak: 0
   📖 totalWordsMastered: 0
   📅 lastStudyDate: 2025-12-07 00:00:00.000

// Step 4-5: Luyện tập & cập nhật
📝 [PRACTICE] Cập nhật progress:
   Từ ID: 1
   Câu trả lời: ✅ Đúng
   correctCount cũ: 0
   correctCount mới: 7
   wrongCount mới: 3
   Level cũ: 0
   Level mới: 5
🎯 [PRACTICE] Kiểm tra mastery:
   ✨ isMastered: true
   ✨ wasMastered: false
   🔥 Sẽ cập nhật streak? true
🔥 [PRACTICE] Từ vừa được mastered, cập nhật streak...
🔥 [STREAK] Kiểm tra:
   📅 Hôm nay: 2025-12-08 00:00:00.000
   📅 Lần cuối: 2025-12-07 00:00:00.000
   📊 Cách: 1 ngày
   🔥 Streak hiện tại: 0
   ⬆️ Streak tăng: 0 → 1
   ✅ Streak đã lưu vào database
🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật

// Step 6: Back Profile
👁️ [PROFILE] didPopNext - Quay lại từ trang khác → Refresh streak
🔄 [PROFILE] _refreshStats() được gọi
📊 [PROFILE] Dữ liệu từ database:
   💰 totalExp: 7
   🔥 currentStreak: 1  ✅ UPDATED!
   📖 totalWordsMastered: 1
   📅 lastStudyDate: 2025-12-08 00:00:00.000

// UI sẽ hiển thị:
Chuỗi ngày học: 1 ngày ✅
```

---

**Chạy test này và báo lại dòng nào không xuất hiện! 🔍**

