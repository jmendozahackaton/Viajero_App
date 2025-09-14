import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import 'package:hackaton_app/features/transport/domain/entities/route_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_stop_entity.dart';

part 'transport_event.dart';
part 'transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final TransportRepository transportRepository;

  TransportBloc({required this.transportRepository})
    : super(TransportInitial()) {
    on<TransportMapLoaded>(_onMapLoaded);
    on<TransportLocationUpdated>(_onLocationUpdated);
    on<TransportRoutesRequested>(_onRoutesRequested);
    on<TransportBusesRequested>(_onBusesRequested);
    on<TransportBusStopsRequested>(_onBusStopsRequested);
    on<TransportRouteSelected>(_onRouteSelected);
    on<TransportBusSelected>(_onBusSelected);
    on<TransportBusStopSelected>(_onBusStopSelected);
    on<TransportUserLocationRequested>(_onUserLocationRequested);
  }

  void _onMapLoaded(TransportMapLoaded event, Emitter<TransportState> emit) {
    emit(TransportMapLoadedState(initialPosition: event.initialPosition));
    add(TransportRoutesRequested());
    add(TransportBusesRequested());
    add(TransportBusStopsRequested());
  }

  void _onLocationUpdated(
    TransportLocationUpdated event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(
          currentLocation: event.location,
        ),
      );
    }
  }

  Future<void> _onRoutesRequested(
    TransportRoutesRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final routes = await transportRepository.getActiveBusRoutes();
        emit((state as TransportMapLoadedState).copyWith(routes: routes));
      } catch (e) {
        emit(TransportError('Error cargando rutas: $e'));
      }
    }
  }

  Future<void> _onBusesRequested(
    TransportBusesRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final buses = await transportRepository.getActiveBuses();
        emit((state as TransportMapLoadedState).copyWith(buses: buses));
      } catch (e) {
        emit(TransportError('Error cargando buses: $e'));
      }
    }
  }

  Future<void> _onBusStopsRequested(
    TransportBusStopsRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final busStops = await transportRepository.getActiveBusStops();
        emit((state as TransportMapLoadedState).copyWith(busStops: busStops));
      } catch (e) {
        emit(TransportError('Error cargando paradas: $e'));
      }
    }
  }

  void _onRouteSelected(
    TransportRouteSelected event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(
          selectedRouteId: event.routeId,
          selectedBusId: null,
          selectedBusStopId: null,
        ),
      );
    }
  }

  void _onBusSelected(
    TransportBusSelected event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(
          selectedBusId: event.busId,
          selectedRouteId: null,
          selectedBusStopId: null,
        ),
      );
    }
  }

  void _onBusStopSelected(
    TransportBusStopSelected event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(
          selectedBusStopId: event.busStopId,
          selectedRouteId: null,
          selectedBusId: null,
        ),
      );
    }
  }

  Future<void> _onUserLocationRequested(
    TransportUserLocationRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final location = await transportRepository.getCurrentUserLocation();
        emit(
          (state as TransportMapLoadedState).copyWith(
            currentLocation: location,
          ),
        );
      } catch (e) {
        emit(TransportError('Error obteniendo ubicación: $e'));
      }
    }
  }
}
