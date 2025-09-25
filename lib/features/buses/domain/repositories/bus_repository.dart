import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/bus_entity.dart';
import '../entities/bus_driver_entity.dart';

abstract class BusRepository {
  // CRUD Básico
  Future<List<BusEntity>> getActiveBuses();
  Future<BusEntity> getBusById(String busId);
  Future<BusEntity> createBus(BusEntity bus);
  Future<BusEntity> updateBus(BusEntity bus);
  Future<void> deleteBus(String busId);

  // Búsquedas Específicas
  Future<List<BusEntity>> getBusesByRoute(String routeId);
  Future<List<BusEntity>> getBusesByDriver(String driverId);
  Future<List<BusEntity>> findBusesNearLocation(
    LatLng location,
    double radiusKm,
  );
  Future<List<BusEntity>> searchBuses(String query);

  // Gestión de Conductores
  Future<void> assignDriverToBus(String busId, String driverId);
  Future<void> unassignDriverFromBus(String busId);
  Future<List<BusDriverEntity>> getAvailableDrivers();
  Future<BusDriverEntity?> getBusDriver(String busId);

  // Streams para tiempo real
  Stream<List<BusEntity>> streamActiveBuses();
  Stream<BusEntity> streamBusLocation(String busId);
  Stream<List<BusEntity>> streamBusesByRoute(String routeId);

  // Métodos de utilidad
  Future<bool> isLicensePlateUnique(
    String licensePlate, {
    String? excludeBusId,
  });
  Future<int> getActiveBusesCount();
  Future<Map<String, int>> getBusesCountByRoute();
}
