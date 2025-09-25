import '../repositories/bus_repository.dart';

class UnassignDriverUseCase {
  final BusRepository repository;

  UnassignDriverUseCase(this.repository);

  Future<void> execute(String busId) {
    return repository.unassignDriverFromBus(busId);
  }
}
