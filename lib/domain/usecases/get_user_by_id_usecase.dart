import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

class GetUserByIdUseCase {
  final UserRepository userRepository;

  GetUserByIdUseCase({required this.userRepository});

  Future<UserEntity> execute(String userId) async {
    return await userRepository.getUserById(userId);
  }
}
