import 'package:equatable/equatable.dart';
import 'lecturer.dart';
import 'semester.dart';

/// Course model.
class Course extends Equatable {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String status;
  final Semester? semester;
  final Lecturer? lecturer;

  const Course({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.status,
    this.semester,
    this.lecturer,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId']?.toString() ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      semester: json['semester'] != null
          ? Semester.fromJson(json['semester'] as Map<String, dynamic>)
          : null,
      lecturer: json['lecturer'] != null
          ? Lecturer.fromJson(json['lecturer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseCode': courseCode,
    'courseName': courseName,
    'status': status,
    if (semester != null) 'semester': semester!.toJson(),
    if (lecturer != null) 'lecturer': lecturer!.toJson(),
  };

  @override
  List<Object?> get props => [
    courseId,
    courseCode,
    courseName,
    status,
    semester,
    lecturer,
  ];
}
