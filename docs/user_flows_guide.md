### 📄 File 2: `user_flows_guide.md`

```markdown
# 🗺️ EduTool Mobile - User Flows & Navigation Guide

Tài liệu này mô tả hành trình của người dùng (User Flows) trong ứng dụng, quyền hạn truy cập theo Role, và các quy tắc xử lý Trải nghiệm Người dùng (UX).

---

## 1. Luồng Xác Thực (Authentication Flow)

- **[Splash Screen]**
  - App khởi chạy -> Kiểm tra `AccessToken` trong Local Storage.
  - Nếu có: Gọi ngầm API `/api/users/me` để lấy Role và điều hướng vào Dashboard tương ứng.
  - Nếu không có / Lỗi 401: Chuyển hướng đến **[Login Screen]**.
- **[Login Screen]**
  - Nhập Email/Username và Password.
  - Thành công -> Kiểm tra trường `role` trong response.
  - Nếu `STUDENT` -> `/student/dashboard`.
  - Nếu `LECTURER` -> `/lecturer/dashboard`.

---

## 2. Luồng Người Dùng (Role-Based Flows)

### 2.1. Student Flow (Sinh viên)

Sử dụng Bottom Navigation Bar (3 tab):

1.  **Tab Tổng quan (Dashboard):** Hiển thị danh sách Deadline sắp tới, cảnh báo bài tập trễ hạn, trạng thái các môn học đang tham gia.
2.  **Tab Môn học (Courses):**
    - Hiển thị danh sách khóa học đang enroll.
    - Bấm vào 1 môn -> **[Course Detail]**. Tại đây có 2 mục chính:
      - _Project:_ Xem thông tin nhóm, nộp/cập nhật link GitHub Repository.
      - _Periodic Report:_ Nộp báo cáo định kỳ (chỉ hiển thị nút Nộp khi thời gian hiện tại nằm trong khoảng `submitStartAt` và `submitEndAt`).
3.  **Tab Cá nhân (Profile):** Đổi mật khẩu, xem thông tin sinh viên, Đăng xuất.

### 2.2. Lecturer Flow (Giảng viên)

Sử dụng Bottom Navigation Bar (3 tab):

1.  **Tab Tổng quan (Dashboard):** Thống kê số lượng sinh viên, cảnh báo các nhóm chưa nộp báo cáo/GitHub.
2.  **Tab Quản lý (Manage):**
    - Hiển thị danh sách các lớp/khóa học đang giảng dạy.
    - Bấm vào 1 môn -> **[Course Detail]**:
      - _Quản lý Project:_ Tạo project, gán sinh viên vào nhóm. Chọn 1 GitHub Repo làm repo chính để track commit.
      - _Báo cáo Commit:_ Mở màn hình xem thống kê GitHub. Bấm "Export CSV" -> Hệ thống gọi API xuất file, tự động đẩy lên Supabase Storage và lưu lại URL qua API `/storage-url`.
      - _Periodic Report:_ Tạo đợt báo cáo mới, xem danh sách sinh viên đã nộp.
3.  **Tab Cá nhân (Profile):** Đổi mật khẩu, Đăng xuất.

---

## 3. Quy Tắc UX & Trạng Thái Trống (Empty States)

### 3.1. Feedback cho người dùng

- **Thành công (Success):** Khi nộp bài/tạo project thành công, dùng **Toast/Snackbar** màu xanh lá (Success Color) ở dưới cùng màn hình (Ví dụ: _"Nộp báo cáo thành công!"_), không bắt người dùng phải bấm "OK" để tắt.
- **Lỗi (Error):** Dùng Snackbar màu đỏ. Nếu lỗi do nhập liệu (Validation Errors), hiển thị text đỏ ngay dưới input field tương ứng.
- **Hành động phá hủy (Destructive Action):** Xóa project, xóa repo, đăng xuất -> BẮT BUỘC hiển thị **Confirm Dialog** (Bottom Sheet hoặc Modal) với nút cảnh báo (Warning/Error Color) trước khi thực hiện.

### 3.2. Hiển thị Loading & Trống (Empty States)

- **Lần đầu tải màn hình:** Dùng hiệu ứng **Skeleton Loading** (Khối xám nhấp nháy) thay vì vòng quay (CircularProgressIndicator) ở giữa màn hình. Vòng quay chỉ dùng cho các nút bấm (Button) khi đang submit form.
- **Dữ liệu trống:** Nếu sinh viên chưa có môn học nào, hoặc môn học chưa có đợt báo cáo, KHÔNG ĐƯỢC để màn hình trắng. Phải hiển thị một hình ảnh minh họa nhỏ (Academic style) và text giải thích (Ví dụ: _"Chưa có đợt báo cáo nào cho môn học này."_).

### 3.3. Pull to Refresh

Tất cả các màn hình dạng danh sách (List Môn học, List Report, List Repo) đều phải bọc trong `RefreshIndicator` để người dùng có thể vuốt từ trên xuống để gọi lại API cập nhật dữ liệu mới nhất.
```
