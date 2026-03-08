/// Request body for `POST /api/github/repositories`.
class SubmitRepoRequest {
  final int projectId;
  final String repoUrl;
  final String? repoName;

  const SubmitRepoRequest({
    required this.projectId,
    required this.repoUrl,
    this.repoName,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'repoUrl': repoUrl,
      if (repoName != null) 'repoName': repoName,
    };
  }
}
