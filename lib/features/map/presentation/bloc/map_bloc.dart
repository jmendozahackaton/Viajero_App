import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<MapLoaded>(_onMapLoaded);
    on<MapLocationUpdated>(_onMapLocationUpdated);
  }

  void _onMapLoaded(MapLoaded event, Emitter<MapState> emit) {
    emit(MapLoadedState(initialPosition: event.initialPosition));
  }

  void _onMapLocationUpdated(MapLocationUpdated event, Emitter<MapState> emit) {
    if (state is MapLoadedState) {
      emit(
        MapLoadedState(
          initialPosition: (state as MapLoadedState).initialPosition,
          currentLocation: event.location,
        ),
      );
    }
  }
}
