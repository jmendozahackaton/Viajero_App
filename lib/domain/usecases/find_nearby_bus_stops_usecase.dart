import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Viajeros/features/transport/domain/entities/bus_stop_entity.dart';
import 'package:Viajeros/features/transport/domain/repositories/transport_repository.dart';

class FindNearbyBusStopsUseCase {
  final TransportRepository transportRepository;

  FindNearbyBusStopsUseCase({required this.transportRepository});

  Future<List<BusStopEntity>> execute(LatLng userLocation, double radiusKm) {
    return transportRepository.findNearbyBusStops(userLocation, radiusKm);
  }
}
