import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

class UpdateUserUseCase {
  final UserRepository userRepository;

  UpdateUserUseCase({required this.userRepository});

  Future<void> execute(UserEntity user) async {
    return await userRepository.updateUser(user);
  }
}
