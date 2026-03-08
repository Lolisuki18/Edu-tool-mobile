import 'package:edutool/features/report/data/models/periodic_report_response.dart';

/// Contract for periodic report operations (Student).
abstract class ReportRepository {
  /// Fetches active (submittable) periodic reports for [courseId].
  ///
  /// Calls `GET /api/periodic-reports/courses/{courseId}/submissions/active`.
  Future<List<PeriodicReportResponse>> getActiveReports({
    required int courseId,
    int page = 0,
    int size = 20,
  });
}
