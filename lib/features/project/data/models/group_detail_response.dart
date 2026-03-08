/// Response model for `GET /api/github/repositories/course/{courseId}/groups`.
///
/// Each item represents one project group within a course.
class GroupDetailResponse {
  final int groupNumber;
  final int projectId;
  final String projectCode;
  final String projectName;
  final String? projectDescription;
  final String? projectTechnologies;
  final int courseId;
  final String courseCode;
  final String courseName;
  final int memberCount;
  final int repoCount;
  final List<GroupMember> members;
  final List<GroupRepo> repositories;

  const GroupDetailResponse({
    required this.groupNumber,
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    this.projectDescription,
    this.projectTechnologies,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.memberCount = 0,
    this.repoCount = 0,
    this.members = const [],
    this.repositories = const [],
  });

  factory GroupDetailResponse.fromJson(Map<String, dynamic> json) {
    return GroupDetailResponse(
      groupNumber: json['groupNumber'] as int? ?? 0,
      projectId: json['projectId'] as int? ?? 0,
      projectCode: json['projectCode'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectDescription: json['projectDescription'] as String?,
      projectTechnologies: json['projectTechnologies'] as String?,
      courseId: json['courseId'] as int? ?? 0,
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
      repoCount: json['repoCount'] as int? ?? 0,
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      repositories:
          (json['repositories'] as List<dynamic>?)
              ?.map((e) => GroupRepo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class GroupMember {
  final int studentId;
  final String studentCode;
  final String fullName;
  final String? githubUsername;
  final String? email;
  final String? roleInProject;

  const GroupMember({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    this.githubUsername,
    this.email,
    this.roleInProject,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      studentId: json['studentId'] as int? ?? 0,
      studentCode: json['studentCode'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      githubUsername: json['githubUsername'] as String?,
      email: json['email'] as String?,
      roleInProject: json['roleInProject'] as String?,
    );
  }
}

class GroupRepo {
  final int repoId;
  final String repoUrl;
  final String repoName;
  final String owner;
  final bool isSelected;
  final int projectId;
  final String projectName;
  final String projectCode;
  final String? createdAt;

  const GroupRepo({
    required this.repoId,
    required this.repoUrl,
    required this.repoName,
    required this.owner,
    required this.isSelected,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    this.createdAt,
  });

  factory GroupRepo.fromJson(Map<String, dynamic> json) {
    return GroupRepo(
      repoId: json['repoId'] as int? ?? 0,
      repoUrl: json['repoUrl'] as String? ?? '',
      repoName: json['repoName'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
      projectId: json['projectId'] as int? ?? 0,
      projectName: json['projectName'] as String? ?? '',
      projectCode: json['projectCode'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }
}
