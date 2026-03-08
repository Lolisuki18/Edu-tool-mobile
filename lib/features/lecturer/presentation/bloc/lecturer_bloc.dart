import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/features/lecturer/data/lecturer_repository.dart';

import 'lecturer_event.dart';
import 'lecturer_state.dart';

class LecturerBloc extends Bloc<LecturerEvent, LecturerState> {
  final LecturerRepository _repository;

  /// Exposed for direct calls in tabs.
  LecturerRepository get repository => _repository;

  int? _activeCourseId;

  LecturerBloc({required LecturerRepository repository})
    : _repository = repository,
      super(const LecturerInitial()) {
    on<LecturerLoadDashboard>(_onLoadDashboard);
    on<LecturerLoadGroups>(_onLoadGroups);
    on<LecturerLoadProjects>(_onLoadProjects);
    on<LecturerSubmitRepo>(_onSubmitRepo);
    on<LecturerSelectRepo>(_onSelectRepo);
    on<LecturerDeleteRepo>(_onDeleteRepo);
    on<LecturerGenerateReport>(_onGenerateReport);
    on<LecturerCreateProject>(_onCreateProject);
    on<LecturerChangePassword>(_onChangePassword);
    on<LecturerLoadPeriodicReports>(_onLoadPeriodicReports);
    on<LecturerCreatePeriodicReport>(_onCreatePeriodicReport);
    on<LecturerDeletePeriodicReport>(_onDeletePeriodicReport);
  }

  Future<void> _onLoadDashboard(
    LecturerLoadDashboard event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      final user = await _repository.getMe();
      final courses = await _repository.getCourses();
      emit(LecturerDashboardLoaded(user: user, courses: courses));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Đã xảy ra lỗi khi tải dữ liệu'));
    }
  }

  Future<void> _onLoadGroups(
    LecturerLoadGroups event,
    Emitter<LecturerState> emit,
  ) async {
    _activeCourseId = event.courseId;
    emit(const LecturerLoading());
    try {
      final groups = await _repository.getGroupsByCourse(event.courseId);
      emit(LecturerGroupsLoaded(groups: groups));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Đã xảy ra lỗi khi tải nhóm'));
    }
  }

  Future<void> _onLoadProjects(
    LecturerLoadProjects event,
    Emitter<LecturerState> emit,
  ) async {
    _activeCourseId = event.courseId;
    emit(const LecturerLoading());
    try {
      final projects = await _repository.getProjectsByCourse(event.courseId);
      emit(LecturerProjectsLoaded(projects: projects));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Đã xảy ra lỗi khi tải project'));
    }
  }

  Future<void> _onSubmitRepo(
    LecturerSubmitRepo event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.submitRepo(
        projectId: event.projectId,
        repoUrl: event.repoUrl,
        repoName: event.repoName,
      );
      emit(const LecturerActionSuccess(message: 'Nộp repository thành công'));
      if (_activeCourseId != null) {
        add(LecturerLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể nộp repository'));
    }
  }

  Future<void> _onSelectRepo(
    LecturerSelectRepo event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.selectRepo(event.repoId);
      emit(const LecturerActionSuccess(message: 'Đã chọn repository'));
      if (_activeCourseId != null) {
        add(LecturerLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể chọn repository'));
    }
  }

  Future<void> _onDeleteRepo(
    LecturerDeleteRepo event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.deleteRepo(event.repoId);
      emit(const LecturerActionSuccess(message: 'Đã xóa repository'));
      if (_activeCourseId != null) {
        add(LecturerLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể xóa repository'));
    }
  }

  Future<void> _onGenerateReport(
    LecturerGenerateReport event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      final data = await _repository.getCommitReport(
        projectId: event.projectId,
        since: event.since,
        until: event.until,
      );
      emit(LecturerReportLoaded(reportData: data));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể tải báo cáo commit'));
    }
  }

  Future<void> _onCreateProject(
    LecturerCreateProject event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.createProject(
        projectCode: event.projectCode,
        projectName: event.projectName,
        courseId: event.courseId,
        description: event.description,
        technologies: event.technologies,
      );
      emit(const LecturerActionSuccess(message: 'Tạo project thành công'));
      add(LecturerLoadProjects(courseId: event.courseId));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể tạo project'));
    }
  }

  Future<void> _onChangePassword(
    LecturerChangePassword event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const LecturerActionSuccess(message: 'Đổi mật khẩu thành công'));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể đổi mật khẩu'));
    }
  }

  // ── Periodic Reports ────────────────────────────────────────────

  Future<void> _onLoadPeriodicReports(
    LecturerLoadPeriodicReports event,
    Emitter<LecturerState> emit,
  ) async {
    _activeCourseId = event.courseId;
    emit(const LecturerLoading());
    try {
      final reports = await _repository.getPeriodicReportsByCourse(
        event.courseId,
      );
      emit(LecturerPeriodicReportsLoaded(reports: reports));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể tải báo cáo định kỳ'));
    }
  }

  Future<void> _onCreatePeriodicReport(
    LecturerCreatePeriodicReport event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.createPeriodicReport(
        courseId: event.courseId,
        reportFromDate: event.reportFromDate,
        reportToDate: event.reportToDate,
        submitStartAt: event.submitStartAt,
        submitEndAt: event.submitEndAt,
        description: event.description,
      );
      emit(
        const LecturerActionSuccess(message: 'Tạo báo cáo định kỳ thành công'),
      );
      add(LecturerLoadPeriodicReports(courseId: event.courseId));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể tạo báo cáo'));
    }
  }

  Future<void> _onDeletePeriodicReport(
    LecturerDeletePeriodicReport event,
    Emitter<LecturerState> emit,
  ) async {
    emit(const LecturerLoading());
    try {
      await _repository.deletePeriodicReport(event.reportId);
      emit(const LecturerActionSuccess(message: 'Đã xóa báo cáo'));
      add(LecturerLoadPeriodicReports(courseId: event.courseId));
    } on ServerException catch (e) {
      emit(LecturerFailure(message: e.message));
    } catch (_) {
      emit(const LecturerFailure(message: 'Không thể xóa báo cáo'));
    }
  }
}
