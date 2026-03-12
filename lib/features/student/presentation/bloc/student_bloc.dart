import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/features/student/data/student_repository.dart';

import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository;

  /// Exposed for direct (non-BLoC) calls in tabs that manage their own state.
  StudentRepository get repository => _repository;

  StudentBloc({required StudentRepository repository})
    : _repository = repository,
      super(const StudentInitial()) {
    on<StudentLoadDashboard>(_onLoadDashboard);
    on<StudentLoadGroups>(_onLoadGroups);
    on<StudentLoadReports>(_onLoadReports);
    on<StudentSubmitRepo>(_onSubmitRepo);
    on<StudentChangePassword>(_onChangePassword);
    on<StudentUpdateGithubUsername>(_onUpdateGithubUsername);
  }

  Future<void> _onUpdateGithubUsername(
    StudentUpdateGithubUsername event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      await _repository.updateGithubUsername(
        studentId: event.studentId,
        githubUsername: event.githubUsername,
      );
      emit(const StudentActionSuccess(message: 'Cập nhật GitHub thành công'));
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Không thể cập nhật GitHub username'));
    }
  }

  Future<void> _onLoadDashboard(
    StudentLoadDashboard event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final user = await _repository.getMe();
      final student = await _repository.getStudentByUserId(user.userId);
      List<EnrollmentDetail> enrollments = [];
      if (student != null) {
        enrollments = await _repository.getMyEnrollments(student.studentId);
      }
      emit(
        StudentDashboardLoaded(
          user: user,
          student: student,
          enrollments: enrollments,
        ),
      );
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Đã xảy ra lỗi khi tải dữ liệu'));
    }
  }

  Future<void> _onLoadGroups(
    StudentLoadGroups event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final groups = await _repository.getGroupsByCourse(event.courseId);
      emit(StudentGroupsLoaded(groups: groups));
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Đã xảy ra lỗi khi tải nhóm'));
    }
  }

  Future<void> _onLoadReports(
    StudentLoadReports event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final reports = await _repository.getActiveReports(event.courseId);
      emit(StudentReportsLoaded(reports: reports));
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Đã xảy ra lỗi khi tải báo cáo'));
    }
  }

  Future<void> _onSubmitRepo(
    StudentSubmitRepo event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      await _repository.submitRepo(
        projectId: event.projectId,
        repoUrl: event.repoUrl,
      );
      emit(const StudentActionSuccess(message: 'Nộp repository thành công'));
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Không thể nộp repository'));
    }
  }

  Future<void> _onChangePassword(
    StudentChangePassword event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const StudentActionSuccess(message: 'Đổi mật khẩu thành công'));
    } on ServerException catch (e) {
      emit(StudentFailure(message: e.message));
    } catch (_) {
      emit(const StudentFailure(message: 'Không thể đổi mật khẩu'));
    }
  }
}
