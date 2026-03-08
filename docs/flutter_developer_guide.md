Markdown# 🛠️ EduTool Design System - Flutter Developer Guide

Tài liệu này hướng dẫn cách setup và sử dụng Design System của EduTool trên nền tảng Flutter. Tuân thủ tài liệu này giúp ứng dụng đồng nhất, dễ bảo trì và không bị rác code bởi các màu sắc/font chữ hardcode.

---

## 1. Cấu trúc thư mục lõi (Folder Structure)

Toàn bộ Design System được đặt trong thư mục `core/theme` và các widget dùng chung đặt ở `shared/widgets`.

```text
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart      # Chứa các hằng số màu sắc
│       ├── app_typography.dart  # Cấu hình TextTheme với font Inter
│       └── app_theme.dart       # Lắp ráp ThemeData tổng
├── shared/
│   └── widgets/
│       ├── academic_button.dart # Custom button chuẩn
│       ├── academic_input.dart  # Custom textfield chuẩn
│       └── status_badge.dart    # Label/Badge trạng thái


2. Nguyên tắc Code (Best Practices)✅ DO (Nên làm)Sử dụng Theme.of(context) để lấy màu và font chữ. Điều này giúp app tự động thích ứng nếu sau này có Dark Mode hoặc đổi màu thương hiệu.Dart// Lấy màu từ AppColors hằng số (cho những màu bất biến)
Container(color: AppColors.background)

// Lấy text style từ Theme context
Text(
  'Tiêu đề bài học',
  style: Theme.of(context).textTheme.displayMedium, // Tương đương H2
)
❌ DON'T (Không nên)Tuyệt đối không hardcode mã màu hex hoặc kích thước font chữ trực tiếp vào các UI Widget.Dart// ❌ SAI: Hardcode mã màu, kích thước gây khó maintain
Text(
  'Tiêu đề',
  style: TextStyle(color: Color(0xFF1E40AF), fontSize: 20, fontWeight: FontWeight.bold),
)
3. Cấu hình cốt lõiBảng Mapping TextStyleFlutter có hệ thống TextTheme mặc định, chúng ta sẽ map (ánh xạ) nó với chuẩn Design System của EduTool:EduTool DesignFlutter TextThemeCode mẫuH1 (24px, w600)displayLargeTheme.of(context).textTheme.displayLargeH2 (20px, w600)displayMediumTheme.of(context).textTheme.displayMediumH3 (18px, w600)displaySmallTheme.of(context).textTheme.displaySmallBody (16px, w400)bodyLargeTheme.of(context).textTheme.bodyLargeSmall (14px, w400)bodyMediumTheme.of(context).textTheme.bodyMediumCaption (12px, w400)labelSmallTheme.of(context).textTheme.labelSmallKhởi tạo AppTheme trong main.dartĐảm bảo MaterialApp của bạn đang sử dụng đúng AppTheme đã thiết lập:Dartimport 'core/theme/app_theme.dart';

MaterialApp(
  title: 'EduTool Mobile',
  theme: AppTheme.lightTheme, // Inject Design System vào đây
  home: const StudentDashboardScreen(),
)
4. Xây dựng Custom WidgetsThay vì dùng ElevatedButton hay TextFormField thô của Flutter rồi copy-paste style khắp nơi, hãy tạo các Wrapper Widget trong thư mục shared/widgets.Ví dụ cách gọi một nút bấm:DartAcademicButton(
  text: 'Nộp bài',
  type: ButtonType.primary,
  onPressed: () => submitAssignment(),
)
```
