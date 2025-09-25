import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bus_management_bloc.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_driver_entity.dart';

class DriverAssignmentPage extends StatefulWidget {
  final BusEntity bus;

  const DriverAssignmentPage({super.key, required this.bus});

  @override
  State<DriverAssignmentPage> createState() => _DriverAssignmentPageState();
}

class _DriverAssignmentPageState extends State<DriverAssignmentPage> {
  @override
  void initState() {
    super.initState();
    // Cargar conductores disponibles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Esto cargaría los conductores - necesitaríamos un evento específico
      context.read<BusManagementBloc>().add(const LoadBusesEvent());
    });
  }

  void _assignDriver(String driverId) {
    context.read<BusManagementBloc>().add(
      AssignDriverEvent(busId: widget.bus.id, driverId: driverId),
    );
    Navigator.pop(context);
  }

  void _unassignDriver() {
    context.read<BusManagementBloc>().add(
      UnassignDriverEvent(busId: widget.bus.id),
    );
    Navigator.pop(context);
  }

  Widget _buildDriverCard(BusDriverEntity driver, bool isAssigned) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAssigned ? Colors.green : Colors.blue,
          child: Text(
            driver.fullName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(driver.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver.email),
            if (driver.licenseNumber != null)
              Text('Licencia: ${driver.licenseNumber}'),
            if (driver.licenseExpiry != null)
              Text(
                'Vence: ${_formatDate(driver.licenseExpiry!)}',
                style: TextStyle(
                  color: driver.isLicenseValid ? Colors.green : Colors.red,
                ),
              ),
            Text(
              'Rutas asignadas: ${driver.assignedRoutes.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isAssigned
            ? const Chip(
                label: Text('ASIGNADO', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
              )
            : ElevatedButton(
                onPressed: driver.isLicenseValid
                    ? () => _assignDriver(driver.userId)
                    : null,
                child: const Text('Asignar'),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignar Conductor - ${widget.bus.licensePlate}'),
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

          // Nota: Necesitaríamos cargar los conductores disponibles
          // Por ahora mostramos un mensaje temporal
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del bus
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_bus,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bus.licensePlate,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Ruta: ${widget.bus.routeId}'),
                              if (widget.bus.driverId != null)
                                Text(
                                  'Conductor actual: ${widget.bus.driverId}',
                                  style: TextStyle(color: Colors.green[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Acción para remover conductor actual
                if (widget.bus.driverId != null) ...[
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Conductor Actualmente Asignado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text('ID: ${widget.bus.driverId}'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _unassignDriver,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Remover'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Lista de conductores (placeholder por ahora)
                const Text(
                  'Conductores Disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    children: [
                      // Esto sería reemplazado por la lista real de conductores
                      _buildPlaceholderDriver(
                        'Carlos Rodríguez',
                        'LIC-123456',
                        true,
                      ),
                      _buildPlaceholderDriver(
                        'María González',
                        'LIC-789012',
                        false,
                      ),
                      _buildPlaceholderDriver(
                        'José Martínez',
                        'LIC-345678',
                        false,
                      ),
                      _buildPlaceholderDriver('Ana López', 'LIC-901234', true),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderDriver(
    String name,
    String license,
    bool licenseValid,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: licenseValid ? Colors.blue : Colors.grey,
          child: Text(name.substring(0, 1)),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Licencia: $license'),
            Text(
              licenseValid ? 'Licencia válida' : 'Licencia vencida',
              style: TextStyle(color: licenseValid ? Colors.green : Colors.red),
            ),
          ],
        ),
        trailing: licenseValid
            ? ElevatedButton(
                onPressed: () {
                  // Simular asignación
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Asignando $name...')));
                },
                child: const Text('Asignar'),
              )
            : const Text('No disponible', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
