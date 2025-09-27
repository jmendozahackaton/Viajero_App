import 'package:Viajeros/domain/repositories/user_repository.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';

class GetUserByIdUseCase {
  final UserRepository userRepository;

  GetUserByIdUseCase({required this.userRepository});

  Future<UserEntity> execute(String userId) async {
    return await userRepository.getUserById(userId);
  }
}
