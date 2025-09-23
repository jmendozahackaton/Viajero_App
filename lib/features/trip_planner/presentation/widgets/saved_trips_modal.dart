// lib/features/trip_planner/presentation/widgets/saved_trips_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/presentation/bloc/trip_planner_bloc.dart';

class SavedTripsModal extends StatelessWidget {
  const SavedTripsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripPlannerBloc, TripPlannerState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Viajes Guardados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTripsList(context, state.savedTrips),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripsList(BuildContext context, List<TripPlanEntity> trips) {
    if (trips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'No tienes viajes guardados',
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripItem(context, trip);
        },
      ),
    );
  }

  Widget _buildTripItem(BuildContext context, TripPlanEntity trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text('De: ${_formatLatLng(trip.origin)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A: ${_formatLatLng(trip.destination)}'),
            Text(
              'Creado: ${_formatDate(trip.plannedTime)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            _deleteTrip(context, trip);
          },
        ),
        onTap: () {
          _loadTrip(context, trip);
        },
      ),
    );
  }

  String _formatLatLng(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deleteTrip(BuildContext context, TripPlanEntity trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Viaje'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este viaje?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo primero

              try {
                // Mostrar indicador de carga
                final scaffold = ScaffoldMessenger.of(context);
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('Eliminando viaje...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Ejecutar la eliminación
                context.read<TripPlannerBloc>().add(
                  DeleteTripPlanEvent(tripPlanId: trip.id),
                );

                // Mensaje de éxito
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('✅ Viaje eliminado correctamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _loadTrip(BuildContext context, TripPlanEntity trip) {
    // Cargar el viaje seleccionado en el bloc
    context.read<TripPlannerBloc>().add(
      PlanTripEvent(origin: trip.origin, destination: trip.destination),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Viaje cargado')));
  }
}
