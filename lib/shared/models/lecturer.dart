import 'package:equatable/equatable.dart';
import 'user.dart';

/// Lecturer model linked to a [User].
class Lecturer extends Equatable {
  final String lecturerId;
  final String staffCode;
  final User? user;

  const Lecturer({
    required this.lecturerId,
    required this.staffCode,
    this.user,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      lecturerId: json['lecturerId']?.toString() ?? '',
      staffCode: json['staffCode'] as String? ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'lecturerId': lecturerId,
    'staffCode': staffCode,
    if (user != null) 'user': user!.toJson(),
  };

  @override
  List<Object?> get props => [lecturerId, staffCode, user];
}
