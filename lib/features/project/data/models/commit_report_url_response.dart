/// Response model for `GET /api/github/repositories/project/{projectId}/report/storage-url`.
class CommitReportUrlResponse {
  final int commitReportId;
  final int projectId;
  final String storageUrl;
  final String? storageKey;
  final String? storageId;
  final String? sinceDate;
  final String? untilDate;
  final String createdAt;

  CommitReportUrlResponse({
    required this.commitReportId,
    required this.projectId,
    required this.storageUrl,
    this.storageKey,
    this.storageId,
    this.sinceDate,
    this.untilDate,
    required this.createdAt,
  });

  factory CommitReportUrlResponse.fromJson(Map<String, dynamic> json) {
    return CommitReportUrlResponse(
      commitReportId: json['commitReportId'] as int,
      projectId: json['projectId'] as int,
      storageUrl: json['storageUrl'] as String,
      storageKey: json['storageKey'] as String?,
      storageId: json['storageId'] as String?,
      sinceDate: json['sinceDate'] as String?,
      untilDate: json['untilDate'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commitReportId': commitReportId,
      'projectId': projectId,
      'storageUrl': storageUrl,
      if (storageKey != null) 'storageKey': storageKey,
      if (storageId != null) 'storageId': storageId,
      if (sinceDate != null) 'sinceDate': sinceDate,
      if (untilDate != null) 'untilDate': untilDate,
      'createdAt': createdAt,
    };
  }
}
