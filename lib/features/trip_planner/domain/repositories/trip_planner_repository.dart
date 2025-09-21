// lib/features/trip_planner/domain/repositories/trip_planner_repository.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_stop_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';

abstract class TripPlannerRepository {
  Future<List<RouteOption>> findRouteOptions(
    LatLng origin,
    LatLng destination,
    TripPreferences preferences,
  );

  Future<List<BusStopEntity>> findNearbyBusStops(
    LatLng location,
    double radiusKm,
  );
  Future<double> calculateWalkingDistance(LatLng start, LatLng end);
  Future<int> estimateTripTime(RouteOption routeOption);
  Future<TripPlanEntity> saveTripPlan(TripPlanEntity tripPlan);
  Stream<List<TripPlanEntity>> getSavedTripPlans();
  Future<void> deleteTripPlan(String tripPlanId);

  // Métodos para simulación en desarrollo
  Future<void> initializeMockData();
  Future<void> startMockMovementSimulation();
}
