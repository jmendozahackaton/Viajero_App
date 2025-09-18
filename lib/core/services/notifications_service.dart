// notifications_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showBusProximityNotification({
    required String busName,
    required String routeName,
    required int minutesAway,
    required String stopName,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'bus_proximity_channel',
          'Notificaciones de Buses',
          channelDescription:
              'Notificaciones cuando buses están próximos a tu parada',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🚌 Bus Cercano: $busName',
      'Llegará a "$stopName" en $minutesAway min (Ruta $routeName)',
      platformChannelSpecifics,
    );
  }

  Future<void> showMultipleBusesNotification(int count, String stopName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'multiple_buses_channel',
          'Múltiples Buses Próximos',
          channelDescription:
              'Notificaciones cuando múltiples buses están próximos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🚌 $count buses próximos',
      'Varios buses se acercan a "$stopName"',
      platformChannelSpecifics,
    );
  }
}
