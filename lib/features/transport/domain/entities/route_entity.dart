import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteEntity {
  final String id;
  final String name; // Ej: "Ruta 101", "Ruta 118"
  final String description; // Ej: "Ciudad Sandino - Mercado Oriental"
  final String origin; // Punto de origen
  final String destination; // Punto de destino
  final List<LatLng> coordinates; // Coordenadas del trazado de la ruta
  final List<String> busStopIds; // IDs de paradas en esta ruta
  final double estimatedTime; // Tiempo estimado del recorrido (minutos)
  final double distance; // Distancia total (km)
  final double fare; // Tarifa (córdobas)
  final bool isActive; // Ruta activa/inactiva

  RouteEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.origin,
    required this.destination,
    required this.coordinates,
    required this.busStopIds,
    required this.estimatedTime,
    required this.distance,
    required this.fare,
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RouteEntity{id: $id, name: $name, origin: $origin, destination: $destination}';
  }
}
