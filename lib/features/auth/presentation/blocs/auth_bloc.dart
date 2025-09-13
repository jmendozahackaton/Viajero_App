import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackaton_app/domain/repositories/auth_repository.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart'; // ← Importar UserRepository
import 'package:hackaton_app/domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository; // ← Agregar UserRepository

  AuthBloc({
    required this.authRepository,
    required this.userRepository, // ← Recibir UserRepository
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final currentUser = authRepository.currentUser;

      if (currentUser != null) {
        // ✅ Usar userRepository para obtener datos completos
        final user = await userRepository.getUserById(currentUser.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error verificando autenticación: $e'));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // ✅ AuthRepository para login (autenticación)
      final user = await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // ✅ UserRepository para obtener datos completos después del login
      final completeUser = await userRepository.getUserById(user.uid);
      emit(AuthAuthenticated(completeUser));
    } catch (e) {
      emit(
        AuthError(
          'Error en login: ${e.toString().replaceFirst('Exception: ', '')}',
        ),
      );
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // ✅ AuthRepository para registro (autenticación + creación en Firestore)
      final user = await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(
        AuthError(
          'Error en registro: ${e.toString().replaceFirst('Exception: ', '')}',
        ),
      );
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error cerrando sesión: $e'));
    }
  }

  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }
}
