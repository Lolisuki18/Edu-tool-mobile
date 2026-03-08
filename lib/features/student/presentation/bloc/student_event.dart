import 'package:equatable/equatable.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile + student profile + enrollments.
class StudentLoadDashboard extends StudentEvent {
  const StudentLoadDashboard();
}

/// Load group details for a specific course.
class StudentLoadGroups extends StudentEvent {
  final int courseId;
  const StudentLoadGroups({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load active periodic reports for a course.
class StudentLoadReports extends StudentEvent {
  final int courseId;
  const StudentLoadReports({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Submit a GitHub repository.
class StudentSubmitRepo extends StudentEvent {
  final int projectId;
  final String repoUrl;
  const StudentSubmitRepo({required this.projectId, required this.repoUrl});

  @override
  List<Object?> get props => [projectId, repoUrl];
}

/// Change password.
class StudentChangePassword extends StudentEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  const StudentChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}
