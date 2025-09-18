// notification_preferences_entity.dart
class NotificationPreferences {
  final bool enabled;
  final int notificationRadius; // metros
  final int minTimeForNotification; // minutos mínimos para notificar
  final List<String> favoriteStops;
  final List<String> favoriteRoutes;

  NotificationPreferences({
    this.enabled = true,
    this.notificationRadius = 500, // 500 metros
    this.minTimeForNotification = 5, // 5 minutos mínimo
    this.favoriteStops = const [],
    this.favoriteRoutes = const [],
  });

  NotificationPreferences copyWith({
    bool? enabled,
    int? notificationRadius,
    int? minTimeForNotification,
    List<String>? favoriteStops,
    List<String>? favoriteRoutes,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      minTimeForNotification:
          minTimeForNotification ?? this.minTimeForNotification,
      favoriteStops: favoriteStops ?? this.favoriteStops,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
    );
  }
}
