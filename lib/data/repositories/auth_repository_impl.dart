import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackaton_app/data/models/user_model_extension.dart';
import 'package:hackaton_app/domain/repositories/auth_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';
import 'package:hackaton_app/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // ✅ MÉTODO PARA TRAducIR ERRORES DE FIREBASE
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico no válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta nuevamente más tarde';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo y contraseña no está habilitado';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Use al menos 6 caracteres';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación. Por favor intenta nuevamente';
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Crear perfil de usuario en Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        userType: 'passenger', // Usuario normal por defecto
        phoneNumber: null,
        photoURL: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fcmToken: null,
        preferences: {
          'notifications': true,
          'darkMode': false,
          'language': 'es',
        },
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      // ✅ CAPTURAR ERRORES ESPECÍFICOS DE FIREBASE
      throw Exception(_getAuthErrorMessage(e.code));
    } on FirebaseException catch (e) {
      throw Exception('Error de Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en registro: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Obtener datos del usuario desde Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      final userModel = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      // ✅ CAPTURAR ERRORES ESPECÍFICOS DE FIREBASE AUTH
      throw Exception(_getAuthErrorMessage(e.code));
    } on FirebaseException catch (e) {
      throw Exception('Error de Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en login: $e');
    }
  }

  @override
  Future<UserEntity> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final userEntity = await signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si es administrador
      final isUserAdmin = await isAdmin(userEntity.uid);

      if (!isUserAdmin) {
        await signOut();
        throw Exception('Acceso denegado. No tienes permisos de administrador');
      }

      return userEntity;
    } on FirebaseAuthException catch (e) {
      // ✅ CAPTURAR ERRORES DE AUTENTICACIÓN TAMBIÉN EN ADMIN LOGIN
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception(
        'Error en login de administrador: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;

        final userModel = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );
        return userModel.toEntity();
      } catch (e) {
        // Silenciar errores en el stream para no romper la app
        return null;
      }
    });
  }

  @override
  UserEntity? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Nota: Esto no incluye datos de Firestore, solo datos básicos de Auth
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      userType: 'passenger', // Valor temporal
      phoneNumber: firebaseUser.phoneNumber,
      photoURL: firebaseUser.photoURL,
      createdAt: DateTime.now(), // Valores temporales
      updatedAt: DateTime.now(),
      fcmToken: null,
      preferences: {},
    );
  }

  @override
  Future<bool> isAdmin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['userType'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}
