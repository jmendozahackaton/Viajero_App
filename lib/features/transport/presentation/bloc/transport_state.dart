part of 'transport_bloc.dart';

@immutable
sealed class TransportState {}

final class TransportInitial extends TransportState {}

final class TransportLoading extends TransportState {}

final class TransportMapLoadedState extends TransportState {
  final LatLng initialPosition;
  final LatLng? currentLocation;
  final List<RouteEntity> routes;
  final List<BusEntity> buses;
  final List<BusStopEntity> busStops;
  final String? selectedRouteId;
  final String? selectedBusId;
  final String? selectedBusStopId;
  final LatLng? userLocation; // ← NUEVO: Ubicación real del usuario
  final bool hasLocationPermission; // ← NUEVO: Estado de permisos
  final List<BusStopEntity> nearbyBusStops; // ← NUEVO: Paradas cercanas

  TransportMapLoadedState({
    required this.initialPosition,
    this.currentLocation,
    this.routes = const [],
    this.buses = const [],
    this.busStops = const [],
    this.selectedRouteId,
    this.selectedBusId,
    this.selectedBusStopId,
    this.userLocation, // ← Inicializar en constructor
    this.hasLocationPermission = false, // ← Valor por defecto
    this.nearbyBusStops = const [], // ← Inicializar vacío
  });

  TransportMapLoadedState copyWith({
    LatLng? initialPosition,
    LatLng? currentLocation,
    List<RouteEntity>? routes,
    List<BusEntity>? buses,
    List<BusStopEntity>? busStops,
    String? selectedRouteId,
    String? selectedBusId,
    String? selectedBusStopId,
    LatLng? userLocation, // ← NUEVO
    bool? hasLocationPermission, // ← NUEVO
    List<BusStopEntity>? nearbyBusStops, // ← NUEVO
  }) {
    return TransportMapLoadedState(
      initialPosition: initialPosition ?? this.initialPosition,
      currentLocation: currentLocation ?? this.currentLocation,
      routes: routes ?? this.routes,
      buses: buses ?? this.buses,
      busStops: busStops ?? this.busStops,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      selectedBusId: selectedBusId ?? this.selectedBusId,
      selectedBusStopId: selectedBusStopId ?? this.selectedBusStopId,
      userLocation: userLocation ?? this.userLocation, // ← NUEVO
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission, // ← NUEVO
      nearbyBusStops: nearbyBusStops ?? this.nearbyBusStops, // ← NUEVO
    );
  }
}

final class TransportError extends TransportState {
  final String message;

  TransportError(this.message);
}

final class TransportMapLoading extends TransportState {
  final String loadingMessage;

  TransportMapLoading(this.loadingMessage);
}
