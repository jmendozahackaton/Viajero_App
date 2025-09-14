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
