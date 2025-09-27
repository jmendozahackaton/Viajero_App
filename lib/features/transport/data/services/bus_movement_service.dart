import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Viajeros/core/services/notifications_service.dart';

class BusMovementService {
  final FirebaseFirestore _firestore;
  final List<Timer> _timers = [];
  final NotificationService _notificationService;
  final Set<String> _notifiedBuses =
      {}; // Para evitar notificaciones duplicadas

  BusMovementService(this._firestore)
    : _notificationService = NotificationService();

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

    // ✅ NUEVO: Verificar proximidad a paradas y notificar
    _checkProximityToStops(busId, newPosition);
  }

  // ✅ NUEVO: Verificar si el bus está cerca de alguna parada
  Future<void> _checkProximityToStops(String busId, LatLng busPosition) async {
    try {
      // Obtener todas las paradas activas
      final stopsSnapshot = await _firestore
          .collection('bus_stops')
          .where('isActive', isEqualTo: true)
          .get();

      for (final stopDoc in stopsSnapshot.docs) {
        final stopData = stopDoc.data();
        final stopLocation = _parseLatLng(stopData['location']);

        // Calcular distancia entre bus y parada
        final distance = Geolocator.distanceBetween(
          busPosition.latitude,
          busPosition.longitude,
          stopLocation.latitude,
          stopLocation.longitude,
        );

        // Si está dentro de 500 metros y no hemos notificado recientemente
        if (distance <= 500 &&
            !_notifiedBuses.contains('$busId-${stopDoc.id}')) {
          await _sendProximityNotification(
            busId,
            stopDoc.id,
            stopData,
            distance,
          );
          _notifiedBuses.add('$busId-${stopDoc.id}');
        }
      }

      // Limpiar buses notificados periódicamente para evitar memory leak
      if (_notifiedBuses.length > 100) {
        _notifiedBuses.clear();
      }
    } catch (e) {
      print('Error checking proximity: $e');
    }
  }

  // ✅ NUEVO: Enviar notificación de proximidad
  Future<void> _sendProximityNotification(
    String busId,
    String stopId,
    Map<String, dynamic> stopData,
    double distance,
  ) async {
    try {
      // Obtener información del bus
      final busDoc = await _firestore.collection('buses').doc(busId).get();
      final busData = busDoc.data()!;

      // Obtener información de la ruta
      final routeDoc = await _firestore
          .collection('bus_routes')
          .doc(busData['routeId'])
          .get();
      final routeData = routeDoc.data()!;

      // Calcular ETA aproximado (metros → minutos a 30 km/h)
      final etaMinutes = ((distance / 1000) / 30 * 60).round();

      // Enviar notificación
      await _notificationService.showBusProximityNotification(
        busName: busData['licensePlate'] ?? 'Bus $busId',
        routeName: routeData['name'] ?? 'Ruta Desconocida',
        minutesAway: etaMinutes.clamp(1, 30), // Mínimo 1 min, máximo 30 min
        stopName: stopData['name'] ?? 'Parada Desconocida',
      );

      print(
        '🚌 Notificación enviada: Bus ${busData['licensePlate']} cerca de ${stopData['name']}',
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // ✅ NUEVO: Parsear LatLng desde Firestore
  LatLng _parseLatLng(dynamic location) {
    if (location is Map<String, dynamic>) {
      return LatLng(
        (location['latitude'] ?? 0.0).toDouble(),
        (location['longitude'] ?? 0.0).toDouble(),
      );
    }
    return const LatLng(0, 0);
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
