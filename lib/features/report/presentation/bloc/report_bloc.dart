import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/features/report/domain/report_repository.dart';

import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc({required ReportRepository repository})
    : _repository = repository,
      super(const ReportInitial()) {
    on<ReportLoadActive>(_onLoadActive);
  }

  Future<void> _onLoadActive(
    ReportLoadActive event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());
    try {
      final reports = await _repository.getActiveReports(
        courseId: event.courseId,
      );
      emit(ReportLoaded(reports: reports));
    } on ServerException catch (e) {
      emit(ReportFailure(message: e.message));
    } catch (_) {
      emit(const ReportFailure(message: 'Đã xảy ra lỗi khi tải báo cáo'));
    }
  }
}
