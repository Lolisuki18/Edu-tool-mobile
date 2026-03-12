import 'package:equatable/equatable.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/commit_report_url_response.dart';

abstract class AdminRepoState extends Equatable {
  const AdminRepoState();

  @override
  List<Object?> get props => [];
}

class AdminRepoInitial extends AdminRepoState {
  const AdminRepoInitial();
}

class AdminRepoLoading extends AdminRepoState {
  const AdminRepoLoading();
}

class AdminRepoGroupsLoaded extends AdminRepoState {
  final List<GroupDetailResponse> groups;
  const AdminRepoGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class AdminRepoExportHistoryLoaded extends AdminRepoState {
  final List<CommitReportUrlResponse> history;
  const AdminRepoExportHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class AdminRepoActionSuccess extends AdminRepoState {
  final String message;
  const AdminRepoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminRepoFailure extends AdminRepoState {
  final String message;
  const AdminRepoFailure(this.message);

  @override
  List<Object?> get props => [message];
}
