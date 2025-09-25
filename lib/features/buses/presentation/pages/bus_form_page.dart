import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bus_management_bloc.dart';
import '../widgets/bus_form.dart';
import '../../domain/entities/bus_entity.dart';

class BusFormPage extends StatelessWidget {
  final BusEntity? initialBus;

  const BusFormPage({super.key, this.initialBus});

  void _onSubmit(BuildContext context, BusEntity bus) {
    if (initialBus == null) {
      // Crear nuevo bus
      context.read<BusManagementBloc>().add(CreateBusEvent(bus: bus));
    } else {
      // Actualizar bus existente
      context.read<BusManagementBloc>().add(UpdateBusEvent(bus: bus));
    }

    Navigator.pop(context);
  }

  void _onCancel(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(initialBus == null ? 'Nuevo Bus' : 'Editar Bus'),
      ),
      body: BusForm(
        initialBus: initialBus,
        onSubmit: (bus) => _onSubmit(context, bus),
        onCancel: () => _onCancel(context),
      ),
    );
  }
}
