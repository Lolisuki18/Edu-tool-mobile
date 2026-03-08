import 'package:equatable/equatable.dart';

/// Events consumed by [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted the login form.
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// User tapped logout.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// User submitted the registration form.
class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;

  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, username, password];
}
