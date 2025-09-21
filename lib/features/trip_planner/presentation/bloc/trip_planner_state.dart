// lib/features/trip_planner/presentation/bloc/trip_planner_state.dart
part of 'trip_planner_bloc.dart';

class TripPlannerState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<RouteOption> routeOptions;
  final List<TripPlanEntity> savedTrips;
  final LatLng? selectedOrigin;
  final LatLng? selectedDestination;
  final TripPreferences currentPreferences;

  const TripPlannerState({
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    required this.routeOptions,
    required this.savedTrips,
    this.selectedOrigin,
    this.selectedDestination,
    required this.currentPreferences,
  });

  factory TripPlannerState.initial() {
    return TripPlannerState(
      isLoading: false,
      routeOptions: const [],
      savedTrips: const [],
      currentPreferences: const TripPreferences(),
    );
  }

  TripPlannerState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<RouteOption>? routeOptions,
    List<TripPlanEntity>? savedTrips,
    LatLng? selectedOrigin,
    LatLng? selectedDestination,
    TripPreferences? currentPreferences,
  }) {
    return TripPlannerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      routeOptions: routeOptions ?? this.routeOptions,
      savedTrips: savedTrips ?? this.savedTrips,
      selectedOrigin: selectedOrigin ?? this.selectedOrigin,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      currentPreferences: currentPreferences ?? this.currentPreferences,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    routeOptions,
    savedTrips,
    selectedOrigin,
    selectedDestination,
    currentPreferences,
  ];
}
