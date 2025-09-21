// lib/features/trip_planner/presentation/widgets/map_location_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPickerDialog extends StatefulWidget {
  final LatLng initialPosition;
  final String title;

  const MapLocationPickerDialog({
    super.key,
    required this.initialPosition,
    required this.title,
  });

  @override
  State<MapLocationPickerDialog> createState() =>
      _MapLocationPickerDialogState();
}

class _MapLocationPickerDialogState extends State<MapLocationPickerDialog> {
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 12,
          ),
          onTap: (latLng) {
            setState(() {
              _selectedLocation = latLng;
            });
          },
          markers: _selectedLocation != null
              ? {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _selectedLocation!,
                    infoWindow: const InfoWindow(
                      title: 'Ubicación seleccionada',
                    ),
                  ),
                }
              : {},
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedLocation != null
              ? () => Navigator.pop(context, _selectedLocation)
              : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}
