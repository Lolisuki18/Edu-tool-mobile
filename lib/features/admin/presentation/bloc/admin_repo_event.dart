import 'package:equatable/equatable.dart';

abstract class AdminRepoEvent extends Equatable {
  const AdminRepoEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupsByCourse extends AdminRepoEvent {
  final int courseId;
  const LoadGroupsByCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class ExportCommitReport extends AdminRepoEvent {
  final int projectId;
  final String projectName;
  final String datePrefix; // e.g. YYYY-MM-DD
  
  const ExportCommitReport({
    required this.projectId,
    required this.projectName,
    required this.datePrefix,
  });

  @override
  List<Object?> get props => [projectId, projectName, datePrefix];
}

class LoadExportHistory extends AdminRepoEvent {
  final int projectId;
  const LoadExportHistory(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class DeleteExportReport extends AdminRepoEvent {
  final int projectId;
  final int reportId;
  const DeleteExportReport(this.projectId, this.reportId);

  @override
  List<Object?> get props => [projectId, reportId];
}
