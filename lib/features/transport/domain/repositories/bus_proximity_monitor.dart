// bus_proximity_monitor.dart
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/core/services/notifications_service.dart';
import 'package:hackaton_app/domain/entities/notification_preferences_entity.dart';
import 'package:hackaton_app/features/transport/domain/entities/bus_entity.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';

class BusProximityMonitor {
  final TransportRepository transportRepository;
  final NotificationService notificationService;
  final List<String> _notifiedBuses = [];

  BusProximityMonitor({
    required this.transportRepository,
    required this.notificationService,
  });

  Future<void> checkProximityToUser({
    required LatLng userLocation,
    required NotificationPreferences prefs,
    required String currentStopName,
  }) async {
    if (!prefs.enabled) return;

    try {
      final activeBuses = await transportRepository.getActiveBuses();
      final nearbyBuses = <BusEntity>[];

      for (final bus in activeBuses) {
        // Verificar si ya notificamos este bus recientemente
        if (_notifiedBuses.contains(bus.id)) continue;

        final distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          bus.currentLocation.latitude,
          bus.currentLocation.longitude,
        );

        // Si está dentro del radio de notificación
        if (distance <= prefs.notificationRadius) {
          nearbyBuses.add(bus);
          _notifiedBuses.add(bus.id);
        }
      }

      // Limitar lista de buses notificados para evitar memory leak
      if (_notifiedBuses.length > 100) {
        _notifiedBuses.removeRange(0, 20);
      }

      // Enviar notificaciones
      await _sendNotifications(nearbyBuses, prefs, currentStopName);
    } catch (e) {
      print('Error en monitor de proximidad: $e');
    }
  }

  Future<void> _sendNotifications(
    List<BusEntity> buses,
    NotificationPreferences prefs,
    String stopName,
  ) async {
    if (buses.isEmpty) return;

    // Si hay múltiples buses, notificación resumida
    if (buses.length > 1) {
      await notificationService.showMultipleBusesNotification(
        buses.length,
        stopName,
      );
      return;
    }

    // Notificación individual para cada bus
    for (final bus in buses) {
      try {
        final route = await transportRepository.getBusRouteById(bus.routeId);
        final eta = await transportRepository.calculateBusETA(
          bus.id,
          bus.routeId,
        );

        if (eta != null && eta.inMinutes >= prefs.minTimeForNotification) {
          await notificationService.showBusProximityNotification(
            busName: bus.licensePlate,
            routeName: route.name,
            minutesAway: eta.inMinutes,
            stopName: stopName,
          );
        }
      } catch (e) {
        print('Error notificando bus ${bus.id}: $e');
      }
    }
  }

  void clearNotifications() {
    _notifiedBuses.clear();
  }
}
