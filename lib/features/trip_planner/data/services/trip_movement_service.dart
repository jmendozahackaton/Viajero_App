// lib/features/trip_planner/data/services/trip_movement_service.dart
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class TripMovementSimulationService {
  final FirebaseFirestore _firestore;
  final List<Timer> _timers = [];

  TripMovementSimulationService(this._firestore);

  void startSimulatingTripMovements() {
    // Simular actualizaciones de ETA en tiempo real
    _timers.add(
      Timer.periodic(Duration(seconds: 15), (timer) {
        _updateAllTripETAs();
      }),
    );

    // Simular notificaciones de viaje
    _timers.add(
      Timer.periodic(Duration(seconds: 30), (timer) {
        _sendTripNotifications();
      }),
    );
  }

  Future<void> _updateAllTripETAs() async {
    final tripsSnapshot = await _firestore
        .collection('saved_trips')
        .where('isActive', isEqualTo: true)
        .get();

    for (final tripDoc in tripsSnapshot.docs) {
      final tripData = tripDoc.data();
      final routeId = tripData['selectedRouteId'];

      if (routeId != null) {
        final updatedETA = _calculateDynamicETA(routeId);

        await _firestore.collection('saved_trips').doc(tripDoc.id).update({
          'estimatedArrival': updatedETA,
          'lastUpdate': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  int _calculateDynamicETA(String routeId) {
    // Simulación de ETA dinámico basado en hora del día y tráfico
    final now = DateTime.now();
    final hour = now.hour;

    // Hora pico: 7-9 AM y 5-7 PM
    final isRushHour = (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19);
    final baseETA = 15; // minutos base

    return isRushHour
        ? baseETA + Random().nextInt(15)
        : baseETA + Random().nextInt(5);
  }

  Future<void> _sendTripNotifications() async {
    final tripsSnapshot = await _firestore
        .collection('saved_trips')
        .where('isActive', isEqualTo: true)
        .get();

    for (final tripDoc in tripsSnapshot.docs) {
      final tripData = tripDoc.data();
      final eta = tripData['estimatedArrival'] ?? 20;

      if (eta <= 5) {
        // Notificar cuando el bus está a 5 minutos o menos
        _sendProximityNotification(tripDoc.id, tripData, eta);
      }
    }
  }

  Future<void> _sendProximityNotification(
    String tripId,
    Map<String, dynamic> tripData,
    int eta,
  ) async {
    // Implementar lógica de notificación
    print('🚌 Notificación: Tu bus llegará en $eta minutos');
  }

  void stopAllSimulations() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}
