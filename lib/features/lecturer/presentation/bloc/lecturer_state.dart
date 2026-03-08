import 'package:equatable/equatable.dart';

import 'package:edutool/shared/models/models.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';

sealed class LecturerState extends Equatable {
  const LecturerState();

  @override
  List<Object?> get props => [];
}

class LecturerInitial extends LecturerState {
  const LecturerInitial();
}

class LecturerLoading extends LecturerState {
  const LecturerLoading();
}

/// Dashboard loaded — user info + courses.
class LecturerDashboardLoaded extends LecturerState {
  final User user;
  final List<Course> courses;

  const LecturerDashboardLoaded({required this.user, required this.courses});

  @override
  List<Object?> get props => [user, courses];
}

/// Groups for a specific course loaded.
class LecturerGroupsLoaded extends LecturerState {
  final List<GroupDetailResponse> groups;
  const LecturerGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

/// Projects for a course loaded.
class LecturerProjectsLoaded extends LecturerState {
  final List<ProjectResponse> projects;
  const LecturerProjectsLoaded({required this.projects});

  @override
  List<Object?> get props => [projects];
}

/// Commit report loaded.
class LecturerReportLoaded extends LecturerState {
  final Map<String, dynamic> reportData;
  const LecturerReportLoaded({required this.reportData});

  @override
  List<Object?> get props => [reportData];
}

/// A transient success.
class LecturerActionSuccess extends LecturerState {
  final String message;
  const LecturerActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LecturerFailure extends LecturerState {
  final String message;
  const LecturerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
