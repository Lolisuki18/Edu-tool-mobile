import 'package:equatable/equatable.dart';

/// GitHub repository model.
class GithubRepository extends Equatable {
  final String repoId;
  final String repoUrl;
  final String repoName;
  final String owner;
  final bool isSelected;
  final String projectId;

  const GithubRepository({
    required this.repoId,
    required this.repoUrl,
    required this.repoName,
    required this.owner,
    required this.isSelected,
    required this.projectId,
  });

  factory GithubRepository.fromJson(Map<String, dynamic> json) {
    return GithubRepository(
      repoId: json['repoId']?.toString() ?? '',
      repoUrl: json['repoUrl'] as String? ?? '',
      repoName: json['repoName'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
      projectId: json['projectId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'repoId': repoId,
    'repoUrl': repoUrl,
    'repoName': repoName,
    'owner': owner,
    'isSelected': isSelected,
    'projectId': projectId,
  };

  @override
  List<Object?> get props => [
    repoId,
    repoUrl,
    repoName,
    owner,
    isSelected,
    projectId,
  ];
}
