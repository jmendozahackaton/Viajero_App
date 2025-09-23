// lib/features/trip_planner/presentation/bloc/trip_planner_event.dart
part of 'trip_planner_bloc.dart';

abstract class TripPlannerEvent extends Equatable {
  const TripPlannerEvent();

  @override
  List<Object> get props => [];
}

class PlanTripEvent extends TripPlannerEvent {
  final LatLng origin;
  final LatLng destination;

  const PlanTripEvent({required this.origin, required this.destination});

  @override
  List<Object> get props => [origin, destination];
}

class ClearSearchEvent extends TripPlannerEvent {}

class DeleteTripPlanEvent extends TripPlannerEvent {
  final String tripPlanId;

  const DeleteTripPlanEvent({required this.tripPlanId});

  @override
  List<Object> get props => [tripPlanId];
}

class SaveTripPlanEvent extends TripPlannerEvent {
  final RouteOption selectedOption;

  const SaveTripPlanEvent({required this.selectedOption});

  @override
  List<Object> get props => [selectedOption];
}

class LoadSavedTripsEvent extends TripPlannerEvent {}

class UpdateTripPreferencesEvent extends TripPlannerEvent {
  final TripPreferences preferences;

  const UpdateTripPreferencesEvent({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class TripsUpdatedEvent extends TripPlannerEvent {
  final List<TripPlanEntity> trips;

  const TripsUpdatedEvent({required this.trips});

  @override
  List<Object> get props => [trips];
}

class TripsLoadErrorEvent extends TripPlannerEvent {
  final String error;

  const TripsLoadErrorEvent({required this.error});

  @override
  List<Object> get props => [error];
}
