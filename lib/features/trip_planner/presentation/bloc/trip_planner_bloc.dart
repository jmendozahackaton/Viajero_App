// lib/features/trip_planner/presentation/bloc/trip_planner_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/get_saved_trips_usecase.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/plan_trip_usecase.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/save_trip_plan_usecase.dart';

part 'trip_planner_event.dart';
part 'trip_planner_state.dart';

class TripPlannerBloc extends Bloc<TripPlannerEvent, TripPlannerState> {
  final PlanTripUseCase _planTripUseCase;
  final SaveTripPlanUseCase _saveTripPlanUseCase;
  final GetSavedTripsUseCase _getSavedTripsUseCase;
  StreamSubscription<List<TripPlanEntity>>? _tripsSubscription;

  TripPlannerBloc({
    required PlanTripUseCase planTripUseCase,
    required SaveTripPlanUseCase saveTripPlanUseCase,
    required GetSavedTripsUseCase getSavedTripsUseCase,
  }) : _planTripUseCase = planTripUseCase,
       _saveTripPlanUseCase = saveTripPlanUseCase,
       _getSavedTripsUseCase = getSavedTripsUseCase,
       super(TripPlannerState.initial()) {
    on<PlanTripEvent>(_onPlanTrip);
    on<SaveTripPlanEvent>(_onSaveTripPlan);
    on<LoadSavedTripsEvent>(_onLoadSavedTrips);
    on<UpdateTripPreferencesEvent>(_onUpdatePreferences);
    on<TripsUpdatedEvent>(_onTripsUpdated);
    on<TripsLoadErrorEvent>(_onTripsLoadError);
  }

  Future<void> _onPlanTrip(
    PlanTripEvent event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final routeOptions = await _planTripUseCase.execute(
        event.origin,
        event.destination,
        state.currentPreferences,
      );

      emit(
        state.copyWith(
          isLoading: false,
          routeOptions: routeOptions,
          selectedOrigin: event.origin,
          selectedDestination: event.destination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al planificar el viaje: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _tripsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSaveTripPlan(
    SaveTripPlanEvent event,
    Emitter<TripPlannerState> emit,
  ) async {
    if (state.selectedOrigin == null || state.selectedDestination == null) {
      emit(
        state.copyWith(
          errorMessage: 'Debe seleccionar origen y destino primero',
        ),
      );
      return;
    }

    try {
      final tripPlan = TripPlanEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        origin: state.selectedOrigin!,
        destination: state.selectedDestination!,
        plannedTime: DateTime.now(),
        routeOptions: state.routeOptions,
        preferences: state.currentPreferences,
      );

      await _saveTripPlanUseCase.execute(tripPlan);
      emit(state.copyWith(successMessage: 'Viaje guardado exitosamente'));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al guardar el viaje: $e'));
    }
  }

  Future<void> _onLoadSavedTrips(
    LoadSavedTripsEvent event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // Cancelar suscripción anterior si existe
    await _tripsSubscription?.cancel();
    _tripsSubscription = null;

    try {
      _tripsSubscription = _getSavedTripsUseCase.execute().listen(
        (trips) {
          if (!isClosed) {
            add(TripsUpdatedEvent(trips: trips));
          }
        },
        onError: (error) {
          if (!isClosed) {
            // Usar add en lugar de emit para evitar problemas de async
            add(TripsLoadErrorEvent(error: error.toString()));
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Error al suscribirse a viajes: $e',
          ),
        );
      }
    }
  }

  void _onTripsLoadError(
    TripsLoadErrorEvent event,
    Emitter<TripPlannerState> emit,
  ) {
    emit(state.copyWith(isLoading: false, errorMessage: event.error));
  }

  void _onTripsUpdated(
    TripsUpdatedEvent event,
    Emitter<TripPlannerState> emit,
  ) {
    emit(state.copyWith(isLoading: false, savedTrips: event.trips));
  }

  void _onUpdatePreferences(
    UpdateTripPreferencesEvent event,
    Emitter<TripPlannerState> emit,
  ) {
    emit(state.copyWith(currentPreferences: event.preferences));
  }
}
