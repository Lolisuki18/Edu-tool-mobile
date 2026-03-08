import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/features/project/domain/project_repository.dart';

import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _repository;

  /// The courseId currently being viewed — kept so we can re-fetch after
  /// a mutating action (submit repo, select repo, etc.).
  int? _activeCourseId;

  ProjectBloc({required ProjectRepository repository})
    : _repository = repository,
      super(const ProjectInitial()) {
    on<ProjectLoadGroups>(_onLoadGroups);
    on<ProjectSubmitRepo>(_onSubmitRepo);
    on<ProjectSelectRepo>(_onSelectRepo);
    on<ProjectExportReport>(_onExportReport);
  }

  // ── Load groups ────────────────────────────────────────────────────────────

  Future<void> _onLoadGroups(
    ProjectLoadGroups event,
    Emitter<ProjectState> emit,
  ) async {
    _activeCourseId = event.courseId;
    emit(const ProjectLoading());
    try {
      final groups = await _repository.getGroupsByCourse(event.courseId);
      emit(ProjectGroupsLoaded(groups: groups));
    } on ServerException catch (e) {
      emit(ProjectFailure(message: e.message));
    } catch (_) {
      emit(const ProjectFailure(message: 'Đã xảy ra lỗi khi tải dữ liệu'));
    }
  }

  // ── Submit repo ────────────────────────────────────────────────────────────

  Future<void> _onSubmitRepo(
    ProjectSubmitRepo event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      await _repository.submitRepo(
        projectId: event.projectId,
        repoUrl: event.repoUrl,
        repoName: event.repoName,
      );
      emit(const ProjectActionSuccess(message: 'Nộp repository thành công'));

      // Re-fetch groups so the list updates.
      if (_activeCourseId != null) {
        add(ProjectLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(ProjectFailure(message: e.message));
    } catch (_) {
      emit(const ProjectFailure(message: 'Không thể nộp repository'));
    }
  }

  // ── Select / switch tracked repo ───────────────────────────────────────────

  Future<void> _onSelectRepo(
    ProjectSelectRepo event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      await _repository.selectRepo(event.repoId);
      emit(const ProjectActionSuccess(message: 'Đã chọn repository để track'));

      if (_activeCourseId != null) {
        add(ProjectLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(ProjectFailure(message: e.message));
    } catch (_) {
      emit(const ProjectFailure(message: 'Không thể chọn repository'));
    }
  }

  // ── Export commit report ───────────────────────────────────────────────────

  Future<void> _onExportReport(
    ProjectExportReport event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      final msg = await _repository.exportCommitReport(
        projectId: event.projectId,
        since: event.since,
        until: event.until,
      );
      emit(ProjectActionSuccess(message: msg));

      // Restore the groups list after showing the success snackbar.
      if (_activeCourseId != null) {
        add(ProjectLoadGroups(courseId: _activeCourseId!));
      }
    } on ServerException catch (e) {
      emit(ProjectFailure(message: e.message));
    } catch (_) {
      emit(const ProjectFailure(message: 'Không thể xuất báo cáo commit'));
    }
  }
}
