import '../repositories/bus_repository.dart';

class DeleteBusUseCase {
  final BusRepository repository;

  DeleteBusUseCase(this.repository);

  Future<void> execute(String busId) {
    return repository.deleteBus(busId);
  }
}
