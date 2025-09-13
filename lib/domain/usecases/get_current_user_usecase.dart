import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

class GetCurrentUserUseCase {
  final UserRepository userRepository;

  GetCurrentUserUseCase({required this.userRepository});

  Future<UserEntity> execute() async {
    return await userRepository.getCurrentUser();
  }
}
