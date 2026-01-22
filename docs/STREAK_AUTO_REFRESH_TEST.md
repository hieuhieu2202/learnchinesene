# ✅ STREAK AUTO-REFRESH - Cách Test

## 🔧 Thay đổi đã thực hiện

### ProfilePage - Auto Refresh
Thêm `WidgetsBindingObserver` để tự động refresh dữ liệu khi user quay lại trang Profile:

```dart
class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);  // ⭐ Listen lifecycle
    // ...
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {  // ⭐ Khi trang focus
      print('👁️ [PROFILE] Trang được focus → Refresh streak');
      _refreshStats();  // ⭐ Refresh từ database
    }
  }
}
```

---

## 🧪 Cách test Streak Update

### Step 1: Xóa Database (nếu cần)
```bash
# Xóa database để reset
adb shell rm /data/data/com.example.learnchinese/databases/chinese.db
```

Hoặc đơn giản hơn: **Xóa app rồi cài lại**

### Step 2: Mở app lần đầu
- App tải dữ liệu user_stats
- `lastStudyDate = hôm qua` (initialization)
- `currentStreak = 0`

### Step 3: Vào Profile (kiểm tra streak)
```
Chuỗi ngày học: 0 ngày
```

### Step 4: Vào Practice & hoàn thành 1 từ
1. Chọn 1 từ vựng bất kỳ
2. Luyện tập: Trả lời đúng **ít nhất 12 câu** để level → 5 (mastered)
3. Console log sẽ show:
   ```
   🎯 [PRACTICE] Kiểm tra mastery:
      ✨ isMastered: true
      ✨ wasMastered: false
      🔥 Sẽ cập nhật streak? true
   🔥 [PRACTICE] Từ vừa được mastered, cập nhật streak...
   🔥 [STREAK] Kiểm tra: ... ⬆️ Streak tăng → 1
   🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật
   ```

### Step 5: Quay lại Profile
- **Trang sẽ tự động refresh** khi bạn back/return
- Console log:
  ```
  👁️ [PROFILE] Trang được focus → Refresh streak
  🔄 Đang tải lại dữ liệu thống kê...
  ```
- ✅ **Chuỗi ngày học sẽ hiển thị: 1 ngày**

### Step 6: Hoàn thành từ khác hôm sau
1. Chờ đến ngày hôm sau (hoặc thay đổi system date nếu test)
2. Hoàn thành từ khác
3. Quay lại Profile
4. ✅ **Chuỗi ngày học: 2 ngày**

---

## 🔍 Debug Tips

### Kiểm tra Console Log
```
[PRACTICE]  - Log từ practice controller
[STREAK]    - Log từ streak update
[PROFILE]   - Log từ profile page
```

### Kiểm tra Database
```bash
adb shell
sqlite3 /data/data/com.example.learnchinese/databases/chinese.db

# Lệnh query
SELECT currentStreak, lastStudyDate FROM user_stats WHERE id = 1;
SELECT wordId, level, mastered FROM progress WHERE wordId = [word_id];
```

### Nếu vẫn không cập nhật
1. **Kiểm tra console log** có error không?
2. **Xóa app cache**: Settings → Apps → Learn Chinese → Storage → Clear Cache
3. **Xóa app + database**: Uninstall → Reinstall
4. **Check android logs**: `flutter logs` hoặc `adb logcat`

---

## 📊 Expected Behavior

| Sự kiện | Kết quả |
|--------|--------|
| Lần đầu hoàn thành từ | Streak: 0 → 1 ✅ |
| Hoàn thành từ lần 2 (cùng từ) | Streak: 1 (không thay đổi) |
| Hoàn thành từ khác hôm sau | Streak: 1 → 2 ✅ |
| Quay lại Profile | Auto-refresh ✅ |
| Bấm nút Refresh | Manual-refresh ✅ |

---

## ✨ Các tính năng được thêm

✅ **Auto-refresh**: Khi app resume → tự động load dữ liệu mới  
✅ **Manual-refresh**: Nút refresh ở AppBar để tự refresh  
✅ **Lifecycle tracking**: Listen app lifecycle để detect khi user quay lại  
✅ **Debug print**: Console log chi tiết từng bước  

**Giờ streak sẽ hiển thị đúng trong Profile! 🔥**

