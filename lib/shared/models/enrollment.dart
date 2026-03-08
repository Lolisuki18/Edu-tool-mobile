import 'package:equatable/equatable.dart';

/// Enrollment model — links a student to a course and optionally a project.
class Enrollment extends Equatable {
  final String enrollmentId;
  final String studentId;
  final String courseId;
  final String? projectId;
  final String roleInProject;
  final int groupNumber;
  final String? deletedAt;
  final String? removedFromProjectAt;

  const Enrollment({
    required this.enrollmentId,
    required this.studentId,
    required this.courseId,
    this.projectId,
    this.roleInProject = '',
    this.groupNumber = 0,
    this.deletedAt,
    this.removedFromProjectAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollmentId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      projectId: json['projectId']?.toString(),
      roleInProject: json['roleInProject'] as String? ?? '',
      groupNumber: json['groupNumber'] as int? ?? 0,
      deletedAt: json['deletedAt'] as String?,
      removedFromProjectAt: json['removedFromProjectAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'enrollmentId': enrollmentId,
    'studentId': studentId,
    'courseId': courseId,
    if (projectId != null) 'projectId': projectId,
    'roleInProject': roleInProject,
    'groupNumber': groupNumber,
  };

  bool get isAssigned => projectId != null && removedFromProjectAt == null;

  @override
  List<Object?> get props => [
    enrollmentId,
    studentId,
    courseId,
    projectId,
    roleInProject,
    groupNumber,
  ];
}
