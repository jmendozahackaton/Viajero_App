import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import 'package:hackaton_app/features/transport/domain/entities/route_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_stop_entity.dart';

class TransportRepositoryImpl implements TransportRepository {
  final FirebaseFirestore _firestore;

  TransportRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  // Colecciones de Firestore
  CollectionReference<Map<String, dynamic>> get _routesCollection =>
      _firestore.collection('bus_routes');

  CollectionReference<Map<String, dynamic>> get _busesCollection =>
      _firestore.collection('buses');

  CollectionReference<Map<String, dynamic>> get _busStopsCollection =>
      _firestore.collection('bus_stops');

  // ========== IMPLEMENTACIÓN DE RUTAS ==========
  @override
  Future<List<RouteEntity>> getActiveBusRoutes() async {
    try {
      final query = await _routesCollection
          .where('isActive', isEqualTo: true)
          .get();
      return query.docs
          .map((doc) => _mapToRouteEntity(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo rutas: $e');
    }
  }

  @override
  Future<RouteEntity> getBusRouteById(String routeId) async {
    try {
      final doc = await _routesCollection.doc(routeId).get();
      if (!doc.exists) throw Exception('Ruta no encontrada');
      return _mapToRouteEntity(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error obteniendo ruta: $e');
    }
  }

  // ========== IMPLEMENTACIÓN DE BUSES ==========
  @override
  Future<List<BusEntity>> getActiveBuses() async {
    try {
      final query = await _busesCollection
          .where('isActive', isEqualTo: true)
          .get();
      return query.docs
          .map((doc) => _mapToBusEntity(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo buses: $e');
    }
  }

  @override
  Future<BusEntity> getBusById(String busId) async {
    try {
      final doc = await _busesCollection.doc(busId).get();
      if (!doc.exists) throw Exception('Bus no encontrado');
      return _mapToBusEntity(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error obteniendo bus: $e');
    }
  }

  // ========== IMPLEMENTACIÓN DE PARADAS ==========
  @override
  Future<List<BusStopEntity>> getActiveBusStops() async {
    try {
      final query = await _busStopsCollection
          .where('isActive', isEqualTo: true)
          .get();
      return query.docs
          .map((doc) => _mapToBusStopEntity(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo paradas: $e');
    }
  }

  @override
  Future<BusStopEntity> getBusStopById(String busStopId) async {
    try {
      final doc = await _busStopsCollection.doc(busStopId).get();
      if (!doc.exists) throw Exception('Parada de bus no encontrada');
      return _mapToBusStopEntity(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error obteniendo parada de bus: $e');
    }
  }

  // ========== MÉTODOS AUXILIARES DE MAPEO ==========
  RouteEntity _mapToRouteEntity(Map<String, dynamic> data, String id) {
    return RouteEntity(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      coordinates: _parseCoordinates(data['coordinates']),
      busStopIds: List<String>.from(data['busStopIds'] ?? []),
      estimatedTime: (data['estimatedTime'] ?? 0).toDouble(),
      distance: (data['distance'] ?? 0).toDouble(),
      fare: (data['fare'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  BusEntity _mapToBusEntity(Map<String, dynamic> data, String id) {
    return BusEntity(
      id: id,
      routeId: data['routeId'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      driverName: data['driverName'] ?? '',
      capacity: data['capacity'] ?? 0,
      currentLocation: _parseLatLng(data['currentLocation']),
      lastUpdate: (data['lastUpdate'] as Timestamp).toDate(),
      currentSpeed: data['currentSpeed'] ?? 0,
      occupancy: data['occupancy'] ?? 0,
      estimatedArrival: data['estimatedArrival'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  BusStopEntity _mapToBusStopEntity(Map<String, dynamic> data, String id) {
    return BusStopEntity(
      id: id,
      name: data['name'] ?? '',
      location: _parseLatLng(data['location']),
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      routeIds: List<String>.from(data['routeIds'] ?? []),
      hasShelter: data['hasShelter'] ?? false,
      hasSeating: data['hasSeating'] ?? false,
      hasLighting: data['hasLighting'] ?? false,
      isAccessible: data['isAccessible'] ?? false,
      isActive: data['isActive'] ?? true,
    );
  }

  // ========== MÉTODOS DE UTILIDAD ==========
  List<LatLng> _parseCoordinates(dynamic coordinates) {
    if (coordinates is List) {
      return coordinates.map((coord) {
        if (coord is Map<String, dynamic>) {
          return LatLng(coord['latitude'] ?? 0.0, coord['longitude'] ?? 0.0);
        }
        return const LatLng(0, 0);
      }).toList();
    }
    return [];
  }

  LatLng _parseLatLng(dynamic location) {
    if (location is Map<String, dynamic>) {
      return LatLng(location['latitude'] ?? 0.0, location['longitude'] ?? 0.0);
    }
    return const LatLng(0, 0);
  }

  // ========== MÉTODOS PENDIENTES DE IMPLEMENTACIÓN ==========
  @override
  Future<int> calculateBusETA(String busId, String busStopId) async {
    // TODO: Implementar cálculo de ETA
    return 5; // Valor temporal
  }

  @override
  Future<double> calculateDistanceToBus(
    String busId,
    LatLng userLocation,
  ) async {
    // TODO: Implementar cálculo de distancia
    return 1.5; // Valor temporal
  }

  @override
  Future<LatLng> getCurrentUserLocation() async {
    // TODO: Implementar geolocalización
    return const LatLng(12.136389, -86.251389); // Managua por defecto
  }

  // ... Implementar otros métodos con throw UnimplementedError() temporalmente
  @override
  Stream<List<RouteEntity>> streamActiveBusRoutes() {
    throw UnimplementedError();
  }

  @override
  Stream<List<BusEntity>> streamActiveBuses() {
    throw UnimplementedError();
  }

  @override
  Stream<BusEntity> streamBusLocation(String busId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BusEntity>> findNearbyBuses(
    LatLng userLocation,
    double radiusKm,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<BusStopEntity>> findNearbyBusStops(
    LatLng location,
    double radiusKm,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<RouteEntity>> getBusRoutesByStop(String busStopId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BusEntity>> getBusesByRoute(String routeId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BusStopEntity>> getBusStopsByRoute(String routeId) {
    throw UnimplementedError();
  }

  @override
  Future<double> calculateDistance(LatLng start, LatLng end) {
    throw UnimplementedError();
  }

  @override
  Future<double> calculateETA(LatLng start, LatLng end) {
    throw UnimplementedError();
  }
}
