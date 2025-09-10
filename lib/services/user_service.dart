import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/data/models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection("Users");

  /// Agregar o actualizar un usuario
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.userId).set(user.toMap());
    } catch (e) {
      ScaffoldMessenger.of(BuildContext as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Error guardando usuario: $e'),
          backgroundColor:
              Colors.red, // Opcional, para indicar el color de error
        ),
      );
      rethrow;
    }
  }

  /// Obtener un usuario por ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromDocument(doc);
    }
    return null;
  }

  /// Obtener todos los usuarios (una sola vez)
  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await _usersCollection.get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();
  }

  /// Escuchar usuarios en tiempo real
  Stream<List<UserModel>> listenUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    });
  }

  /// Eliminar un usuario
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      print('Usuario $userId eliminado correctamente');
    } catch (e) {
      print('Error al eliminar usuario: $e');
      rethrow;
    }
  }
}
