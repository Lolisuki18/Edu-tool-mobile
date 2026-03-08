# 🏗️ EduTool Mobile - Architecture & State Management Guide

Tài liệu này quy định kiến trúc tổng thể, cách quản lý trạng thái (State Management) và chiến lược xử lý dữ liệu của ứng dụng EduTool. Tuân thủ kiến trúc này giúp code dễ test, dễ mở rộng và đồng nhất khi làm việc nhóm (hoặc khi dùng AI để gen code).

---

## 1. Tech Stack Cốt Lõi

- **State Management:** `flutter_bloc` (Sử dụng Cubit cho các logic đơn giản và BLoC cho các màn hình phức tạp nhiều event).
- **Routing:** `go_router` (Hỗ trợ deep link và điều hướng theo role).
- **Dependency Injection (DI):** `get_it` kết hợp `injectable`.
- **Networking:** `dio` kết hợp `cookie_jar` (để quản lý HttpOnly Refresh Token).
- **Local Storage:** `flutter_secure_storage` (lưu Access Token), `shared_preferences` (lưu cài đặt app).

---

## 2. Kiến Trúc Dự Án (Clean Architecture - Feature Driven)

Dự án áp dụng mô hình Clean Architecture nhưng được chia theo từng Feature (Tính năng) để tránh thư mục quá phình to.

```text
lib/
├── core/                        # Cấu hình lõi (Theme, Network, DI, Constants)
│   ├── network/                 # Cấu hình Dio, Interceptors
│   ├── router/                  # Cấu hình go_router
│   └── errors/                  # Xử lý Exception chung
├── shared/                      # UI Components, Utils dùng chung (Button, Input)
└── features/
    ├── auth/                    # Feature: Đăng nhập, Đăng ký
    │   ├── data/                # Data Layer (Models, DataSources, Repositories Impl)
    │   ├── domain/              # Domain Layer (Entities, Repositories Interface)
    │   └── presentation/        # UI Layer (Screens, Widgets, BLoC/Cubit)
    ├── student/                 # Feature: Màn hình của Student
    └── lecturer/                # Feature: Màn hình của Lecturer




Nguyên tắc luồng dữ liệu (Data Flow)
UI (Screen) ➔ BLoC (xử lý event) ➔ Repository (xử lý logic gọi API/Local) ➔ DataSource (Dio gọi API) ➔ Trả data ngược lại để BLoC emit State ➔ UI cập nhật.

3. Quản Lý Trạng Thái (BLoC Pattern)
Mỗi màn hình chính sẽ đi kèm với một BLoC hoặc Cubit.

State Class: Cần sử dụng package freezed hoặc equatable để tạo State.

Trạng thái chuẩn: Luôn phải có 4 trạng thái cơ bản: Initial, Loading, Success(T data), Failure(String message).

4. Cơ chế xử lý Token & Networking
4.1. Access Token (Lưu ở SecureStorage)
Gắn vào header của mọi request (trừ các API /auth/*).

Thực hiện qua AuthInterceptor của Dio.

4.2. Refresh Token (Lưu ở Cookie)
Sử dụng dio_cookie_manager và cookie_jar. Khi API trả về 401 Unauthorized, TokenInterceptor sẽ thực hiện quy trình sau:

Lock Dio (chặn các request khác lại).

Gọi API POST /auth/refresh (cookie sẽ tự động được gửi kèm).

Nếu thành công: Cập nhật Access Token mới vào SecureStorage, Unlock Dio và retry (gọi lại) các request bị lỗi.

Nếu thất bại (Refresh Token cũng hết hạn): Xóa toàn bộ token cục bộ, điều hướng thẳng về màn hình Login qua go_router và báo "Phiên đăng nhập hết hạn".
```

Tất cả API đều trả về dạng BaseResponse<T>. Tầng DataSource phải parse được isSuccess và code.

Nếu isSuccess == false: Ném ra một ServerException chứa message và errors list.

Tầng Repository bắt Exception này và chuyển đổi thành Failure object để trả về cho BLoC.

BLoC emit trạng thái Failure(message). UI lắng nghe và hiển thị Toast/Snack
