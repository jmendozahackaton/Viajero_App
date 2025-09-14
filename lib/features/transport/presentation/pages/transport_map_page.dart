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
          infoWindow: InfoWindow(title: stop.name, snippet: stop.description),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueViolet,
          ),
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
            snippet: 'Conductor: ${bus.driverName}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
