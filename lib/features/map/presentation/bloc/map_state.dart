part of 'map_bloc.dart';

sealed class MapState {}

final class MapInitial extends MapState {}

final class MapLoadedState extends MapState {
  final LatLng initialPosition;
  final LatLng? currentLocation;

  MapLoadedState({required this.initialPosition, this.currentLocation});
}

final class MapError extends MapState {
  final String message;

  MapError(this.message);
}
