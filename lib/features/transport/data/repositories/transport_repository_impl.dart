import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/core/services/geolocation_service.dart';
import 'package:geolocator/geolocator.dart';
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
  // Mejorar el método _parseCoordinates
  List<LatLng> _parseCoordinates(dynamic coordinates) {
    if (coordinates is List) {
      return coordinates.whereType<Map<String, dynamic>>().map((coord) {
        return LatLng(
          (coord['latitude'] ?? 0.0).toDouble(),
          (coord['longitude'] ?? 0.0).toDouble(),
        );
      }).toList();
    }
    return [];
  }

  // Mejorar el método _parseLatLng
  LatLng _parseLatLng(dynamic location) {
    if (location is Map<String, dynamic>) {
      return LatLng(
        (location['latitude'] ?? 0.0).toDouble(),
        (location['longitude'] ?? 0.0).toDouble(),
      );
    }
    return const LatLng(0, 0);
  }

  // ========== MÉTODOS PENDIENTES DE IMPLEMENTACIÓN ==========
  @override
  Future<int> calculateBusETA(String busId, String busStopId) async {
    // -TODO: Implementar cálculo de ETA
    return 5; // Valor temporal
  }

  @override
  Future<double> calculateDistanceToBus(
    String busId,
    LatLng userLocation,
  ) async {
    // -TODO: Implementar cálculo de distancia
    return 1.5; // Valor temporal
  }

  @override
  Future<LatLng> getCurrentUserLocation() async {
    // Coordenadas de Managua, Nicaragua
    const LatLng managuaLocation = LatLng(12.136389, -86.251389);

    // Forzar ubicación de Managua en modo debug/emulador
    const bool isEmulator = bool.fromEnvironment(
      'IS_EMULATOR',
      defaultValue: false,
    );

    if (kDebugMode || isEmulator) {
      print('Usando ubicación de prueba: Managua, Nicaragua');
      return managuaLocation;
    }

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Servicios de ubicación desactivados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación permanentemente denegados');
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Fallback a Managua si hay error en producción
      if (kReleaseMode) {
        print('Error obteniendo ubicación, usando fallback: Managua');
        return managuaLocation;
      } else {
        print('Error obteniendo ubicación en emulador: $e');
        return managuaLocation; // Siempre retorna Managua en desarrollo
      }
    }
  }

  // ... Implementar otros métodos con throw UnimplementedError() temporalmente
  @override
  Stream<List<RouteEntity>> streamActiveBusRoutes() {
    return _routesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              return _mapToRouteEntity(doc.data(), doc.id);
            }),
          );
        });
  }

  @override
  Stream<List<BusEntity>> streamActiveBuses() {
    return _busesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              return _mapToBusEntity(doc.data(), doc.id);
            }),
          );
        });
  }

  @override
  Stream<List<BusStopEntity>> streamActiveBusStops() {
    return _busStopsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              return _mapToBusStopEntity(doc.data(), doc.id);
            }),
          );
        });
  }

  @override
  Stream<BusEntity> streamBusLocation(String busId) {
    return _busesCollection.doc(busId).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        throw Exception('Bus no encontrado');
      }
      return _mapToBusEntity(snapshot.data()!, snapshot.id);
    });
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
  ) async {
    try {
      final allStops = await getActiveBusStops();

      return allStops.where((stop) {
        final distance =
            Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              stop.location.latitude,
              stop.location.longitude,
            ) /
            1000;

        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Error buscando paradas cercanas: $e');
    }
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
  Future<double> calculateDistance(LatLng start, LatLng end) async {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Convertir metros a kilómetros
  }

  @override
  Future<double> calculateETA(LatLng start, LatLng end) {
    final distance = GeolocationService.calculateDistance(start, end);
    const averageBusSpeed = 30.0; // 30 km/h promedio
    return Future.value(
      GeolocationService.calculateETA(distance, averageBusSpeed),
    );
  }
}
