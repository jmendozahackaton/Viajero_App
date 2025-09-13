import 'package:hackaton_app/data/models/user_model.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

extension UserModelExtension on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      userType: userType,
      phoneNumber: phoneNumber,
      photoURL: photoURL,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fcmToken: fcmToken,
      preferences: Map<String, dynamic>.from(preferences),
    );
  }
}

extension UserEntityExtension on UserEntity {
  UserModel toModel() {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      userType: userType,
      phoneNumber: phoneNumber,
      photoURL: photoURL,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fcmToken: fcmToken,
      preferences: Map<String, dynamic>.from(preferences),
    );
  }
}
