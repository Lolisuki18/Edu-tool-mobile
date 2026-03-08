import 'package:equatable/equatable.dart';
import 'user.dart';

/// Student model linked to a [User].
class Student extends Equatable {
  final String studentId;
  final String studentCode;
  final String githubUsername;
  final User? user;

  const Student({
    required this.studentId,
    required this.studentCode,
    required this.githubUsername,
    this.user,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId']?.toString() ?? '',
      studentCode: json['studentCode'] as String? ?? '',
      githubUsername: json['githubUsername'] as String? ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentCode': studentCode,
    'githubUsername': githubUsername,
    if (user != null) 'user': user!.toJson(),
  };

  @override
  List<Object?> get props => [studentId, studentCode, githubUsername, user];
}
