import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/bus_entity.dart';

class BusForm extends StatefulWidget {
  final BusEntity? initialBus;
  final Function(BusEntity) onSubmit;
  final Function() onCancel;

  const BusForm({
    super.key,
    this.initialBus,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<BusForm> createState() => _BusFormState();
}

class _BusFormState extends State<BusForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licensePlateController;
  late TextEditingController _routeIdController;
  late TextEditingController _capacityController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(
      text: widget.initialBus?.licensePlate ?? '',
    );
    _routeIdController = TextEditingController(
      text: widget.initialBus?.routeId ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.initialBus?.capacity.toString() ?? '50',
    );
    _isActive = widget.initialBus?.isActive ?? true;
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _routeIdController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bus = BusEntity(
        id: widget.initialBus?.id ?? '',
        routeId: _routeIdController.text,
        licensePlate: _licensePlateController.text,
        driverId: widget.initialBus?.driverId,
        capacity: int.parse(_capacityController.text),
        currentLocation:
            widget.initialBus?.currentLocation ??
            const LatLng(12.136389, -86.251389),
        lastUpdate: DateTime.now(),
        currentSpeed: 0,
        occupancy: 0,
        estimatedArrival: 0,
        isActive: _isActive,
        createdAt: widget.initialBus?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(bus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'Placa del Bus',
                hintText: 'Ej: M-101-ABC',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la placa del bus';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeIdController,
              decoration: const InputDecoration(
                labelText: 'ID de Ruta',
                hintText: 'Ej: route_101',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el ID de la ruta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidad',
                hintText: 'Ej: 50',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la capacidad';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'La capacidad debe ser un número positivo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bus Activo'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      widget.initialBus == null ? 'Crear' : 'Actualizar',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
