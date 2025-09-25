import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class UpdateBusUseCase {
  final BusRepository repository;

  UpdateBusUseCase(this.repository);

  Future<BusEntity> execute(BusEntity bus) async {
    // Validar que la placa sea única (excluyendo el bus actual)
    final isUnique = await repository.isLicensePlateUnique(
      bus.licensePlate,
      excludeBusId: bus.id,
    );

    if (!isUnique) {
      throw Exception(
        'La placa ${bus.licensePlate} ya está registrada en otro bus',
      );
    }

    return await repository.updateBus(bus);
  }
}
