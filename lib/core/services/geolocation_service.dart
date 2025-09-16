import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeolocationService {
  // Verificar y solicitar permisos
  static Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  // Stream de actualizaciones de ubicación - CORREGIDO
  static Stream<Position> getLocationStream() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Calcular distancia entre dos puntos
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Calcular ETA basado en distancia y velocidad promedio
  static double calculateETA(double distanceMeters, double averageSpeedKmh) {
    if (averageSpeedKmh <= 0) return 0;

    double speedMetersPerSecond = (averageSpeedKmh * 1000) / 3600;
    return distanceMeters / speedMetersPerSecond / 60; // Devuelve minutos
  }

  // Verificar si los servicios de ubicación están disponibles
  static Future<bool> isLocationServiceAvailable() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      bool hasPermission = await _checkPermissions();
      return serviceEnabled && hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Obtener la última ubicación conocida
  static Future<Position?> getLastKnownLocation() async {
    try {
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error obteniendo última ubicación conocida: $e');
      return null;
    }
  }
}
