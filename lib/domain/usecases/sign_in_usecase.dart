import 'package:Viajeros/domain/repositories/auth_repository.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';

class SignInUseCase {
  final AuthRepository authRepository;

  SignInUseCase({required this.authRepository});

  Future<UserEntity> execute({
    required String email,
    required String password,
  }) {
    return authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
