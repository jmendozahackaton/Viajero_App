import 'package:flutter_test/flutter_test.dart';
import 'package:hackaton_app/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Should create empty user', () {
      final user = UserModel.empty();

      expect(user.uid, '');
      expect(user.email, '');
      expect(user.userType, 'passenger');
      expect(user.preferences['notifications'], true);
    });

    test('Should convert to map and back', () {
      final originalUser = UserModel(
        uid: 'test123',
        email: 'test@example.com',
        displayName: 'Test User',
        userType: 'passenger',
        phoneNumber: '+50588888888',
        photoURL: 'https://example.com/photo.jpg',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        fcmToken: 'token123',
        preferences: {
          'notifications': true,
          'darkMode': false,
          'language': 'es',
        },
        isActive: true,
      );

      // Convertir a mapa
      final userMap = originalUser.toMap();

      // Convertir de vuelta a UserModel
      final convertedUser = UserModel.fromMap(userMap);

      expect(convertedUser.uid, originalUser.uid);
      expect(convertedUser.email, originalUser.email);
      expect(convertedUser.displayName, originalUser.displayName);
      expect(convertedUser.userType, originalUser.userType);
    });

    test('Should handle null values correctly', () {
      final user = UserModel(
        uid: 'test123',
        email: 'test@example.com',
        displayName: 'Test User',
        userType: 'passenger',
        phoneNumber: null,
        photoURL: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fcmToken: null,
        preferences: {},
        isActive: true,
      );

      final userMap = user.toMap();
      final convertedUser = UserModel.fromMap(userMap);

      expect(convertedUser.phoneNumber, isNull);
      expect(convertedUser.photoURL, isNull);
      expect(convertedUser.fcmToken, isNull);
    });

    test('Should copy with changes', () {
      final originalUser = UserModel(
        uid: 'test123',
        email: 'test@example.com',
        displayName: 'Test User',
        userType: 'passenger',
        phoneNumber: null,
        photoURL: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fcmToken: null,
        preferences: {},
        isActive: true,
      );

      final copiedUser = originalUser.copyWith(
        displayName: 'New Name',
        userType: 'admin',
      );

      expect(copiedUser.uid, originalUser.uid);
      expect(copiedUser.email, originalUser.email);
      expect(copiedUser.displayName, 'New Name');
      expect(copiedUser.userType, 'admin');
    });
  });
}
