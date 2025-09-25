import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusEntity {
  final String id;
  final String routeId;
  final String licensePlate;
  final String? driverId;
  final int capacity;
  final LatLng currentLocation;
  final DateTime lastUpdate;
  final int currentSpeed;
  final int occupancy;
  final int estimatedArrival;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BusEntity({
    required this.id,
    required this.routeId,
    required this.licensePlate,
    this.driverId,
    required this.capacity,
    required this.currentLocation,
    required this.lastUpdate,
    required this.currentSpeed,
    required this.occupancy,
    required this.estimatedArrival,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  BusEntity copyWith({
    String? id,
    String? routeId,
    String? licensePlate,
    String? driverId,
    int? capacity,
    LatLng? currentLocation,
    DateTime? lastUpdate,
    int? currentSpeed,
    int? occupancy,
    int? estimatedArrival,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusEntity(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      licensePlate: licensePlate ?? this.licensePlate,
      driverId: driverId ?? this.driverId,
      capacity: capacity ?? this.capacity,
      currentLocation: currentLocation ?? this.currentLocation,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      occupancy: occupancy ?? this.occupancy,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BusEntity(id: $id, licensePlate: $licensePlate, routeId: $routeId, driverId: $driverId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
