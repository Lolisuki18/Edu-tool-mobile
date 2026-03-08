import 'package:equatable/equatable.dart';

import 'package:edutool/features/project/data/models/group_detail_response.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// No data loaded yet.
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// A network request is in-flight.
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// Groups (with members + repos) loaded successfully.
class ProjectGroupsLoaded extends ProjectState {
  final List<GroupDetailResponse> groups;

  const ProjectGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

/// A one-shot action completed (submit repo, select repo, export report).
/// The UI should show a Snackbar and then the bloc re-loads data automatically.
class ProjectActionSuccess extends ProjectState {
  final String message;

  const ProjectActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Something went wrong.
class ProjectFailure extends ProjectState {
  final String message;

  const ProjectFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
