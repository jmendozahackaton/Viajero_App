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
    } catch (e) {
      throw Exception('Error en registro: $e');
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
    } catch (e) {
      throw Exception('Error en login: $e');
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
    } catch (e) {
      throw Exception('Error en login de administrador: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final userModel = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      return userModel.toEntity();
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
