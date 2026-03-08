# Edu Tool — Tổng Quan Tính Năng Đã Hoàn Thành (Web)

> Tài liệu này liệt kê toàn bộ tính năng đã được triển khai trên **Web Frontend (React/TypeScript)** để làm cơ sở tham chiếu khi xây dựng **Mobile App**.
>
> Cập nhật: 08/03/2026

---

## Mục Lục

1. [Phân Quyền & Vai Trò](#1-phân-quyền--vai-trò)
2. [Xác Thực (Auth)](#2-xác-thực-auth)
3. [Trang Chủ / Landing Page](#3-trang-chủ--landing-page)
4. [Quản Lý Admin — Danh Sách Tính Năng](#4-quản-lý-admin)
   - [Dashboard](#41-dashboard)
   - [Quản lý Người dùng (Users)](#42-quản-lý-người-dùng-users)
   - [Quản lý Sinh viên (Students)](#43-quản-lý-sinh-viên-students)
   - [Quản lý Giảng viên (Lecturers)](#44-quản-lý-giảng-viên-lecturers)
   - [Quản lý Học kỳ (Semesters)](#45-quản-lý-học-kỳ-semesters)
   - [Quản lý Môn học (Courses)](#46-quản-lý-môn-học-courses)
   - [Quản lý Đăng ký Môn học (Enrollments)](#47-quản-lý-đăng-ký-môn-học-enrollments)
   - [Quản lý Nhóm / Dự án (Groups & Projects)](#48-quản-lý-nhóm--dự-án-groups--projects)
   - [Quản lý Repository](#49-quản-lý-repository)
   - [Quản lý Báo cáo Commit (Reports)](#410-quản-lý-báo-cáo-commit-reports)
   - [Quản lý Jira](#411-quản-lý-jira)
5. [API Services](#5-api-services)
6. [Các Data Model Chính](#6-các-data-model-chính)
7. [Tổng Hợp Trạng Thái Tính Năng](#7-tổng-hợp-trạng-thái-tính-năng)
8. [Ghi Chú cho Mobile App](#8-ghi-chú-cho-mobile-app)

---

## 1. Phân Quyền & Vai Trò

| Role       | Mô tả         | Quyền truy cập                                       |
| ---------- | ------------- | ---------------------------------------------------- |
| `ADMIN`    | Quản trị viên | Toàn bộ `/admin/*` dashboard                         |
| `LECTURER` | Giảng viên    | `/home`, xem và quản lý Repository & Groups của mình |
| `STUDENT`  | Sinh viên     | `/home` (landing page)                               |

- `ProtectedRoute` kiểm tra JWT trước mỗi route.
- Chưa xác thực → redirect `/auth/login`
- Sai role → redirect `/`
- Token hết hạn → tự động refresh (silent refresh qua cookie `httpOnly`)

---

## 2. Xác Thực (Auth)

### Màn hình đã có

| Route            | Chức năng                                                   |
| ---------------- | ----------------------------------------------------------- |
| `/auth/login`    | Đăng nhập bằng username + password                          |
| `/auth/register` | Đăng ký tài khoản mới (fullName, email, username, password) |

### Luồng hoạt động

1. POST `/auth/login` → nhận `accessToken` + thông tin user (role, fullName, email, status)
2. Lưu token vào `localStorage` (`edu_token`, `edu_user`)
3. Redirect theo role: ADMIN → `/admin`, LECTURER/STUDENT → `/home`
4. Đăng xuất: POST `/auth/logout` → xóa localStorage + cookie

### API Endpoints

| Method | Endpoint         | Mô tả       |
| ------ | ---------------- | ----------- |
| `POST` | `/auth/login`    | Đăng nhập   |
| `POST` | `/auth/register` | Đăng ký     |
| `POST` | `/auth/logout`   | Đăng xuất   |
| `POST` | `/auth/refresh`  | Refresh JWT |

### Validation (per-field errors)

- Hiển thị lỗi từng trường từ API response
- Hiển thị lỗi chung nếu sai username/password

---

## 3. Trang Chủ / Landing Page

- Route: `/home` (chỉ LECTURER & STUDENT)
- Nội dung thuần **Marketing/Landing** — chưa có chức năng nghiệp vụ dành riêng cho student/lecturer
- Các section: Hero, Features, UserRole overview, HowItWorks, CTA
- Có NavMenu và UserDropdown (logout)

> ⚠️ **Lưu ý Mobile App:** Đây là phần chưa có tính năng thực tế cho student/lecturer. Mobile app sẽ cần xây dựng dashboard student & lecturer từ đầu.

---

## 4. Quản Lý Admin

### 4.1 Dashboard

- Route: `/admin`
- Số liệu tổng quan (hiện tại là static):
  - Tổng số nhóm: 24
  - Giảng viên: 8
  - Sinh viên: 120
  - Repository: 24
- Card tích hợp: **Jira Cloud** & **GitHub**
- Feed hoạt động gần đây (Recent Activity)

---

### 4.2 Quản Lý Người Dùng (Users)

- Route: `/admin/users`
- **CRUD đầy đủ**: Xem danh sách, Tạo mới, Xem chi tiết, Chỉnh sửa, Xóa
- **Tính năng:**
  - Bảng phân trang, có thể sort theo cột
  - Badge Role (ADMIN / LECTURER / STUDENT) và Status (ACTIVE / INACTIVE)
  - Confirm dialog trước khi xóa
  - **Import CSV** (upload file)
  - **Export CSV** (download file)
- **Fields:** `userId`, `username`, `fullName`, `email`, `role`, `status`

---

### 4.3 Quản Lý Sinh Viên (Students)

- Route: `/admin/students`
- **CRUD đầy đủ**: Xem, Tạo, Chỉnh sửa (có thể VIEW-ONLY modal)
- **Tính năng:**
  - Bảng phân trang + tìm kiếm theo keyword
  - CSV import/export _(code đã viết nhưng đang comment out)_
- **Fields:** `studentId`, `studentCode`, `githubUsername`, `userId` (liên kết User)

---

### 4.4 Quản Lý Giảng Viên (Lecturers)

- Route: `/admin/lecturers`
- **CRUD đầy đủ**: Xem, Tạo, Chỉnh sửa (có VIEW-ONLY modal)
- **Tính năng:**
  - Bảng phân trang, sort
- **Fields:** `lecturerId`, `staffCode`, `userId` (liên kết User)

---

### 4.5 Quản Lý Học Kỳ (Semesters)

- Route: `/admin/semesters`
- **Tính năng:**
  - Xem danh sách học kỳ + client-side pagination
  - Tạo mới, Chỉnh sửa
  - Status badge: **Active** / **Ended** (tính từ `endDate`)
  - _(Chưa có chức năng Xóa học kỳ)_
- **Fields:** `semesterId`, `name`, `startDate`, `endDate`

---

### 4.6 Quản Lý Môn Học (Courses)

- Route: `/admin/courses`
- **CRUD đầy đủ**: Xem, Tạo, Chỉnh sửa, Xóa
- Từ row của course, có thể navigate thẳng sang trang **Group Management** hoặc **Enrollment Management** theo courseId
- **Fields:** `courseId`, `courseCode`, `courseName`, `status`, `semester`, `lecturer`

---

### 4.7 Quản Lý Đăng Ký Môn Học (Enrollments)

- Route: `/admin/enrollments` (hỗ trợ query param `?courseId=`)
- **Tính năng:**
  - Chọn môn học → xem danh sách sinh viên đã đăng ký
  - Đăng ký sinh viên vào môn học (enroll by studentId)
  - Gán sinh viên vào nhóm/project (với role & groupNumber)
  - Xóa khỏi nhóm (remove from project, giữ enrollment)
  - Xóa enrollment hoàn toàn
- **Fields:** `enrollmentId`, `studentId`, `courseId`, `projectId`, `roleInProject`, `groupNumber`, `deletedAt`, `removedFromProjectAt`

---

### 4.8 Quản Lý Nhóm / Dự Án (Groups & Projects)

Có **2 trang riêng biệt** nhưng liên kết với nhau:

#### `/admin/projects` — Project Management

- Xem danh sách tất cả project
- Filter theo `projectCode` và `courseId`
- Bật/tắt xem project đã xóa (soft-deleted)
- **CRUD đầy đủ** + **Soft delete + Restore**
- **Fields:** `projectId`, `projectCode`, `projectName`, `courseId`, `description`, `technologies`, `deletedAt`, `memberCount`

#### `/admin/groups` — Group Management

- Chọn môn học → xem danh sách project (nhóm) + sinh viên enrolled
- **Tính năng:**
  - Accordion per project — hiện member list
  - Tạo mới / Chỉnh sửa project gắn với course
  - Xóa project
  - Xem sinh viên chưa được gán nhóm (**Unassigned Students Section**)
  - Thêm sinh viên vào nhóm (chọn từ danh sách unassigned, gán role + group number)
  - Xóa sinh viên khỏi nhóm

---

### 4.9 Quản Lý Repository

- Route: `/admin/repositories` (truy cập được bởi cả **ADMIN** và **LECTURER**)
- **Tính năng:**
  - Chọn môn học → xem repo được nhóm theo project/group (dạng accordion)
  - Xem thành viên của từng nhóm
  - **CRUD Repository:** Thêm GitHub URL, Chỉnh sửa, Xóa
  - Đánh dấu repo "chính" (select main repo) cho mỗi nhóm
  - **Export Commit Report:**
    - Chọn khoảng thời gian (date range)
    - Tải xuống file Excel (commit report)
    - Đồng thời upload file lên **Supabase Storage** để lưu lịch sử
- **Fields của Repo:** `repoId`, `repoUrl`, `repoName`, `owner`, `isSelected`, `projectId`
- **Commit Report JSON** chứa: tổng commit, additions, deletions per sinh viên

---

### 4.10 Quản Lý Báo Cáo Commit (Reports)

- Route: `/admin/reports` (chỉ **ADMIN**)
- **Tính năng:**
  - Chọn môn học → chọn project → xem lịch sử báo cáo đã lưu (từ Supabase)
  - Xem danh sách file Excel đã export theo thời gian
  - Xóa báo cáo (xóa cả trên Supabase + database)

---

### 4.11 Quản Lý Jira

- Route: `/admin/jira`
- ❌ **Chỉ là Placeholder** — hiện tại chỉ có `<div>Quản lý Jira</div>`
- Chưa có tính năng gì

---

## 5. API Services

**Base URL:** `VITE_API_URL` (mặc định: `http://localhost:3000/api`)

**Header:** `Authorization: Bearer <accessToken>`

**Auto token refresh:** Khi API trả về 403, Axios interceptor tự gọi `/auth/refresh`, hàng đợi các request bị lỗi rồi retry sau khi refresh thành công.

### Auth

| Method | Endpoint         |
| ------ | ---------------- |
| POST   | `/auth/login`    |
| POST   | `/auth/register` |
| POST   | `/auth/logout`   |
| POST   | `/auth/refresh`  |

### Users

| Method | Endpoint                                        |
| ------ | ----------------------------------------------- |
| GET    | `/api/users?page=&size=&sortBy=&sortDirection=` |
| GET    | `/api/users/:id`                                |
| POST   | `/api/users`                                    |
| PUT    | `/api/users/:id`                                |
| DELETE | `/api/users/:id`                                |
| GET    | `/api/users/export`                             |
| POST   | `/api/users/import`                             |

### Students

| Method | Endpoint                             |
| ------ | ------------------------------------ |
| GET    | `/api/students?page=&size=&keyword=` |
| GET    | `/api/students/:id`                  |
| POST   | `/api/students`                      |
| PUT    | `/api/students/:id`                  |
| DELETE | `/api/students/:id`                  |

### Lecturers

| Method | Endpoint                                        |
| ------ | ----------------------------------------------- |
| GET    | `/api/lecturers?page=&size=&sortBy=&direction=` |
| GET    | `/api/lecturers/:id`                            |
| POST   | `/api/lecturers`                                |
| PUT    | `/api/lecturers/:id`                            |
| DELETE | `/api/lecturers/:id`                            |

### Projects

| Method | Endpoint                           |
| ------ | ---------------------------------- |
| GET    | `/api/projects?code=&courseId=`    |
| GET    | `/api/projects/:id`                |
| POST   | `/api/projects`                    |
| PUT    | `/api/projects/:id`                |
| DELETE | `/api/projects/:id?permanent=true` |
| PATCH  | `/api/projects/:id` (restore)      |

### Semesters

| Method | Endpoint         |
| ------ | ---------------- |
| GET    | `/semesters`     |
| POST   | `/semesters`     |
| PUT    | `/semesters/:id` |

### Courses

| Method | Endpoint       |
| ------ | -------------- |
| GET    | `/courses`     |
| GET    | `/courses/:id` |
| POST   | `/courses`     |
| PUT    | `/courses/:id` |
| DELETE | `/courses/:id` |

### Enrollments

| Method | Endpoint                                           |
| ------ | -------------------------------------------------- |
| GET    | `/api/enrollments?courseId=&studentId=&projectId=` |
| POST   | `/api/enrollments`                                 |
| PUT    | `/api/enrollments/:id`                             |
| PUT    | `/api/enrollments/:id/project?projectId=`          |
| PATCH  | `/api/enrollments/:id?action=remove-from-project`  |
| DELETE | `/api/enrollments/:id`                             |

### Repositories & Reports

| Method | Endpoint                                                            |
| ------ | ------------------------------------------------------------------- |
| GET    | `/api/github/repositories/course/:courseId/groups`                  |
| POST   | `/api/github/repositories`                                          |
| PUT    | `/api/github/repositories/:id`                                      |
| PATCH  | `/api/github/repositories/:id/select`                               |
| DELETE | `/api/github/repositories/:id`                                      |
| GET    | `/api/github/repositories/project/:id/report/json`                  |
| GET    | `/api/github/repositories/project/:id/report/csv`                   |
| POST   | `/api/github/repositories/project/:id/report/storage-url`           |
| GET    | `/api/github/repositories/project/:id/report/storage-url`           |
| DELETE | `/api/github/repositories/project/:id/report/storage-url/:reportId` |

---

## 6. Các Data Model Chính

```typescript
// User
{
  userId: string
  username: string
  fullName: string
  email: string
  role: "ADMIN" | "LECTURER" | "STUDENT"
  status: "ACTIVE" | "INACTIVE"
}

// Student
{
  studentId: string
  studentCode: string
  githubUsername: string
  user: User
}

// Lecturer
{
  lecturerId: string
  staffCode: string
  user: User
}

// Project
{
  projectId: string
  projectCode: string
  projectName: string
  courseId: string
  courseCode: string
  description: string
  technologies: string
  deletedAt: string | null
  memberCount: number
}

// Course
{
  courseId: string
  courseCode: string
  courseName: string
  status: string
  semester: Semester
  lecturer: Lecturer
}

// Semester
{
  semesterId: string
  name: string
  startDate: string
  endDate: string
}

// Enrollment
{
  enrollmentId: string
  studentId: string
  courseId: string
  projectId: string | null
  roleInProject: string
  groupNumber: number
  deletedAt: string | null
  removedFromProjectAt: string | null
}

// GithubRepository
{
  repoId: string
  repoUrl: string
  repoName: string
  owner: string
  isSelected: boolean
  projectId: string
}

// GroupRepository (grouped view)
{
  groupNumber: number
  projectId: string
  members: Student[]
  repositories: GithubRepository[]
}

// JWT Payload
{
  sub: string  // userId
  role: string
  iat: number
  exp: number
}

// API Wrapper
ApiResponse<T> = {
  code: number
  data: T
  errors: Record<string, string>
  message: string
  success: boolean
  timestamp: string
}

// Pagination
PaginatedResponse<T> = {
  content: T[]
  totalPages: number
  totalElements: number
  number: number  // current page (0-based)
  size: number
}
```

---

## 7. Tổng Hợp Trạng Thái Tính Năng

| Tính năng                 | Trạng thái    | Ghi chú                 |
| ------------------------- | ------------- | ----------------------- |
| Đăng nhập / Đăng xuất     | ✅ Hoàn thành | JWT + auto refresh      |
| Đăng ký tài khoản         | ✅ Hoàn thành |                         |
| Quản lý User (CRUD + CSV) | ✅ Hoàn thành | Import + Export CSV     |
| Quản lý Sinh viên (CRUD)  | ✅ Hoàn thành | CSV đang comment out    |
| Quản lý Giảng viên (CRUD) | ✅ Hoàn thành |                         |
| Quản lý Học kỳ (C/U/R)    | ✅ Hoàn thành | Chưa có Delete          |
| Quản lý Môn học (CRUD)    | ✅ Hoàn thành |                         |
| Quản lý Đăng ký môn học   | ✅ Hoàn thành | Enroll, assign, remove  |
| Quản lý Nhóm / Dự án      | ✅ Hoàn thành | Soft delete + Restore   |
| Quản lý Repository GitHub | ✅ Hoàn thành | CRUD + select main repo |
| Export Báo cáo Commit     | ✅ Hoàn thành | Excel + upload Supabase |
| Lịch sử Báo cáo Commit    | ✅ Hoàn thành | Xem + xóa report        |
| Tích hợp Jira             | ❌ Chưa làm   | Chỉ là placeholder      |
| Dashboard Student         | ⚠️ Chưa có    | Chỉ có landing page     |
| Dashboard Lecturer        | ⚠️ Chưa có    | Chỉ có landing page     |

---

## 8. Ghi Chú cho Mobile App

### Tính năng ưu tiên để port sang Mobile

Dựa trên những gì web đã có, mobile app nên tập trung vào:

1. **Auth flow** — Login, Logout, Token refresh (silent refresh)
2. **Student view:**
   - Xem thông tin nhóm/project của mình
   - Xem danh sách repo của nhóm
   - Xem commit report của bản thân
3. **Lecturer view:**
   - Xem danh sách môn học đang phụ trách
   - Xem nhóm sinh viên theo môn
   - Xem và quản lý Repository
   - Export báo cáo commit
4. **Admin view (nếu cần):**
   - Dashboard tổng quan
   - Quản lý user, sinh viên, giảng viên

### Lưu ý kỹ thuật

| Hạng mục              | Thông tin                                                                       |
| --------------------- | ------------------------------------------------------------------------------- |
| **Auth storage**      | Web dùng `localStorage` — Mobile dùng `SecureStore` (Expo) hoặc `AsyncStorage`  |
| **Token**             | Bearer JWT trong header `Authorization`                                         |
| **Refresh token**     | Cookie `httpOnly` trên web → Mobile cần cơ chế khác (lưu refresh token an toàn) |
| **File upload**       | Supabase Storage bucket: `edu-tool-storage`                                     |
| **Pagination**        | Server-side, Spring Page (0-based index)                                        |
| **API errors**        | Trả về `errors: Record<string, string>` cho validation từng field               |
| **Jira**              | Chưa có — không cần port                                                        |
| **CSV import/export** | Ít khả thi trên mobile, có thể bỏ qua                                           |
