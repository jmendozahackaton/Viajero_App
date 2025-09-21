// lib/features/trip_planner/presentation/pages/trip_planner_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackaton_app/features/trip_planner/domain/entities/trip_plan_entity.dart';
import 'package:hackaton_app/features/trip_planner/presentation/bloc/trip_planner_bloc.dart';
import 'package:hackaton_app/features/trip_planner/presentation/widgets/map_location_picker_dialog.dart';
import 'package:hackaton_app/features/trip_planner/presentation/widgets/saved_trips_modal.dart';
import 'package:hackaton_app/features/trip_planner/presentation/widgets/slider_list_tile.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final LatLng _initialPosition = const LatLng(
    12.136389,
    -86.251389,
  ); // Managua
  LatLng? _selectedOrigin;
  LatLng? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _initializeDevelopmentData();

    // Cargar viajes guardados al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripPlannerBloc>().add(LoadSavedTripsEvent());
    });
  }

  Future<void> _initializeDevelopmentData() async {
    const bool isDevelopment = true;

    if (isDevelopment) {
      try {
        // Inicializar datos de prueba si es necesario
        // (Esto podría moverse al Bloc si es apropiado)
        print('✅ Modo desarrollo activado para planificador');
      } catch (e) {
        print('⚠️ Error en configuración de desarrollo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador de Viajes'),
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
            icon: const Icon(Icons.history),
            onPressed: _showSavedTrips,
            tooltip: 'Viajes guardados',
          ),
        ],
      ),
      body: BlocConsumer<TripPlannerBloc, TripPlannerState>(
        listener: (context, state) {
          // Mostrar mensajes de error o éxito
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildLocationInputs(),
                const SizedBox(height: 16),
                _buildPreferencesSection(state),
                const SizedBox(height: 16),
                _buildActionButtons(state),
                const SizedBox(height: 16),
                _buildResultsSection(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: InputDecoration(
                labelText: 'Origen',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () => _selectLocation(true),
                ),
              ),
              readOnly: true,
              onTap: () => _selectLocation(true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Destino',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.place),
                  onPressed: () => _selectLocation(false),
                ),
              ),
              readOnly: true,
              onTap: () => _selectLocation(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(TripPlannerState state) {
    return ExpansionTile(
      title: const Text('Preferencias de Viaje'),
      children: [
        SwitchListTile(
          title: const Text('Minimizar transbordos'),
          value: state.currentPreferences.minimizeTransfers,
          onChanged: (value) => _updatePreferences(minimizeTransfers: value),
        ),
        SwitchListTile(
          title: const Text('Minimizar caminata'),
          value: state.currentPreferences.minimizeWalking,
          onChanged: (value) => _updatePreferences(minimizeWalking: value),
        ),
        SwitchListTile(
          title: const Text('Priorizar accesibilidad'),
          value: state.currentPreferences.prioritizeAccessibility,
          onChanged: (value) =>
              _updatePreferences(prioritizeAccessibility: value),
        ),
        SliderListTile(
          title: 'Tiempo máximo de espera',
          value: state.currentPreferences.maxWaitTime.toDouble(),
          min: 5,
          max: 30,
          divisions: 5,
          label: '${state.currentPreferences.maxWaitTime} min',
          onChanged: (value) => _updatePreferences(maxWaitTime: value.round()),
        ),
        SliderListTile(
          title: 'Distancia máxima a caminar',
          value: state.currentPreferences.maxWalkingDistance.toDouble(),
          min: 100,
          max: 2000,
          divisions: 19,
          label: '${state.currentPreferences.maxWalkingDistance}m',
          onChanged: (value) =>
              _updatePreferences(maxWalkingDistance: value.round()),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TripPlannerState state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                state.isLoading ||
                    _selectedOrigin == null ||
                    _selectedDestination == null
                ? null
                : () => _planTrip(),
            child: state.isLoading
                ? const CircularProgressIndicator()
                : const Text('Planificar Viaje'),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: _swapLocations,
          tooltip: 'Intercambiar origen y destino',
        ),
      ],
    );
  }

  Widget _buildResultsSection(TripPlannerState state) {
    if (state.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null && state.routeOptions.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            state.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.routeOptions.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'Selecciona origen y destino para planificar tu viaje',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: state.routeOptions.length,
        itemBuilder: (context, index) {
          final option = state.routeOptions[index];
          return _buildRouteOptionCard(option, index);
        },
      ),
    );
  }

  Widget _buildRouteOptionCard(RouteOption option, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opción ${index + 1}: ${option.routeName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${option.estimatedTime} min'),
                const SizedBox(width: 16),
                Icon(Icons.directions_walk, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${option.walkingDistance.round()}m caminando'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text('C\$${option.fare.toStringAsFixed(2)}'),
                const SizedBox(width: 16),
                Icon(Icons.swap_horiz, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${option.transfers} transbordos'),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _saveTripPlan(option),
              child: const Text('Guardar Viaje'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocation(bool isOrigin) async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapLocationPickerDialog(
        initialPosition: _initialPosition,
        title: isOrigin ? 'Seleccionar Origen' : 'Seleccionar Destino',
      ),
    );

    if (result != null) {
      setState(() {
        if (isOrigin) {
          _selectedOrigin = result;
          _originController.text =
              '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
        } else {
          _selectedDestination = result;
          _destinationController.text =
              '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final temp = _selectedOrigin;
      _selectedOrigin = _selectedDestination;
      _selectedDestination = temp;

      final tempText = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = tempText;
    });
  }

  void _updatePreferences({
    bool? minimizeTransfers,
    bool? minimizeWalking,
    bool? prioritizeAccessibility,
    int? maxWaitTime,
    int? maxWalkingDistance,
  }) {
    final currentState = context.read<TripPlannerBloc>().state;
    final newPreferences = currentState.currentPreferences.copyWith(
      minimizeTransfers: minimizeTransfers,
      minimizeWalking: minimizeWalking,
      prioritizeAccessibility: prioritizeAccessibility,
      maxWaitTime: maxWaitTime,
      maxWalkingDistance: maxWalkingDistance,
    );

    context.read<TripPlannerBloc>().add(
      UpdateTripPreferencesEvent(preferences: newPreferences),
    );
  }

  void _planTrip() {
    if (_selectedOrigin != null && _selectedDestination != null) {
      context.read<TripPlannerBloc>().add(
        PlanTripEvent(
          origin: _selectedOrigin!,
          destination: _selectedDestination!,
        ),
      );
    }
  }

  void _saveTripPlan(RouteOption option) {
    context.read<TripPlannerBloc>().add(
      SaveTripPlanEvent(selectedOption: option),
    );
  }

  void _showSavedTrips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SavedTripsModal(), // ← Sin parámetros
    );
  }
}
