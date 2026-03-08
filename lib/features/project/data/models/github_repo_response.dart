/// Response model for GitHub repository endpoints.
///
/// ```json
/// {
///   "repoId": 1,
///   "repoUrl": "https://github.com/org/repo",
///   "repoName": "repo",
///   "owner": "org",
///   "isSelected": false,
///   "projectId": 1,
///   "projectName": "EduTool Mobile App",
///   "projectCode": "PROJ-001",
///   "createdAt": "2026-03-08T10:00:00"
/// }
/// ```
class GithubRepoResponse {
  final int repoId;
  final String repoUrl;
  final String repoName;
  final String owner;
  final bool isSelected;
  final int projectId;
  final String projectName;
  final String projectCode;
  final String? createdAt;

  const GithubRepoResponse({
    required this.repoId,
    required this.repoUrl,
    required this.repoName,
    required this.owner,
    required this.isSelected,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    this.createdAt,
  });

  factory GithubRepoResponse.fromJson(Map<String, dynamic> json) {
    return GithubRepoResponse(
      repoId: json['repoId'] as int? ?? 0,
      repoUrl: json['repoUrl'] as String? ?? '',
      repoName: json['repoName'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
      projectId: json['projectId'] as int? ?? 0,
      projectName: json['projectName'] as String? ?? '',
      projectCode: json['projectCode'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }
}
