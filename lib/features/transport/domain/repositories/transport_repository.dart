import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/route_entity.dart';
import '../entities/bus_entity.dart';
import '../entities/bus_stop_entity.dart';

abstract class TransportRepository {
  // ========== RUTAS DE BUSES ==========
  /// Obtiene todas las rutas activas del sistema
  Future<List<RouteEntity>> getActiveBusRoutes();

  /// Obtiene una ruta específica por su ID
  Future<RouteEntity> getBusRouteById(String routeId);

  /// Obtiene las rutas que pasan por una parada específica
  Future<List<RouteEntity>> getBusRoutesByStop(String busStopId);

  /// Stream de rutas activas (para actualizaciones en tiempo real)
  Stream<List<RouteEntity>> streamActiveBusRoutes();

  // ========== BUSES INDIVIDUALES ==========
  /// Obtiene todos los buses activos en el sistema
  Future<List<BusEntity>> getActiveBuses();

  /// Obtiene los buses de una ruta específica
  Future<List<BusEntity>> getBusesByRoute(String routeId);

  /// Obtiene un bus específico por su ID
  Future<BusEntity> getBusById(String busId);

  /// Stream de buses activos (para seguimiento en tiempo real)
  Stream<List<BusEntity>> streamActiveBuses();

  /// Stream de Paradas Activas
  Stream<List<BusStopEntity>> streamActiveBusStops();

  /// Stream de ubicación de un bus específico
  Stream<BusEntity> streamBusLocation(String busId);

  // ========== PARADAS DE BUSES ==========
  /// Obtiene todas las paradas activas del sistema
  Future<List<BusStopEntity>> getActiveBusStops();

  /// Obtiene las paradas de una ruta específica
  Future<List<BusStopEntity>> getBusStopsByRoute(String routeId);

  /// Obtiene una parada específica por su ID
  Future<BusStopEntity> getBusStopById(String busStopId);

  /// Encuentra paradas cercanas a una ubicación
  Future<List<BusStopEntity>> findNearbyBusStops(
    LatLng location,
    double radiusKm,
  );

  // ========== FUNCIONALIDADES PARA USUARIOS ==========
  /// Calcula el tiempo estimado de llegada de un bus a una parada
  Future<int> calculateBusETA(String busId, String busStopId);

  /// Calcula la distancia entre un bus y una parada
  Future<double> calculateDistanceToBus(String busId, LatLng userLocation);

  /// Encuentra buses cercanos a una ubicación
  Future<List<BusEntity>> findNearbyBuses(LatLng userLocation, double radiusKm);

  /// Obtiene la ubicación actual del usuario
  Future<LatLng> getCurrentUserLocation();

  /// Calcula la distancia entre dos puntos
  Future<double> calculateDistance(LatLng start, LatLng end);

  /// Calcula el tiempo estimado entre dos puntos
  Future<double> calculateETA(LatLng start, LatLng end);
}
