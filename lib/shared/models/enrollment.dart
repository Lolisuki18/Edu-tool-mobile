import 'package:equatable/equatable.dart';

/// Enrollment model — links a student to a course and optionally a project.
class Enrollment extends Equatable {
  final String enrollmentId;
  final String studentId;
  final String? studentCode;
  final String? studentName;
  final String courseId;
  final String? courseCode;
  final String? courseName;
  final String? projectId;
  final String? projectCode;
  final String? projectName;
  final String roleInProject;
  final int groupNumber;
  final String? enrolledAt;
  final String? deletedAt;
  final String? removedFromProjectAt;

  const Enrollment({
    required this.enrollmentId,
    required this.studentId,
    this.studentCode,
    this.studentName,
    required this.courseId,
    this.courseCode,
    this.courseName,
    this.projectId,
    this.projectCode,
    this.projectName,
    this.roleInProject = '',
    this.groupNumber = 0,
    this.enrolledAt,
    this.deletedAt,
    this.removedFromProjectAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollmentId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentCode: json['studentCode'] as String?,
      studentName: json['studentName'] as String?,
      courseId: json['courseId']?.toString() ?? '',
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      projectId: json['projectId']?.toString(),
      projectCode: json['projectCode'] as String?,
      projectName: json['projectName'] as String?,
      roleInProject: json['roleInProject'] as String? ?? '',
      groupNumber: json['groupNumber'] as int? ?? 0,
      enrolledAt: json['enrolledAt'] as String?,
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
