import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/map/presentation/bloc/map_bloc.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(
    12.136389,
    -86.251389,
  ); // Managua

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Rutas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => MapBloc()..add(MapLoaded(_initialPosition)),
        child: BlocBuilder<MapBloc, MapState>(
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
              markers: _buildMarkers(state),
            );
          },
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(MapState state) {
    final markers = <Marker>{};

    // Marcador de posición inicial
    markers.add(
      Marker(
        markerId: const MarkerId('initial_position'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'Managua'),
      ),
    );

    return markers;
  }
}
