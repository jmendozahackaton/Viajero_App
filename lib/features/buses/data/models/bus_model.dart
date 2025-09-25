import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/bus_entity.dart';

class BusModel {
  final String routeId;
  final String licensePlate;
  final String? driverId;
  final int capacity;
  final Map<String, dynamic> currentLocation;
  final Timestamp lastUpdate;
  final int currentSpeed;
  final int occupancy;
  final int estimatedArrival;
  final bool isActive;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  BusModel({
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

  // Convertir de Model a Entity
  BusEntity toEntity(String id) {
    return BusEntity(
      id: id,
      routeId: routeId,
      licensePlate: licensePlate,
      driverId: driverId,
      capacity: capacity,
      currentLocation: LatLng(
        currentLocation['latitude'] ?? 0.0,
        currentLocation['longitude'] ?? 0.0,
      ),
      lastUpdate: lastUpdate.toDate(),
      currentSpeed: currentSpeed,
      occupancy: occupancy,
      estimatedArrival: estimatedArrival,
      isActive: isActive,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  // Convertir de Entity a Model
  factory BusModel.fromEntity(BusEntity entity) {
    return BusModel(
      routeId: entity.routeId,
      licensePlate: entity.licensePlate,
      driverId: entity.driverId,
      capacity: entity.capacity,
      currentLocation: {
        'latitude': entity.currentLocation.latitude,
        'longitude': entity.currentLocation.longitude,
      },
      lastUpdate: Timestamp.fromDate(entity.lastUpdate),
      currentSpeed: entity.currentSpeed,
      occupancy: entity.occupancy,
      estimatedArrival: entity.estimatedArrival,
      isActive: entity.isActive,
      createdAt: Timestamp.fromDate(entity.createdAt),
      updatedAt: entity.updatedAt != null
          ? Timestamp.fromDate(entity.updatedAt!)
          : null,
    );
  }

  // Convertir de Map a Model
  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      routeId: map['routeId'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      driverId: map['driverId'],
      capacity: map['capacity'] ?? 0,
      currentLocation: Map<String, dynamic>.from(map['currentLocation'] ?? {}),
      lastUpdate: map['lastUpdate'] ?? Timestamp.now(),
      currentSpeed: map['currentSpeed'] ?? 0,
      occupancy: map['occupancy'] ?? 0,
      estimatedArrival: map['estimatedArrival'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  // Convertir de Model a Map
  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'licensePlate': licensePlate,
      'driverId': driverId,
      'capacity': capacity,
      'currentLocation': currentLocation,
      'lastUpdate': lastUpdate,
      'currentSpeed': currentSpeed,
      'occupancy': occupancy,
      'estimatedArrival': estimatedArrival,
      'isActive': isActive,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
