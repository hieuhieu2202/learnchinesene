# 🐛 STREAK DEBUG GUIDE - Kiểm Tra Từng Bước

## 📝 Các Debug Print đã thêm

### 1. **PracticeSessionController** - Progress Update
```
📝 [PRACTICE] Cập nhật progress:
   Từ ID: [word_id]
   Câu trả lời: ✅ Đúng / ❌ Sai
   correctCount cũ: [old_count]
   correctCount mới: [new_count]
   wrongCount mới: [new_wrong_count]
   Level cũ: [old_level]
   Level mới: [new_level]
```

**Kiểm tra**: correctCount có tăng không? Level có đạt >= 7 không?

### 2. **PracticeSessionController** - Mastery Check
```
🎯 [PRACTICE] Kiểm tra mastery:
   📊 Level cũ: [old]
   📊 Level mới: [new]
   ✨ isMastered: [true/false]
   ✨ wasMastered: [true/false]
   🔥 Sẽ cập nhật streak? [true/false]
```

**Kiểm tra**: `isMastered && !wasMastered` = true không?

### 3. **UserStatsLocalDataSource** - Streak Update
```
🔥 [STREAK] Kiểm tra:
   📅 Hôm nay: [date]
   📅 Lần cuối: [date]
   📊 Cách: [days] ngày
   🔥 Streak hiện tại: [count]
   ⬆️ Streak tăng: [old] → [new]
   ✅ Streak đã lưu vào database
```

**Kiểm tra**: `difference == 0` hay `difference == 1`?

### 4. **ProfilePage** - Refresh Stats
```
🔄 [PROFILE] _refreshStats() được gọi
👁️ [PROFILE] didPopNext - Quay lại từ trang khác → Refresh streak
📊 [PROFILE] Dữ liệu từ database:
   💰 totalExp: [value]
   🔥 currentStreak: [value]
   📖 totalWordsMastered: [value]
   📅 lastStudyDate: [date]
```

**Kiểm tra**: currentStreak value có đúng không?

---

## 🧪 Cách Test & Debug

### Step 1: Xóa Database
```bash
adb shell rm /data/data/com.example.learnchinese/databases/chinese.db
# Hoặc uninstall + reinstall app
```

### Step 2: Khởi động App
- Xem console log không lỗi

### Step 3: Vào Profile
Console log sẽ hiển thị:
```
🔄 [PROFILE] _refreshStats() được gọi
📊 [PROFILE] Dữ liệu từ database:
   💰 totalExp: 0
   🔥 currentStreak: 0
   📖 totalWordsMastered: 0
   📅 lastStudyDate: [hôm qua]  ⭐ (initialization)
```

**✅ Kiểm tra**: lastStudyDate = hôm qua OK?

### Step 4: Vào Practice & Luyện Tập
Trả lời **ít nhất 7 câu đúng**:

Console log sẽ hiển thị:
```
📝 [PRACTICE] Cập nhật progress:
   Từ ID: [id]
   Câu trả lời: ✅ Đúng
   correctCount cũ: 0
   correctCount mới: 7
   Level cũ: 0
   Level mới: 5

🎯 [PRACTICE] Kiểm tra mastery:
   ✨ isMastered: true
   ✨ wasMastered: false
   🔥 Sẽ cập nhật streak? true

🔥 [PRACTICE] Từ vừa được mastered, cập nhật streak...
🔥 [STREAK] Kiểm tra:
   📊 Cách: 1 ngày
   ⬆️ Streak tăng: 0 → 1
   ✅ Streak đã lưu vào database
🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật
```

**✅ Kiểm tra**: Mỗi dòng có hay không?

### Step 5: Back về Profile
Console log sẽ hiển thị:
```
👁️ [PROFILE] didPopNext - Quay lại từ trang khác → Refresh streak
🔄 [PROFILE] _refreshStats() được gọi
📊 [PROFILE] Dữ liệu từ database:
   💰 totalExp: 7
   🔥 currentStreak: 1  ⭐ (từ 0 → 1)
   📖 totalWordsMastered: 1
   📅 lastStudyDate: [hôm nay]
```

**✅ Kiểm tra**: currentStreak = 1 không?

---

## 🔍 Nếu vẫn không cập nhật

### Kiểm tra danh sách (theo thứ tự):

1. **Step 4 Console log có `isMastered: true && wasMastered: false`?**
   - ❌ Không → Level không đạt 7 (check correctCount)
   - ✅ Có → Tiếp Step 2

2. **Có dòng `🔥 [STREAK]...` không?**
   - ❌ Không → `_updateStreakOnWordMastered()` không được gọi (kiểm tra await)
   - ✅ Có → Tiếp Step 3

3. **Dòng `⬆️ Streak tăng` có không? Value là bao nhiêu?**
   - ❌ Chỉ thấy "Đã học hôm nay → Không cập nhật" → `difference == 0` (bug!)
   - ✅ Thấy tăng → Tiếp Step 4

4. **Step 5 currentStreak value đúng không?**
   - ❌ Vẫn 0 → Database chưa save (kiểm tra `updateUserStats()`)
   - ✅ = 1 → Success!

---

## 📊 Nếu difference == 0 (Bug!)

### Nguyên nhân:
```
lastStudyDate = hôm nay
todayDate = hôm nay
difference = 0 ngày
```

### Giải pháp:
- Check `getUserStats()` initialization → lastStudyDate phải = hôm qua
- Check khi cập nhật streak, `lastStudyDate` được set = hôm nay không?

---

## 📌 Console Log Reference

| Log | Ý nghĩa |
|-----|---------|
| `📝 [PRACTICE]` | Cập nhật progress |
| `🎯 [PRACTICE] isMastered: true` | Từ vừa mastered |
| `🔥 [STREAK] Kiểm tra` | Streak logic chạy |
| `⬆️ Streak tăng` | Cập nhật thành công |
| `❌ Sai` | Lỗi xảy ra |

---

**Test từng bước và xem log để tìm nguyên nhân! 🔍**

