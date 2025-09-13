import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';

class StreamUserUseCase {
  final UserRepository userRepository;

  StreamUserUseCase({required this.userRepository});

  Stream<UserEntity> execute(String userId) {
    return userRepository.streamUser(userId);
  }
}
