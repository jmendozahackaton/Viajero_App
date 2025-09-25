import 'package:flutter/material.dart';
import '../../domain/entities/bus_driver_entity.dart';

class DriverSelectionDialog extends StatefulWidget {
  final String? currentDriverId;
  final Function(String) onDriverSelected;
  final Function() onDriverRemoved;

  const DriverSelectionDialog({
    super.key,
    this.currentDriverId,
    required this.onDriverSelected,
    required this.onDriverRemoved,
  });

  @override
  State<DriverSelectionDialog> createState() => _DriverSelectionDialogState();
}

class _DriverSelectionDialogState extends State<DriverSelectionDialog> {
  List<BusDriverEntity> _availableDrivers = [];
  String? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _selectedDriverId = widget.currentDriverId;
    _loadAvailableDrivers();
  }

  void _loadAvailableDrivers() {
    // Simulación de carga de conductores
    // En implementación real, esto vendría del BLoC o repository
    setState(() {
      _availableDrivers = [
        BusDriverEntity(
          userId: 'driver_001',
          fullName: 'Carlos Rodríguez',
          email: 'carlos@transporte.com',
          licenseNumber: 'LIC-123456',
          licenseExpiry: DateTime.now().add(const Duration(days: 365)),
          assignedRoutes: ['route_101', 'route_118'],
          isActive: true,
          createdAt: DateTime.now(),
        ),
        BusDriverEntity(
          userId: 'driver_002',
          fullName: 'María González',
          email: 'maria@transporte.com',
          licenseNumber: 'LIC-789012',
          licenseExpiry: DateTime.now().add(const Duration(days: 200)),
          assignedRoutes: ['route_120'],
          isActive: true,
          createdAt: DateTime.now(),
        ),
        BusDriverEntity(
          userId: 'driver_003',
          fullName: 'José Martínez',
          email: 'jose@transporte.com',
          licenseNumber: 'LIC-345678',
          licenseExpiry: DateTime.now().subtract(
            const Duration(days: 30),
          ), // Vencida
          assignedRoutes: [],
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
    });
  }

  void _handleDriverSelection(String driverId) {
    setState(() {
      _selectedDriverId = driverId;
    });
  }

  void _handleConfirm() {
    if (_selectedDriverId != null) {
      widget.onDriverSelected(_selectedDriverId!);
    }
  }

  void _handleRemove() {
    widget.onDriverRemoved();
  }

  Widget _buildDriverListItem(BusDriverEntity driver) {
    final isSelected = _selectedDriverId == driver.userId;
    final isCurrentDriver = widget.currentDriverId == driver.userId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentDriver ? Colors.green : Colors.blue,
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  size: 14,
                  color: driver.isLicenseValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  driver.licenseNumber ?? 'Sin licencia',
                  style: TextStyle(
                    color: driver.isLicenseValid ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (driver.assignedRoutes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Rutas: ${driver.assignedRoutes.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: isCurrentDriver
            ? const Chip(
                label: Text('ACTUAL', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
              )
            : Radio<String>(
                value: driver.userId,
                groupValue: _selectedDriverId,
                onChanged: driver.isLicenseValid
                    ? (value) => _handleDriverSelection(value!)
                    : null,
              ),
        onTap: driver.isLicenseValid
            ? () => _handleDriverSelection(driver.userId)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Seleccionar Conductor'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            if (widget.currentDriverId != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Actualmente asignado: ${_getCurrentDriverName()}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleRemove,
                      child: const Text(
                        'Remover',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selecciona un conductor disponible:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: _availableDrivers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _availableDrivers.length,
                      itemBuilder: (context, index) {
                        return _buildDriverListItem(_availableDrivers[index]);
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedDriverId != null
                          ? _handleConfirm
                          : null,
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDriverName() {
    final currentDriver = _availableDrivers.firstWhere(
      (driver) => driver.userId == widget.currentDriverId,
      orElse: () => BusDriverEntity(
        userId: widget.currentDriverId!,
        fullName: 'Conductor no encontrado',
        email: '',
        assignedRoutes: [],
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
    return currentDriver.fullName;
  }
}
