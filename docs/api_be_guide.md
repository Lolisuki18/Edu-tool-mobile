# EduTool API Documentation

> **Dành cho Flutter Mobile Client**  
> Base URL: `http://<host>:8080`  
> Tất cả request/response dùng `Content-Type: application/json` trừ khi có ghi chú khác.

---

## Mục lục

1. [Cấu trúc Response chung](#1-cấu-trúc-response-chung)
2. [Authentication](#2-authentication)
3. [User Management](#3-user-management)
4. [Student](#4-student)
5. [Lecturer](#5-lecturer)
6. [Semester](#6-semester)
7. [Course](#7-course)
8. [Project](#8-project)
9. [Course Enrollment](#9-course-enrollment)
10. [Periodic Report](#10-periodic-report)
11. [GitHub Repository & Commit Report](#11-github-repository--commit-report)
12. [Ghi chú cho Flutter](#12-ghi-chú-cho-flutter)

---

## 1. Cấu trúc Response chung

Mọi API đều trả về `BaseResponse<T>`:

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Success",
  "data": { ... },
  "errors": [],
  "timestamp": "2026-03-08T10:00:00"
}
```

| Field       | Type      | Mô tả                                                |
| ----------- | --------- | ---------------------------------------------------- |
| `isSuccess` | `boolean` | `true` nếu thành công                                |
| `code`      | `int`     | HTTP status code (200, 201, 400, 401, 403, 404, 500) |
| `message`   | `string`  | Thông báo chi tiết                                   |
| `data`      | `T`       | Dữ liệu trả về (null nếu lỗi)                        |
| `errors`    | `array`   | Danh sách lỗi validation                             |
| `timestamp` | `string`  | Thời điểm response (ISO 8601)                        |

**Paginated Response** (khi API có phân trang) – `data` sẽ có dạng:

```json
{
  "content": [ ... ],
  "page": {
    "pageNumber": 0,
    "pageSize": 10,
    "totalElements": 50,
    "totalPages": 5
  }
}
```

---

## 2. Authentication

### 2.1 Đăng ký

```
POST /auth/register
```

**Request Body:**

```json
{
  "fullName": "Nguyen Van A",
  "email": "vana@fpt.edu.vn",
  "username": "vana_fpt",
  "password": "Abc12345"
}
```

| Field      | Required | Validation                                   |
| ---------- | -------- | -------------------------------------------- |
| `fullName` | ✅       | 2–255 ký tự                                  |
| `email`    | ✅       | Email hợp lệ, tối đa 100 ký tự               |
| `username` | ✅       | 3–50 ký tự, chỉ `a-z A-Z 0-9 _`              |
| `password` | ✅       | 8–100 ký tự, phải có chữ hoa, chữ thường, số |

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Registration successful. Please check your email to verify your account.",
  "data": null
}
```

---

### 2.2 Xác thực Email

```
GET /auth/verify?token={token}
```

| Param   | Type     | Mô tả               |
| ------- | -------- | ------------------- |
| `token` | `string` | Token gửi qua email |

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Email verified successfully. You can now log in.",
  "data": null
}
```

---

### 2.3 Đăng nhập

```
POST /auth/login
```

**Request Body:**

```json
{
  "username": "vana_fpt",
  "password": "Abc12345"
}
```

> `username` có thể là username **hoặc** email.

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Login successful",
  "data": {
    "role": "STUDENT",
    "fullName": "Nguyen Van A",
    "email": "vana@fpt.edu.vn",
    "status": "ACTIVE",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

> **Flutter**: Lưu `accessToken` vào `SecureStorage`. Gửi kèm mọi request tiếp theo trong header:  
> `Authorization: Bearer {accessToken}`

> **Lưu ý**: Server set `refreshToken` trong **HttpOnly Cookie** (`/auth/refresh`). Flutter dùng `http` package cần bật cookie handling (dùng `http` + `cookie_jar`).

---

### 2.4 Làm mới Access Token

```
POST /auth/refresh
```

> Cookie `refreshToken` phải được gửi kèm tự động.  
> Access token hết hạn sau **10 giờ** (36,000,000ms).

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Token refreshed successfully",
  "data": {
    "role": "STUDENT",
    "fullName": "Nguyen Van A",
    "email": "vana@fpt.edu.vn",
    "status": "ACTIVE",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 2.5 Đăng xuất

```
POST /auth/logout
```

> Xóa cookie `refreshToken` phía server.

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Logged out successfully",
  "data": null
}
```

---

## 3. User Management

> Header bắt buộc: `Authorization: Bearer {accessToken}`

### 3.1 Lấy thông tin user hiện tại

```
GET /api/users/me
```

**Roles cho phép:** Tất cả (đã đăng nhập)

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "User information retrieved successfully",
  "data": {
    "userId": 1,
    "username": "vana_fpt",
    "role": "STUDENT",
    "fullName": "Nguyen Van A",
    "email": "vana@fpt.edu.vn",
    "status": "ACTIVE"
  }
}
```

---

### 3.2 Tạo user mới (Admin)

```
POST /api/users
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "username": "lecturer01",
  "password": "Pass1234",
  "email": "lecturer01@fpt.edu.vn",
  "fullName": "Tran Thi B",
  "role": "LECTURER",
  "status": "ACTIVE"
}
```

| Field      | Required | Values                                        |
| ---------- | -------- | --------------------------------------------- |
| `username` | ✅       | 3–50 ký tự                                    |
| `password` | ✅       | 6–100 ký tự                                   |
| `email`    | ✅       | Email hợp lệ                                  |
| `fullName` | ✅       | Tối đa 255 ký tự                              |
| `role`     | ✅       | `ADMIN` / `LECTURER` / `STUDENT`              |
| `status`   | ❌       | `ACTIVE` (default) / `INACTIVE` / `SUSPENDED` |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "User created successfully",
  "data": {
    "userId": 5,
    "username": "lecturer01",
    "role": "LECTURER",
    "fullName": "Tran Thi B",
    "email": "lecturer01@fpt.edu.vn",
    "status": "ACTIVE"
  }
}
```

---

### 3.3 Lấy user theo ID (Admin)

```
GET /api/users/{userId}
```

**Roles:** `ADMIN`

**Response 200:** → `data` là `UserResponse` (xem 3.1)

---

### 3.4 Lấy danh sách users (Admin)

```
GET /api/users?keyword=&role=&status=&page=0&size=10&sortBy=userId&sortDirection=ASC
```

**Roles:** `ADMIN`

| Query Param     | Type     | Mô tả                                        |
| --------------- | -------- | -------------------------------------------- |
| `username`      | `string` | Tìm theo username (fuzzy)                    |
| `email`         | `string` | Tìm theo email (fuzzy)                       |
| `fullName`      | `string` | Tìm theo tên (fuzzy)                         |
| `keyword`       | `string` | Tìm trên cả username/email/fullName          |
| `role`          | `string` | `ADMIN` / `LECTURER` / `STUDENT`             |
| `status`        | `string` | `ACTIVE` / `INACTIVE` / `SUSPENDED`          |
| `page`          | `int`    | Trang (mặc định: 0)                          |
| `size`          | `int`    | Kích thước trang (mặc định: 10)              |
| `sortBy`        | `string` | `userId` / `username` / `email` / `fullName` |
| `sortDirection` | `string` | `ASC` / `DESC`                               |

**Response 200:** → `data` là `Page<UserResponse>` (phân trang)

---

### 3.5 Cập nhật user (Admin)

```
PUT /api/users/{userId}
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "email": "newemail@fpt.edu.vn",
  "fullName": "Nguyen Van A Updated",
  "role": "LECTURER",
  "status": "INACTIVE",
  "password": "NewPass123"
}
```

> Tất cả các field đều **optional**.

**Response 200:** → `data` là `UserResponse`

---

### 3.6 Xóa user (Admin)

```
DELETE /api/users/{userId}
```

**Roles:** `ADMIN`

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "User deleted successfully",
  "data": null
}
```

---

### 3.7 Cập nhật role user (Admin)

```
PUT /api/users/admin/update-role
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "userId": 5,
  "role": "LECTURER"
}
```

---

### 3.8 Đổi password (User hiện tại)

```
PUT /api/users/me/password
```

**Roles:** Tất cả (đã đăng nhập)

**Request Body:**

```json
{
  "currentPassword": "OldPass123",
  "newPassword": "NewPass456",
  "confirmPassword": "NewPass456"
}
```

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Password changed successfully",
  "data": null
}
```

---

### 3.9 Đổi email (User hiện tại)

```
PUT /api/users/me/email
```

**Roles:** Tất cả (đã đăng nhập)

**Request Body:**

```json
{
  "newEmail": "newemail@fpt.edu.vn",
  "password": "CurrentPass123"
}
```

---

### 3.10 Export CSV (Admin)

```
GET /api/users/export
```

**Roles:** `ADMIN`  
**Response:** File CSV (`text/csv`)

---

### 3.11 Import CSV (Admin)

```
POST /api/users/import
Content-Type: multipart/form-data
```

**Roles:** `ADMIN`

**Form field:** `file` (`.csv`)

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Import completed",
  "data": {
    "successCount": 8,
    "errorCount": 2,
    "totalRows": 10,
    "errors": ["Row 3: Duplicate email", "Row 7: Invalid role"],
    "message": "Import completed: 8 succeeded, 2 failed"
  }
}
```

---

## 4. Student

### 4.1 Tạo student profile (Admin)

```
POST /api/students
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "studentCode": "SE170001",
  "userId": 3,
  "githubUsername": "vana-github"
}
```

| Field            | Required | Validation                              |
| ---------------- | -------- | --------------------------------------- |
| `studentCode`    | ✅       | 3–50 ký tự, duy nhất                    |
| `userId`         | ✅       | ID của user đã tồn tại với role STUDENT |
| `githubUsername` | ❌       | Tối đa 100 ký tự                        |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Student created successfully",
  "data": {
    "studentId": 1,
    "studentCode": "SE170001",
    "githubUsername": "vana-github",
    "user": {
      "userId": 3,
      "username": "vana_fpt",
      "role": "STUDENT",
      "fullName": "Nguyen Van A",
      "email": "vana@fpt.edu.vn",
      "status": "ACTIVE"
    },
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 4.2 Lấy student theo ID

```
GET /api/students/{id}
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:** → `data` là `StudentResponse` (xem 4.1)

---

### 4.3 Tìm kiếm students (có phân trang)

```
GET /api/students?keyword=&studentCode=&githubUsername=&fullName=&page=0&size=10&sortBy=studentId&direction=ASC
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

| Query Param      | Mô tả                                                                     |
| ---------------- | ------------------------------------------------------------------------- |
| `studentCode`    | Tìm theo mã SV                                                            |
| `githubUsername` | Tìm theo GitHub username                                                  |
| `fullName`       | Tìm theo tên                                                              |
| `keyword`        | Tìm trên tất cả các field trên                                            |
| `page`           | Trang (default: 0)                                                        |
| `size`           | Kích thước trang (1–100, default: 10)                                     |
| `sortBy`         | `studentId` / `studentCode` / `fullName` / `githubUsername` / `createdAt` |
| `direction`      | `ASC` / `DESC`                                                            |

**Response 200:** → `data` là `Page<StudentResponse>` (phân trang Spring)

---

### 4.4 Cập nhật student

```
PUT /api/students/{id}
```

**Roles:** `ADMIN` / `STUDENT`

**Request Body:**

```json
{
  "studentCode": "SE170001",
  "githubUsername": "new-github-username"
}
```

**Response 200:** → `data` là `StudentResponse`

---

### 4.5 Xóa student (Admin)

```
DELETE /api/students/{id}
```

**Roles:** `ADMIN`

**Response 200:** `data: null`

---

## 5. Lecturer

### 5.1 Tạo lecturer profile (Admin)

```
POST /api/lecturers
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "staffCode": "GV001",
  "userId": 5
}
```

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Lecturer created successfully",
  "data": {
    "lecturerId": 1,
    "staffCode": "GV001",
    "user": {
      "userId": 5,
      "username": "lecturer01",
      "role": "LECTURER",
      "fullName": "Tran Thi B",
      "email": "lecturer01@fpt.edu.vn",
      "status": "ACTIVE"
    },
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 5.2 Lấy lecturer theo ID

```
GET /api/lecturers/{id}
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** → `data` là `LecturerResponse` (xem 5.1)

---

### 5.3 Lấy lecturer theo userId

```
GET /api/lecturers/user/{userId}
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** → `data` là `LecturerResponse`

---

### 5.4 Tìm kiếm lecturers (có phân trang)

```
GET /api/lecturers?keyword=&fullName=&staffCode=&page=0&size=10&sortBy=lecturerId&direction=ASC
```

**Roles:** `ADMIN` / `LECTURER`

| Param       | Mô tả                                                 |
| ----------- | ----------------------------------------------------- |
| `fullName`  | Tìm theo tên                                          |
| `staffCode` | Tìm theo mã GV                                        |
| `keyword`   | Tìm trên fullName, staffCode                          |
| `sortBy`    | `lecturerId` / `staffCode` / `fullName` / `createdAt` |

---

### 5.5 Cập nhật lecturer

```
PUT /api/lecturers/{id}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "staffCode": "GV001-UPDATED"
}
```

---

### 5.6 Xóa lecturer (Admin)

```
DELETE /api/lecturers/{id}
```

**Roles:** `ADMIN`

---

## 6. Semester

### 6.1 Tạo semester (Admin)

```
POST /semesters
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "name": "Spring 2026",
  "startDate": "2026-01-01",
  "endDate": "2026-05-31",
  "status": true
}
```

| Field       | Required | Mô tả                   |
| ----------- | -------- | ----------------------- |
| `name`      | ✅       | 1–100 ký tự             |
| `startDate` | ✅       | Định dạng `yyyy-MM-dd`  |
| `endDate`   | ✅       | Định dạng `yyyy-MM-dd`  |
| `status`    | ✅       | `true` = đang hoạt động |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Success",
  "data": {
    "semesterId": 1,
    "name": "Spring 2026",
    "startDate": "2026-01-01",
    "endDate": "2026-05-31",
    "status": true,
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 6.2 Cập nhật semester (Admin)

```
PUT /semesters/{semesterId}
```

**Roles:** `ADMIN`

**Request Body:** sama như 6.1

---

### 6.3 Lấy semester theo ID

```
GET /semesters/{semesterId}
```

**Roles:** Tất cả (đã đăng nhập)

**Response 200:** → `data` là `SemesterResponse` (xem 6.1)

---

### 6.4 Lấy tất cả semesters

```
GET /semesters
```

**Response 200:** → `data` là `List<SemesterResponse>`

---

### 6.5 Xóa semester (Admin – soft delete)

```
DELETE /semesters/{semesterId}
```

**Roles:** `ADMIN`

> Chuyển `status` về `false`, không xóa khỏi DB.

---

## 7. Course

### 7.1 Tạo course

```
POST /courses
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "courseCode": "SWD392",
  "courseName": "Software Architecture Design",
  "status": true,
  "semesterId": 1,
  "lecturerId": 2
}
```

| Field        | Required | Mô tả                     |
| ------------ | -------- | ------------------------- |
| `courseCode` | ✅       | Duy nhất                  |
| `courseName` | ✅       |                           |
| `status`     | ❌       | `true` = active (default) |
| `semesterId` | ❌       | ID học kỳ                 |
| `lecturerId` | ❌       | ID giảng viên             |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Course created successfully",
  "data": {
    "courseId": 1,
    "courseCode": "SWD392",
    "courseName": "Software Architecture Design",
    "status": true,
    "createdAt": "2026-03-08T10:00:00",
    "semester": {
      "semesterId": 1,
      "name": "Spring 2026",
      "startDate": "2026-01-01",
      "endDate": "2026-05-31",
      "status": true,
      "createdAt": "2026-03-08T09:00:00"
    },
    "lecturer": {
      "lecturerId": 2,
      "staffCode": "GV001",
      "user": { ... },
      "createdAt": "..."
    }
  }
}
```

---

### 7.2 Lấy tất cả courses

```
GET /courses
```

**Response 200:** → `data` là `List<CourseResponse>`

---

### 7.3 Lấy course theo ID

```
GET /courses/{courseId}
```

**Response 200:** → `data` là `CourseResponse`

---

### 7.4 Lấy course theo courseCode

```
GET /courses/code/{courseCode}
```

**Response 200:** → `data` là `CourseResponse`

---

### 7.5 Cập nhật course

```
PUT /courses/{courseId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** Giống 7.1

---

### 7.6 Xóa course

```
DELETE /courses/{courseId}
```

**Roles:** `ADMIN` / `LECTURER`

---

## 8. Project

### 8.1 Tạo project

```
POST /api/projects
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "projectCode": "PROJ-001",
  "projectName": "EduTool Mobile App",
  "courseId": 1,
  "description": "Ứng dụng quản lý học tập",
  "technologies": "Flutter, Spring Boot, PostgreSQL"
}
```

| Field          | Required | Mô tả    |
| -------------- | -------- | -------- |
| `projectCode`  | ✅       | Duy nhất |
| `projectName`  | ✅       |          |
| `courseId`     | ✅       |          |
| `description`  | ❌       |          |
| `technologies` | ❌       |          |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Project created successfully",
  "data": {
    "projectId": 1,
    "projectCode": "PROJ-001",
    "projectName": "EduTool Mobile App",
    "courseId": 1,
    "courseCode": "SWD392",
    "courseName": "Software Architecture Design",
    "description": "Ứng dụng quản lý học tập",
    "technologies": "Flutter, Spring Boot, PostgreSQL",
    "createdAt": "2026-03-08T10:00:00",
    "deletedAt": null,
    "memberCount": 0
  }
}
```

---

### 8.2 Lấy project theo ID

```
GET /api/projects/{projectId}
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:** → `data` là `ProjectResponse`

---

### 8.3 Lấy projects (list/filter)

```
GET /api/projects?code=&courseId=&deleted=false
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

| Param      | Mô tả                                    |
| ---------- | ---------------------------------------- |
| `code`     | Lấy 1 project theo projectCode           |
| `courseId` | Lấy tất cả projects của môn học          |
| `deleted`  | `true` = lấy projects đã xóa (chỉ admin) |

> Nếu không truyền param nào → lấy tất cả projects.

**Response 200:** → `data` là `List<ProjectResponse>`

---

### 8.4 Cập nhật project

```
PUT /api/projects/{projectId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** Giống 8.1

---

### 8.5 Khôi phục project đã xóa

```
PATCH /api/projects/{projectId}?action=restore
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** → `data` là `ProjectResponse`

---

### 8.6 Xóa project

```
DELETE /api/projects/{projectId}?permanent=false
```

**Roles:** `ADMIN` / `LECTURER`

| Param       | Mô tả                                                                 |
| ----------- | --------------------------------------------------------------------- |
| `permanent` | `false` (default) = soft delete; `true` = xóa vĩnh viễn (chỉ `ADMIN`) |

---

## 9. Course Enrollment

### 9.1 Enroll sinh viên vào course

```
POST /api/enrollments
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "studentId": 1,
  "courseId": 1
}
```

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Student enrolled successfully",
  "data": {
    "enrollmentId": 1,
    "studentId": 1,
    "studentCode": "SE170001",
    "studentName": "Nguyen Van A",
    "courseId": 1,
    "courseCode": "SWD392",
    "courseName": "Software Architecture Design",
    "projectId": null,
    "projectCode": null,
    "projectName": null,
    "roleInProject": null,
    "groupNumber": null,
    "enrolledAt": "2026-03-08T10:00:00",
    "deletedAt": null,
    "removedFromProjectAt": null
  }
}
```

---

### 9.2 Lấy enrollment theo ID

```
GET /api/enrollments/{enrollmentId}
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

---

### 9.3 Lấy danh sách enrollments (filter)

```
GET /api/enrollments?courseId=&studentId=&projectId=
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

> Phải cung cấp **một** trong ba param.

| Param       | Mô tả                       |
| ----------- | --------------------------- |
| `courseId`  | Lấy tất cả SV trong môn học |
| `studentId` | Lấy tất cả môn học của SV   |
| `projectId` | Lấy tất cả SV trong project |

**Response 200:** → `data` là `List<EnrollmentResponse>`

---

### 9.4 Cập nhật enrollment (gán project/role/group)

```
PUT /api/enrollments/{enrollmentId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "projectId": 1,
  "roleInProject": "leader",
  "groupNumber": 1
}
```

> Tất cả field đều **optional**.

**Response 200:** → `data` là `EnrollmentResponse`

---

### 9.5 Xóa enrollment

```
DELETE /api/enrollments/{enrollmentId}?permanent=false
```

**Roles:** `ADMIN` / `LECTURER`

| Param       | Mô tả                                                               |
| ----------- | ------------------------------------------------------------------- |
| `permanent` | `false` (default) = soft delete khỏi course; `true` = xóa vĩnh viễn |

---

### 9.6 Các action trên enrollment (PATCH)

```
PATCH /api/enrollments/{enrollmentId}?action={action}
```

**Roles:** `ADMIN` / `LECTURER`

| `action`              | Mô tả                                  |
| --------------------- | -------------------------------------- |
| `restore`             | Khôi phục enrollment đã soft-delete    |
| `remove-from-project` | Xóa SV khỏi project (vẫn trong course) |
| `restore-to-project`  | Thêm lại SV vào project                |

**Response 200:** → `data` là `EnrollmentResponse`

---

## 10. Periodic Report

### 10.1 Tạo periodic report

```
POST /api/periodic-reports
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "courseId": 1,
  "reportFromDate": "2026-03-01T00:00:00",
  "reportToDate": "2026-03-07T23:59:59",
  "submitStartAt": "2026-03-08T00:00:00",
  "submitEndAt": "2026-03-10T23:59:59",
  "description": "Báo cáo tuần 1"
}
```

| Field            | Required | Mô tả                         |
| ---------------- | -------- | ----------------------------- |
| `courseId`       | ✅       |                               |
| `reportFromDate` | ✅       | ISO 8601 datetime             |
| `reportToDate`   | ✅       | ISO 8601 datetime             |
| `submitStartAt`  | ✅       | Thời điểm bắt đầu nộp báo cáo |
| `submitEndAt`    | ✅       | Hạn nộp                       |
| `description`    | ❌       |                               |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Periodic report created successfully",
  "data": {
    "reportId": 1,
    "courseId": 1,
    "courseCode": "SWD392",
    "courseName": "Software Architecture Design",
    "reportFromDate": "2026-03-01T00:00:00",
    "reportToDate": "2026-03-07T23:59:59",
    "submitStartAt": "2026-03-08T00:00:00",
    "submitEndAt": "2026-03-10T23:59:59",
    "description": "Báo cáo tuần 1",
    "status": "ACTIVE",
    "createdAt": "2026-03-08T10:00:00",
    "reportDetailCount": 0
  }
}
```

> `status`: `ACTIVE` = đang mở / `INACTIVE` = đã xóa

---

### 10.2 Lấy periodic report theo ID

```
GET /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

---

### 10.3 Lấy tất cả periodic reports (phân trang)

```
GET /api/periodic-reports?page=0&size=10&sortBy=createdAt&sortDirection=DESC
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:** → `data` là `PageResponse<PeriodicReportResponse>`

---

### 10.4 Lấy periodic reports theo course (phân trang)

```
GET /api/periodic-reports/courses/{courseId}?fromDate=&toDate=&page=0&size=10&sortBy=reportFromDate&sortDirection=DESC
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

| Param      | Mô tả                                |
| ---------- | ------------------------------------ |
| `fromDate` | Filter từ ngày (ISO 8601, optional)  |
| `toDate`   | Filter đến ngày (ISO 8601, optional) |

---

### 10.5 Lấy periodic reports đang mở (có thể submit)

```
GET /api/periodic-reports/courses/{courseId}/submissions/active?page=0&size=10
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

> Chỉ trả về các report hiện đang trong thời gian cho phép nộp (`submitStartAt` ≤ now ≤ `submitEndAt`).

---

### 10.6 Cập nhật periodic report

```
PUT /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** Giống 10.1

---

### 10.7 Xóa periodic report (soft delete → INACTIVE)

```
DELETE /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER`

---

### 10.8 Khôi phục periodic report (→ ACTIVE)

```
PATCH /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER`

---

### 10.9 Lấy danh sách periodic reports đã xóa (Admin)

```
GET /api/periodic-reports/inactive?page=0&size=10&sortBy=createdAt&sortDirection=DESC
```

**Roles:** `ADMIN`

---

## 11. GitHub Repository & Commit Report

### 11.1 Nộp github repository cho project

```
POST /api/github/repositories
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Request Body:**

```json
{
  "projectId": 1,
  "repoUrl": "https://github.com/org/repo-name",
  "repoName": "repo-name"
}
```

| Field       | Required | Mô tả                            |
| ----------- | -------- | -------------------------------- |
| `projectId` | ✅       |                                  |
| `repoUrl`   | ✅       | URL GitHub hợp lệ                |
| `repoName`  | ❌       | Nếu bỏ qua, tự trích xuất từ URL |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Repository submitted successfully",
  "data": {
    "repoId": 1,
    "repoUrl": "https://github.com/org/repo-name",
    "repoName": "repo-name",
    "owner": "org",
    "isSelected": false,
    "projectId": 1,
    "projectName": "EduTool Mobile App",
    "projectCode": "PROJ-001",
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 11.2 Lấy danh sách repositories

```
GET /api/github/repositories?projectId=&courseId=
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

> Phải cung cấp `projectId` **hoặc** `courseId`.

**Response 200:** → `data` là `List<GithubRepositoryResponse>`

---

### 11.3 Lấy repository theo ID

```
GET /api/github/repositories/{repoId}
```

**Response 200:** → `data` là `GithubRepositoryResponse`

---

### 11.4 Cập nhật repository

```
PUT /api/github/repositories/{repoId}
```

**Request Body:** Giống 11.1

---

### 11.5 Chọn repository để track commits (Admin/Lecturer)

```
PATCH /api/github/repositories/{repoId}/select
```

**Roles:** `ADMIN` / `LECTURER`

> Chỉ 1 repo được chọn trong cùng 1 project. Repo đang chọn trước sẽ bị bỏ chọn.

**Response 200:** → `data` là `GithubRepositoryResponse` với `isSelected: true`

---

### 11.6 Xóa repository

```
DELETE /api/github/repositories/{repoId}
```

**Roles:** `ADMIN` / `LECTURER`

---

### 11.7 Lấy repositories nhóm theo group trong course

```
GET /api/github/repositories/course/{courseId}/groups
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Retrieved 3 groups",
  "data": [
    {
      "groupNumber": 1,
      "projectId": 1,
      "projectCode": "PROJ-001",
      "projectName": "EduTool Mobile App",
      "projectDescription": "...",
      "projectTechnologies": "Flutter, Spring Boot",
      "courseId": 1,
      "courseCode": "SWD392",
      "courseName": "Software Architecture Design",
      "memberCount": 4,
      "repoCount": 1,
      "members": [
        {
          "studentId": 1,
          "studentCode": "SE170001",
          "fullName": "Nguyen Van A",
          "githubUsername": "vana-github",
          "email": "vana@fpt.edu.vn",
          "roleInProject": "leader"
        }
      ],
      "repositories": [
        {
          "repoId": 1,
          "repoUrl": "https://github.com/org/repo",
          "repoName": "repo",
          "owner": "org",
          "isSelected": true,
          "projectId": 1,
          "projectName": "EduTool Mobile App",
          "projectCode": "PROJ-001",
          "createdAt": "2026-03-08T10:00:00"
        }
      ]
    }
  ]
}
```

---

### 11.8 Xuất báo cáo commit dạng JSON

```
GET /api/github/repositories/project/{projectId}/report/json?since=2026-03-01&until=2026-03-08
```

**Roles:** `ADMIN` / `LECTURER`

| Param   | Mô tả                  |
| ------- | ---------------------- |
| `since` | `yyyy-MM-dd`, optional |
| `until` | `yyyy-MM-dd`, optional |

> Project phải có ít nhất 1 repository được chọn (`isSelected: true`).

**Response 200:**

```json
{
  "isSuccess": true,
  "code": 200,
  "message": "Report generated successfully",
  "data": {
    "projectId": 1,
    "repositories": ["https://github.com/org/repo"],
    "period": {
      "since": "2026-03-01",
      "until": "2026-03-08"
    },
    "generatedAt": "2026-03-08T10:00:00",
    "diagnostic": {
      "githubTokenConfigured": true,
      "repositories": [
        { "repository": "https://github.com/org/repo", "status": "OK" }
      ],
      "registeredGithubUsernames": ["vana-github", "vanb-github"]
    },
    "summary": [
      {
        "group": "Group 1",
        "studentCode": "SE170001",
        "fullName": "Nguyen Van A",
        "githubUsername": "vana-github",
        "role": "leader",
        "totalCommits": 25,
        "totalAdditions": 1500,
        "totalDeletions": 200,
        "avgCommitsPerWeek": 6.25
      }
    ],
    "summaryByRepository": [
      {
        "group": "Group 1",
        "studentCode": "SE170001",
        "fullName": "Nguyen Van A",
        "githubUsername": "vana-github",
        "role": "leader",
        "repository": "https://github.com/org/repo",
        "totalCommits": 25,
        "totalAdditions": 1500,
        "totalDeletions": 200
      }
    ],
    "weeklyDetails": [
      {
        "group": "Group 1",
        "studentCode": "SE170001",
        "fullName": "Nguyen Van A",
        "githubUsername": "vana-github",
        "repository": "https://github.com/org/repo",
        "year": 2026,
        "week": 10,
        "commits": 8,
        "additions": 450,
        "deletions": 60
      }
    ]
  }
}
```

---

### 11.9 Xuất báo cáo commit dạng CSV

```
GET /api/github/repositories/project/{projectId}/report/csv?since=2026-03-01&until=2026-03-08
```

**Roles:** `ADMIN` / `LECTURER`

> **Response:** File nhị phân `text/csv`. Flutter tải file này và upload lên Supabase Storage.

---

### 11.10 Lưu URL báo cáo (sau khi upload Supabase)

```
POST /api/github/repositories/project/{projectId}/report/storage-url
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:**

```json
{
  "storageUrl": "https://xyz.supabase.co/storage/v1/object/public/reports/report.csv",
  "storageKey": "reports/report.csv",
  "storageId": "uuid-of-file",
  "since": "2026-03-01",
  "until": "2026-03-08"
}
```

| Field        | Required | Mô tả                       |
| ------------ | -------- | --------------------------- |
| `storageUrl` | ✅       | URL công khai trên Supabase |
| `storageKey` | ❌       | Path trong bucket           |
| `storageId`  | ❌       | UUID của file               |
| `since`      | ❌       | Ngày bắt đầu báo cáo        |
| `until`      | ❌       | Ngày kết thúc báo cáo       |

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Report URL saved successfully",
  "data": {
    "commitReportId": 1,
    "projectId": 1,
    "storageUrl": "https://...",
    "storageKey": "reports/report.csv",
    "storageId": "uuid",
    "sinceDate": "2026-03-01",
    "untilDate": "2026-03-08",
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 11.11 Lấy danh sách URL báo cáo đã lưu

```
GET /api/github/repositories/project/{projectId}/report/storage-url
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** → `data` là `List<CommitReportUrlResponse>`

---

### 11.12 Xóa URL báo cáo

```
DELETE /api/github/repositories/project/{projectId}/report/storage-url/{commitReportId}
```

**Roles:** `ADMIN` / `LECTURER`

---

## 12. Ghi chú cho Flutter

### Authentication Header

```dart
// Thêm vào mọi request (trừ /auth/*)
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $accessToken',
}
```

### Xử lý Token hết hạn

1. Khi nhận `code: 401` → gọi `POST /auth/refresh`
2. Nếu refresh thành công → lưu access token mới, retry request gốc
3. Nếu refresh thất bại → redirect về màn hình Login

### DateTime Format

- Server trả về: `"2026-03-08T10:00:00"` → parse bằng `DateTime.parse()`
- Gửi lên server: ISO 8601, ví dụ `"2026-03-01T00:00:00"`
- Date only (semester): `"2026-01-01"` → `"yyyy-MM-dd"`

### Enums quan trọng

| Enum           | Values                                                    |
| -------------- | --------------------------------------------------------- |
| `Role`         | `ADMIN`, `LECTURER`, `STUDENT`                            |
| `UserStatus`   | `ACTIVE`, `INACTIVE`, `SUSPENDED`, `VERIFICATION_PENDING` |
| `ReportStatus` | `ACTIVE`, `INACTIVE`                                      |

### Phân trang (Pagination)

Khi response có phân trang, `data` có cấu trúc:

```dart
class PageResponse<T> {
  List<T> content;
  PageInfo page;
}

class PageInfo {
  int pageNumber;
  int pageSize;
  int totalElements;
  int totalPages;
}
```

> Bắt đầu từ `pageNumber = 0` (zero-indexed).

### Error Handling

```dart
if (!response['isSuccess']) {
  final code = response['code'];       // 400, 401, 403, 404, 500
  final message = response['message']; // Thông báo lỗi
  final errors = response['errors'];   // Lỗi validation (nếu có)
}
```

### Base URL

- **Local dev:** `http://10.0.2.2:8080` (Android Emulator)
- **Local dev:** `http://localhost:8080` (iOS Simulator)
- **Production:** Cấu hình theo server thực tế

### Cookie (Refresh Token)

Server set `refreshToken` qua `Set-Cookie` header với `HttpOnly; Secure; SameSite=Strict`. Flutter cần dùng thư viện hỗ trợ cookie:

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.0.0
  dio_cookie_manager: ^3.0.0
  cookie_jar: ^4.0.0
```

```dart
final cookieJar = CookieJar();
final dio = Dio();
dio.interceptors.add(CookieManager(cookieJar));
```
