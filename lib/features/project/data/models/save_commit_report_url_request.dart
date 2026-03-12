/// Request body for `POST /api/github/repositories/project/{projectId}/report/storage-url`.
class SaveCommitReportUrlRequest {
  final String storageUrl;
  final String? storageKey;
  final String? storageId;
  final String? since;
  final String? until;

  SaveCommitReportUrlRequest({
    required this.storageUrl,
    this.storageKey,
    this.storageId,
    this.since,
    this.until,
  });

  Map<String, dynamic> toJson() {
    return {
      'storageUrl': storageUrl,
      if (storageKey != null) 'storageKey': storageKey,
      if (storageId != null) 'storageId': storageId,
      if (since != null) 'since': since,
      if (until != null) 'until': until,
    };
  }
}
