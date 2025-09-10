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
    // Función helper para obtener valor sin importar case o existencia
    dynamic getValue(Map<String, dynamic> data, List<String> possibleKeys) {
      for (var key in possibleKeys) {
        if (data.containsKey(key)) return data[key];
      }
      return null;
    }

    return UserModel(
      userId: documentId,
      email: getValue(map, ['email', 'Email'])?.toString() ?? '',
      nombre: getValue(map, ['nombre', 'Nombre'])?.toString() ?? '',
      rol: getValue(map, ['rol', 'Rol'])?.toString() ?? 'Pasajero',
      activo: getValue(map, ['activo', 'Activo']) as bool? ?? false,
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
