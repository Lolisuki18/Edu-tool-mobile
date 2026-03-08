import 'package:equatable/equatable.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/shared/models/models.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminDashboardLoaded extends AdminState {
  final User user;
  final Map<String, int> counts;
  const AdminDashboardLoaded({required this.user, required this.counts});

  @override
  List<Object?> get props => [user, counts];
}

class AdminUsersLoaded extends AdminState {
  final PaginatedData<User> data;
  const AdminUsersLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AdminStudentsLoaded extends AdminState {
  final PaginatedData<Student> data;
  const AdminStudentsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AdminLecturersLoaded extends AdminState {
  final PaginatedData<Lecturer> data;
  const AdminLecturersLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AdminSemestersLoaded extends AdminState {
  final List<Semester> semesters;
  const AdminSemestersLoaded(this.semesters);

  @override
  List<Object?> get props => [semesters];
}

class AdminCoursesLoaded extends AdminState {
  final List<Course> courses;
  const AdminCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class AdminEnrollmentsLoaded extends AdminState {
  final List<Enrollment> enrollments;
  const AdminEnrollmentsLoaded(this.enrollments);

  @override
  List<Object?> get props => [enrollments];
}

class AdminProjectsLoaded extends AdminState {
  final PaginatedData<Project> data;
  const AdminProjectsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminFailure extends AdminState {
  final String message;
  const AdminFailure(this.message);

  @override
  List<Object?> get props => [message];
}
