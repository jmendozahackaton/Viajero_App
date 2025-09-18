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
  final LatLng? userLocation;
  final bool hasLocationPermission;
  final List<BusStopEntity> nearbyBusStops;
  final List<RouteEntity> stopRoutes;
  final Map<String, Duration?> stopETAs;
  final bool isLoadingStopRoutes;
  final String? errorMessage;

  // NUEVAS propiedades para manejar diálogos
  final bool showRouteDetailsDialog; // ← Para mostrar/ocultar diálogo
  final RouteEntity? dialogRoute; // ← Datos del diálogo
  final BusStopEntity? dialogBusStop; // ← Datos del diálogo
  final Duration? dialogETA; // ← Datos del diálogo
  final double? dialogDistance; // ← Datos del diálogo

  TransportMapLoadedState({
    required this.initialPosition,
    this.currentLocation,
    this.routes = const [],
    this.buses = const [],
    this.busStops = const [],
    this.selectedRouteId,
    this.selectedBusId,
    this.selectedBusStopId,
    this.userLocation,
    this.hasLocationPermission = false,
    this.nearbyBusStops = const [],
    this.stopRoutes = const [],
    this.stopETAs = const {},
    this.isLoadingStopRoutes = false,
    this.errorMessage,
    // Inicializar nuevas propiedades
    this.showRouteDetailsDialog = false, // ← Valor por defecto: false
    this.dialogRoute,
    this.dialogBusStop,
    this.dialogETA,
    this.dialogDistance,
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
    LatLng? userLocation,
    bool? hasLocationPermission,
    List<BusStopEntity>? nearbyBusStops,
    List<RouteEntity>? stopRoutes,
    Map<String, Duration?>? stopETAs,
    bool? isLoadingStopRoutes,
    String? errorMessage,
    // Nuevas propiedades para copyWith
    bool? showRouteDetailsDialog,
    RouteEntity? dialogRoute,
    BusStopEntity? dialogBusStop,
    Duration? dialogETA,
    double? dialogDistance,
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
      userLocation: userLocation ?? this.userLocation,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      nearbyBusStops: nearbyBusStops ?? this.nearbyBusStops,
      stopRoutes: stopRoutes ?? this.stopRoutes,
      stopETAs: stopETAs ?? this.stopETAs,
      isLoadingStopRoutes: isLoadingStopRoutes ?? this.isLoadingStopRoutes,
      errorMessage: errorMessage ?? this.errorMessage,
      // Nuevas propiedades
      showRouteDetailsDialog:
          showRouteDetailsDialog ?? this.showRouteDetailsDialog,
      dialogRoute: dialogRoute ?? this.dialogRoute,
      dialogBusStop: dialogBusStop ?? this.dialogBusStop,
      dialogETA: dialogETA ?? this.dialogETA,
      dialogDistance: dialogDistance ?? this.dialogDistance,
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
