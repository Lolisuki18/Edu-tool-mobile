/// Response model for periodic report endpoints.
///
/// ```json
/// {
///   "reportId": 1,
///   "courseId": 1,
///   "courseCode": "SWD392",
///   "courseName": "Software Architecture Design",
///   "reportFromDate": "2026-03-01T00:00:00",
///   "reportToDate": "2026-03-07T23:59:59",
///   "submitStartAt": "2026-03-08T00:00:00",
///   "submitEndAt": "2026-03-10T23:59:59",
///   "description": "Báo cáo tuần 1",
///   "status": "ACTIVE",
///   "createdAt": "2026-03-08T10:00:00",
///   "reportDetailCount": 0
/// }
/// ```
class PeriodicReportResponse {
  final int reportId;
  final int courseId;
  final String courseCode;
  final String courseName;
  final String reportFromDate;
  final String reportToDate;
  final String submitStartAt;
  final String submitEndAt;
  final String? description;
  final String status;
  final String? createdAt;
  final int reportDetailCount;

  const PeriodicReportResponse({
    required this.reportId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.reportFromDate,
    required this.reportToDate,
    required this.submitStartAt,
    required this.submitEndAt,
    this.description,
    required this.status,
    this.createdAt,
    this.reportDetailCount = 0,
  });

  factory PeriodicReportResponse.fromJson(Map<String, dynamic> json) {
    return PeriodicReportResponse(
      reportId: json['reportId'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      reportFromDate: json['reportFromDate'] as String? ?? '',
      reportToDate: json['reportToDate'] as String? ?? '',
      submitStartAt: json['submitStartAt'] as String? ?? '',
      submitEndAt: json['submitEndAt'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      reportDetailCount: json['reportDetailCount'] as int? ?? 0,
    );
  }

  /// Whether the current time is within the submission window.
  bool get isSubmittable {
    try {
      final now = DateTime.now();
      final start = DateTime.parse(submitStartAt);
      final end = DateTime.parse(submitEndAt);
      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }
}
