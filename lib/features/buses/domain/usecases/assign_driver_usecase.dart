import 'package:hackaton_app/domain/repositories/user_repository.dart';
import '../repositories/bus_repository.dart';

class AssignDriverUseCase {
  final BusRepository busRepository;
  final UserRepository userRepository;

  AssignDriverUseCase(this.busRepository, this.userRepository);

  Future<void> execute(String busId, String driverId) async {
    // Validar que el usuario existe y es conductor
    final user = await userRepository.getUserById(driverId);
    if (user.userType != 'driver') {
      throw Exception('El usuario no tiene rol de conductor');
    }

    // Validar que el conductor está activo
    if (!user.isActive) {
      throw Exception('El conductor no está activo');
    }

    return await busRepository.assignDriverToBus(busId, driverId);
  }
}
