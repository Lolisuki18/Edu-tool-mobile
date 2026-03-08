import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadDashboard extends AdminEvent {
  const AdminLoadDashboard();
}

class AdminLoadUsers extends AdminEvent {
  final int page;
  final String? search;
  const AdminLoadUsers({this.page = 0, this.search});

  @override
  List<Object?> get props => [page, search];
}

class AdminCreateUser extends AdminEvent {
  final Map<String, dynamic> body;
  const AdminCreateUser(this.body);

  @override
  List<Object?> get props => [body];
}

class AdminUpdateUser extends AdminEvent {
  final String id;
  final Map<String, dynamic> body;
  const AdminUpdateUser({required this.id, required this.body});

  @override
  List<Object?> get props => [id, body];
}

class AdminDeleteUser extends AdminEvent {
  final String id;
  const AdminDeleteUser(this.id);

  @override
  List<Object?> get props => [id];
}

class AdminLoadStudents extends AdminEvent {
  final int page;
  final String? search;
  const AdminLoadStudents({this.page = 0, this.search});

  @override
  List<Object?> get props => [page, search];
}

class AdminLoadLecturers extends AdminEvent {
  final int page;
  final String? search;
  const AdminLoadLecturers({this.page = 0, this.search});

  @override
  List<Object?> get props => [page, search];
}

class AdminLoadSemesters extends AdminEvent {
  const AdminLoadSemesters();
}

class AdminCreateSemester extends AdminEvent {
  final Map<String, dynamic> body;
  const AdminCreateSemester(this.body);

  @override
  List<Object?> get props => [body];
}

class AdminUpdateSemester extends AdminEvent {
  final String id;
  final Map<String, dynamic> body;
  const AdminUpdateSemester({required this.id, required this.body});

  @override
  List<Object?> get props => [id, body];
}

class AdminDeleteSemester extends AdminEvent {
  final String id;
  const AdminDeleteSemester(this.id);

  @override
  List<Object?> get props => [id];
}

class AdminLoadCourses extends AdminEvent {
  const AdminLoadCourses();
}

class AdminCreateCourse extends AdminEvent {
  final Map<String, dynamic> body;
  const AdminCreateCourse(this.body);

  @override
  List<Object?> get props => [body];
}

class AdminUpdateCourse extends AdminEvent {
  final String id;
  final Map<String, dynamic> body;
  const AdminUpdateCourse({required this.id, required this.body});

  @override
  List<Object?> get props => [id, body];
}

class AdminDeleteCourse extends AdminEvent {
  final String id;
  const AdminDeleteCourse(this.id);

  @override
  List<Object?> get props => [id];
}

class AdminLoadEnrollments extends AdminEvent {
  final int courseId;
  const AdminLoadEnrollments({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class AdminCreateEnrollment extends AdminEvent {
  final Map<String, dynamic> body;
  const AdminCreateEnrollment(this.body);

  @override
  List<Object?> get props => [body];
}

class AdminDeleteEnrollment extends AdminEvent {
  final String id;
  const AdminDeleteEnrollment(this.id);

  @override
  List<Object?> get props => [id];
}

class AdminUpdateEnrollment extends AdminEvent {
  final String id;
  final Map<String, dynamic> body;
  const AdminUpdateEnrollment({required this.id, required this.body});

  @override
  List<Object?> get props => [id, body];
}

class AdminLoadProjects extends AdminEvent {
  final int page;
  final int? courseId;
  const AdminLoadProjects({this.page = 0, this.courseId});

  @override
  List<Object?> get props => [page, courseId];
}

class AdminCreateProject extends AdminEvent {
  final Map<String, dynamic> body;
  const AdminCreateProject(this.body);

  @override
  List<Object?> get props => [body];
}

class AdminDeleteProject extends AdminEvent {
  final String id;
  const AdminDeleteProject(this.id);

  @override
  List<Object?> get props => [id];
}

class AdminChangePassword extends AdminEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  const AdminChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
