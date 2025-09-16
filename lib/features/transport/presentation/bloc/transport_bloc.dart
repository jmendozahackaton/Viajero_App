import 'dart:async';

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
  StreamSubscription<List<RouteEntity>>? _routesSubscription;
  StreamSubscription<List<BusEntity>>? _busesSubscription;
  StreamSubscription<List<BusStopEntity>>? _busStopsSubscription;

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

    on<TransportRoutesUpdated>(_onRoutesUpdated);
    on<TransportBusesUpdated>(_onBusesUpdated);
    on<TransportBusStopsUpdated>(_onBusStopsUpdated);
    on<TransportLocationPermissionRequested>(_onLocationPermissionRequested);
    on<TransportNearbyBusStopsRequested>(_onNearbyBusStopsRequested);
    on<TransportUserLocationUpdated>(_onUserLocationUpdated);

    _startStreamSubscriptions();
  }

  @override
  Future<void> close() {
    _routesSubscription?.cancel();
    _busesSubscription?.cancel();
    _busStopsSubscription?.cancel();
    return super.close();
  }

  void _startStreamSubscriptions() {
    // Suscribirse a rutas activas
    _routesSubscription = transportRepository.streamActiveBusRoutes().listen(
      (routes) {
        if (state is TransportMapLoadedState) {
          add(TransportRoutesUpdated(routes));
        }
      },
      onError: (error) {
        // Manejar errores de stream
      },
    );

    // Suscribirse a buses activos
    _busesSubscription = transportRepository.streamActiveBuses().listen(
      (buses) {
        if (state is TransportMapLoadedState) {
          add(TransportBusesUpdated(buses));
        }
      },
      onError: (error) {
        // Manejar errores de stream
      },
    );

    // Suscribirse a paradas activas
    _busStopsSubscription = transportRepository.streamActiveBusStops().listen(
      (busStops) {
        if (state is TransportMapLoadedState) {
          add(TransportBusStopsUpdated(busStops));
        }
      },
      onError: (error) {
        // Manejar errores de stream
      },
    );
  }

  void _onRoutesUpdated(
    TransportRoutesUpdated event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit((state as TransportMapLoadedState).copyWith(routes: event.routes));
    }
  }

  void _onBusesUpdated(
    TransportBusesUpdated event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit((state as TransportMapLoadedState).copyWith(buses: event.buses));
    }
  }

  void _onBusStopsUpdated(
    TransportBusStopsUpdated event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(busStops: event.busStops),
      );
    }
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
        final currentState = state as TransportMapLoadedState;

        // Si ya tenemos permisos, obtener ubicación directamente
        if (currentState.hasLocationPermission) {
          final location = await transportRepository.getCurrentUserLocation();
          emit(
            currentState.copyWith(
              userLocation: location,
              currentLocation: location,
            ),
          );

          // Buscar paradas cercanas
          add(
            TransportNearbyBusStopsRequested(
              userLocation: location,
              radiusKm: 1.0,
            ),
          );
        } else {
          // Si no tenemos permisos, solicitarlos
          add(TransportLocationPermissionRequested());
        }
      } catch (e) {
        emit(TransportError('Error obteniendo ubicación: $e'));
      }
    }
  }

  Future<void> _onLocationPermissionRequested(
    TransportLocationPermissionRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final currentState = state as TransportMapLoadedState;

        // Intentar obtener la ubicación (esto solicitará permisos)
        final userLocation = await transportRepository.getCurrentUserLocation();

        emit(
          currentState.copyWith(
            userLocation: userLocation,
            hasLocationPermission: true,
            currentLocation:
                userLocation, // Mover cámara a la ubicación del usuario
          ),
        );

        // Buscar paradas cercanas automáticamente
        add(
          TransportNearbyBusStopsRequested(
            userLocation: userLocation,
            radiusKm: 1.0,
          ),
        );
      } catch (e) {
        // Si falla, actualizar estado para indicar permisos denegados
        emit(
          (state as TransportMapLoadedState).copyWith(
            hasLocationPermission: false,
          ),
        );
      }
    }
  }

  Future<void> _onNearbyBusStopsRequested(
    TransportNearbyBusStopsRequested event,
    Emitter<TransportState> emit,
  ) async {
    if (state is TransportMapLoadedState) {
      try {
        final nearbyStops = await transportRepository.findNearbyBusStops(
          event.userLocation,
          event.radiusKm,
        );

        emit(
          (state as TransportMapLoadedState).copyWith(
            nearbyBusStops: nearbyStops,
          ),
        );
      } catch (e) {
        // No emitir error, solo loggear
        print('Error buscando paradas cercanas: $e');
      }
    }
  }

  void _onUserLocationUpdated(
    TransportUserLocationUpdated event,
    Emitter<TransportState> emit,
  ) {
    if (state is TransportMapLoadedState) {
      emit(
        (state as TransportMapLoadedState).copyWith(
          userLocation: event.userLocation,
        ),
      );
    }
  }
}
