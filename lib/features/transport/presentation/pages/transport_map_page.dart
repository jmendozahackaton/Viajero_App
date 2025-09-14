import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import '../bloc/transport_bloc.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_stop_entity.dart';

class TransportMapPage extends StatefulWidget {
  const TransportMapPage({super.key});

  @override
  State<TransportMapPage> createState() => _TransportMapPageState();
}

class _TransportMapPageState extends State<TransportMapPage> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(
    12.136389,
    -86.251389,
  ); // Managua
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  BitmapDescriptor? _busIcon;
  BitmapDescriptor? _busStopIcon;
  BitmapDescriptor? _selectedBusIcon;
  BitmapDescriptor? _selectedBusStopIcon;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    try {
      // Íconos para buses - tamaño ajustado
      _busIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), // ← Tamaño reducido
        'assets/icons/bus.png',
      );

      _selectedBusIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), // ← Tamaño reducido
        'assets/icons/bus_selected.png',
      );

      // Íconos para paradas - tamaño ajustado
      _busStopIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), // ← Tamaño reducido
        'assets/icons/bus_stop.png',
      );

      _selectedBusStopIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), // ← Tamaño reducido
        'assets/icons/bus_stop_selected.png',
      );
    } catch (e) {
      print('Error cargando íconos personalizados: $e');
      _busIcon = null;
      _selectedBusIcon = null;
      _busStopIcon = null;
      _selectedBusStopIcon = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Transporte Público'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<TransportBloc>().add(
                TransportUserLocationRequested(),
              );
            },
            tooltip: 'Mi ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransportBloc>().add(TransportRoutesRequested());
              context.read<TransportBloc>().add(TransportBusesRequested());
              context.read<TransportBloc>().add(TransportBusStopsRequested());
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => TransportBloc(
          transportRepository: context
              .read<TransportRepository>(), // ← Tipo especificado
        )..add(TransportMapLoaded(_initialPosition)),
        child: BlocConsumer<TransportBloc, TransportState>(
          listener: (context, state) {
            if (state is TransportMapLoadedState) {
              _updateMapData(state);
            }
          },
          builder: (context, state) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              markers: _markers,
            );
          },
        ),
      ),
    );
  }

  void _updateMapData(TransportMapLoadedState state) {
    _updatePolylines(state.routes, state.selectedRouteId);
    _updateMarkers(
      state.buses,
      state.busStops,
      state.selectedBusId,
      state.selectedBusStopId,
    );

    if (state.currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(state.currentLocation!),
      );
    }
  }

  void _updatePolylines(List<RouteEntity> routes, String? selectedRouteId) {
    _polylines.clear();

    for (final route in routes) {
      final isSelected = route.id == selectedRouteId;

      _polylines.add(
        Polyline(
          polylineId: PolylineId(route.id),
          points: route.coordinates,
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 5 : 3,
          geodesic: true,
          onTap: () => _onRouteTapped(route),
        ),
      );
    }
  }

  void _updateMarkers(
    List<BusEntity> buses,
    List<BusStopEntity> busStops,
    String? selectedBusId,
    String? selectedBusStopId,
  ) {
    _markers.clear();

    // Marcador de posición inicial (Managua)
    _markers.add(
      Marker(
        markerId: const MarkerId('managua'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'Managua'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Marcadores de paradas de buses
    for (final stop in busStops) {
      final isSelected = stop.id == selectedBusStopId;

      _markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: stop.location,
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Tap para más información',
          ),
          icon: _getBusStopIcon(isSelected),
          onTap: () => _onBusStopTapped(stop),
        ),
      );
    }

    // Marcadores de buses
    for (final bus in buses) {
      final isSelected = bus.id == selectedBusId;

      _markers.add(
        Marker(
          markerId: MarkerId('bus_${bus.id}'),
          position: bus.currentLocation,
          infoWindow: InfoWindow(
            title: 'Bus ${bus.licensePlate}',
            snippet: 'Tap para ver detalles',
          ),
          icon: _getBusIcon(isSelected),
          onTap: () => _onBusTapped(bus),
        ),
      );
    }
  }

  BitmapDescriptor _getBusIcon(bool isSelected) {
    if (isSelected && _selectedBusIcon != null) return _selectedBusIcon!;
    if (_busIcon != null) return _busIcon!;

    // Fallback a markers de Google con colores temáticos
    return BitmapDescriptor.defaultMarkerWithHue(
      isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
    );
  }

  BitmapDescriptor _getBusStopIcon(bool isSelected) {
    if (isSelected && _selectedBusStopIcon != null)
      return _selectedBusStopIcon!;
    if (_busStopIcon != null) return _busStopIcon!;

    // Fallback a markers de Google con colores temáticos
    return BitmapDescriptor.defaultMarkerWithHue(
      isSelected ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueViolet,
    );
  }

  void _onBusTapped(BusEntity bus) {
    final bloc = context.read<TransportBloc>();
    bloc.add(TransportBusSelected(bus.id));

    // Mostrar modal con info del bus
    _showBusInfoModal(bus);
  }

  void _onBusStopTapped(BusStopEntity busStop) {
    final bloc = context.read<TransportBloc>();
    bloc.add(TransportBusStopSelected(busStop.id));

    // Mostrar modal con info de la parada
    _showBusStopInfoModal(busStop);
  }

  void _onRouteTapped(RouteEntity route) {
    final bloc = context.read<TransportBloc>();
    bloc.add(TransportRouteSelected(route.id));

    // Mostrar modal con info de la ruta
    _showRouteInfoModal(route);
  }

  void _showBusInfoModal(BusEntity bus) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bus ${bus.licensePlate}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Conductor:', bus.driverName),
              _buildInfoRow('Ruta:', bus.routeId),
              _buildInfoRow(
                'Capacidad:',
                '${bus.occupancy}/${bus.capacity} pasajeros',
              ),
              _buildInfoRow('Velocidad:', '${bus.currentSpeed} km/h'),
              _buildInfoRow('Llegada estimada:', '${bus.estimatedArrival} min'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar seguimiento de bus
                  Navigator.pop(context);
                },
                child: const Text('Seguir este bus'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBusStopInfoModal(BusStopEntity busStop) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busStop.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                busStop.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Dirección:', busStop.address),
              _buildInfoRow(
                'Rutas que pasan:',
                '${busStop.routeIds.length} rutas',
              ),
              _buildInfoRow('Techo:', busStop.hasShelter ? 'Sí' : 'No'),
              _buildInfoRow('Asientos:', busStop.hasSeating ? 'Sí' : 'No'),
              _buildInfoRow('Iluminación:', busStop.hasLighting ? 'Sí' : 'No'),
              _buildInfoRow('Accesible:', busStop.isAccessible ? 'Sí' : 'No'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar ver rutas de esta parada
                  Navigator.pop(context);
                },
                child: const Text('Ver rutas disponibles'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRouteInfoModal(RouteEntity route) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ruta ${route.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                route.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Origen:', route.origin),
              _buildInfoRow('Destino:', route.destination),
              _buildInfoRow('Distancia:', '${route.distance} km'),
              _buildInfoRow('Tiempo estimado:', '${route.estimatedTime} min'),
              _buildInfoRow('Tarifa:', 'C\$${route.fare}'),
              _buildInfoRow('Paradas:', '${route.busStopIds.length} paradas'),
              _buildInfoRow('Estado:', route.isActive ? 'Activa' : 'Inactiva'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar ver paradas de esta ruta
                        Navigator.pop(context);
                      },
                      child: const Text('Ver paradas'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar ver buses en esta ruta
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Ver buses',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
