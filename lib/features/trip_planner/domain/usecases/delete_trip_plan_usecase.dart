import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';

class DeleteTripPlanUseCase {
  final TripPlannerRepository repository;

  DeleteTripPlanUseCase({required this.repository});

  Future<void> execute(String tripPlanId) {
    return repository.deleteTripPlan(tripPlanId);
  }
}
