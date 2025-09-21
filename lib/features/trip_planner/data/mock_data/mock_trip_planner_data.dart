// lib/features/trip_planner/data/mock_data/mock_trip_planner_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MockTripPlannerDataService {
  final FirebaseFirestore _firestore;

  MockTripPlannerDataService(this._firestore);

  Future<void> createMockTripPlannerData() async {
    await _createMockTripPreferences();
    await _createMockSavedTrips();
  }

  Future<void> _createMockTripPreferences() async {
    final prefsRef = _firestore.collection('trip_preferences');

    await prefsRef.doc('default_preferences').set({
      'minimizeTransfers': false,
      'minimizeWalking': true,
      'prioritizeAccessibility': true,
      'maxWaitTime': 10,
      'maxWalkingDistance': 500,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createMockSavedTrips() async {
    final tripsRef = _firestore.collection('saved_trips');

    // Viaje de ejemplo 1: UCA a Metrocentro
    await tripsRef.doc('trip_001').set({
      'origin': {'latitude': 12.126, 'longitude': -86.268},
      'destination': {'latitude': 12.135, 'longitude': -86.270},
      'plannedTime': FieldValue.serverTimestamp(),
      'preferences': {
        'minimizeTransfers': true,
        'minimizeWalking': false,
        'prioritizeAccessibility': true,
        'maxWaitTime': 15,
        'maxWalkingDistance': 1000,
      },
      'selectedRouteId': 'route_101',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Viaje de ejemplo 2: Mercado Oriental a Carretera Norte
    await tripsRef.doc('trip_002').set({
      'origin': {'latitude': 12.115, 'longitude': -86.235},
      'destination': {'latitude': 12.151528, 'longitude': -86.238633},
      'plannedTime': FieldValue.serverTimestamp(),
      'preferences': {
        'minimizeTransfers': false,
        'minimizeWalking': true,
        'prioritizeAccessibility': false,
        'maxWaitTime': 10,
        'maxWalkingDistance': 500,
      },
      'selectedRouteId': 'route_120',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
