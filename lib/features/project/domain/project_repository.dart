import 'package:edutool/features/project/data/models/github_repo_response.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';
import 'package:edutool/features/project/data/models/commit_report_url_response.dart';

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

  /// Calls `GET /api/github/repositories/project/{projectId}/report/csv`.
  /// Downloads the CSV content for the project report. Return byte array.
  Future<List<int>> downloadCommitReportCsv({
    required int projectId,
    String? since,
    String? until,
  });

  /// Calls `POST /api/github/repositories/project/{projectId}/report/storage-url`.
  /// Saves the report URL returned by Supabase to the backend DB.
  Future<CommitReportUrlResponse> saveCommitReportUrl({
    required int projectId,
    required String storageUrl,
    String? storageKey,
    String? storageId,
    String? since,
    String? until,
  });

  /// Calls `GET /api/github/repositories/project/{projectId}/report/storage-url`.
  /// Gets all previously generated and saved reports for the project.
  Future<List<CommitReportUrlResponse>> getCommitReportHistory(int projectId);
  
  /// Calls `DELETE /api/github/repositories/project/{projectId}/report/storage-url/{reportId}`.
  /// Deletes a previously saved report from the DB.
  Future<void> deleteCommitReportUrl(int projectId, int reportId);
}
