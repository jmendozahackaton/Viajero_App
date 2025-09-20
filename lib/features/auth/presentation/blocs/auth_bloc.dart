import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackaton_app/domain/repositories/auth_repository.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({required this.authRepository, required this.userRepository})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);

    // Escuchar cambios de autenticación de Firebase
    _listenToAuthChanges();
  }

  // Método para escuchar cambios de autenticación
  void _listenToAuthChanges() {
    authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        // Usuario autenticado, obtener datos completos
        try {
          final completeUser = await userRepository.getUserById(user.uid);
          add(AuthUserUpdated(completeUser));
        } catch (e) {
          add(AuthCheckRequested()); // Forzar verificación
        }
      } else {
        // Usuario no autenticado, emitir estado correspondiente
        if (state is! AuthUnauthenticated) {
          add(AuthCheckRequested());
        }
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Solo emitir loading si no estamos ya en un estado de loading
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    try {
      final currentUser = authRepository.currentUser;

      if (currentUser != null) {
        // Obtener usuario completo desde Firestore
        final user = await userRepository.getUserById(currentUser.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error verificando autenticación: $e'));
      // Después de error, verificar again después de un delay
      await Future.delayed(const Duration(seconds: 2));
      add(AuthCheckRequested());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Forzar verificación completa después del login
      add(AuthCheckRequested());
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
      await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      // ✅ OPCIÓN: Cerrar sesión automáticamente después del registro
      await authRepository.signOut();

      emit(AuthRegistrationSuccess('Cuenta creada exitosamente'));
    } catch (e) {
      emit(AuthError('Error en registro: ${e.toString()}'));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.signOut();
      // ✅ Asegurarse de emitir UNAUTHENTICATED inmediatamente
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error cerrando sesión: $e'));
      // Even en error, intentar verificar el estado actual
      add(AuthCheckRequested());
    }
  }

  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  // Método para forzar recarga del usuario actual
  void reloadUser() {
    add(AuthCheckRequested());
  }
}
