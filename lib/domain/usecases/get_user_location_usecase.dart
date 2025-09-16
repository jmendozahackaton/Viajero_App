import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';

class GetUserLocationUseCase {
  final TransportRepository transportRepository;

  GetUserLocationUseCase({required this.transportRepository});

  Future<LatLng> execute() {
    return transportRepository.getCurrentUserLocation();
  }
}
