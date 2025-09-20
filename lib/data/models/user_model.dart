import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String userType; // 'passenger' o 'admin'
  final String? phoneNumber;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;
  final Map<String, dynamic> preferences;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.userType,
    this.phoneNumber,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
    required this.preferences,
    required this.isActive,
  });

  // Método para convertir UserModel a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'fcmToken': fcmToken,
      'preferences': preferences,
      'isActive': isActive,
    };
  }

  // Método para crear UserModel desde Map (desde Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      userType: map['userType'] ?? 'passenger',
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      fcmToken: map['fcmToken'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }

  // Método para crear un UserModel vacío (útil para inicialización)
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: '',
      userType: 'passenger',
      phoneNumber: null,
      photoURL: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fcmToken: null,
      preferences: {'notifications': true, 'darkMode': false, 'language': 'es'},
      isActive: true,
    );
  }

  // Método para copiar el UserModel con cambios
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? userType,
    String? phoneNumber,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
    Map<String, dynamic>? preferences,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
    );
  }

  // Override del método toString para debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, userType: $userType)';
  }

  // Override de equals y hashCode para comparaciones
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.userType == userType;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        userType.hashCode;
  }
}
