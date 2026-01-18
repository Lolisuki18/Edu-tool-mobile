import 'package:edutool/src/models/models.dart';

class MockDataService {
  static final users = <User>[
    User(id: 'u1', name: 'Alice', email: 'alice@example.com', role: 'Lecturer'),
    User(id: 'u2', name: 'Bob', email: 'bob@example.com', role: 'Team Leader'),
    User(
      id: 'u3',
      name: 'Charlie',
      email: 'charlie@example.com',
      role: 'Member',
    ),
  ];

  static final courses = <Course>[
    Course(
      id: 'c1',
      code: 'CS101',
      name: 'Software Project I',
      lecturerId: 'u1',
    ),
    Course(
      id: 'c2',
      code: 'CS202',
      name: 'Advanced SW Project',
      lecturerId: 'u1',
    ),
  ];

  static final projects = <Project>[
    Project(
      id: 'p1',
      name: 'EduTool',
      code: 'P-EDU-1',
      courseId: 'c1',
      description: 'Tool for managing projects',
      tech: ['Flutter', 'Dart', 'GitHub'],
    ),
    Project(
      id: 'p2',
      name: 'ChatApp',
      code: 'P-CHAT-1',
      courseId: 'c1',
      description: 'Realtime chat app',
      tech: ['Flutter', 'Firebase'],
    ),
  ];

  static final repos = <Repo>[
    Repo(
      id: 'r1',
      projectId: 'p1',
      name: 'edutool-app',
      url: 'https://github.com/example/edutool-app',
    ),
    Repo(
      id: 'r2',
      projectId: 'p1',
      name: 'edutool-backend',
      url: 'https://github.com/example/edutool-backend',
    ),
  ];

  static final commits = <Commit>[
    Commit(
      id: 'cm1',
      repoId: 'r1',
      sha: 'a1b2c3',
      authorName: 'Charlie',
      message: 'Init project',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Commit(
      id: 'cm2',
      repoId: 'r1',
      sha: 'd4e5f6',
      authorName: 'Charlie',
      message: 'Add login UI',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Commit(
      id: 'cm3',
      repoId: 'r2',
      sha: 'z9y8x7',
      authorName: 'Bob',
      message: 'Setup CI',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static List<Course> getCoursesForUser(String userId) {
    // simple mock: return all courses for lecturer Alice, else return c1
    final user = users.firstWhere(
      (u) => u.id == userId,
      orElse: () => users[2],
    );
    if (user.role == 'Lecturer') return courses;
    return courses.where((c) => c.id == 'c1').toList();
  }

  static List<Project> getProjectsForCourse(String courseId) =>
      projects.where((p) => p.courseId == courseId).toList();

  static List<Repo> getReposForProject(String projectId) =>
      repos.where((r) => r.projectId == projectId).toList();

  static List<Commit> getCommitsForRepo(String repoId) =>
      commits.where((c) => c.repoId == repoId).toList();
}
