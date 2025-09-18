part of 'transport_bloc.dart';

@immutable
sealed class TransportEvent {}

final class TransportMapLoaded extends TransportEvent {
  final LatLng initialPosition;

  TransportMapLoaded(this.initialPosition);
}

final class TransportLocationUpdated extends TransportEvent {
  final LatLng location;

  TransportLocationUpdated(this.location);
}

final class TransportRoutesRequested extends TransportEvent {}

final class TransportBusesRequested extends TransportEvent {}

final class TransportBusStopsRequested extends TransportEvent {}

final class TransportResetDialogState extends TransportEvent {}

final class TransportRouteSelected extends TransportEvent {
  final String routeId;

  TransportRouteSelected(this.routeId);
}

final class TransportBusSelected extends TransportEvent {
  final String busId;

  TransportBusSelected(this.busId);
}

final class TransportBusStopSelected extends TransportEvent {
  final String busStopId;

  TransportBusStopSelected(this.busStopId);
}

final class TransportUserLocationRequested extends TransportEvent {}

final class TransportRoutesUpdated extends TransportEvent {
  final List<RouteEntity> routes;

  TransportRoutesUpdated(this.routes);
}

final class TransportBusesUpdated extends TransportEvent {
  final List<BusEntity> buses;

  TransportBusesUpdated(this.buses);
}

final class TransportBusStopsUpdated extends TransportEvent {
  final List<BusStopEntity> busStops;

  TransportBusStopsUpdated(this.busStops);
}

final class TransportLocationPermissionRequested extends TransportEvent {}

final class TransportNearbyBusStopsRequested extends TransportEvent {
  final LatLng userLocation;
  final double radiusKm;

  TransportNearbyBusStopsRequested({
    required this.userLocation,
    this.radiusKm = 1.0,
  });
}

final class TransportUserLocationUpdated extends TransportEvent {
  final LatLng userLocation;

  TransportUserLocationUpdated(this.userLocation);
}

// Eventos para manejar rutas y ETA
final class TransportRoutesForStopRequested extends TransportEvent {
  final String busStopId;

  TransportRoutesForStopRequested(this.busStopId);
}

final class TransportStopETAsRequested extends TransportEvent {
  final String busStopId;

  TransportStopETAsRequested(this.busStopId);
}

final class TransportRouteETARequested extends TransportEvent {
  final String routeId;
  final String busStopId;

  TransportRouteETARequested(this.routeId, this.busStopId);
}

final class TransportRouteDetailsRequested extends TransportEvent {
  final String routeId;
  final String busStopId;
  final Duration eta;

  TransportRouteDetailsRequested(this.routeId, this.busStopId, this.eta);
}
