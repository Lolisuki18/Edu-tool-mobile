import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/features/auth/domain/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

/// Handles authentication events (login / logout).
///
/// On [AuthLoginRequested]:
///   1. Emit [AuthLoading].
///   2. Call `repository.login(...)` which persists the access token internally.
///   3. Emit [AuthSuccess] with the user's role so the UI can navigate.
///   4. On error, emit [AuthFailure] with a human-readable message.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _repository.login(
        username: event.username,
        password: event.password,
      );

      emit(
        AuthSuccess(
          role: response.role,
          fullName: response.fullName,
          email: response.email,
        ),
      );
    } on ServerException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (_) {
      emit(const AuthFailure(message: 'Đã xảy ra lỗi. Vui lòng thử lại.'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logout();
    } finally {
      emit(const AuthInitial());
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _repository.register(
        fullName: event.fullName,
        email: event.email,
        username: event.username,
        password: event.password,
      );

      emit(const AuthRegisterSuccess());
    } on ServerException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (_) {
      emit(const AuthFailure(message: 'Đã xảy ra lỗi. Vui lòng thử lại.'));
    }
  }
}
