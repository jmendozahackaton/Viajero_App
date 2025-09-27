// lib/features/trip_planner/presentation/widgets/route_map_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Viajeros/features/transport/domain/entities/bus_stop_entity.dart';
import 'package:Viajeros/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:Viajeros/features/transport/domain/entities/route_entity.dart';

class RouteMapDialog extends StatelessWidget {
  final RouteOption routeOption;
  final LatLng origin;
  final LatLng destination;

  const RouteMapDialog({
    super.key,
    required this.routeOption,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 500,
        child: Column(
          children: [
            AppBar(
              title: Text('Ruta: ${routeOption.routeName}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _calculateCenter(origin, destination),
                  zoom: 12,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('origin'),
                    position: origin,
                    infoWindow: const InfoWindow(title: 'Origen'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: destination,
                    infoWindow: const InfoWindow(title: 'Destino'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                  ..._createBusStopMarkers(routeOption.busStopSequence),
                },
                polylines: {
                  Polyline(
                    polylineId: PolylineId(routeOption.routeId),
                    points: _getRoutePoints(routeOption),
                    color: Colors.blue,
                    width: 4,
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    Icons.access_time,
                    '${routeOption.estimatedTime} min',
                  ),
                  _buildInfoItem(
                    Icons.directions_walk,
                    '${routeOption.walkingDistance.round()}m',
                  ),
                  _buildInfoItem(
                    Icons.currency_exchange,
                    'C\$${routeOption.fare.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _calculateCenter(LatLng origin, LatLng destination) {
    return LatLng(
      (origin.latitude + destination.latitude) / 2,
      (origin.longitude + destination.longitude) / 2,
    );
  }

  Set<Marker> _createBusStopMarkers(List<BusStopEntity> busStops) {
    return busStops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;

      return Marker(
        markerId: MarkerId('stop_$index'),
        position: stop.location,
        infoWindow: InfoWindow(title: stop.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();
  }

  List<LatLng> _getRoutePoints(RouteOption option) {
    // Aquí necesitarías obtener las coordenadas reales de la ruta
    // Por ahora, creamos una línea recta entre las paradas como ejemplo
    final points = <LatLng>[];

    if (option.busStopSequence.isNotEmpty) {
      points.add(option.busStopSequence.first.location);
      points.add(option.busStopSequence.last.location);
    }

    return points;
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
