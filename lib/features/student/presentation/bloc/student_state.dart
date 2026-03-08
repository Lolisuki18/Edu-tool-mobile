import 'package:equatable/equatable.dart';

import 'package:edutool/shared/models/models.dart';
import 'package:edutool/features/student/data/student_repository.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

/// Dashboard loaded successfully.
class StudentDashboardLoaded extends StudentState {
  final User user;
  final Student? student;
  final List<EnrollmentDetail> enrollments;

  const StudentDashboardLoaded({
    required this.user,
    this.student,
    required this.enrollments,
  });

  @override
  List<Object?> get props => [user, student, enrollments];
}

/// Group details loaded for a course.
class StudentGroupsLoaded extends StudentState {
  final List<GroupDetailResponse> groups;

  const StudentGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

/// Active reports loaded for a course.
class StudentReportsLoaded extends StudentState {
  final List<PeriodicReportResponse> reports;

  const StudentReportsLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

/// A one-off action succeeded.
class StudentActionSuccess extends StudentState {
  final String message;
  const StudentActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StudentFailure extends StudentState {
  final String message;
  const StudentFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
