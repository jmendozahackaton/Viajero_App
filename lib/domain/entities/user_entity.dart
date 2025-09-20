import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final String userType;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;
  final Map<String, dynamic> preferences;
  final bool isActive; // ← NUEVO: para activar/desactivar usuarios

  UserEntity({
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

  UserEntity copyWith({
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
    return UserEntity(
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

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fcmToken': fcmToken,
      'preferences': preferences,
      'isActive': isActive,
    };
  }

  // Método para crear UserModel desde Map (desde Firestore)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
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
  factory UserEntity.empty() {
    return UserEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
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
