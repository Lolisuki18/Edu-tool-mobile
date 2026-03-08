# Hướng dẫn Test API Endpoints – EduTool Mobile

> Tài liệu này liệt kê **tất cả API endpoint** mà app đang gọi, **trạng thái UI**, và **cách test từng endpoint** trực tiếp trên ứng dụng.

---

## Mục lục

1. [Chuẩn bị môi trường](#1-chuẩn-bị-môi-trường)
2. [Tổng quan Endpoint Coverage](#2-tổng-quan-endpoint-coverage)
3. [Auth – 3 endpoint](#3-auth--3-endpoint)
4. [Admin – 32 endpoint](#4-admin--32-endpoint)
5. [Student – 8 endpoint](#5-student--8-endpoint)
6. [Lecturer – 15 endpoint](#6-lecturer--15-endpoint)
7. [Chưa có UI (cần bổ sung)](#7-chưa-có-ui-cần-bổ-sung)
8. [Test bằng Postman / cURL](#8-test-bằng-postman--curl)

---

## 1. Chuẩn bị môi trường

### 1.1 Chạy Backend

```bash
# Đảm bảo BE đang chạy trên port 8080
# Base URL tự động theo platform:
#   - Windows/macOS/Linux desktop: http://localhost:8080
#   - Android emulator:            http://10.0.2.2:8080
#   - Web (Chrome):                http://localhost:8080
```

### 1.2 Chạy Flutter App

```bash
cd edutool

# Windows desktop
flutter run -d windows

# Android emulator
flutter run -d emulator-5554

# Chrome
flutter run -d chrome
```

### 1.3 Tài khoản test

| Role     | Cách tạo                                             |
| -------- | ---------------------------------------------------- |
| Student  | Đăng ký qua màn hình Register → BE gán role mặc định |
| Lecturer | Admin tạo qua tab Lecturers                          |
| Admin    | Seed data từ BE hoặc đổi role trực tiếp trong DB     |

---

## 2. Tổng quan Endpoint Coverage

| Nhóm                | Tổng endpoint | Có UI  | Chưa có UI |
| ------------------- | ------------- | ------ | ---------- |
| Auth                | 3             | 3      | 0          |
| Admin – Users       | 5             | 5      | 0          |
| Admin – Students    | 5             | 3      | 2          |
| Admin – Lecturers   | 4             | 2      | 2          |
| Admin – Semesters   | 4             | 4      | 0          |
| Admin – Courses     | 4             | 4      | 0          |
| Admin – Enrollments | 4             | 4      | 0          |
| Admin – Projects    | 4             | 4      | 0          |
| Admin – Dashboard   | 6 (reuse)     | 6      | 0          |
| Student             | 8             | 8      | 0          |
| Lecturer            | 15            | 15     | 0          |
| **Tổng unique**     | **~43**       | **39** | **4**      |

> **39/43 endpoint đã có UI** để test trực tiếp trên app.

---

## 3. Auth – 3 endpoint

### 3.1 POST `/auth/register` — Đăng ký

| Mục           | Chi tiết                                                |
| ------------- | ------------------------------------------------------- |
| **Màn hình**  | Login → nhấn "Đăng ký"                                  |
| **Cách test** | Nhập fullName, email, username, password → nhấn Đăng ký |
| **Kết quả**   | Thành công → thông báo kiểm tra email                   |
| **Lỗi test**  | Bỏ trống field → hiển thị validation error              |

### 3.2 POST `/auth/login` — Đăng nhập

| Mục           | Chi tiết                                                             |
| ------------- | -------------------------------------------------------------------- |
| **Màn hình**  | `/login`                                                             |
| **Cách test** | Nhập username + password → nhấn Đăng nhập                            |
| **Kết quả**   | Thành công → chuyển đến Dashboard theo role (Admin/Student/Lecturer) |
| **Lỗi test**  | Sai password → hiển thị lỗi "Invalid credentials"                    |

### 3.3 POST `/auth/logout` — Đăng xuất

| Mục           | Chi tiết                                     |
| ------------- | -------------------------------------------- |
| **Màn hình**  | Tab Profile (bất kỳ role) → nhấn "Đăng xuất" |
| **Cách test** | Nhấn nút Đăng xuất                           |
| **Kết quả**   | Quay về màn hình Login, xoá token            |

---

## 4. Admin – 32 endpoint

> Đăng nhập bằng tài khoản Admin. Sau khi login sẽ vào Dashboard.

### 4.1 Dashboard (6 endpoint – GET reuse)

| Mục           | Chi tiết                                                                                                        |
| ------------- | --------------------------------------------------------------------------------------------------------------- |
| **Màn hình**  | Admin Dashboard – màn hình đầu tiên                                                                             |
| **Cách test** | Đăng nhập Admin → tự động hiển thị                                                                              |
| **Endpoint**  | Gọi đồng thời 6 GET: `/api/users`, `/api/students`, `/api/lecturers`, `/semesters`, `/courses`, `/api/projects` |
| **Kết quả**   | Hiển thị 6 card đếm số lượng (Users, Students, Lecturers, Semesters, Courses, Projects)                         |

### 4.2 Users CRUD (5 endpoint)

#### GET `/api/users/me` — Thông tin cá nhân

| Màn hình  | Tab Profile                         |
| --------- | ----------------------------------- |
| Cách test | Nhấn tab Profile ở sidebar          |
| Kết quả   | Hiển thị tên, email, role, username |

#### PUT `/api/users/me/password` — Đổi mật khẩu

| Màn hình  | Tab Profile → "Đổi mật khẩu"                    |
| --------- | ----------------------------------------------- |
| Cách test | Nhấn nút Đổi mật khẩu → nhập old + new password |
| Kết quả   | Thành công → SnackBar xanh                      |
| Lỗi test  | Nhập sai old password → lỗi                     |

#### GET `/api/users` — Danh sách users (paginated)

| Màn hình  | Sidebar → "Users"                             |
| --------- | --------------------------------------------- |
| Cách test | Nhấn mục Users, cuộn xuống để load thêm trang |
| Kết quả   | Danh sách user với fullName, email, role      |

#### POST `/api/users` — Tạo user mới

| Màn hình  | Tab Users → nút FAB (+)                                         |
| --------- | --------------------------------------------------------------- |
| Cách test | Nhấn (+) → nhập fullName, email, username, password, role → Lưu |
| Kết quả   | User mới xuất hiện trong danh sách                              |

#### DELETE `/api/users/{id}` — Xoá user

| Màn hình  | Tab Users → vuốt trái hoặc nhấn icon xoá |
| --------- | ---------------------------------------- |
| Cách test | Nhấn icon thùng rác trên user → xác nhận |
| Kết quả   | User bị xoá khỏi danh sách               |

### 4.3 Students (3/5 endpoint có UI)

#### GET `/api/students` — Danh sách sinh viên (paginated)

| Màn hình  | Sidebar → "Students"                   |
| --------- | -------------------------------------- |
| Cách test | Nhấn mục Students, cuộn để phân trang  |
| Kết quả   | Danh sách SV với mã, tên, chuyên ngành |

#### POST `/api/students` — Tạo sinh viên ✅

| Màn hình  | Tab Students → FAB (+)          |
| --------- | ------------------------------- |
| Cách test | Nhấn (+) → nhập thông tin → Lưu |

#### DELETE `/api/students/{id}` — Xoá sinh viên ✅

| Màn hình | Tab Students → icon xoá |
| -------- | ----------------------- |

#### ⚠️ GET `/api/students/{id}` — Chi tiết 1 SV → **CHƯA CÓ UI**

#### ⚠️ PUT `/api/students/{id}` — Cập nhật SV → **CHƯA CÓ UI**

### 4.4 Lecturers (2/4 endpoint có UI)

#### GET `/api/lecturers` — Danh sách giảng viên (paginated)

| Màn hình  | Sidebar → "Lecturers"                  |
| --------- | -------------------------------------- |
| Cách test | Nhấn mục Lecturers, cuộn để phân trang |

#### POST `/api/lecturers` — Tạo giảng viên

| Màn hình  | Tab Lecturers → FAB (+)         |
| --------- | ------------------------------- |
| Cách test | Nhấn (+) → nhập thông tin → Lưu |

#### ⚠️ PUT `/api/lecturers/{id}` — Cập nhật GV → **CHƯA CÓ UI**

#### ⚠️ DELETE `/api/lecturers/{id}` — Xoá GV → **CHƯA CÓ UI**

### 4.5 Semesters CRUD (4 endpoint) ✅

#### GET `/semesters` — Danh sách học kỳ

| Màn hình  | Sidebar → "Semesters" |
| --------- | --------------------- |
| Cách test | Nhấn mục Semesters    |

#### POST `/semesters` — Tạo học kỳ

| Màn hình  | Tab Semesters → FAB (+)                       |
| --------- | --------------------------------------------- |
| Cách test | Nhấn (+) → nhập tên, startDate, endDate → Lưu |

#### PUT `/semesters/{id}` — Cập nhật học kỳ

| Màn hình  | Tab Semesters → nhấn vào 1 item         |
| --------- | --------------------------------------- |
| Cách test | Nhấn vào semester → sửa thông tin → Lưu |

#### DELETE `/semesters/{id}` — Xoá học kỳ

| Màn hình | Tab Semesters → icon xoá |
| -------- | ------------------------ |

### 4.6 Courses CRUD (4 endpoint) ✅

#### GET `/courses` — Danh sách môn học

| Màn hình | Sidebar → "Courses" |
| -------- | ------------------- |

#### POST `/courses` — Tạo môn học

| Màn hình  | Tab Courses → FAB (+)                                                  |
| --------- | ---------------------------------------------------------------------- |
| Cách test | Nhấn (+) → nhập courseCode, courseName, chọn semester + lecturer → Lưu |

#### PUT `/courses/{id}` — Cập nhật môn học

| Màn hình | Tab Courses → nhấn vào item |
| -------- | --------------------------- |

#### DELETE `/courses/{id}` — Xoá môn học

| Màn hình | Tab Courses → icon xoá |
| -------- | ---------------------- |

### 4.7 Enrollments CRUD (4 endpoint) ✅

#### GET `/api/enrollments?courseId={id}` — Danh sách enrollment theo môn

| Màn hình  | Sidebar → "Enrollments"                                                    |
| --------- | -------------------------------------------------------------------------- |
| Cách test | Chọn môn học từ dropdown → danh sách enrollment hiện ra                    |
| Lưu ý     | **Bắt buộc chọn course** trước khi load (BE trả 400 nếu không có courseId) |

#### POST `/api/enrollments` — Tạo enrollment

| Màn hình  | Tab Enrollments → FAB (+)                 |
| --------- | ----------------------------------------- |
| Cách test | Nhấn (+) → nhập studentId, courseId → Lưu |

#### PUT `/api/enrollments/{id}` — Cập nhật enrollment (gán project)

| Màn hình  | Tab Enrollments → nhấn vào 1 enrollment                             |
| --------- | ------------------------------------------------------------------- |
| Cách test | Nhấn vào enrollment → dialog sửa projectId, role, groupNumber → Lưu |

#### DELETE `/api/enrollments/{id}` — Xoá enrollment

| Màn hình | Tab Enrollments → icon xoá |
| -------- | -------------------------- |

### 4.8 Projects CRUD (4 endpoint) ✅

#### GET `/api/projects?courseId={id}` — Danh sách project theo môn

| Màn hình  | Sidebar → "Projects"                        |
| --------- | ------------------------------------------- |
| Cách test | Chọn course từ dropdown → hiển thị projects |

#### POST `/api/projects` — Tạo project

| Màn hình | Tab Projects → FAB (+) |
| -------- | ---------------------- |

#### PUT `/api/projects/{id}` — Cập nhật project

| Màn hình | Tab Projects → nhấn vào item |
| -------- | ---------------------------- |

#### DELETE `/api/projects/{id}` — Xoá project

| Màn hình | Tab Projects → icon xoá |
| -------- | ----------------------- |

---

## 5. Student – 8 endpoint

> Đăng nhập bằng tài khoản Student.

### 5.1 GET `/api/users/me` — Thông tin cá nhân

| Màn hình  | Tab "Tài khoản" (tab cuối cùng)                   |
| --------- | ------------------------------------------------- |
| Cách test | Nhấn tab Profile / tự động load khi vào Dashboard |

### 5.2 PUT `/api/users/me/password` — Đổi mật khẩu

| Màn hình | Tab Profile → "Đổi mật khẩu" |
| -------- | ---------------------------- |

### 5.3 GET `/api/students?userId={id}` — Lấy thông tin SV theo userId

| Màn hình | Tab Dashboard – tự động gọi sau login |
| -------- | ------------------------------------- |

### 5.4 GET `/api/enrollments?studentId={id}` — Danh sách môn đã đăng ký

| Màn hình  | Tab Dashboard → hiển thị danh sách course cards  |
| --------- | ------------------------------------------------ |
| Cách test | Login Student → trang chủ hiện các môn đã enroll |

### 5.5 GET `/api/github/repositories/course/{courseId}/groups` — Nhóm & repo theo môn

| Màn hình  | Tab "Nhóm" → chọn môn                                         |
| --------- | ------------------------------------------------------------- |
| Cách test | Nhấn tab Nhóm → chọn course từ dropdown → hiện danh sách nhóm |

### 5.6 POST `/api/github/repositories` — Nộp GitHub repo

| Màn hình  | Tab "Nhóm" → nút "Nộp repo"                   |
| --------- | --------------------------------------------- |
| Cách test | Nhấn nút → nhập GitHub URL → Submit           |
| Lưu ý     | Chỉ hoạt động nếu student đã được gán project |

### 5.7 GET `/api/periodic-reports/courses/{courseId}/submissions/active` — Báo cáo định kỳ đang mở

| Màn hình  | Tab "Báo cáo" → chọn course                                     |
| --------- | --------------------------------------------------------------- |
| Cách test | Nhấn tab Báo cáo → chọn môn → hiện danh sách report đang active |

### 5.8 POST `/auth/logout` — Đăng xuất

| Màn hình | Tab Profile → "Đăng xuất" |
| -------- | ------------------------- |

---

## 6. Lecturer – 15 endpoint

> Đăng nhập bằng tài khoản Lecturer.

### 6.1 GET `/api/users/me` — Thông tin cá nhân

| Màn hình | Tab "Profile" (tab 5) |
| -------- | --------------------- |

### 6.2 PUT `/api/users/me/password` — Đổi mật khẩu

| Màn hình | Tab Profile → "Đổi mật khẩu" |
| -------- | ---------------------------- |

### 6.3 GET `/courses` — Danh sách môn dạy

| Màn hình  | Tab Home → tự động gọi                           |
| --------- | ------------------------------------------------ |
| Cách test | Login Lecturer → trang chủ hiện danh sách course |

### 6.4 GET `/api/enrollments?courseId={id}` — Danh sách SV trong môn

| Màn hình | Tab Home → chọn 1 course card |
| -------- | ----------------------------- |

### 6.5 GET `/api/github/repositories/course/{courseId}/groups` — Nhóm & repo

| Màn hình  | Tab "Nhóm" → chọn course                            |
| --------- | --------------------------------------------------- |
| Cách test | Nhấn tab Nhóm → chọn môn → hiện nhóm và repo status |

### 6.6 GET `/api/github/repositories?courseId={id}` — Repo theo môn

| Màn hình | Tab "Nhóm" → chọn course → section repos |
| -------- | ---------------------------------------- |

### 6.7 POST `/api/github/repositories` — Nộp repo

| Màn hình | Tab "Nhóm" → nút "Nộp repo" |
| -------- | --------------------------- |

### 6.8 PATCH `/api/github/repositories/{id}/select` — Chọn repo chính

| Màn hình | Tab "Nhóm" → nhấn vào 1 repo → "Chọn repo này" |
| -------- | ---------------------------------------------- |

### 6.9 DELETE `/api/github/repositories/{id}` — Xoá repo

| Màn hình | Tab "Nhóm" → nhấn icon xoá trên repo |
| -------- | ------------------------------------ |

### 6.10 GET `/api/projects?courseId={id}` — Danh sách project

| Màn hình | Tab "Projects" → chọn course |
| -------- | ---------------------------- |

### 6.11 POST `/api/projects` — Tạo project

| Màn hình  | Tab "Projects" → FAB (+)                       |
| --------- | ---------------------------------------------- |
| Cách test | Nhấn (+) → nhập tên project, chọn course → Lưu |

### 6.12 GET `/api/github/repositories/project/{projectId}/report/json` — Commit report

| Màn hình  | Tab "Reports" → tab "Commit Report"                                     |
| --------- | ----------------------------------------------------------------------- |
| Cách test | Chọn project → chọn dateRange → nhấn "Tạo báo cáo" → hiện summary cards |

### 6.13 GET `/api/periodic-reports/courses/{courseId}` — Danh sách báo cáo định kỳ

| Màn hình  | Tab "Reports" → tab "Báo cáo định kỳ" → chọn course           |
| --------- | ------------------------------------------------------------- |
| Cách test | Chuyển sang tab "Báo cáo định kỳ" → chọn môn → hiện danh sách |

### 6.14 POST `/api/periodic-reports` — Tạo báo cáo định kỳ

| Màn hình  | Tab "Báo cáo định kỳ" → nút "Tạo báo cáo"                                             |
| --------- | ------------------------------------------------------------------------------------- |
| Cách test | Nhấn "Tạo" → chọn 4 ngày (reportFrom, reportTo, submitStart, submitEnd) + mô tả → Lưu |

### 6.15 DELETE `/api/periodic-reports/{id}` — Xoá báo cáo định kỳ

| Màn hình | Tab "Báo cáo định kỳ" → icon xoá trên item |
| -------- | ------------------------------------------ |

---

## 7. Chưa có UI (cần bổ sung)

Các endpoint đã có method trong repository nhưng **chưa có màn hình** để trigger:

| #   | Method | Endpoint              | Repository       | Ghi chú           |
| --- | ------ | --------------------- | ---------------- | ----------------- |
| 1   | GET    | `/api/students/{id}`  | admin_repository | Xem chi tiết 1 SV |
| 2   | PUT    | `/api/students/{id}`  | admin_repository | Cập nhật SV       |
| 3   | PUT    | `/api/lecturers/{id}` | admin_repository | Cập nhật GV       |
| 4   | DELETE | `/api/lecturers/{id}` | admin_repository | Xoá GV            |

### Endpoint chưa được implement (chỉ có constant):

| #   | Constant              | Endpoint                              | Mô tả             |
| --- | --------------------- | ------------------------------------- | ----------------- |
| 1   | `usersExport`         | GET `/api/users/export`               | Export CSV        |
| 2   | `usersImport`         | POST `/api/users/import`              | Import CSV        |
| 3   | `reportCsv()`         | GET `.../report/csv`                  | Commit report CSV |
| 4   | `reportStorageUrl()`  | GET/POST `.../report/storage-url`     | Lưu trữ report    |
| 5   | `enrollmentProject()` | PATCH `/api/enrollments/{id}/project` | Gán project riêng |

---

## 8. Test bằng Postman / cURL

Nếu muốn test endpoint **không qua app**, dùng Postman hoặc cURL:

### 8.1 Lấy token

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin01", "password": "Abc12345"}'
```

Response:

```json
{
  "isSuccess": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "..."
  }
}
```

### 8.2 Dùng token cho các API khác

```bash
# GET danh sách users
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer <accessToken>"

# POST tạo semester
curl -X POST http://localhost:8080/semesters \
  -H "Authorization: Bearer <accessToken>" \
  -H "Content-Type: application/json" \
  -d '{"semesterName": "Spring 2026", "startDate": "2026-01-15", "endDate": "2026-05-30"}'

# GET enrollments theo course
curl "http://localhost:8080/api/enrollments?courseId=1" \
  -H "Authorization: Bearer <accessToken>"

# PUT cập nhật enrollment
curl -X PUT http://localhost:8080/api/enrollments/1 \
  -H "Authorization: Bearer <accessToken>" \
  -H "Content-Type: application/json" \
  -d '{"projectId": 5, "roleInProject": "leader", "groupNumber": 1}'

# DELETE xoá project
curl -X DELETE http://localhost:8080/api/projects/3 \
  -H "Authorization: Bearer <accessToken>"

# GET commit report
curl "http://localhost:8080/api/github/repositories/project/1/report/json?fromDate=2026-01-01&toDate=2026-03-08" \
  -H "Authorization: Bearer <accessToken>"

# POST tạo periodic report
curl -X POST http://localhost:8080/api/periodic-reports \
  -H "Authorization: Bearer <accessToken>" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": 1,
    "reportFromDate": "2026-03-01",
    "reportToDate": "2026-03-15",
    "submitStartAt": "2026-03-16T00:00:00",
    "submitEndAt": "2026-03-20T23:59:59"
  }'
```

### 8.3 Postman Collection

Cách setup nhanh:

1. **Import** → New Collection "EduTool API"
2. **Variables**: `base_url` = `http://localhost:8080`, `token` = (để trống)
3. **Pre-request script** cho collection:
   ```javascript
   // Auto-login nếu token hết hạn
   if (!pm.collectionVariables.get("token")) {
     pm.sendRequest(
       {
         url: pm.collectionVariables.get("base_url") + "/auth/login",
         method: "POST",
         header: { "Content-Type": "application/json" },
         body: {
           mode: "raw",
           raw: JSON.stringify({
             username: "admin01",
             password: "Abc12345",
           }),
         },
       },
       (err, res) => {
         const token = res.json().data.accessToken;
         pm.collectionVariables.set("token", token);
       },
     );
   }
   ```
4. **Authorization** tab → Bearer Token → `{{token}}`
5. Tạo request cho từng endpoint theo bảng ở trên

---

## Checklist Test theo Role

### ☐ Admin Flow

- [ ] Login admin → Dashboard hiện 6 card đếm
- [ ] Sidebar → Users → danh sách hiển thị, cuộn phân trang
- [ ] Users → (+) tạo user → hiện trong list
- [ ] Users → xoá user → biến mất
- [ ] Sidebar → Students → danh sách hiển thị
- [ ] Students → (+) tạo SV
- [ ] Students → xoá SV
- [ ] Sidebar → Lecturers → danh sách hiển thị
- [ ] Lecturers → (+) tạo GV
- [ ] Sidebar → Semesters → CRUD đầy đủ (list, create, edit, delete)
- [ ] Sidebar → Courses → CRUD đầy đủ
- [ ] Sidebar → Enrollments → chọn course → list enrollment
- [ ] Enrollments → (+) tạo enrollment
- [ ] Enrollments → nhấn item → sửa projectId/role/group
- [ ] Enrollments → xoá enrollment
- [ ] Sidebar → Projects → chọn course → list project
- [ ] Projects → CRUD
- [ ] Profile → hiển thị thông tin
- [ ] Profile → đổi mật khẩu
- [ ] Profile → đăng xuất

### ☐ Student Flow

- [ ] Login student → Dashboard hiện danh sách môn đã enroll
- [ ] Tab Nhóm → chọn course → hiện nhóm & repo
- [ ] Tab Nhóm → nộp GitHub repo
- [ ] Tab Báo cáo → chọn course → hiện active reports
- [ ] Tab Profile → hiển thị info
- [ ] Tab Profile → đổi mật khẩu
- [ ] Tab Profile → đăng xuất

### ☐ Lecturer Flow

- [ ] Login lecturer → Dashboard hiện course list
- [ ] Tab Nhóm → chọn course → hiện nhóm
- [ ] Tab Nhóm → nộp/chọn/xoá repo
- [ ] Tab Projects → chọn course → list project
- [ ] Tab Projects → tạo project
- [ ] Tab Reports → Commit Report → chọn project + date → generate
- [ ] Tab Reports → Báo cáo định kỳ → chọn course → list
- [ ] Tab Reports → tạo báo cáo định kỳ
- [ ] Tab Reports → xoá báo cáo định kỳ
- [ ] Tab Profile → đổi mật khẩu
- [ ] Tab Profile → đăng xuất

---

_Cập nhật lần cuối: 2026-03-08_
