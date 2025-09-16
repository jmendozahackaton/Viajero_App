import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusMovementService {
  final FirebaseFirestore _firestore;
  final List<Timer> _timers = [];

  BusMovementService(this._firestore);

  // Simular movimiento de todos los buses activos
  void startSimulatingBusMovements() {
    // Obtener todos los buses activos y simular movimiento para cada uno
    _firestore
        .collection('buses')
        .where('isActive', isEqualTo: true)
        .get()
        .then((querySnapshot) {
          for (final doc in querySnapshot.docs) {
            _simulateBusMovement(doc.id, doc.data());
          }
        });
  }

  // Simular movimiento para un bus específico
  void _simulateBusMovement(String busId, Map<String, dynamic> busData) {
    // Obtener la ruta del bus
    final routeId = busData['routeId'];
    _firestore.collection('bus_routes').doc(routeId).get().then((routeDoc) {
      if (routeDoc.exists) {
        final routeData = routeDoc.data()!;
        final coordinates = _parseCoordinates(routeData['coordinates']);

        if (coordinates.isNotEmpty) {
          _startMovementAlongRoute(busId, coordinates);
        }
      }
    });
  }

  // Mover el bus a lo largo de la ruta
  void _startMovementAlongRoute(String busId, List<LatLng> routeCoordinates) {
    int currentIndex = 0;
    const movementInterval = Duration(
      seconds: 10,
    ); // Actualizar cada 10 segundos

    final timer = Timer.periodic(movementInterval, (timer) {
      if (currentIndex < routeCoordinates.length - 1) {
        // Mover al siguiente punto
        currentIndex++;

        // Actualizar posición en Firestore
        _updateBusPosition(
          busId,
          routeCoordinates[currentIndex],
          _calculateSpeed(currentIndex, routeCoordinates.length),
        );
      } else {
        // Reiniciar la ruta cuando llega al final
        currentIndex = 0;
      }
    });

    _timers.add(timer);
  }

  // Actualizar posición del bus en Firestore
  Future<void> _updateBusPosition(
    String busId,
    LatLng newPosition,
    int speed,
  ) async {
    await _firestore.collection('buses').doc(busId).update({
      'currentLocation': {
        'latitude': newPosition.latitude,
        'longitude': newPosition.longitude,
      },
      'currentSpeed': speed,
      'lastUpdate': FieldValue.serverTimestamp(),
      'estimatedArrival': _calculateETA(newPosition, busId),
    });
  }

  // Calcular velocidad basada en progreso en la ruta
  int _calculateSpeed(int currentIndex, int totalPoints) {
    final progress = currentIndex / totalPoints;

    // Variar velocidad entre 20-60 km/h basado en progreso
    if (progress < 0.2) return 20 + (progress * 200).toInt(); // Acelerando
    if (progress > 0.8)
      return 60 - ((progress - 0.8) * 200).toInt(); // Desacelerando
    return 40 + (Random().nextInt(20) - 10); // Velocidad crucero con variación
  }

  // Calcular ETA aproximado (simplificado)
  int _calculateETA(LatLng currentPosition, String busId) {
    // Simulación simple - podríamos hacerlo más preciso después
    return 5 + Random().nextInt(15);
  }

  // Parsear coordenadas desde Firestore
  List<LatLng> _parseCoordinates(dynamic coordinates) {
    if (coordinates is List) {
      return coordinates.whereType<Map<String, dynamic>>().map((coord) {
        return LatLng(
          (coord['latitude'] ?? 0.0).toDouble(),
          (coord['longitude'] ?? 0.0).toDouble(),
        );
      }).toList();
    }
    return [];
  }

  // Detener todas las simulaciones
  void stopAllSimulations() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  // Limpiar recursos
  void dispose() {
    stopAllSimulations();
  }
}
