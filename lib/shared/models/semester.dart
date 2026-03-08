import 'package:equatable/equatable.dart';

/// Semester model.
class Semester extends Equatable {
  final String semesterId;
  final String name;
  final String startDate;
  final String endDate;
  final bool status;

  const Semester({
    required this.semesterId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.status = true,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semesterId: json['semesterId']?.toString() ?? '',
      name: json['semesterName'] as String? ?? json['name'] as String? ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'semesterId': semesterId,
    'semesterName': name,
    'startDate': startDate,
    'endDate': endDate,
    'status': status,
  };

  bool get isActive => status;

  @override
  List<Object?> get props => [semesterId, name, startDate, endDate, status];
}
