import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:edutool/features/project/domain/project_repository.dart';
import 'admin_repo_event.dart';
import 'admin_repo_state.dart';

class AdminRepoBloc extends Bloc<AdminRepoEvent, AdminRepoState> {
  final ProjectRepository _repository;
  final SupabaseClient _supabase;

  AdminRepoBloc({
    required ProjectRepository repository,
    required SupabaseClient supabase,
  })  : _repository = repository,
        _supabase = supabase,
        super(const AdminRepoInitial()) {
    on<LoadGroupsByCourse>(_onLoadGroups);
    on<ExportCommitReport>(_onExportCommitReport);
    on<LoadExportHistory>(_onLoadExportHistory);
    on<DeleteExportReport>(_onDeleteExportReport);
  }

  Future<void> _onLoadGroups(
    LoadGroupsByCourse event,
    Emitter<AdminRepoState> emit,
  ) async {
    emit(const AdminRepoLoading());
    try {
      final groups = await _repository.getGroupsByCourse(event.courseId);
      emit(AdminRepoGroupsLoaded(groups));
    } catch (e) {
      emit(AdminRepoFailure(e.toString()));
    }
  }

  Future<void> _onExportCommitReport(
    ExportCommitReport event,
    Emitter<AdminRepoState> emit,
  ) async {
    emit(const AdminRepoLoading());
    try {
      // 1. Download CSV bytes from backend
      final bytes = await _repository.downloadCommitReportCsv(projectId: event.projectId);

      // 2. Upload to Supabase Storage
      final fileName = 'commit-report-project-${event.projectId}-${event.datePrefix}-${DateTime.now().millisecondsSinceEpoch}.csv';
      final storagePath = 'reports/$fileName';

      await _supabase.storage.from('reports').uploadBinary(
            storagePath,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(contentType: 'text/csv'),
          );

      // 3. Get Public URL
      final publicUrl = _supabase.storage.from('reports').getPublicUrl(storagePath);

      // 4. Save URL to backend DB
      await _repository.saveCommitReportUrl(
        projectId: event.projectId,
        storageUrl: publicUrl,
        storageKey: storagePath,
      );

      emit(const AdminRepoActionSuccess('Xuất báo cáo và lưu trữ thành công!'));
    } catch (e) {
      emit(AdminRepoFailure('Lỗi khi xuất báo cáo: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExportHistory(
    LoadExportHistory event,
    Emitter<AdminRepoState> emit,
  ) async {
    emit(const AdminRepoLoading());
    try {
      final history = await _repository.getCommitReportHistory(event.projectId);
      emit(AdminRepoExportHistoryLoaded(history));
    } catch (e) {
      emit(AdminRepoFailure(e.toString()));
    }
  }

  Future<void> _onDeleteExportReport(
    DeleteExportReport event,
    Emitter<AdminRepoState> emit,
  ) async {
    // We remain in the loading state and then probably reload history,
    // but typically a delete action success is enough, the UI will trigger a reload.
    try {
      await _repository.deleteCommitReportUrl(event.projectId, event.reportId);
      emit(const AdminRepoActionSuccess('Xoá lịch sử báo cáo thành công'));
    } catch (e) {
      emit(AdminRepoFailure(e.toString()));
    }
  }
}
