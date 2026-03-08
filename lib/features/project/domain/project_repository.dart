import 'package:edutool/features/project/data/models/github_repo_response.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';

/// Contract for project & GitHub repository operations.
abstract class ProjectRepository {
  /// Fetches all projects belonging to [courseId].
  Future<List<ProjectResponse>> getProjectsByCourse(int courseId);

  /// Fetches group details (members + repos) for a course.
  Future<List<GroupDetailResponse>> getGroupsByCourse(int courseId);

  /// Submits a new GitHub repository for a project.
  Future<GithubRepoResponse> submitRepo({
    required int projectId,
    required String repoUrl,
    String? repoName,
  });

  /// Gets all repositories for a project.
  Future<List<GithubRepoResponse>> getReposByProject(int projectId);

  /// Selects a repo to track commits.
  Future<GithubRepoResponse> selectRepo(int repoId);

  /// Exports commit report as JSON (returns server message on success).
  Future<String> exportCommitReport({
    required int projectId,
    String? since,
    String? until,
  });
}
