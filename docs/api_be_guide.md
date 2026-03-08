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
11. [Ghi chú cho Flutter](#11-ghi-chú-cho-flutter)

> ⚠️ **Lưu ý**: GitHub Repository & Commit Report APIs chưa được implement trong BE hiện tại.

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

**Paginated Response** — `data` có dạng `Page<T>` của Spring:

```json
{
  "content": [ ... ],
  "page": {
    "number": 0,
    "size": 10,
    "totalElements": 50,
    "totalPages": 5
  }
}
```

---

## 2. Authentication

> Không cần `Authorization` header.

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

> **Flutter**: Lưu `accessToken` vào SecureStorage. Gửi kèm mọi request tiếp theo:  
> `Authorization: Bearer {accessToken}`

> Server set `refreshToken` trong **HttpOnly Cookie** tại path `/auth/refresh`. Flutter cần dùng `dio_cookie_manager` để tự động gửi cookie khi refresh.

---

### 2.4 Làm mới Access Token

```
POST /auth/refresh
```

> Cookie `refreshToken` phải được gửi kèm tự động.  
> Access token hết hạn sau **10 giờ**.

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

**Roles:** Tất cả (đã đăng nhập)

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

### 3.2 Tạo user mới

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

**Response 201:** → `data` là `UserResponse` (xem 3.1)

---

### 3.3 Lấy user theo ID

```
GET /api/users/{userId}
```

**Roles:** `ADMIN`

**Response 200:** → `data` là `UserResponse`

---

### 3.4 Lấy danh sách users (phân trang)

```
GET /api/users?username=&email=&fullName=&keyword=&role=&status=&page=0&size=10&sortBy=userId&sortDirection=ASC
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

**Response 200:** → `data` là `Page<UserResponse>`

---

### 3.5 Cập nhật user

```
PUT /api/users/{userId}
```

**Roles:** `ADMIN`

**Request Body:** (tất cả optional)

```json
{
  "email": "newemail@fpt.edu.vn",
  "fullName": "Nguyen Van A Updated",
  "role": "LECTURER",
  "status": "INACTIVE",
  "password": "NewPass123"
}
```

**Response 200:** → `data` là `UserResponse`

---

### 3.6 Xóa user

```
DELETE /api/users/{userId}
```

**Roles:** `ADMIN`

**Response 200:** `data: null`

---

### 3.7 Cập nhật role user

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

### 3.8 Đổi password

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

**Response 200:** `data: null`

---

### 3.9 Đổi email

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

### 3.10 Export CSV

```
GET /api/users/export
```

**Roles:** `ADMIN`  
**Response:** File `text/csv`

---

### 3.11 Import CSV

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

### 4.1 Tạo student profile

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

**Response 200:** → `data` là `StudentResponse`

---

### 4.3 Tìm kiếm students (phân trang)

```
GET /api/students?keyword=&studentCode=&githubUsername=&fullName=&page=0&size=10&sortBy=studentId&direction=ASC
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

| Query Param      | Mô tả                                                                     |
| ---------------- | ------------------------------------------------------------------------- |
| `studentCode`    | Tìm theo mã SV                                                            |
| `githubUsername` | Tìm theo GitHub username                                                  |
| `fullName`       | Tìm theo tên                                                              |
| `keyword`        | Tìm trên tất cả field                                                     |
| `page`           | Trang (default: 0)                                                        |
| `size`           | Kích thước trang (1–100, default: 10)                                     |
| `sortBy`         | `studentId` / `studentCode` / `fullName` / `githubUsername` / `createdAt` |
| `direction`      | `ASC` / `DESC`                                                            |

**Response 200:** → `data` là `Page<StudentResponse>`

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

### 4.5 Xóa student

```
DELETE /api/students/{id}
```

**Roles:** `ADMIN`

**Response 200:** `data: null`

---

## 5. Lecturer

### 5.1 Tạo lecturer profile

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

**Response 200:** → `data` là `LecturerResponse`

---

### 5.3 Lấy lecturer theo userId

```
GET /api/lecturers/user/{userId}
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** → `data` là `LecturerResponse`

---

### 5.4 Tìm kiếm lecturers (phân trang)

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

**Response 200:** → `data` là `Page<LecturerResponse>`

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

**Response 200:** → `data` là `LecturerResponse`

---

### 5.6 Xóa lecturer

```
DELETE /api/lecturers/{id}
```

**Roles:** `ADMIN`

**Response 200:** `data: null`

---

## 6. Semester

> ⚠️ **Lưu ý**: Semester endpoints **không** có prefix `/api/`.

### 6.1 Tạo semester

```
POST /semesters
```

**Roles:** `ADMIN`

**Request Body:**

```json
{
  "semesterName": "Spring 2026",
  "startDate": "2026-01-01",
  "endDate": "2026-05-31",
  "status": true
}
```

**Response 201:**

```json
{
  "isSuccess": true,
  "code": 201,
  "message": "Success",
  "data": {
    "semesterId": 1,
    "semesterName": "Spring 2026",
    "startDate": "2026-01-01",
    "endDate": "2026-05-31",
    "status": true,
    "createdAt": "2026-03-08T10:00:00"
  }
}
```

---

### 6.2 Cập nhật semester

```
PUT /semesters/{semesterId}
```

**Roles:** `ADMIN`

**Request Body:** Giống 6.1

**Response 200:** → `data` là `SemesterResponse`

---

### 6.3 Lấy semester theo ID

```
GET /semesters/{semesterId}
```

**Roles:** Tất cả (đã đăng nhập)

**Response 200:** → `data` là `SemesterResponse`

---

### 6.4 Lấy tất cả semesters

```
GET /semesters
```

**Roles:** Tất cả (đã đăng nhập)

**Response 200:** → `data` là `List<SemesterResponse>`

---

### 6.5 Xóa semester (soft delete)

```
DELETE /semesters/{semesterId}
```

**Roles:** `ADMIN`

> Chuyển `status` về `false`, không xóa khỏi DB.

**Response 200:** `data: null`

---

## 7. Course

> ⚠️ **Lưu ý**: Course endpoints **không** có prefix `/api/`.

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
      "semesterName": "Spring 2026",
      "startDate": "2026-01-01",
      "endDate": "2026-05-31",
      "status": true,
      "createdAt": "2026-03-08T09:00:00"
    },
    "lecturer": {
      "lecturerId": 2,
      "staffCode": "GV001",
      "user": { "...": "..." },
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

**Roles:** Tất cả (đã đăng nhập)

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

**Response 200:** → `data` là `CourseResponse`

---

### 7.6 Xóa course

```
DELETE /courses/{courseId}
```

**Roles:** `ADMIN` / `LECTURER`

**Response 200:** `data: null`

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

> Nếu không truyền param nào → lấy tất cả projects (không phân trang).

**Response 200:** → `data` là `List<ProjectResponse>`

---

### 8.4 Cập nhật project

```
PUT /api/projects/{projectId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** Giống 8.1

**Response 200:** → `data` là `ProjectResponse`

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

**Response 200:** → `data` là `EnrollmentResponse`

---

### 9.3 Lấy danh sách enrollments (filter)

```
GET /api/enrollments?courseId=&studentId=&projectId=
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

> Phải cung cấp **một** trong ba param. Nếu không có param → lỗi 400.

| Param       | Mô tả                       |
| ----------- | --------------------------- |
| `courseId`  | Lấy tất cả SV trong môn học |
| `studentId` | Lấy tất cả môn học của SV   |
| `projectId` | Lấy tất cả SV trong project |

**Response 200:** → `data` là `List<EnrollmentResponse>`

---

### 9.4 Cập nhật enrollment (đổi project/role/group)

```
PUT /api/enrollments/{enrollmentId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** (tất cả optional)

```json
{
  "projectId": 1,
  "roleInProject": "leader",
  "groupNumber": 1
}
```

**Response 200:** → `data` là `EnrollmentResponse`

---

### 9.5 Gán sinh viên vào project

```
PUT /api/enrollments/{enrollmentId}/project?projectId={projectId}
```

**Roles:** `ADMIN` / `LECTURER`

> Dùng để phân nhóm — gán trực tiếp 1 SV vào 1 project bằng query param `projectId`.

**Response 200:** → `data` là `EnrollmentResponse`

---

### 9.6 Xóa enrollment

```
DELETE /api/enrollments/{enrollmentId}?permanent=false
```

**Roles:** `ADMIN` / `LECTURER`

| Param       | Mô tả                                                               |
| ----------- | ------------------------------------------------------------------- |
| `permanent` | `false` (default) = soft delete khỏi course; `true` = xóa vĩnh viễn |

---

### 9.7 Actions trên enrollment (PATCH)

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

### 9.8 Xem lịch sử SV đã bị xóa khỏi project

```
GET /api/enrollments/projects/{projectId}/history
```

**Roles:** `ADMIN` / `LECTURER`

> Trả về danh sách các enrollment có `removedFromProjectAt != null` của project đó.

**Response 200:** → `data` là `List<EnrollmentResponse>`

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

---

### 10.2 Lấy periodic report theo ID

```
GET /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:** → `data` là `PeriodicReportResponse`

---

### 10.3 Lấy tất cả periodic reports (phân trang)

```
GET /api/periodic-reports?page=0&size=10&sortBy=createdAt&sortDirection=DESC
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

**Response 200:** → `data` là `Page<PeriodicReportResponse>`

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

**Response 200:** → `data` là `Page<PeriodicReportResponse>`

---

### 10.5 Lấy periodic reports đang mở (có thể submit)

```
GET /api/periodic-reports/courses/{courseId}/submissions/active?page=0&size=10
```

**Roles:** `ADMIN` / `LECTURER` / `STUDENT`

> Chỉ trả về các report hiện đang trong thời gian cho phép nộp (`submitStartAt` ≤ now ≤ `submitEndAt`).

**Response 200:** → `data` là `Page<PeriodicReportResponse>`

---

### 10.6 Cập nhật periodic report

```
PUT /api/periodic-reports/{reportId}
```

**Roles:** `ADMIN` / `LECTURER`

**Request Body:** Giống 10.1

**Response 200:** → `data` là `PeriodicR
