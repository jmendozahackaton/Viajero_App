part of 'map_bloc.dart';

sealed class MapEvent {}

final class MapLoaded extends MapEvent {
  final LatLng initialPosition;

  MapLoaded(this.initialPosition);
}

final class MapLocationUpdated extends MapEvent {
  final LatLng location;

  MapLocationUpdated(this.location);
}
