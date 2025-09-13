import 'package:hackaton_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Registro de usuario
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  // Login de usuario
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Login de administrador
  Future<UserEntity> signInAsAdmin({
    required String email,
    required String password,
  });

  // Cerrar sesión
  Future<void> signOut();

  // Estado de autenticación
  Stream<UserEntity?> get authStateChanges;

  // Usuario actual (solo datos básicos de Auth)
  UserEntity? get currentUser;

  // Verificar si es administrador
  Future<bool> isAdmin(String userId);
}
