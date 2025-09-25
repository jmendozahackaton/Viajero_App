import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class GetBusesByRouteUseCase {
  final BusRepository repository;

  GetBusesByRouteUseCase(this.repository);

  Future<List<BusEntity>> execute(String routeId) {
    return repository.getBusesByRoute(routeId);
  }
}
