import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class CreateBusUseCase {
  final BusRepository repository;

  CreateBusUseCase(this.repository);

  Future<BusEntity> execute(BusEntity bus) async {
    // Validar que la placa sea única
    final isUnique = await repository.isLicensePlateUnique(bus.licensePlate);
    if (!isUnique) {
      throw Exception('La placa ${bus.licensePlate} ya está registrada');
    }

    return await repository.createBus(bus);
  }
}
