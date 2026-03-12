import 'package:equatable/equatable.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Load active (submittable) periodic reports for a course.
class ReportLoadActive extends ReportEvent {
  final int courseId;

  const ReportLoadActive({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load all periodic reports (Admin).
class ReportLoadAll extends ReportEvent {
  final int page;
  final int size;

  const ReportLoadAll({required this.page, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}
