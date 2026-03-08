import 'package:equatable/equatable.dart';

sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Load group details (members + repos) for a course.
class ProjectLoadGroups extends ProjectEvent {
  final int courseId;

  const ProjectLoadGroups({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Submit a new GitHub repository URL for a project.
class ProjectSubmitRepo extends ProjectEvent {
  final int projectId;
  final String repoUrl;
  final String? repoName;

  const ProjectSubmitRepo({
    required this.projectId,
    required this.repoUrl,
    this.repoName,
  });

  @override
  List<Object?> get props => [projectId, repoUrl, repoName];
}

/// Select / switch the tracked repository for a project.
class ProjectSelectRepo extends ProjectEvent {
  final int repoId;

  const ProjectSelectRepo({required this.repoId});

  @override
  List<Object?> get props => [repoId];
}

/// Export commit report (JSON) for a project.
class ProjectExportReport extends ProjectEvent {
  final int projectId;
  final String? since;
  final String? until;

  const ProjectExportReport({required this.projectId, this.since, this.until});

  @override
  List<Object?> get props => [projectId, since, until];
}
