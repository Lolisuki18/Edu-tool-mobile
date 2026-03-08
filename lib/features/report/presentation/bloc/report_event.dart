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
