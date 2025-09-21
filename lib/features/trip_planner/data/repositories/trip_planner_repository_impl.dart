// lib/features/trip_planner/data/repositories/trip_planner_repository_impl.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/trip_planner/data/mock_data/mock_trip_planner_data.dart';
import 'package:hackaton_app/features/trip_planner/data/services/trip_movement_service.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';

// IMPORTAR DEPENDENCIAS EXISTENTES
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import 'package:hackaton_app/features/transport/domain/entities/route_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_stop_entity.dart';

class TripPlannerRepositoryImpl implements TripPlannerRepository {
  final FirebaseFirestore _firestore;
  final TransportRepository _transportRepository;
  final MockTripPlannerDataService _mockDataService;
  final TripMovementSimulationService _movementService;

  TripPlannerRepositoryImpl({
    required FirebaseFirestore firestore,
    required TransportRepository transportRepository,
  }) : _firestore = firestore,
       _transportRepository = transportRepository,
       _mockDataService = MockTripPlannerDataService(firestore),
       _movementService = TripMovementSimulationService(firestore);

  // ========== IMPLEMENTACIÓN DE MÉTODOS PRINCIPALES ==========

  @override
  Future<List<RouteOption>> findRouteOptions(
    LatLng origin,
    LatLng destination,
    TripPreferences preferences,
  ) async {
    try {
      // 1. Encontrar paradas cercanas al origen y destino
      final nearOrigin = await findNearbyBusStops(
        origin,
        preferences.maxWalkingDistance / 1000,
      );
      final nearDestination = await findNearbyBusStops(
        destination,
        preferences.maxWalkingDistance / 1000,
      );

      // 2. Obtener todas las rutas activas
      final allRoutes = await _transportRepository.getActiveBusRoutes();

      // 3. Algoritmo de planificación de ruta
      return _calculateRouteOptions(
        origin,
        destination,
        nearOrigin,
        nearDestination,
        allRoutes,
        preferences,
      );
    } catch (e) {
      throw Exception('Error finding route options: $e');
    }
  }

  @override
  Future<List<BusStopEntity>> findNearbyBusStops(
    LatLng location,
    double radiusKm,
  ) async {
    try {
      // Reutilizar el método del repositorio de transporte
      return await _transportRepository.findNearbyBusStops(location, radiusKm);
    } catch (e) {
      throw Exception('Error finding nearby bus stops: $e');
    }
  }

  @override
  Future<double> calculateWalkingDistance(LatLng start, LatLng end) async {
    // Implementación simplificada - podrías usar el paquete geolocator
    final distance = _calculateHaversineDistance(start, end);
    return distance;
  }

  @override
  Future<int> estimateTripTime(RouteOption routeOption) async {
    // Estimación basada en distancia y velocidad promedio (20 km/h)
    const averageSpeed = 20.0; // km/h
    final timeHours = routeOption.totalDistance / averageSpeed;
    return (timeHours * 60).round(); // Convertir a minutos
  }

  @override
  Future<TripPlanEntity> saveTripPlan(TripPlanEntity tripPlan) async {
    try {
      final docRef = _firestore.collection('saved_trips').doc(tripPlan.id);

      await docRef.set({
        'origin': {
          'latitude': tripPlan.origin.latitude,
          'longitude': tripPlan.origin.longitude,
        },
        'destination': {
          'latitude': tripPlan.destination.latitude,
          'longitude': tripPlan.destination.longitude,
        },
        'plannedTime': tripPlan.plannedTime,
        'preferences': {
          'minimizeTransfers': tripPlan.preferences.minimizeTransfers,
          'minimizeWalking': tripPlan.preferences.minimizeWalking,
          'prioritizeAccessibility':
              tripPlan.preferences.prioritizeAccessibility,
          'maxWaitTime': tripPlan.preferences.maxWaitTime,
          'maxWalkingDistance': tripPlan.preferences.maxWalkingDistance,
        },
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return tripPlan;
    } catch (e) {
      throw Exception('Error saving trip plan: $e');
    }
  }

  @override
  Stream<List<TripPlanEntity>> getSavedTripPlans() {
    return _firestore
        .collection('saved_trips')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              return _mapToTripPlanEntity(doc.data(), doc.id);
            }),
          );
        });
  }

  @override
  Future<void> deleteTripPlan(String tripPlanId) async {
    try {
      await _firestore.collection('saved_trips').doc(tripPlanId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error deleting trip plan: $e');
    }
  }

  @override
  Future<void> initializeMockData() async {
    await _mockDataService.createMockTripPlannerData();
  }

  @override
  Future<void> startMockMovementSimulation() async {
    _movementService.startSimulatingTripMovements();
  }

  // ========== MÉTODOS AUXILIARES ==========

  List<RouteOption> _calculateRouteOptions(
    LatLng origin,
    LatLng destination,
    List<BusStopEntity> nearOrigin,
    List<BusStopEntity> nearDestination,
    List<RouteEntity> allRoutes,
    TripPreferences preferences,
  ) {
    final options = <RouteOption>[];

    // Lógica para encontrar rutas directas
    _findDirectRoutes(
      origin,
      destination,
      nearOrigin,
      nearDestination,
      allRoutes,
      options,
      preferences,
    );

    // Lógica para encontrar rutas con transbordos
    if (!preferences.minimizeTransfers) {
      _findTransferRoutes(
        origin,
        destination,
        nearOrigin,
        nearDestination,
        allRoutes,
        options,
        preferences,
      );
    }

    // Aplicar preferencias y ordenar
    return _applyPreferencesAndSort(options, preferences);
  }

  void _findDirectRoutes(
    LatLng origin,
    LatLng destination,
    List<BusStopEntity> nearOrigin,
    List<BusStopEntity> nearDestination,
    List<RouteEntity> allRoutes,
    List<RouteOption> options,
    TripPreferences preferences,
  ) {
    for (final originStop in nearOrigin) {
      for (final destinationStop in nearDestination) {
        for (final route in allRoutes) {
          if (route.busStopIds.contains(originStop.id) &&
              route.busStopIds.contains(destinationStop.id)) {
            final originIndex = route.busStopIds.indexOf(originStop.id);
            final destinationIndex = route.busStopIds.indexOf(
              destinationStop.id,
            );

            if (originIndex < destinationIndex) {
              final busStops = _getBusStopSequence(
                route,
                originIndex,
                destinationIndex,
              );
              final walkingDistance = _calculateTotalWalkingDistance(
                origin,
                destination,
                originStop,
                destinationStop,
              );

              if (walkingDistance <= preferences.maxWalkingDistance) {
                options.add(
                  RouteOption(
                    routeId: route.id,
                    routeName: route.name,
                    busStopSequence: busStops,
                    totalDistance:
                        route.distance *
                        ((destinationIndex - originIndex) /
                            route.busStopIds.length),
                    estimatedTime: _estimateDirectRouteTime(
                      route,
                      originIndex,
                      destinationIndex,
                      walkingDistance,
                    ),
                    fare: route.fare,
                    transfers: 0,
                    walkingDistance: walkingDistance,
                    sustainabilityScore: _calculateSustainabilityScore(route),
                  ),
                );
              }
            }
          }
        }
      }
    }
  }

  void _findTransferRoutes(
    LatLng origin,
    LatLng destination,
    List<BusStopEntity> nearOrigin,
    List<BusStopEntity> nearDestination,
    List<RouteEntity> allRoutes,
    List<RouteOption> options,
    TripPreferences preferences,
  ) {
    // Implementación simplificada de rutas con transbordos
    // (Para una implementación real necesitarías un algoritmo de grafo)

    for (final originStop in nearOrigin) {
      for (final destinationStop in nearDestination) {
        // Buscar rutas que conecten a través de una parada intermedia
        for (final route1 in allRoutes) {
          if (route1.busStopIds.contains(originStop.id)) {
            for (final route2 in allRoutes) {
              if (route2.busStopIds.contains(destinationStop.id) &&
                  route1.id != route2.id) {
                // Encontrar paradas de transferencia comunes
                final transferStops = route1.busStopIds
                    .where((stopId) => route2.busStopIds.contains(stopId))
                    .toList();

                for (final transferStopId in transferStops) {
                  final walkingDistance = _calculateTotalWalkingDistance(
                    origin,
                    destination,
                    originStop,
                    destinationStop,
                  );

                  if (walkingDistance <= preferences.maxWalkingDistance) {
                    options.add(
                      RouteOption(
                        routeId: '${route1.id}-${route2.id}',
                        routeName: '${route1.name} → ${route2.name}',
                        busStopSequence:
                            [], // Podrías poblarlo con las paradas reales
                        totalDistance:
                            (route1.distance + route2.distance) *
                            0.6, // Estimación
                        estimatedTime: _estimateTransferRouteTime(
                          route1,
                          route2,
                          originStop.id,
                          destinationStop.id,
                          transferStopId,
                          walkingDistance,
                        ),
                        fare: route1.fare + route2.fare,
                        transfers: 1,
                        walkingDistance: walkingDistance,
                        sustainabilityScore:
                            (_calculateSustainabilityScore(route1) +
                                _calculateSustainabilityScore(route2)) /
                            2,
                      ),
                    );
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  List<RouteOption> _applyPreferencesAndSort(
    List<RouteOption> options,
    TripPreferences preferences,
  ) {
    // Aplicar filtros basados en preferencias
    var filteredOptions = options.where((option) {
      if (preferences.minimizeTransfers && option.transfers > 0) return false;
      if (preferences.minimizeWalking && option.walkingDistance > 500)
        return false;
      return true;
    }).toList();

    // Ordenar según preferencias
    filteredOptions.sort((a, b) {
      if (preferences.minimizeTransfers) {
        final transferCompare = a.transfers.compareTo(b.transfers);
        if (transferCompare != 0) return transferCompare;
      }

      if (preferences.minimizeWalking) {
        final walkingCompare = a.walkingDistance.compareTo(b.walkingDistance);
        if (walkingCompare != 0) return walkingCompare;
      }

      return a.estimatedTime.compareTo(b.estimatedTime);
    });

    return filteredOptions;
  }

  List<BusStopEntity> _getBusStopSequence(
    RouteEntity route,
    int startIndex,
    int endIndex,
  ) {
    // Obtener las paradas reales para la secuencia
    // Esto requeriría una llamada adicional al repositorio
    return []; // Implementación simplificada
  }

  double _calculateTotalWalkingDistance(
    LatLng origin,
    LatLng destination,
    BusStopEntity originStop,
    BusStopEntity destinationStop,
  ) {
    final distanceToOriginStop = _calculateHaversineDistance(
      origin,
      originStop.location,
    );
    final distanceToDestinationStop = _calculateHaversineDistance(
      destination,
      destinationStop.location,
    );
    return distanceToOriginStop + distanceToDestinationStop;
  }

  int _estimateDirectRouteTime(
    RouteEntity route,
    int startIndex,
    int endIndex,
    double walkingDistance,
  ) {
    final segmentDistance =
        route.distance * ((endIndex - startIndex) / route.busStopIds.length);
    final busTime = (segmentDistance / 20) * 60; // 20 km/h promedio → minutos
    final walkingTime =
        (walkingDistance / 1000) / 5 * 60; // 5 km/h caminando → minutos

    return (busTime + walkingTime + 5).round(); // +5 minutos de espera
  }

  int _estimateTransferRouteTime(
    RouteEntity route1,
    RouteEntity route2,
    String originStopId,
    String destinationStopId,
    String transferStopId,
    double walkingDistance,
  ) {
    // Estimación simplificada para rutas con transbordo
    final busTime1 = (route1.distance * 0.5 / 20) * 60;
    final busTime2 = (route2.distance * 0.5 / 20) * 60;
    final walkingTime = (walkingDistance / 1000) / 5 * 60;
    const transferWaitTime = 10; // 10 minutos de espera para transbordo

    return (busTime1 + busTime2 + walkingTime + transferWaitTime).round();
  }

  double _calculateSustainabilityScore(RouteEntity route) {
    // Puntuación de sostenibilidad basada en distancia y tipo de ruta
    return 100 - (route.distance * 0.5); // Ejemplo simplificado
  }

  double _calculateHaversineDistance(LatLng start, LatLng end) {
    // Fórmula de Haversine para calcular distancia entre dos puntos
    const R = 6371e3; // Radio de la Tierra en metros
    num pi = 3.1416;
    final a1 = start.latitude * pi / 180;
    final a2 = end.latitude * pi / 180;
    final ac = (end.latitude - start.latitude) * pi / 180;
    final ab = (end.longitude - start.longitude) * pi / 180;

    final a =
        sin(ac / 2) * sin(ac / 2) +
        cos(a1) * cos(a2) * sin(ab / 2) * sin(ab / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distancia en metros
  }

  TripPlanEntity _mapToTripPlanEntity(Map<String, dynamic> data, String id) {
    return TripPlanEntity(
      id: id,
      origin: _parseLatLng(data['origin']),
      destination: _parseLatLng(data['destination']),
      plannedTime: (data['plannedTime'] as Timestamp).toDate(),
      routeOptions: [], // Se podría cargar posteriormente
      preferences: _mapToTripPreferences(data['preferences']),
    );
  }

  TripPreferences _mapToTripPreferences(Map<String, dynamic>? data) {
    if (data == null) return const TripPreferences();

    return TripPreferences(
      minimizeTransfers: data['minimizeTransfers'] ?? false,
      minimizeWalking: data['minimizeWalking'] ?? false,
      prioritizeAccessibility: data['prioritizeAccessibility'] ?? false,
      maxWaitTime: data['maxWaitTime'] ?? 15,
      maxWalkingDistance: data['maxWalkingDistance'] ?? 1000,
    );
  }

  LatLng _parseLatLng(dynamic location) {
    if (location is Map<String, dynamic>) {
      return LatLng(
        (location['latitude'] ?? 0.0).toDouble(),
        (location['longitude'] ?? 0.0).toDouble(),
      );
    }
    return const LatLng(0, 0);
  }
}
