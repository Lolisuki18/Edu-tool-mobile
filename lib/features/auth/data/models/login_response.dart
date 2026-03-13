/// Response `data` object from `POST /auth/login` and `POST /auth/refresh`.
///
/// ```json
/// {
///   "role": "STUDENT",
///   "fullName": "Nguyen Van A",
///   "email": "vana@fpt.edu.vn",
///   "status": "ACTIVE",
///   "accessToken": "eyJ..."
/// }
/// ```
class LoginResponse {
  final String role;
  final String fullName;
  final String email;
  final String status;
  final String accessToken;
  final String? refreshToken;

  const LoginResponse({
    required this.role,
    required this.fullName,
    required this.email,
    required this.status,
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      role: json['role'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
