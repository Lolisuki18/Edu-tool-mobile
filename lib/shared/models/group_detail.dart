import 'package:equatable/equatable.dart';
import 'github_repository.dart';
import 'student.dart';

/// Grouped view: a project group with its members and repos.
class GroupDetail extends Equatable {
  final int groupNumber;
  final String projectId;
  final String? projectCode;
  final String? projectName;
  final List<Student> members;
  final List<GithubRepository> repositories;

  const GroupDetail({
    required this.groupNumber,
    required this.projectId,
    this.projectCode,
    this.projectName,
    this.members = const [],
    this.repositories = const [],
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      groupNumber: json['groupNumber'] as int? ?? 0,
      projectId: json['projectId']?.toString() ?? '',
      projectCode: json['projectCode'] as String?,
      projectName: json['projectName'] as String?,
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      repositories:
          (json['repositories'] as List<dynamic>?)
              ?.map((e) => GithubRepository.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [groupNumber, projectId, members, repositories];
}
