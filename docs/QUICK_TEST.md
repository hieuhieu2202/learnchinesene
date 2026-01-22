# 🎬 TEST STEP-BY-STEP - Kiểm tra Kinh nghiệm & Chuỗi ngày học

## 📋 CÁC BƯỚC TEST CHI TIẾT

### BƯỚC 1️⃣: Chuẩn bị
```
1. Mở Flutter DevTools (hoặc logcat)
2. Chạy ứng dụng: flutter run
3. Đợi app khởi động xong
4. Chuẩn bị ghi chép kết quả
```

### BƯỚC 2️⃣: Test hoàn thành bài lần 1
```
1. Vào trang: Review Today
2. Bấm nút: "Bắt đầu ôn tập"
3. Hoàn thành bài tập:
   - Trả lời đúng ít nhất 5 câu (bắt buộc để tính EXP)
   - Bỏ qua/sai các câu khác
   - Hoàn thành hết tất cả câu hỏi
```

### BƯỚC 3️⃣: Kiểm tra Logs
Sau khi hoàn thành, mở console và tìm:

```
✅ HOÀN THÀNH BÀI:
   📊 Câu đúng: [N]
   ⭐ EXP tính được: [X]
   ✅ EXP đã lưu vào database
   ✅ Streak đã cập nhật

💾 [DATABASE] Cập nhật EXP:
   📊 EXP cũ: [old]
   ➕ Thêm: [exp]
   ✅ EXP mới: [new]

🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: [date]
   📅 Ngày học cuối: [date]
   📊 Chênh lệch: 0 ngày
   ✅ Đã học hôm nay rồi - Không cập nhật streak
```

**Nếu thấy logs này** → ✅ **PASSED: EXP được tính**

### BƯỚC 4️⃣: Kiểm tra Profile
```
1. Bấm: Back → Quay lại màn hình chính
2. Vào: Profile (hoặc Hệ thống → Hồ sơ)
3. Bấm nút: Refresh (⟲) ở góc phải
4. Chờ dữ liệu tải lại
5. Kiểm tra:
   - EXP tăng từ 0 → [X] ✅
   - Streak vẫn 0 (vì lần đầu) ✅
```

**Kết quả dự kiến**:
```
Kinh nghiệm: [X] EXP  (X = 5*10 + 50 = 100 nếu 5 câu đúng)
Chuỗi ngày học: 0 ngày (Lần đầu)
```

---

## 🔥 TEST CASE 2: Hoàn thành bài lần 2 (cùng ngày)

### Mục tiêu
Kiểm tra:
- ✅ EXP tiếp tục cộng dồn
- ✅ Streak không tăng (vì cùng ngày)

### Các bước
```
1. Vào: Review Today → Bắt đầu ôn tập
2. Hoàn thành bài 2 (trả lời đúng 3 câu)
3. Kiểm tra logs:
   ⭐ EXP tính được: 80 (3*10 + 50)
   💾 EXP cũ: [prev] → EXP mới: [prev+80]
   🔥 Kiểm tra Streak: Chênh lệch 0 ngày → Không cập nhật
4. Vào Profile → Bấm Refresh
5. Kiểm tra:
   EXP mới = EXP cũ + 80 ✅
   Streak vẫn 0 ✅
```

---

## 📅 TEST CASE 3: Hoàn thành bài lần 3 (ngày hôm sau)

### Mục tiêu
Kiểm tra:
- ✅ EXP tiếp tục tăng
- ✅ Streak tăng từ 0 → 1

### Cách test (giả lập)
```
Vì bạn cần chờ ngày hôm sau, bạn có thể:

Option 1: Chờ hôm sau (dễ nhất)
- Tắt ứng dụng hôm nay
- Mở lại hôm sau
- Hoàn thành bài
- Streak sẽ tăng lên 1

Option 2: Thay đổi hệ thống ngày (advanced)
- Vào Settings → Developer options
- Thay đổi System date/time
- Hoàn thành bài
- Kiểm tra logs
```

### Logs dự kiến
```
🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: 2024-12-09
   📅 Ngày học cuối: 2024-12-08
   📊 Chênh lệch: 1 ngày
   🔥 Streak hiện tại: 0
   ⬆️ Tiếp tục streak → Mới: 1
```

### Kết quả dự kiến
```
Kinh nghiệm: [EXP cũ + 80] EXP ✅
Chuỗi ngày học: 1 ngày ✅
```

---

## 🔄 TEST CASE 4: Reset Streak (cách 2+ ngày)

### Mục tiêu
Kiểm tra:
- ✅ Streak reset nếu không học 2+ ngày

### Cách test
```
1. Ngày 1: Hoàn thành bài
   → Streak = 1
   
2. Ngày 2-3: Không hoàn thành bài
   
3. Ngày 4: Hoàn thành bài
   → Logs sẽ show: Chênh lệch 3 ngày
   → Streak reset = 1
```

### Logs dự kiến
```
🔥 [DATABASE] Kiểm tra Streak:
   📅 Ngày hôm nay: 2024-12-12
   📅 Ngày học cuối: 2024-12-08
   📊 Chênh lệch: 4 ngày
   🔥 Streak hiện tại: 1
   🔄 Reset streak (cách 3 ngày) → Mới: 1
```

---

## ❌ TROUBLESHOOTING

### Vấn đề 1: Không thấy logs
**Nguyên nhân**: AddExperienceUseCase không được gọi

**Kiểm tra**:
```
1. Xem console có dòng "✅ HOÀN THÀNH BÀI" không
2. Nếu không → _autoCloseAfterFinish() không được gọi
3. Kiểm tra _moveNext() có gọi _autoCloseAfterFinish() không
```

### Vấn đề 2: Logs hiển thị nhưng Profile không update
**Nguyên nhân**: Database update đúng nhưng UI không refresh

**Giải pháp**:
```
1. Bấm nút Refresh (⟲) trên Profile
2. Hoặc: Exit ứng dụng → Mở lại
3. Kiểm tra dữ liệu có thay đổi không
```

### Vấn đề 3: EXP không tính (0 câu đúng)
**Nguyên nhân**: Điều kiện `correctCount > 0` trong logic

**Expected**: Nếu trả lời sai hết, không tính EXP
**Kiểm tra**: Phải trả lời đúng ít nhất 1 câu

---

## 📊 SUMMARY TABLE

| Test | Điều kiện | Logs | EXP | Streak | Status |
|------|-----------|------|-----|--------|--------|
| 1️⃣ Lần đầu | 5 đúng | ✅ | 100 | 0 | ✅ |
| 2️⃣ Lần 2 (cùng ngày) | 3 đúng | ✅ | +80 | 0 | ✅ |
| 3️⃣ Lần 3 (ngày sau) | 4 đúng | ✅ | +90 | 1 | ✅ |
| 4️⃣ Reset (cách 2+ ngày) | Cách 3 ngày | ✅ | +X | 1 | ✅ |

---

## ✅ FINAL CHECKLIST

- [ ] Logs "✅ HOÀN THÀNH BÀI" xuất hiện khi hoàn thành bài
- [ ] Logs "💾 [DATABASE]" xuất hiện (EXP được cập nhật)
- [ ] Logs "🔥 [DATABASE]" xuất hiện (Streak được kiểm tra)
- [ ] Không có "❌" error logs
- [ ] Bấm Refresh trên Profile → EXP tăng
- [ ] Streak tăng đúng logic (0 khi cùng ngày, 1 khi hôm sau)
- [ ] Reset streak khi cách 2+ ngày

---

**Status**: ✅ Test guide ready  
**Action**: Run → Complete lesson → Check logs → Refresh Profile

Chia sẻ logs với tôi nếu có vấn đề!

