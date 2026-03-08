import 'package:equatable/equatable.dart';

/// States emitted by [AuthBloc].
///
/// Four standard states per architecture guide:
/// Initial → Loading → Success / Failure.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// No auth action has been taken yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Login request is in-flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Login succeeded. Carries the user's [role] for navigation and profile info.
class AuthSuccess extends AuthState {
  final String role;
  final String fullName;
  final String email;

  const AuthSuccess({
    required this.role,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [role, fullName, email];
}

/// Login (or logout) failed.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Registration succeeded — user should navigate to login.
class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess();
}
