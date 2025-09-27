import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Viajeros/features/buses/domain/entities/bus_entity.dart';
import 'package:Viajeros/features/buses/presentation/pages/bus_form_page.dart';
import '../bloc/bus_management_bloc.dart';
import '../widgets/driver_selection_dialog.dart';
import 'driver_assignment_page.dart';

class BusDetailsPage extends StatefulWidget {
  final String busId;

  const BusDetailsPage({super.key, required this.busId});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar detalles del bus al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusManagementBloc>().add(
        LoadBusByIdEvent(busId: widget.busId),
      );
    });
  }

  void _navigateToDriverAssignment() {
    final state = context.read<BusManagementBloc>().state;
    final bus = state.selectedBus;

    if (bus != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DriverAssignmentPage(bus: bus)),
      );
    }
  }

  void _showDriverSelectionDialog() {
    final state = context.read<BusManagementBloc>().state;
    final bus = state.selectedBus;

    if (bus != null) {
      showDialog(
        context: context,
        builder: (context) => DriverSelectionDialog(
          currentDriverId: bus.driverId,
          onDriverSelected: (driverId) {
            context.read<BusManagementBloc>().add(
              AssignDriverEvent(busId: bus.id, driverId: driverId),
            );
            Navigator.pop(context);
          },
          onDriverRemoved: () {
            context.read<BusManagementBloc>().add(
              UnassignDriverEvent(busId: bus.id),
            );
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  void _showLocationOnMap() {
    final state = context.read<BusManagementBloc>().state;
    final bus = state.selectedBus;

    if (bus != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ubicación del Bus'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: bus.currentLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(bus.id),
                  position: bus.currentLocation,
                  infoWindow: InfoWindow(
                    title: 'Bus ${bus.licensePlate}',
                    snippet:
                        'Última actualización: ${_formatTime(bus.lastUpdate)}',
                  ),
                ),
              },
            ),
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
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showStatusChangeDialog(bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Desactivar Bus' : 'Activar Bus'),
        content: Text(
          currentStatus
              ? '¿Estás seguro de que quieres desactivar este bus?'
              : '¿Estás seguro de que quieres activar este bus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final state = context.read<BusManagementBloc>().state;
              final bus = state.selectedBus;

              if (bus != null) {
                final updatedBus = bus.copyWith(isActive: !currentStatus);
                context.read<BusManagementBloc>().add(
                  UpdateBusEvent(bus: updatedBus),
                );
              }

              Navigator.pop(context);
            },
            child: Text(currentStatus ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Bus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<BusManagementBloc>().state;
              final bus = state.selectedBus;

              if (bus != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusFormPage(initialBus: bus),
                  ),
                );
              }
            },
            tooltip: 'Editar bus',
          ),
        ],
      ),
      body: BlocConsumer<BusManagementBloc, BusManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bus = state.selectedBus;
          if (bus == null) {
            return const Center(child: Text('Bus no encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información principal
                _buildHeaderSection(bus),
                const SizedBox(height: 24),

                // Información de ubicación
                _buildLocationSection(bus),
                const SizedBox(height: 24),

                // Información del conductor
                _buildDriverSection(bus),
                const SizedBox(height: 24),

                // Estadísticas y métricas
                _buildMetricsSection(bus),
                const SizedBox(height: 24),

                // Acciones
                _buildActionsSection(bus),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BusEntity bus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bus.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_bus, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.licensePlate,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ruta: ${bus.routeId}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      bus.isActive ? 'ACTIVO' : 'INACTIVO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: bus.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BusEntity bus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación Actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${bus.currentLocation.latitude.toStringAsFixed(6)}\n'
                    'Lng: ${bus.currentLocation.longitude.toStringAsFixed(6)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _showLocationOnMap,
                  child: const Text('Ver en Mapa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${_formatDateTime(bus.lastUpdate)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection(BusEntity bus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conductor Asignado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (bus.driverId == null) ...[
              const Text('No hay conductor asignado'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _showDriverSelectionDialog,
                child: const Text('Asignar Conductor'),
              ),
            ] else ...[
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(bus.driverId!),
                subtitle: const Text('Conductor asignado'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                      onPressed: _showDriverSelectionDialog,
                      tooltip: 'Cambiar conductor',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        context.read<BusManagementBloc>().add(
                          UnassignDriverEvent(busId: bus.id),
                        );
                      },
                      tooltip: 'Remover conductor',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BusEntity bus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas del Bus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem('Capacidad', '${bus.capacity}'),
                _buildMetricItem('Ocupación', '${bus.occupancy}'),
                _buildMetricItem('Velocidad', '${bus.currentSpeed} km/h'),
                _buildMetricItem('ETA', '${bus.estimatedArrival} min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionsSection(BusEntity bus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showStatusChangeDialog(bus.isActive),
              style: ElevatedButton.styleFrom(
                backgroundColor: bus.isActive ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(bus.isActive ? 'Desactivar Bus' : 'Activar Bus'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // Navegar a historial de viajes (futura implementación)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
              child: const Text('Ver Historial de Viajes'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
  }
}
