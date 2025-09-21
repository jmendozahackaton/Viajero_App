// lib/features/trip_planner/domain/usecases/plan_trip_usecase.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';

class PlanTripUseCase {
  final TripPlannerRepository repository;

  PlanTripUseCase({
    required this.repository,
  }); // Debe tener parámetro con nombre

  Future<List<RouteOption>> execute(
    LatLng origin,
    LatLng destination,
    TripPreferences preferences,
  ) async {
    return await repository.findRouteOptions(origin, destination, preferences);
  }
}
