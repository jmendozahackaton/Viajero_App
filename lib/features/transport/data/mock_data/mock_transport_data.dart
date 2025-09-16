import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataService {
  final FirebaseFirestore _firestore;

  MockDataService(this._firestore);

  Future<void> createMockTransportData() async {
    await _createMockRoutes();
    await _createMockBusStops();
    await _createMockBuses();
  }

  Future<void> _createMockRoutes() async {
    final routesRef = _firestore.collection('bus_routes');

    // Ruta 101: Ciudad Sandino - Mercado Oriental
    await routesRef.doc('route_101').set({
      'name': 'Ruta 101',
      'description': 'Ciudad Sandino - Mercado Oriental',
      'origin': 'Ciudad Sandino',
      'destination': 'Mercado Oriental',
      'coordinates': [
        {'latitude': 12.158, 'longitude': -86.348}, // Ciudad Sandino
        {'latitude': 12.143, 'longitude': -86.318},
        {'latitude': 12.136, 'longitude': -86.291},
        {'latitude': 12.126, 'longitude': -86.268}, // UCA
        {'latitude': 12.120, 'longitude': -86.250},
        {'latitude': 12.115, 'longitude': -86.235}, // Mercado Oriental
      ],
      'busStopIds': ['stop_uca', 'stop_metrocentro', 'stop_mercado_oriental'],
      'estimatedTime': 45,
      'distance': 18.5,
      'fare': 10.0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Ruta 118: Villa Libertad - Mercado Israel
    await routesRef.doc('route_118').set({
      'name': 'Ruta 118',
      'description': 'Villa Libertad - Mercado Israel',
      'origin': 'Villa Libertad',
      'destination': 'Mercado Israel',
      'coordinates': [
        {'latitude': 12.165, 'longitude': -86.325}, // Villa Libertad
        {'latitude': 12.152, 'longitude': -86.305},
        {'latitude': 12.142, 'longitude': -86.285},
        {'latitude': 12.135, 'longitude': -86.270}, // Metrocentro
        {'latitude': 12.128, 'longitude': -86.255},
        {'latitude': 12.122, 'longitude': -86.240}, // Mercado Israel
      ],
      'busStopIds': ['stop_metrocentro', 'stop_mercado_israel'],
      'estimatedTime': 35,
      'distance': 15.2,
      'fare': 8.0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // NUEVA RUTA 120: Las Brisas - Carretera Norte
    await routesRef.doc('route_120').set({
      'name': 'Ruta 120',
      'description': 'Las Brisas - Carretera Norte',
      'origin': 'Las Brisas',
      'destination': 'Carretera Norte',
      'coordinates': [
        {'latitude': 12.145, 'longitude': -86.310}, // Las Brisas
        {'latitude': 12.140, 'longitude': -86.295},
        {
          'latitude': 12.136600,
          'longitude': -86.251966,
        }, // Nueva parada específica
        {'latitude': 12.141027, 'longitude': -86.242356},
        {'latitude': 12.151528, 'longitude': -86.238633}, // Carretera Norte
      ],
      'busStopIds': [
        'stop_las_colinas',
        'stop_nueva_parada',
        'stop_centro_historico',
      ],
      'estimatedTime': 30,
      'distance': 12.7,
      'fare': 7.5,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createMockBusStops() async {
    final stopsRef = _firestore.collection('bus_stops');

    // Parada UCA
    await stopsRef.doc('stop_uca').set({
      'name': 'UCA',
      'description': 'Universidad Centroamericana',
      'address': 'Universidad Centroamericana, Managua',
      'location': {'latitude': 12.126, 'longitude': -86.268},
      'routeIds': ['route_101', 'route_118'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Parada Metrocentro
    await stopsRef.doc('stop_metrocentro').set({
      'name': 'Metrocentro',
      'description': 'Centro Comercial Metrocentro',
      'address': 'Metrocentro, Managua',
      'location': {'latitude': 12.135, 'longitude': -86.270},
      'routeIds': ['route_101', 'route_118'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Parada Mercado Oriental
    await stopsRef.doc('stop_mercado_oriental').set({
      'name': 'Mercado Oriental',
      'description': 'Mercado Oriental de Managua',
      'address': 'Mercado Oriental, Managua',
      'location': {'latitude': 12.115, 'longitude': -86.235},
      'routeIds': ['route_101'],
      'hasShelter': false,
      'hasSeating': false,
      'hasLighting': false,
      'isAccessible': false,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Parada Mercado Israel
    await stopsRef.doc('stop_mercado_israel').set({
      'name': 'Mercado Israel',
      'description': 'Mercado Israel Lewites',
      'address': 'Mercado Israel, Managua',
      'location': {'latitude': 12.122, 'longitude': -86.240},
      'routeIds': ['route_118'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // NUEVAS PARADAS PARA LA RUTA 120

    // Parada Las Colinas
    await stopsRef.doc('stop_las_brisas').set({
      'name': 'Las Brisas',
      'description': 'Residencial Las Brisas',
      'address': 'Residencial Las Brisas, Managua',
      'location': {'latitude': 12.145, 'longitude': -86.310},
      'routeIds': ['route_120'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // NUEVA PARADA en la coordenada específica (12.136631, -86.251172)
    await stopsRef.doc('stop_nueva_parada').set({
      'name': 'Parque Central',
      'description': 'Parque Central de Managua',
      'address': 'Cerca del centro de la ciudad, Managua',
      'location': {'latitude': 12.136631, 'longitude': -86.251172},
      'routeIds': ['route_120'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Parada Carretera Norte
    await stopsRef.doc('stop_carretera_norte').set({
      'name': 'Carretera Norte',
      'description': 'Carretera Norte',
      'address': 'Carretera Norte, Managua',
      'location': {'latitude': 12.151528, 'longitude': -86.238633},
      'routeIds': ['route_120'],
      'hasShelter': true,
      'hasSeating': true,
      'hasLighting': true,
      'isAccessible': true,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createMockBuses() async {
    final busesRef = _firestore.collection('buses');

    // Bus en Ruta 101
    await busesRef.doc('bus_101_001').set({
      'routeId': 'route_101',
      'licensePlate': 'M-101-ABC',
      'driverName': 'Carlos Rodríguez',
      'capacity': 50,
      'currentLocation': {'latitude': 12.136, 'longitude': -86.291},
      'lastUpdate': FieldValue.serverTimestamp(),
      'currentSpeed': 40,
      'occupancy': 28,
      'estimatedArrival': 8,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Bus en Ruta 118
    await busesRef.doc('bus_118_001').set({
      'routeId': 'route_118',
      'licensePlate': 'M-118-XYZ',
      'driverName': 'María González',
      'capacity': 45,
      'currentLocation': {'latitude': 12.145, 'longitude': -86.295},
      'lastUpdate': FieldValue.serverTimestamp(),
      'currentSpeed': 35,
      'occupancy': 22,
      'estimatedArrival': 12,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Otro bus en Ruta 101
    await busesRef.doc('bus_101_002').set({
      'routeId': 'route_101',
      'licensePlate': 'M-101-DEF',
      'driverName': 'José Martínez',
      'capacity': 48,
      'currentLocation': {'latitude': 12.120, 'longitude': -86.250},
      'lastUpdate': FieldValue.serverTimestamp(),
      'currentSpeed': 25,
      'occupancy': 35,
      'estimatedArrival': 15,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // NUEVO BUS para la Ruta 120
    await busesRef.doc('bus_120_001').set({
      'routeId': 'route_120',
      'licensePlate': 'M-120-GHI',
      'driverName': 'Ana López',
      'capacity': 42,
      'currentLocation': {'latitude': 12.140, 'longitude': -86.295},
      'lastUpdate': FieldValue.serverTimestamp(),
      'currentSpeed': 38,
      'occupancy': 19,
      'estimatedArrival': 5,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
