// lib/features/trip_planner/domain/usecases/get_saved_trips_usecase.dart
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';

class GetSavedTripsUseCase {
  final TripPlannerRepository repository;

  GetSavedTripsUseCase({required this.repository});

  Stream<List<TripPlanEntity>> execute() {
    return repository.getSavedTripPlans();
  }
}
