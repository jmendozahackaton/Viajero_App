part of 'auth_bloc.dart'; // ← DEBE SER LA ÚNICA LÍNEA

// @immutable ← ELIMINAR de aquí (va en el archivo principal)
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
