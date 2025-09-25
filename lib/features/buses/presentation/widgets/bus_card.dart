import 'package:flutter/material.dart';
import '../../domain/entities/bus_entity.dart';

class BusCard extends StatelessWidget {
  final BusEntity bus;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BusCard({
    super.key,
    required this.bus,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bus.isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.directions_bus, color: Colors.white, size: 30),
        ),
        title: Text(
          bus.licensePlate,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: bus.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ruta: ${bus.routeId}'),
            Text('Capacidad: ${bus.capacity} pasajeros'),
            if (bus.driverId != null) Text('Conductor: ${bus.driverId}'),
            Text(
              bus.isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: bus.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
                tooltip: 'Editar bus',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Eliminar bus',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
