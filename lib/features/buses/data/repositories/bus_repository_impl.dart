import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_driver_entity.dart';
import '../../domain/repositories/bus_repository.dart';
import '../models/bus_model.dart';

class BusRepositoryImpl implements BusRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  BusRepositoryImpl(this._firestore, this._userRepository);

  CollectionReference get _busesCollection => _firestore.collection('buses');
  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<List<BusEntity>> getActiveBuses() async {
    try {
      final query = await _busesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) {
        // Cast explícito aquí
        final data = doc.data() as Map<String, dynamic>;
        return BusModel.fromMap(data).toEntity(doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo buses activos: $e');
    }
  }

  @override
  Future<BusEntity> getBusById(String busId) async {
    try {
      final doc = await _busesCollection.doc(busId).get();
      if (!doc.exists) {
        throw Exception('Bus con ID $busId no encontrado');
      }
      // Cast explícito aquí también
      final data = doc.data() as Map<String, dynamic>;
      return BusModel.fromMap(data).toEntity(doc.id);
    } catch (e) {
      throw Exception('Error obteniendo bus: $e');
    }
  }

  @override
  Future<BusEntity> createBus(BusEntity bus) async {
    try {
      final busModel = BusModel.fromEntity(bus);
      final docRef = await _busesCollection.add(busModel.toMap());

      // Retornar el bus con el ID generado por Firestore
      return bus.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error creando bus: $e');
    }
  }

  @override
  Future<BusEntity> updateBus(BusEntity bus) async {
    try {
      final busModel = BusModel.fromEntity(bus);
      await _busesCollection.doc(bus.id).update({
        ...busModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return bus;
    } catch (e) {
      throw Exception('Error actualizando bus: $e');
    }
  }

  @override
  Future<void> deleteBus(String busId) async {
    try {
      // Soft delete - marcar como inactivo en lugar de eliminar
      await _busesCollection.doc(busId).delete();
    } catch (e) {
      throw Exception('Error eliminando bus: $e');
    }
  }

  @override
  Future<List<BusEntity>> getBusesByRoute(String routeId) async {
    try {
      final query = await _busesCollection
          .where('routeId', isEqualTo: routeId)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BusModel.fromMap(data).toEntity(doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo buses por ruta: $e');
    }
  }

  @override
  Future<List<BusEntity>> getBusesByDriver(String driverId) async {
    try {
      final query = await _busesCollection
          .where('driverId', isEqualTo: driverId)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BusModel.fromMap(data).toEntity(doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo buses por conductor: $e');
    }
  }

  @override
  Future<List<BusEntity>> findBusesNearLocation(
    LatLng location,
    double radiusKm,
  ) async {
    // Implementación simplificada - en producción usaría geoqueries
    try {
      final allBuses = await getActiveBuses();

      return allBuses.where((bus) {
        final distance = _calculateDistance(
          location.latitude,
          location.longitude,
          bus.currentLocation.latitude,
          bus.currentLocation.longitude,
        );
        return distance <= radiusKm * 1000; // Convertir km a metros
      }).toList();
    } catch (e) {
      throw Exception('Error buscando buses cercanos: $e');
    }
  }

  @override
  Future<List<BusEntity>> searchBuses(String query) async {
    try {
      final allBuses = await getActiveBuses();

      return allBuses.where((bus) {
        final searchTerm = query.toLowerCase();
        return bus.licensePlate.toLowerCase().contains(searchTerm) ||
            bus.id.toLowerCase().contains(searchTerm);
      }).toList();
    } catch (e) {
      throw Exception('Error buscando buses: $e');
    }
  }

  @override
  Future<void> assignDriverToBus(String busId, String driverId) async {
    try {
      await _busesCollection.doc(busId).update({
        'driverId': driverId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error asignando conductor: $e');
    }
  }

  @override
  Future<void> unassignDriverFromBus(String busId) async {
    try {
      await _busesCollection.doc(busId).update({
        'driverId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error desasignando conductor: $e');
    }
  }

  @override
  Future<List<BusDriverEntity>> getAvailableDrivers() async {
    try {
      final query = await _usersCollection
          .where('userType', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        if (data is! Map<String, dynamic>) {
          throw FormatException(
            'Formato de datos inválido para el conductor ${doc.id}',
          );
        }

        return BusDriverEntity(
          userId: doc.id,
          fullName: data['displayName']?.toString() ?? 'Sin nombre',
          email: data['email']?.toString() ?? '',
          phoneNumber: data['phoneNumber']?.toString(),
          licenseNumber: data['licenseNumber']?.toString(),
          licenseExpiry: data['licenseExpiry'] != null
              ? (data['licenseExpiry'] as Timestamp).toDate()
              : null,
          assignedRoutes: List<String>.from(data['assignedRoutes'] ?? []),
          isActive: data['isActive'] ?? true,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo conductores disponibles: $e');
    }
  }

  @override
  Future<BusDriverEntity?> getBusDriver(String busId) async {
    try {
      final bus = await getBusById(busId);
      if (bus.driverId == null) return null;

      final userDoc = await _usersCollection.doc(bus.driverId!).get();
      if (!userDoc.exists) return null;

      // Cast explícito aquí
      final data = userDoc.data() as Map<String, dynamic>;

      return BusDriverEntity(
        userId: userDoc.id,
        fullName: data['displayName'] ?? 'Sin nombre',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'],
        licenseNumber: data['licenseNumber'],
        licenseExpiry: data['licenseExpiry'] != null
            ? (data['licenseExpiry'] as Timestamp).toDate()
            : null,
        assignedRoutes: List<String>.from(data['assignedRoutes'] ?? []),
        isActive: data['isActive'] ?? true,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw Exception('Error obteniendo conductor del bus: $e');
    }
  }

  @override
  Stream<List<BusEntity>> streamActiveBuses() {
    return _busesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              final data = doc.data() as Map<String, dynamic>;
              return BusModel.fromMap(data).toEntity(doc.id);
            }),
          );
        });
  }

  @override
  Stream<BusEntity> streamBusLocation(String busId) {
    return _busesCollection.doc(busId).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        throw Exception('Bus no encontrado');
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return BusModel.fromMap(data).toEntity(snapshot.id);
    });
  }

  @override
  Stream<List<BusEntity>> streamBusesByRoute(String routeId) {
    return _busesCollection
        .where('routeId', isEqualTo: routeId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              final data = doc.data() as Map<String, dynamic>;
              return BusModel.fromMap(data).toEntity(doc.id);
            }),
          );
        });
  }

  @override
  Future<bool> isLicensePlateUnique(
    String licensePlate, {
    String? excludeBusId,
  }) async {
    try {
      Query query = _busesCollection.where(
        'licensePlate',
        isEqualTo: licensePlate,
      );

      if (excludeBusId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeBusId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Error verificando placa única: $e');
    }
  }

  @override
  Future<int> getActiveBusesCount() async {
    final query = await _busesCollection
        .where('isActive', isEqualTo: true)
        .get();
    return query.docs.length;
  }

  @override
  Future<Map<String, int>> getBusesCountByRoute() async {
    final buses = await getActiveBuses();
    final result = <String, int>{};

    for (final bus in buses) {
      result.update(bus.routeId, (value) => value + 1, ifAbsent: () => 1);
    }

    return result;
  }

  // Método auxiliar para calcular distancia
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371e3; // Radio de la Tierra en metros
    double pi = 3.1416; // Valor PI
    final A1 = lat1 * pi / 180;
    final A2 = lat2 * pi / 180;
    final AA = (lat2 - lat1) * pi / 180;
    final BA = (lon2 - lon1) * pi / 180;

    final a =
        sin(AA / 2) * sin(AA / 2) +
        cos(A1) * cos(A2) * sin(BA / 2) * sin(BA / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}
