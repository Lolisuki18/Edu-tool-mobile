import 'package:equatable/equatable.dart';

sealed class LecturerEvent extends Equatable {
  const LecturerEvent();

  @override
  List<Object?> get props => [];
}

/// Load lecturer dashboard (user profile + courses).
class LecturerLoadDashboard extends LecturerEvent {
  const LecturerLoadDashboard();
}

/// Load groups for a specific course.
class LecturerLoadGroups extends LecturerEvent {
  final int courseId;
  const LecturerLoadGroups({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load projects for a course.
class LecturerLoadProjects extends LecturerEvent {
  final int courseId;
  const LecturerLoadProjects({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Submit a repository for a project.
class LecturerSubmitRepo extends LecturerEvent {
  final int projectId;
  final String repoUrl;
  final String? repoName;
  const LecturerSubmitRepo({
    required this.projectId,
    required this.repoUrl,
    this.repoName,
  });

  @override
  List<Object?> get props => [projectId, repoUrl, repoName];
}

/// Select a repo to track.
class LecturerSelectRepo extends LecturerEvent {
  final int repoId;
  const LecturerSelectRepo({required this.repoId});

  @override
  List<Object?> get props => [repoId];
}

/// Delete a repo.
class LecturerDeleteRepo extends LecturerEvent {
  final int repoId;
  const LecturerDeleteRepo({required this.repoId});

  @override
  List<Object?> get props => [repoId];
}

/// Generate commit report for a project.
class LecturerGenerateReport extends LecturerEvent {
  final int projectId;
  final String? since;
  final String? until;
  const LecturerGenerateReport({
    required this.projectId,
    this.since,
    this.until,
  });

  @override
  List<Object?> get props => [projectId, since, until];
}

/// Create a new project.
class LecturerCreateProject extends LecturerEvent {
  final String projectCode;
  final String projectName;
  final int courseId;
  final String? description;
  final String? technologies;
  const LecturerCreateProject({
    required this.projectCode,
    required this.projectName,
    required this.courseId,
    this.description,
    this.technologies,
  });

  @override
  List<Object?> get props => [projectCode, projectName, courseId];
}

/// Change password.
class LecturerChangePassword extends LecturerEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  const LecturerChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}
