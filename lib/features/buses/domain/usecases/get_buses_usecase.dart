import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class GetBusesUseCase {
  final BusRepository repository;

  GetBusesUseCase(this.repository);

  Future<List<BusEntity>> execute({bool activeOnly = true}) async {
    if (activeOnly) {
      return await repository.getActiveBuses();
    }
    // Para obtener todos los buses (incluyendo inactivos)
    // necesitaríamos un método adicional en el repository
    return await repository.getActiveBuses();
  }
}
