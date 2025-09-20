import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/core/services/notifications_service.dart';
import 'package:hackaton_app/domain/entities/notification_preferences_entity.dart';
import 'package:hackaton_app/features/transport/data/mock_data/mock_transport_data.dart';
import 'package:hackaton_app/features/transport/data/services/bus_movement_service.dart';
import 'package:hackaton_app/features/transport/domain/repositories/bus_proximity_monitor.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import 'package:hackaton_app/features/transport/presentation/widgets/slider_list_tile.dart';
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
  final Map<String, Marker> _animatedMarkers = {};
  final Map<String, LatLng> _busTargetPositions = {};
  LatLng? _userLocation;
  bool _isLocating = false;
  late BusProximityMonitor _proximityMonitor;
  late NotificationPreferences _notificationPrefs;
  Timer? _proximityTimer;
  bool _isSimulationStarted = false;

  BitmapDescriptor? _busIcon;
  BitmapDescriptor? _busStopIcon;
  BitmapDescriptor? _selectedBusIcon;
  BitmapDescriptor? _selectedBusStopIcon;
  BitmapDescriptor? _userLocationIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    _requestLocationPermissions();
    _initializeNotifications();
    _initializeDevelopmentData();
  }

  Future<void> _initializeDevelopmentData() async {
    const bool isDevelopment = true; // Puedes hacer esto configurable

    if (isDevelopment && !_isSimulationStarted) {
      try {
        final firestore = FirebaseFirestore.instance;

        // Crear datos de prueba
        final mockData = MockDataService(firestore);
        await mockData.createMockTransportData();
        print('✅ Datos de prueba creados exitosamente');

        // Iniciar simulación de movimiento
        final movementService = BusMovementService(firestore);
        movementService.startSimulatingBusMovements();
        print('✅ Simulación de movimiento iniciada');

        _isSimulationStarted = true; // Marcar como iniciado
      } catch (e) {
        print('⚠️ Error en configuración de desarrollo: $e');
      }
    }
  }

  Future<void> _initializeNotifications() async {
    _notificationPrefs = NotificationPreferences(); // Valores por defecto
    _proximityMonitor = BusProximityMonitor(
      transportRepository: context.read<TransportRepository>(),
      notificationService: NotificationService(),
    );

    await NotificationService().initialize();
    _startProximityMonitoring();
  }

  void _startProximityMonitoring() {
    // Verificar cada 30 segundos
    _proximityTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_userLocation != null) {
        await _proximityMonitor.checkProximityToUser(
          userLocation: _userLocation!,
          prefs: _notificationPrefs,
          currentStopName: 'Parada Actual', // Puedes obtener esto del contexto
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _proximityTimer?.cancel();
    super.dispose();
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

      // Ícono para ubicación del usuario
      _userLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/icons/user_location.png', // Puedes crear este asset
      );
    } catch (e) {
      print('Error cargando íconos personalizados: $e');
      _busIcon = null;
      _selectedBusIcon = null;
      _busStopIcon = null;
      _selectedBusStopIcon = null;
    }
  }

  Future<void> _requestLocationPermissions() async {
    // Esperar a que el mapa se cargue
    await Future.delayed(const Duration(seconds: 2));

    final bloc = context.read<TransportBloc>();
    bloc.add(TransportLocationPermissionRequested());
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLocating = true);

    try {
      final transportRepository = context.read<TransportRepository>();
      final location = await transportRepository.getCurrentUserLocation();

      setState(() {
        _userLocation = location;
        _isLocating = false;
      });

      // Mover cámara a la ubicación del usuario
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
    } catch (e) {
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error obteniendo ubicación: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Transporte Público'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home), // ← Botón de retroceso
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
          tooltip: 'Regresar al inicio',
        ),
        actions: [
          // Mantener solo el botón de actualización en AppBar
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _showNotificationSettings,
            tooltip: 'Configurar notificaciones',
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransportBloc>().add(TransportRoutesRequested());
              context.read<TransportBloc>().add(TransportBusesRequested());
              context.read<TransportBloc>().add(TransportBusStopsRequested());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Datos actualizados'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => TransportBloc(
          transportRepository: context.read<TransportRepository>(),
        )..add(TransportMapLoaded(_initialPosition)),
        child: BlocConsumer<TransportBloc, TransportState>(
          listener: (context, state) {
            if (state is TransportMapLoadedState) {
              _updateMapData(state);

              // MOVER LA LÓGICA DE DIÁLOGO AQUÍ DENTRO
              if (state.showRouteDetailsDialog &&
                  state.dialogRoute != null &&
                  state.dialogBusStop != null &&
                  state.dialogETA != null &&
                  state.dialogDistance != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showRouteDetailsDialog(
                    state.dialogRoute!,
                    state.dialogBusStop!,
                    state.dialogETA!,
                    state.dialogDistance!,
                  );

                  final bloc = context.read<TransportBloc>();
                  bloc.add(TransportResetDialogState());
                });
              }
            }

            // Manejar errores
            if (state is TransportMapLoadedState &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
              myLocationButtonEnabled:
                  false, // Desactivar el botón nativo de Google Maps
              polylines: _polylines,
              markers: _markers,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para paradas cercanas (nueva funcionalidad)
          FloatingActionButton(
            onPressed: _findNearbyStops,
            child: const Icon(Icons.near_me),
            tooltip: 'Paradas cercanas',
            backgroundColor: Colors.green, // Color distintivo
          ),
          const SizedBox(height: 16),
          // Botón para mi ubicación (única ubicación ahora)
          FloatingActionButton(
            onPressed: _getUserLocation,
            child: _isLocating
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Mi ubicación',
            backgroundColor: Colors.blue, // Color coherente con la app
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text('Notificaciones de buses'),
                    value: _notificationPrefs.enabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationPrefs = _notificationPrefs.copyWith(
                          enabled: value,
                        );
                      });
                    },
                  ),
                  SliderListTile(
                    title: 'Radio de notificación',
                    value: _notificationPrefs.notificationRadius.toDouble(),
                    min: 100,
                    max: 1000,
                    divisions: 9,
                    label: '${_notificationPrefs.notificationRadius}m',
                    onChanged: (value) {
                      setState(() {
                        _notificationPrefs = _notificationPrefs.copyWith(
                          notificationRadius: value.round(),
                        );
                      });
                    },
                  ),
                  SliderListTile(
                    title: 'Tiempo mínimo para notificar',
                    value: _notificationPrefs.minTimeForNotification.toDouble(),
                    min: 1,
                    max: 15,
                    divisions: 14,
                    label: '${_notificationPrefs.minTimeForNotification}min',
                    onChanged: (value) {
                      setState(() {
                        _notificationPrefs = _notificationPrefs.copyWith(
                          minTimeForNotification: value.round(),
                        );
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Guardar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _findNearbyStops() async {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero obtén tu ubicación')),
      );
      return;
    }

    setState(() => _isLocating = true);

    try {
      final transportRepository = context.read<TransportRepository>();
      final nearbyStops = await transportRepository.findNearbyBusStops(
        _userLocation!,
        1.0,
      ); // 1km radio

      _showNearbyStopsModal(nearbyStops);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error buscando paradas: $e')));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _updateMapData(TransportMapLoadedState state) {
    _updatePolylines(state.routes, state.selectedRouteId);
    _updateMarkers(
      state.buses,
      state.busStops,
      state.selectedBusId,
      state.selectedBusStopId,
    );
    _updateUserMarker();
  }

  void _updateUserMarker() {
    if (_userLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          icon:
              _userLocationIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
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

    _updateBusMarkers(buses, selectedBusId);
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

  void _updateBusMarkers(List<BusEntity> buses, String? selectedBusId) {
    for (final bus in buses) {
      final isSelected = bus.id == selectedBusId;

      // Animación suave hacia nueva posición
      _animateBusMovement(bus, isSelected);
    }
  }

  void _animateBusMovement(BusEntity bus, bool isSelected) {
    final markerId = 'bus_${bus.id}';
    final targetPosition = bus.currentLocation;

    // Si es una posición nueva, animar
    if (_busTargetPositions[markerId] != targetPosition) {
      _busTargetPositions[markerId] = targetPosition;

      // Podríamos agregar animación aquí más adelante
      _animatedMarkers[markerId] = Marker(
        markerId: MarkerId(markerId),
        position: targetPosition,
        infoWindow: InfoWindow(
          title: 'Bus ${bus.licensePlate}',
          snippet:
              'Conductor: ${bus.driverName}\nVelocidad: ${bus.currentSpeed} km/h',
        ),
        icon: _getBusIcon(isSelected),
        onTap: () => _onBusTapped(bus),
      );
    }

    _markers.add(_animatedMarkers[markerId]!);
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
              // ... información existente

              // Agregar información de movimiento
              _buildInfoRow('Velocidad:', '${bus.currentSpeed} km/h'),
              _buildInfoRow(
                'Última actualización:',
                _formatLastUpdate(bus.lastUpdate),
              ),
              _buildInfoRow(
                'Próxima parada:',
                'En ${bus.estimatedArrival} min',
              ),

              // Botones de acción
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _startBusTracking(bus);
                        Navigator.pop(context);
                      },
                      child: const Text('Seguir este bus'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showBusRoute(bus.routeId);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Ver ruta',
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

  String _formatLastUpdate(DateTime lastUpdate) {
    final difference = DateTime.now().difference(lastUpdate);
    if (difference.inSeconds < 60)
      return 'Hace ${difference.inSeconds} segundos';
    if (difference.inMinutes < 60)
      return 'Hace ${difference.inMinutes} minutos';
    return 'Hace ${difference.inHours} horas';
  }

  void _startBusTracking(BusEntity bus) {
    // Centrar mapa en el bus y seguir su movimiento
    _mapController.animateCamera(CameraUpdate.newLatLng(bus.currentLocation));

    // Podríamos agregar más funcionalidades de seguimiento aquí
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Siguiendo bus ${bus.licensePlate}')),
    );
  }

  void _showBusRoute(String routeId) {
    final bloc = context.read<TransportBloc>();
    bloc.add(TransportRouteSelected(routeId));

    // Aquí podríamos destacar la ruta o mostrar información adicional
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
                  Navigator.pop(context); // Cerrar modal actual
                  _findRoutesForStop(
                    busStop,
                  ); // Llamar a la función, NO al modal directamente
                },
                child: const Text('Ver rutas disponibles'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _findRoutesForStop(BusStopEntity busStop) async {
    setState(() => _isLocating = true);

    try {
      final transportRepository = context.read<TransportRepository>();

      // Usar el método del repository directamente
      final routes = await transportRepository.getBusRoutesByStop(busStop.id);

      _showRoutesForStopModal(routes, busStop);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error buscando rutas: $e')));
    } finally {
      setState(() => _isLocating = false);
    }
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

  void _showNearbyStopsModal(List<BusStopEntity> nearbyStops) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal se expanda
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paradas Cercanas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${nearbyStops.length} paradas encontradas en 1km a la redonda',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              if (nearbyStops.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No se encontraron paradas cercanas en el radio de búsqueda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: nearbyStops.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final stop = nearbyStops[index];
                      return _buildNearbyStopItem(stop);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNearbyStopItem(BusStopEntity stop) {
    // Calcular distancia desde la ubicación del usuario
    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      stop.location.latitude,
      stop.location.longitude,
    );

    final distanceText = distance < 1000
        ? '${distance.round()} m'
        : '${(distance / 1000).toStringAsFixed(1)} km';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.directions_bus, color: Colors.white, size: 24),
      ),
      title: Text(stop.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stop.address,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.directions_walk, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                distanceText,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Icon(Icons.route, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${stop.routeIds.length} ${stop.routeIds.length == 1 ? 'ruta' : 'rutas'}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context); // Cerrar el modal de paradas cercanas

        // Centrar el mapa en la parada seleccionada
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(stop.location.latitude, stop.location.longitude),
            16.0, // Zoom más cercano
          ),
        );

        // Mostrar la información detallada de la parada después de un breve delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _showBusStopInfoModal(stop);
        });
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

  void _showRoutesForStopModal(
    List<RouteEntity> routes,
    BusStopEntity busStop,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rutas en ${busStop.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (routes.isEmpty)
                const Text('No hay rutas disponibles en esta parada')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return ListTile(
                        title: Text(route.name),
                        subtitle: Text(route.description),
                        onTap: () {
                          Navigator.pop(context); // Cerrar modal de rutas
                          _calculateRouteETA(
                            route,
                            busStop,
                          ); // Nueva función para ETA
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _calculateRouteETA(RouteEntity route, BusStopEntity busStop) async {
    setState(() => _isLocating = true);

    try {
      final transportRepository = context.read<TransportRepository>();

      // 1. Obtener buses activos de la ruta
      final buses = await transportRepository.getActiveBusesByRoute(route.id);
      if (buses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay buses activos en la ruta ${route.name}'),
          ),
        );
        return;
      }

      // 2. Calcular ETA para el primer bus
      final eta = await transportRepository.calculateBusETA(
        buses.first.id,
        busStop.id,
      );

      if (eta != null) {
        _showRouteDetailsModal(route.id, busStop.id, eta);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo calcular el tiempo de llegada')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error calculando ETA: $e')));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Widget _buildRoutesList(List<RouteEntity> routes, String busStopId) {
    return Expanded(
      child: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return ListTile(
            title: Text(route.name),
            subtitle: Text(route.description),
            onTap: () {
              final bloc = context.read<TransportBloc>();
              bloc.add(TransportRouteETARequested(route.id, busStopId));
            },
          );
        },
      ),
    );
  }

  void _showRouteDetailsModal(String routeId, String busStopId, Duration eta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiempo estimado de llegada'),
        content: Text('Llegará en aproximadamente ${_formatDuration(eta)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRouteDetails(
                routeId,
                busStopId,
                eta,
              ); // Nueva función para detalles
            },
            child: const Text('Ver detalles'),
          ),
        ],
      ),
    );
  }

  void _showRouteDetails(String routeId, String busStopId, Duration eta) async {
    setState(() => _isLocating = true);

    try {
      final transportRepository = context.read<TransportRepository>();

      // Obtener datos completos
      final route = await transportRepository.getBusRouteById(routeId);
      final busStop = await transportRepository.getBusStopById(busStopId);

      // Calcular distancia
      double distance = 0.0;
      if (_userLocation != null) {
        distance = await transportRepository.calculateDistance(
          _userLocation!,
          busStop.location,
        );
      }

      _showRouteDetailsDialog(route, busStop, eta, distance);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error mostrando detalles: $e')));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _showRouteDetailsDialog(
    RouteEntity route,
    BusStopEntity busStop,
    Duration eta,
    double distance,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(route.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parada: ${busStop.name}'),
            Text('Tiempo estimado: ${_formatDuration(eta)}'),
            Text('Distancia: ${distance.toStringAsFixed(1)} km'),
            Text('Tarifa: C\$${route.fare.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return 'menos de 1 minuto';
    if (duration.inMinutes < 60) return '${duration.inMinutes} minutos';
    return '${duration.inHours} hora(s) ${duration.inMinutes.remainder(60)} minutos';
  }
}
