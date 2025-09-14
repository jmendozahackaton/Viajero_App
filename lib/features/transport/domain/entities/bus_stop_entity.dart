import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopEntity {
  final String id;
  final String name; // Ej: "Parada UCA", "Metrocentro", "Mercado Oriental"
  final LatLng location; // Coordenadas GPS exactas
  final String description; // Descripción o referencia
  final String address; // Dirección física
  final List<String> routeIds; // Rutas que pasan por esta parada
  final bool hasShelter; // Tiene techo/sombra
  final bool hasSeating; // Tiene asientos
  final bool hasLighting; // Tiene iluminación
  final bool isAccessible; // Accesible para discapacitados
  final bool isActive; // Parada activa

  BusStopEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.address,
    required this.routeIds,
    this.hasShelter = false,
    this.hasSeating = false,
    this.hasLighting = false,
    this.isAccessible = false,
    this.isActive = true,
  });

  // Método para verificar si una ruta específica pasa por esta parada
  bool servesRoute(String routeId) => routeIds.contains(routeId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusStopEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusStopEntity{id: $id, name: $name, address: $address}';
  }
}
