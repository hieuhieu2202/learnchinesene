# ✅ DATABASE LOGGING - In Dữ Liệu Từ Database

## 🔧 Thay đổi vừa thêm

### 1. **updateUserStats()** - Confirm save
```dart
@override
Future<void> updateUserStats(UserStats stats) async {
  // ...save to database
  print('✅ [DATABASE] updateUserStats saved successfully');
}
```

### 2. **updateStreak()** - Print database content
```dart
Future<void> updateStreak() async {
  try {
    final db = await DatabaseHelper.database;  // ⭐ Get DB reference
    // ...logic
    if (difference == 1) {
      // ...update
      _printDatabaseContent(db);  // ⭐ In dữ liệu
    }
  }
}
```

### 3. **_printDatabaseContent()** - Helper method (mới)
```dart
void _printDatabaseContent(Database db) async {
  try {
    print('\n📊 [DATABASE] Dữ liệu sau update:');
    final result = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      final row = result.first;
      print('   ID: ${row['id']}');
      print('   currentStreak: ${row['currentStreak']}');  // ⭐ Check giá trị
      print('   totalExp: ${row['totalExp']}');
      print('   lastStudyDate: ${row['lastStudyDate']}');
      print('   totalWordsMastered: ${row['totalWordsMastered']}');
      print('✅ Database verified!\n');
    }
  } catch (e) {
    print('   ❌ Lỗi khi đọc database: $e\n');
  }
}
```

---

## 📊 Console Log Output (Expected)

```
🔥 [STREAK] Kiểm tra:
   📊 Cách: 1 ngày
   ⬆️ Streak tăng: 0 → 1
   ✅ Streak đã lưu vào database
✅ [DATABASE] updateUserStats saved successfully

📊 [DATABASE] Dữ liệu sau update:
   ID: 1
   currentStreak: 1  ⭐ VERIFY: = 1 không?
   totalExp: 0
   lastStudyDate: 2025-12-08 00:00:00.000
   totalWordsMastered: 0
✅ Database verified!
```

---

## 🧪 Cách test

### Step 1: Xóa database
```bash
adb shell rm /data/data/com.example.chinese_master/databases/chinese.db
```

### Step 2: Khởi động app & Practice
1. Vào Practice
2. Trả lời ≥7 câu đúng
3. Xem console log

### Step 3: Tìm dòng này
```
📊 [DATABASE] Dữ liệu sau update:
   currentStreak: 1
```

---

## ✨ Những dòng cần có

| Dòng | Ý nghĩa |
|-----|---------|
| `✅ [DATABASE] updateUserStats saved successfully` | Dữ liệu được lưu ✅ |
| `📊 [DATABASE] Dữ liệu sau update:` | In dữ liệu từ DB ✅ |
| `currentStreak: 1` | Streak được cập nhật ✅ |
| `✅ Database verified!` | Verify thành công ✅ |

---

## 🔍 Nếu vẫn chưa hiển thị

1. **Không thấy `✅ [DATABASE] updateUserStats`?**
   - → `updateUserStats()` không được gọi
   - → Check `await updateUserStats(newStats)`

2. **Không thấy `📊 [DATABASE]` dữ liệu?**
   - → `_printDatabaseContent(db)` không được gọi
   - → Check `if (difference == 1) { _printDatabaseContent(db); }`

3. **Thấy nhưng currentStreak vẫn = 0?**
   - → Database update thất bại
   - → Check `await db.update(...)`

4. **Lỗi `No database`?**
   - → DatabaseHelper chưa khởi tạo
   - → Check `DatabaseHelper.database`

---

**Bây giờ sẽ thấy rõ dữ liệu từ database! 🔍**

