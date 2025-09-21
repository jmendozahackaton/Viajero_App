// lib/features/trip_planner/domain/usecases/save_trip_plan_usecase.dart
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';

class SaveTripPlanUseCase {
  final TripPlannerRepository repository;

  SaveTripPlanUseCase({required this.repository}); // Parámetro con nombre

  Future<TripPlanEntity> execute(TripPlanEntity tripPlan) async {
    return await repository.saveTripPlan(tripPlan);
  }
}
