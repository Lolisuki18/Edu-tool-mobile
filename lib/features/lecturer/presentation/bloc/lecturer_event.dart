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

/// Load periodic reports for a course.
class LecturerLoadPeriodicReports extends LecturerEvent {
  final int courseId;
  const LecturerLoadPeriodicReports({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Create a periodic report.
class LecturerCreatePeriodicReport extends LecturerEvent {
  final int courseId;
  final String reportFromDate;
  final String reportToDate;
  final String submitStartAt;
  final String submitEndAt;
  final String? description;
  const LecturerCreatePeriodicReport({
    required this.courseId,
    required this.reportFromDate,
    required this.reportToDate,
    required this.submitStartAt,
    required this.submitEndAt,
    this.description,
  });

  @override
  List<Object?> get props => [courseId, reportFromDate, reportToDate];
}

/// Delete a periodic report.
class LecturerDeletePeriodicReport extends LecturerEvent {
  final int reportId;
  final int courseId;
  const LecturerDeletePeriodicReport({
    required this.reportId,
    required this.courseId,
  });

  @override
  List<Object?> get props => [reportId, courseId];
}

/// Assign student to a project/group.
class LecturerAssignStudentToGroup extends LecturerEvent {
  final int enrollmentId;
  final int projectId;
  final int groupNumber;
  final String? role;

  const LecturerAssignStudentToGroup({
    required this.enrollmentId,
    required this.projectId,
    required this.groupNumber,
    this.role,
  });

  @override
  List<Object?> get props => [enrollmentId, projectId, groupNumber, role];
}

/// Update user profile.
class LecturerUpdateProfile extends LecturerEvent {
  final String fullName;

  const LecturerUpdateProfile({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}
