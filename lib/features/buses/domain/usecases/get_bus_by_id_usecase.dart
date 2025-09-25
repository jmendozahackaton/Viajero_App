import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class GetBusByIdUseCase {
  final BusRepository repository;

  GetBusByIdUseCase(this.repository);

  Future<BusEntity> execute(String busId) {
    return repository.getBusById(busId);
  }
}
