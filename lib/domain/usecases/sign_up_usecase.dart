import 'package:Viajeros/domain/repositories/auth_repository.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';

class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase({required this.authRepository});

  Future<UserEntity> execute({
    required String email,
    required String password,
    required String displayName,
  }) {
    return authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
