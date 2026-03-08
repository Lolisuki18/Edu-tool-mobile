import 'package:equatable/equatable.dart';

/// Semester model.
class Semester extends Equatable {
  final String semesterId;
  final String name;
  final String startDate;
  final String endDate;

  const Semester({
    required this.semesterId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semesterId: json['semesterId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'semesterId': semesterId,
    'name': name,
    'startDate': startDate,
    'endDate': endDate,
  };

  bool get isActive {
    try {
      return DateTime.parse(endDate).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  List<Object?> get props => [semesterId, name, startDate, endDate];
}
