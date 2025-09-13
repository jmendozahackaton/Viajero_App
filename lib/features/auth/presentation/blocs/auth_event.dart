part of 'auth_bloc.dart'; // ← DEBE SER LA ÚNICA LÍNEA

// @immutable ← ELIMINAR de aquí (va en el archivo principal)
sealed class AuthEvent {}

final class AuthCheckRequested extends AuthEvent {}

final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});
}

final class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

final class AuthSignOutRequested extends AuthEvent {}

final class AuthUserUpdated extends AuthEvent {
  final UserEntity user;

  AuthUserUpdated(this.user);
}
