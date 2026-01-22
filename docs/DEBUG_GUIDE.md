# 🔍 DEBUG GUIDE - Kiểm tra logic Kinh nghiệm & Chuỗi ngày học

## 📝 LỐI ĐÃ SỬA

### 1. ✅ ProfilePage
- ✅ Thêm nút **Refresh** (⟲) ở góc trên
- ✅ `_refreshStats()` sẽ tải lại dữ liệu mỗi lần bấm
- ✅ Hiển thị "Đang tải..." khi fetch dữ liệu

### 2. ✅ PracticeSessionController
- ✅ Thêm chi tiết logging trong `_updateExperienceAndStreak()`
- ✅ In ra console: EXP tính được, câu đúng/tổng, etc.
- ✅ Gọi `addExperienceUseCase` chỉ khi `correctCount > 0`

### 3. ✅ UserStatsLocalDataSource
- ✅ Thêm logging khi cập nhật EXP
- ✅ Thêm logging khi kiểm tra/cập nhật Streak
- ✅ In ra: EXP cũ → mới, Streak logic, ngày học

---

## 🔍 CÁC BƯỚC DEBUG

### Bước 1: Xem Logs khi Hoàn thành bài

Khi hoàn thành bài tập, mở **Flutter DevTools** hoặc **logcat** và tìm dòng log:

```
✅ HOÀN THÀNH BÀI:
   📊 Câu đúng: [N]/[Total]
   ⭐ EXP tính được: [X] ([N]*10 + 50)
   ✅ EXP đã lưu vào database
   ✅ Streak đã cập nhật
```

**Nếu không thấy log này** → Có vấn đề ở:
- AddExperienceUseCase không được inject
- _autoCloseAfterFinish() không được gọi
- Function bị catch exception

---

### Bước 2: Xem Logs Database

Tiếp theo, bạn sẽ thấy:

```
💾 [DATABASE] Cập nhật EXP:
   📊 EXP cũ: [old]
   ➕ Thêm: [exp]
   ✅ EXP mới: [new]
```

**Nếu thấy log này** → Database đang cập nhật ✅

```
🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: [today]
   📅 Ngày học cuối: [last]
   📊 Chênh lệch: [N] ngày
   🔥 Streak hiện tại: [current]
   [⬆️ Tiếp tục / 🔄 Reset / ✅ Không thay đổi]
```

**Nếu thấy log này** → Streak logic đang chạy ✅

---

### Bước 3: Kiểm tra Profile

1. **Hoàn thành bài tập** → Xem logs ở bước 1 & 2
2. **Quay lại Profile**
3. **Bấm nút Refresh** (⟲) ở góc trên phải
4. **Kiểm tra EXP & Streak có tăng không**

---

## ⚠️ NẾUKHÔNG CÓ THAY ĐỔI

### Trường hợp 1: Logs không hiển thị
**Nguyên nhân**: `_autoCloseAfterFinish()` không được gọi

**Cách sửa**: Kiểm tra `_moveNext()` line 428-445
- Có gọi `_autoCloseAfterFinish()` không?
- `isFinished.value = true` trước `_autoCloseAfterFinish()` không?

### Trường hợp 2: Logs hiển thị nhưng database không update
**Nguyên nhân**: Exception trong `addExp()` hoặc `updateStreak()`

**Cách sửa**: Xem logs console chi tiết
- Có dòng `❌ [DATABASE]` không?
- Exception là gì? (Có thể DB lock, constraint, etc.)

### Trường hợp 3: Database update nhưng Profile không hiển thị mới
**Nguyên nhân**: Profile chưa refresh

**Cách sửa**:
1. **Bấm nút Refresh** ở Profile (⟲)
2. Hoặc: Exit → Re-enter Profile

### Trường hợp 4: Nút Refresh không làm gì
**Nguyên nhân**: `_refreshStats()` có lỗi

**Cách debug**:
```dart
void _refreshStats() {
  print('🔄 Bấm refresh');  // Thêm dòng này
  setState(() {
    _userStatsFuture = _getUserStats();
  });
}
```

---

## 📊 EXPECTED LOGS

### Lần hoàn thành đầu tiên

```
✅ HOÀN THÀNH BÀI:
   📊 Câu đúng: 5/10
   ⭐ EXP tính được: 100 (5*10 + 50)
   ✅ EXP đã lưu vào database
   ✅ Streak đã cập nhật

💾 [DATABASE] Cập nhật EXP:
   📊 EXP cũ: 0
   ➕ Thêm: 100
   ✅ EXP mới: 100

🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: 2024-12-08
   📅 Ngày học cuối: 2024-12-08
   📊 Chênh lệch: 0 ngày
   🔥 Streak hiện tại: 0
   ✅ Đã học hôm nay rồi - Không cập nhật streak
```

### Lần hoàn thành thứ hai (cùng ngày)

```
✅ HOÀN THÀNH BÀI:
   📊 Câu đúng: 3/10
   ⭐ EXP tính được: 80 (3*10 + 50)
   ✅ EXP đã lưu vào database
   ✅ Streak đã cập nhật

💾 [DATABASE] Cập nhật EXP:
   📊 EXP cũ: 100
   ➕ Thêm: 80
   ✅ EXP mới: 180

🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: 2024-12-08
   📅 Ngày học cuối: 2024-12-08
   📊 Chênh lệch: 0 ngày
   🔥 Streak hiện tại: 0
   ✅ Đã học hôm nay rồi - Không cập nhật streak
```

### Lần hoàn thành ngày hôm sau

```
✅ HOÀN THÀNH BÀI:
   📊 Câu đúng: 4/10
   ⭐ EXP tính được: 90 (4*10 + 50)
   ✅ EXP đã lưu vào database
   ✅ Streak đã cập nhật

💾 [DATABASE] Cập nhật EXP:
   📊 EXP cũ: 180
   ➕ Thêm: 90
   ✅ EXP mới: 270

🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: 2024-12-09
   📅 Ngày học cuối: 2024-12-08
   📊 Chênh lệch: 1 ngày
   🔥 Streak hiện tại: 0
   ⬆️ Tiếp tục streak → Mới: 1
```

---

## ✅ VERIFICATION CHECKLIST

- [ ] Logs "✅ HOÀN THÀNH BÀI" xuất hiện
- [ ] Logs "💾 [DATABASE] Cập nhật EXP" xuất hiện
- [ ] Logs "🔥 [DATABASE] Kiểm tra Streak" xuất hiện
- [ ] Không có "❌" error logs
- [ ] Profile bấm Refresh → EXP tăng
- [ ] Profile bấm Refresh → Streak thay đổi đúng logic

---

## 🚀 KỲ TIẾP

Nếu tất cả checks đều ✅:
1. **Logs đầy đủ** → Logic tốt ✅
2. **Database update** → Dữ liệu lưu ✅
3. **Profile refresh** → UI hiển thị ✅

Nếu còn vấn đề, chia sẻ logs đầy đủ và tôi sẽ debug tiếp.

---

**Status**: Debug guide ready
**Test**: Run → Complete lesson → Check logs → Refresh Profile

