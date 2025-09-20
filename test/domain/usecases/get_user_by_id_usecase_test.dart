import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hackaton_app/domain/usecases/get_user_by_id_usecase.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetUserByIdUseCase getUserByIdUseCase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    getUserByIdUseCase = GetUserByIdUseCase(userRepository: mockUserRepository);
  });

  test('Should get user by id from repository', () async {
    // Arrange
    final userEntity = UserEntity(
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

    when(
      mockUserRepository.getUserById('test123'),
    ).thenAnswer((_) async => userEntity);

    // Act
    final result = await getUserByIdUseCase.execute('test123');

    // Assert
    expect(result, userEntity);
    verify(mockUserRepository.getUserById('test123'));
    verifyNoMoreInteractions(mockUserRepository);
  });
}
