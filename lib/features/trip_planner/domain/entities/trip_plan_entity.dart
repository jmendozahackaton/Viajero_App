// lib/features/trip_planner/domain/entities/trip_plan_entity.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_stop_entity.dart';

class TripPlanEntity {
  final String id;
  final LatLng origin;
  final LatLng destination;
  final DateTime plannedTime;
  final List<RouteOption> routeOptions;
  final TripPreferences preferences;

  const TripPlanEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.plannedTime,
    required this.routeOptions,
    required this.preferences,
  });

  TripPlanEntity copyWith({
    String? id,
    LatLng? origin,
    LatLng? destination,
    DateTime? plannedTime,
    List<RouteOption>? routeOptions,
    TripPreferences? preferences,
  }) {
    return TripPlanEntity(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      plannedTime: plannedTime ?? this.plannedTime,
      routeOptions: routeOptions ?? this.routeOptions,
      preferences: preferences ?? this.preferences,
    );
  }
}

class RouteOption {
  final String routeId;
  final String routeName;
  final List<BusStopEntity> busStopSequence;
  final double totalDistance;
  final int estimatedTime;
  final double fare;
  final int transfers;
  final double walkingDistance;
  final double sustainabilityScore;

  const RouteOption({
    required this.routeId,
    required this.routeName,
    required this.busStopSequence,
    required this.totalDistance,
    required this.estimatedTime,
    required this.fare,
    required this.transfers,
    required this.walkingDistance,
    required this.sustainabilityScore,
  });
}

class TripPreferences {
  final bool minimizeTransfers;
  final bool minimizeWalking;
  final bool prioritizeAccessibility;
  final int maxWaitTime;
  final int maxWalkingDistance;

  const TripPreferences({
    this.minimizeTransfers = false,
    this.minimizeWalking = false,
    this.prioritizeAccessibility = false,
    this.maxWaitTime = 15,
    this.maxWalkingDistance = 1000,
  });

  TripPreferences copyWith({
    bool? minimizeTransfers,
    bool? minimizeWalking,
    bool? prioritizeAccessibility,
    int? maxWaitTime,
    int? maxWalkingDistance,
  }) {
    return TripPreferences(
      minimizeTransfers: minimizeTransfers ?? this.minimizeTransfers,
      minimizeWalking: minimizeWalking ?? this.minimizeWalking,
      prioritizeAccessibility:
          prioritizeAccessibility ?? this.prioritizeAccessibility,
      maxWaitTime: maxWaitTime ?? this.maxWaitTime,
      maxWalkingDistance: maxWalkingDistance ?? this.maxWalkingDistance,
    );
  }
}
