import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String nombre;
  final String rol;
  final bool activo;

  UserModel({
    required this.userId,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.activo,
  });

  /// Crear un objeto desde un Map (ej: documento Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      userId: documentId,
      email: map['Email'] ?? '',
      nombre: map['Nombre'] ?? '',
      rol: map['Rol'] ?? 'Pasajero',
      activo: map['Activo'] ?? false,
    );
  }

  /// Convertir objeto a Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {'email': email, 'nombre': nombre, 'rol': rol, 'activo': activo};
  }

  /// Crear objeto desde un DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }
}
