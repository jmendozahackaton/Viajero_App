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
  });

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
