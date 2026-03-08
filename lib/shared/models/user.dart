import 'package:equatable/equatable.dart';

/// User model matching the backend `User` entity.
class User extends Equatable {
  final String userId;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String status;

  const User({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'fullName': fullName,
    'email': email,
    'role': role,
    'status': status,
  };

  User copyWith({
    String? userId,
    String? username,
    String? fullName,
    String? email,
    String? role,
    String? status,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isLecturer => role == 'LECTURER';
  bool get isStudent => role == 'STUDENT';
  bool get isActive => status == 'ACTIVE';

  @override
  List<Object?> get props => [userId, username, fullName, email, role, status];
}
