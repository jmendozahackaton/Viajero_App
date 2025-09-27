import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Viajeros/data/models/user_model.dart';
import 'package:Viajeros/data/models/user_model_extension.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';
import 'package:Viajeros/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Colección de usuarios en Firestore
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    return await getUserById(user.uid);
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Error obteniendo usuario: $e');
    }
  }

  @override
  Future<void> createUser(UserEntity user) async {
    try {
      final userModel = user.toModel();
      await _usersCollection.doc(user.uid).set(userModel.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final userModel = user.toModel();
      final updatedUser = userModel.copyWith(updatedAt: DateTime.now());

      // Convertir Map<String, dynamic> a Map<Object, Object?> para Firebase
      final updateData = updatedUser.toMap().map(
        (key, value) => MapEntry<Object, Object?>(key, value),
      );

      await _usersCollection.doc(user.uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<void> updateUserFcmToken(String userId, String fcmToken) async {
    try {
      await _usersCollection.doc(userId).update({
        'fcmToken': fcmToken,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  @override
  Future<List<UserEntity>> getUsersByType(String userType) async {
    try {
      final query = await _usersCollection
          .where('userType', isEqualTo: userType)
          .get();

      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by type: $e');
    }
  }

  @override
  Stream<UserEntity> streamUser(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map(
          (snapshot) =>
              UserModel.fromMap(snapshot.data() as Map<String, dynamic>),
        )
        .map((model) => model.toEntity());
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>).toEntity();
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo usuarios: $e');
    }
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'userType': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error actualizando rol: $e');
    }
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      print('Actualizando usuario $userId a isActive: $isActive'); // ← DEBUG

      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando estado: $e'); // ← DEBUG
      throw Exception('Error actualizando estado: $e');
    }
  }
}
