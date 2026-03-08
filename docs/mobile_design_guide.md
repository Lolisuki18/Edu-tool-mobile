# 📱 EduTool Design System – Mobile UI/UX Guide (Academic Style)

Tài liệu này định nghĩa chuẩn thiết kế giao diện cho **EduTool Mobile App**, kế thừa triết lý từ phiên bản Web nhưng được tối ưu hóa cho màn hình cảm ứng và không gian di động.

Mục tiêu:

- Tối ưu hóa **vùng chạm (Touch Targets)** và **khả năng đọc (Readability)** trên màn hình nhỏ.
- Giữ vững triết lý **Academic First** (Rõ ràng > Màu mè, Giảm tải nhận thức).

---

## 1. Hệ thống màu sắc (App Colors)

Vẫn giữ nguyên bộ màu học thuật từ Web, nhưng quy định lại tỷ lệ sử dụng trên Mobile.

| Thuộc tính     | Màu            | Hex       | Ý nghĩa & Cách dùng trên Mobile         |
| :------------- | :------------- | :-------- | :-------------------------------------- |
| **Primary**    | Academic Blue  | `#1E40AF` | App Bar, Nút chính, Card nổi bật.       |
| **Secondary**  | Neutral Slate  | `#475569` | Icon tab không active, Nút phụ.         |
| **Background** | App Background | `#F8FAFC` | Màu nền chủ đạo của toàn bộ app.        |
| **Card**       | Surface/Panel  | `#FFFFFF` | Nền của các Card, Dialog, Bottom Sheet. |
| **Success**    | Green          | `#15803D` | Trạng thái nộp bài thành công.          |
| **Warning**    | Amber          | `#B45309` | Deadline sắp tới.                       |
| **Error**      | Red            | `#B91C1C` | Lỗi mạng, Deadline quá hạn.             |

---

## 2. Typography (Kích thước chữ Mobile)

Chữ trên Mobile cần nhỏ hơn Web nhưng khoảng cách dòng (Line-height) phải đủ rộng để dễ đọc. Sử dụng font **Inter**.

| Loại        | Size | Line-height | Weight          | Ứng dụng thực tế                     |
| :---------- | :--- | :---------- | :-------------- | :----------------------------------- |
| **H1**      | 24px | 32px        | 600 (Semi-bold) | Tiêu đề màn hình chính (Greeting)    |
| **H2**      | 20px | 28px        | 600 (Semi-bold) | Tiêu đề AppBar, Tên môn học          |
| **H3**      | 18px | 26px        | 600 (Semi-bold) | Tiêu đề Card, Dialog, Bottom Sheet   |
| **Body**    | 16px | 24px        | 400 (Regular)   | Nội dung bài học, Mô tả dài          |
| **Small**   | 14px | 20px        | 400 (Regular)   | Phụ đề, Nút bấm phụ, Text field      |
| **Caption** | 12px | 16px        | 400 (Regular)   | Metadata, Giờ giấc, Badge trạng thái |

---

## 3. Touch Targets & Spacing (Kích thước & Khoảng cách)

Thiết bị di động sử dụng ngón tay để tương tác, do đó không gian chạm rất quan trọng.

- **Vùng chạm tối thiểu (Min Touch Target):** `48x48 pt`. Mọi nút bấm, icon có thể ấn được không được nhỏ hơn kích thước này (kể cả icon nhỏ cũng phải có padding trong suốt để đủ 48pt).
- **Chiều cao Nút chính (Primary Button Height):** `48px` đến `56px`. Chiều rộng (Width) thường là full màn hình trừ đi margin.
- **Margin lề màn hình:** Tiêu chuẩn là `16px` hoặc `20px` từ mép màn hình vào nội dung.
- **Khoảng cách các phần tử (Spacing):** Dùng hệ số của 4 hoặc 8 (`4px`, `8px`, `16px`, `24px`, `32px`).

---

## 4. Hành vi tương tác (Mobile Gestures)

- **Không có Hover:** Thay thế trạng thái Hover của Web bằng trạng thái **Pressed (Ripple Effect)**.
- **Navigation:** Sử dụng **Bottom Navigation Bar** cho các tính năng cốt lõi. Dùng **Bottom Sheet** thay vì Modal/Popup giữa màn hình khi cần chọn/nhập liệu nhanh.
- **Pull to Refresh:** Bắt buộc có ở các màn hình danh sách (Danh sách bài tập, Thông báo).

📌 _EduTool Design System – Mobile Edition | Version: 1.0_
