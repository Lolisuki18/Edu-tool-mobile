/// Response model for `GET /api/projects` and `GET /api/projects/{id}`.
///
/// ```json
/// {
///   "projectId": 1,
///   "projectCode": "PROJ-001",
///   "projectName": "EduTool Mobile App",
///   "courseId": 1,
///   "courseCode": "SWD392",
///   "courseName": "Software Architecture Design",
///   "description": "...",
///   "technologies": "Flutter, Spring Boot",
///   "createdAt": "2026-03-08T10:00:00",
///   "deletedAt": null,
///   "memberCount": 4
/// }
/// ```
class ProjectResponse {
  final int projectId;
  final String projectCode;
  final String projectName;
  final int courseId;
  final String courseCode;
  final String courseName;
  final String? description;
  final String? technologies;
  final String? createdAt;
  final String? deletedAt;
  final int memberCount;

  const ProjectResponse({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.description,
    this.technologies,
    this.createdAt,
    this.deletedAt,
    this.memberCount = 0,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      projectId: json['projectId'] as int? ?? 0,
      projectCode: json['projectCode'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      courseId: json['courseId'] as int? ?? 0,
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      description: json['description'] as String?,
      technologies: json['technologies'] as String?,
      createdAt: json['createdAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
    );
  }
}
