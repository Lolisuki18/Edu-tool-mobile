import 'package:equatable/equatable.dart';

import 'package:edutool/features/report/data/models/periodic_report_response.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

/// No data loaded yet.
class ReportInitial extends ReportState {
  const ReportInitial();
}

/// A network request is in-flight.
class ReportLoading extends ReportState {
  const ReportLoading();
}

/// Active reports loaded successfully.
class ReportLoaded extends ReportState {
  final List<PeriodicReportResponse> reports;

  const ReportLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

/// Something went wrong.
class ReportFailure extends ReportState {
  final String message;

  const ReportFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
