import 'package:equatable/equatable.dart';

/// Project (group) model.
class Project extends Equatable {
  final String projectId;
  final String projectCode;
  final String projectName;
  final String courseId;
  final String? courseCode;
  final String? description;
  final String? technologies;
  final String? deletedAt;
  final int memberCount;

  const Project({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.courseId,
    this.courseCode,
    this.description,
    this.technologies,
    this.deletedAt,
    this.memberCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId']?.toString() ?? '',
      projectCode: json['projectCode'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseCode: json['courseCode'] as String?,
      description: json['description'] as String?,
      technologies: json['technologies'] as String?,
      deletedAt: json['deletedAt'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'projectCode': projectCode,
    'projectName': projectName,
    'courseId': courseId,
    if (courseCode != null) 'courseCode': courseCode,
    if (description != null) 'description': description,
    if (technologies != null) 'technologies': technologies,
  };

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [
    projectId,
    projectCode,
    projectName,
    courseId,
    deletedAt,
    memberCount,
  ];
}
