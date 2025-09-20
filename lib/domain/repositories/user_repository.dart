import 'package:hackaton_app/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> getUserById(String userId);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<void> updateUserFcmToken(String userId, String fcmToken);
  Future<List<UserEntity>> getUsersByType(String userType);
  Stream<UserEntity> streamUser(String userId);
  Future<bool> userExists(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserRole(String userId, String newRole);
  Future<void> updateUserStatus(String userId, bool isActive);
}
