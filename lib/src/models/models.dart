class User {
  final String id;
  final String name;
  final String email;
  final String role;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class Course {
  final String id;
  final String code;
  final String name;
  final String lecturerId;
  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.lecturerId,
  });
}

class Project {
  final String id;
  final String name;
  final String code;
  final String courseId;
  final String description;
  final List<String> tech;
  Project({
    required this.id,
    required this.name,
    required this.code,
    required this.courseId,
    this.description = '',
    this.tech = const [],
  });
}

class Repo {
  final String id;
  final String projectId;
  final String name;
  final String url;
  Repo({
    required this.id,
    required this.projectId,
    required this.name,
    required this.url,
  });
}

class Commit {
  final String id;
  final String repoId;
  final String sha;
  final String authorName;
  final String message;
  final DateTime timestamp;
  Commit({
    required this.id,
    required this.repoId,
    required this.sha,
    required this.authorName,
    required this.message,
    required this.timestamp,
  });
}

class ReportPeriod {
  final String id;
  final String courseId;
  final String name;
  final DateTime start;
  final DateTime end;
  ReportPeriod({
    required this.id,
    required this.courseId,
    required this.name,
    required this.start,
    required this.end,
  });
}
