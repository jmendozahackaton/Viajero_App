import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusEntity {
  final String id;
  final String routeId; // ID de la ruta asignada
  final String licensePlate; // Placa del bus (ej: "T-123-ABC")
  final String driverName; // Nombre del conductor
  final int capacity; // Capacidad total de pasajeros
  final LatLng currentLocation; // Ubicación actual GPS
  final DateTime lastUpdate; // Última actualización de ubicación
  final int currentSpeed; // Velocidad actual (km/h)
  final int occupancy; // Pasajeros actuales a bordo
  final int estimatedArrival; // Minutos hasta próxima parada
  final bool isActive; // En servicio o no

  BusEntity({
    required this.id,
    required this.routeId,
    required this.licensePlate,
    required this.driverName,
    required this.capacity,
    required this.currentLocation,
    required this.lastUpdate,
    this.currentSpeed = 0,
    this.occupancy = 0,
    this.estimatedArrival = 0,
    this.isActive = true,
  });

  // Método para verificar si el bus está en movimiento
  bool get isMoving => currentSpeed > 5;

  // Método para verificar capacidad disponible
  int get availableSeats => capacity - occupancy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusEntity{id: $id, licensePlate: $licensePlate, routeId: $routeId}';
  }
}
