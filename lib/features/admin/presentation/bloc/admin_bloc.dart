import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/features/admin/data/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc({required AdminRepository repository})
    : _repository = repository,
      super(const AdminInitial()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
    on<AdminLoadUsers>(_onLoadUsers);
    on<AdminCreateUser>(_onCreateUser);
    on<AdminUpdateUser>(_onUpdateUser);
    on<AdminDeleteUser>(_onDeleteUser);
    on<AdminLoadStudents>(_onLoadStudents);
    on<AdminLoadLecturers>(_onLoadLecturers);
    on<AdminLoadSemesters>(_onLoadSemesters);
    on<AdminCreateSemester>(_onCreateSemester);
    on<AdminUpdateSemester>(_onUpdateSemester);
    on<AdminDeleteSemester>(_onDeleteSemester);
    on<AdminLoadCourses>(_onLoadCourses);
    on<AdminCreateCourse>(_onCreateCourse);
    on<AdminUpdateCourse>(_onUpdateCourse);
    on<AdminDeleteCourse>(_onDeleteCourse);
    on<AdminLoadEnrollments>(_onLoadEnrollments);
    on<AdminCreateEnrollment>(_onCreateEnrollment);
    on<AdminUpdateEnrollment>(_onUpdateEnrollment);
    on<AdminDeleteEnrollment>(_onDeleteEnrollment);
    on<AdminLoadProjects>(_onLoadProjects);
    on<AdminCreateProject>(_onCreateProject);
    on<AdminDeleteProject>(_onDeleteProject);
    on<AdminChangePassword>(_onChangePassword);
  }

  AdminRepository get repository => _repository;

  // ── Dashboard ─────────────────────────────────────────────────────

  Future<void> _onLoadDashboard(
    AdminLoadDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final results = await Future.wait([
        _repository.getMe(),
        _repository.getDashboardCounts(),
      ]);
      emit(
        AdminDashboardLoaded(
          user: results[0] as dynamic,
          counts: results[1] as Map<String, int>,
        ),
      );
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Users ─────────────────────────────────────────────────────────

  Future<void> _onLoadUsers(
    AdminLoadUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final data = await _repository.getUsers(
        page: event.page,
        search: event.search,
      );
      emit(AdminUsersLoaded(data));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onCreateUser(
    AdminCreateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.createUser(event.body);
      emit(const AdminActionSuccess('Tạo user thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUser(
    AdminUpdateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.updateUser(event.id, event.body);
      emit(const AdminActionSuccess('Cập nhật user thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteUser(
    AdminDeleteUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteUser(event.id);
      emit(const AdminActionSuccess('Xóa user thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Students ──────────────────────────────────────────────────────

  Future<void> _onLoadStudents(
    AdminLoadStudents event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final data = await _repository.getStudents(
        page: event.page,
        search: event.search,
      );
      emit(AdminStudentsLoaded(data));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Lecturers ─────────────────────────────────────────────────────

  Future<void> _onLoadLecturers(
    AdminLoadLecturers event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final data = await _repository.getLecturers(
        page: event.page,
        search: event.search,
      );
      emit(AdminLecturersLoaded(data));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Semesters ─────────────────────────────────────────────────────

  Future<void> _onLoadSemesters(
    AdminLoadSemesters event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final semesters = await _repository.getSemesters();
      emit(AdminSemestersLoaded(semesters));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onCreateSemester(
    AdminCreateSemester event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.createSemester(event.body);
      emit(const AdminActionSuccess('Tạo học kỳ thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateSemester(
    AdminUpdateSemester event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.updateSemester(event.id, event.body);
      emit(const AdminActionSuccess('Cập nhật học kỳ thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteSemester(
    AdminDeleteSemester event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteSemester(event.id);
      emit(const AdminActionSuccess('Xóa học kỳ thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Courses ───────────────────────────────────────────────────────

  Future<void> _onLoadCourses(
    AdminLoadCourses event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final courses = await _repository.getCourses();
      emit(AdminCoursesLoaded(courses));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onCreateCourse(
    AdminCreateCourse event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.createCourse(event.body);
      emit(const AdminActionSuccess('Tạo môn học thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateCourse(
    AdminUpdateCourse event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.updateCourse(event.id, event.body);
      emit(const AdminActionSuccess('Cập nhật môn học thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteCourse(
    AdminDeleteCourse event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteCourse(event.id);
      emit(const AdminActionSuccess('Xóa môn học thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Enrollments ───────────────────────────────────────────────────

  Future<void> _onLoadEnrollments(
    AdminLoadEnrollments event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final data = await _repository.getEnrollments(courseId: event.courseId);
      emit(AdminEnrollmentsLoaded(data));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onCreateEnrollment(
    AdminCreateEnrollment event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.createEnrollment(event.body);
      emit(const AdminActionSuccess('Tạo enrollment thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateEnrollment(
    AdminUpdateEnrollment event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.updateEnrollment(event.id, event.body);
      emit(const AdminActionSuccess('Cập nhật enrollment thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteEnrollment(
    AdminDeleteEnrollment event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteEnrollment(event.id);
      emit(const AdminActionSuccess('Xóa enrollment thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Projects ──────────────────────────────────────────────────────

  Future<void> _onLoadProjects(
    AdminLoadProjects event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final data = await _repository.getProjects(
        page: event.page,
        courseId: event.courseId,
      );
      emit(AdminProjectsLoaded(data));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onCreateProject(
    AdminCreateProject event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.createProject(event.body);
      emit(const AdminActionSuccess('Tạo project thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteProject(
    AdminDeleteProject event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteProject(event.id);
      emit(const AdminActionSuccess('Xóa project thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ── Change Password ───────────────────────────────────────────────

  Future<void> _onChangePassword(
    AdminChangePassword event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const AdminActionSuccess('Đổi mật khẩu thành công'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }
}
