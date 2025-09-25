import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bus_management_bloc.dart';
import '../widgets/bus_card.dart';
import 'bus_form_page.dart';
import 'bus_details_page.dart';

class BusesListPage extends StatefulWidget {
  const BusesListPage({super.key});

  @override
  State<BusesListPage> createState() => _BusesListPageState();
}

class _BusesListPageState extends State<BusesListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar buses al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusManagementBloc>().add(const LoadBusesEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToBusForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusFormPage()),
    );
  }

  void _navigateToBusDetails(String busId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BusDetailsPage(busId: busId)),
    );
  }

  void _showDeleteDialog(String busId, String licensePlate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Bus'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el bus $licensePlate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<BusManagementBloc>().add(
                DeleteBusEvent(busId: busId),
              );
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Buses'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home), // ← Botón de retroceso
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
          tooltip: 'Regresar al inicio',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToBusForm,
            tooltip: 'Agregar nuevo bus',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar buses',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<BusManagementBloc>().add(ClearSearchEvent());
                  },
                ),
              ),
              onChanged: (value) {
                context.read<BusManagementBloc>().add(
                  SearchBusesEvent(query: value),
                );
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<BusManagementBloc, BusManagementState>(
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

                if (state.filteredBuses.isEmpty) {
                  return const Center(child: Text('No se encontraron buses'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<BusManagementBloc>().add(
                      const LoadBusesEvent(),
                    );
                  },
                  child: ListView.builder(
                    itemCount: state.filteredBuses.length,
                    itemBuilder: (context, index) {
                      final bus = state.filteredBuses[index];
                      return BusCard(
                        bus: bus,
                        onTap: () => _navigateToBusDetails(bus.id),
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusFormPage(initialBus: bus),
                            ),
                          );
                        },
                        onDelete: () =>
                            _showDeleteDialog(bus.id, bus.licensePlate),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBusForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
