import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_driver_entity.dart';
import '../../domain/usecases/get_buses_usecase.dart';
import '../../domain/usecases/get_bus_by_id_usecase.dart';
import '../../domain/usecases/create_bus_usecase.dart';
import '../../domain/usecases/update_bus_usecase.dart';
import '../../domain/usecases/delete_bus_usecase.dart';
import '../../domain/usecases/get_buses_by_route_usecase.dart';
import '../../domain/usecases/assign_driver_usecase.dart';
import '../../domain/usecases/unassign_driver_usecase.dart';

part 'bus_management_event.dart';
part 'bus_management_state.dart';

class BusManagementBloc extends Bloc<BusManagementEvent, BusManagementState> {
  final GetBusesUseCase _getBusesUseCase;
  final GetBusByIdUseCase _getBusByIdUseCase;
  final CreateBusUseCase _createBusUseCase;
  final UpdateBusUseCase _updateBusUseCase;
  final DeleteBusUseCase _deleteBusUseCase;
  final GetBusesByRouteUseCase _getBusesByRouteUseCase;
  final AssignDriverUseCase _assignDriverUseCase;
  final UnassignDriverUseCase _unassignDriverUseCase;

  BusManagementBloc({
    required GetBusesUseCase getBusesUseCase,
    required GetBusByIdUseCase getBusByIdUseCase,
    required CreateBusUseCase createBusUseCase,
    required UpdateBusUseCase updateBusUseCase,
    required DeleteBusUseCase deleteBusUseCase,
    required GetBusesByRouteUseCase getBusesByRouteUseCase,
    required AssignDriverUseCase assignDriverUseCase,
    required UnassignDriverUseCase unassignDriverUseCase,
  }) : _getBusesUseCase = getBusesUseCase,
       _getBusByIdUseCase = getBusByIdUseCase,
       _createBusUseCase = createBusUseCase,
       _updateBusUseCase = updateBusUseCase,
       _deleteBusUseCase = deleteBusUseCase,
       _getBusesByRouteUseCase = getBusesByRouteUseCase,
       _assignDriverUseCase = assignDriverUseCase,
       _unassignDriverUseCase = unassignDriverUseCase,
       super(BusManagementState.initial()) {
    on<LoadBusesEvent>(_onLoadBuses);
    on<LoadBusByIdEvent>(_onLoadBusById);
    on<CreateBusEvent>(_onCreateBus);
    on<UpdateBusEvent>(_onUpdateBus);
    on<DeleteBusEvent>(_onDeleteBus);
    on<AssignDriverEvent>(_onAssignDriver);
    on<UnassignDriverEvent>(_onUnassignDriver);
    on<SearchBusesEvent>(_onSearchBuses);
    on<LoadBusesByRouteEvent>(_onLoadBusesByRoute);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadBuses(
    LoadBusesEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final buses = await _getBusesUseCase.execute(
        activeOnly: event.activeOnly,
      );
      emit(
        state.copyWith(
          isLoading: false,
          buses: buses,
          filteredBuses: _applySearchFilter(buses, state.searchQuery),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error cargando buses: $e',
        ),
      );
    }
  }

  Future<void> _onLoadBusById(
    LoadBusByIdEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final bus = await _getBusByIdUseCase.execute(event.busId);
      emit(state.copyWith(isLoading: false, selectedBus: bus));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error cargando bus: $e',
        ),
      );
    }
  }

  Future<void> _onCreateBus(
    CreateBusEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final newBus = await _createBusUseCase.execute(event.bus);
      final updatedBuses = [...state.buses, newBus];

      emit(
        state.copyWith(
          isLoading: false,
          buses: updatedBuses,
          filteredBuses: _applySearchFilter(updatedBuses, state.searchQuery),
          successMessage: 'Bus creado exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Error creando bus: $e'),
      );
    }
  }

  Future<void> _onUpdateBus(
    UpdateBusEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final updatedBus = await _updateBusUseCase.execute(event.bus);
      final updatedBuses = state.buses
          .map((bus) => bus.id == updatedBus.id ? updatedBus : bus)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          buses: updatedBuses,
          filteredBuses: _applySearchFilter(updatedBuses, state.searchQuery),
          selectedBus: updatedBus,
          successMessage: 'Bus actualizado exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error actualizando bus: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteBus(
    DeleteBusEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _deleteBusUseCase.execute(event.busId);
      final updatedBuses = state.buses
          .where((bus) => bus.id != event.busId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          buses: updatedBuses,
          filteredBuses: _applySearchFilter(updatedBuses, state.searchQuery),
          successMessage: 'Bus eliminado exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error eliminando bus: $e',
        ),
      );
    }
  }

  Future<void> _onAssignDriver(
    AssignDriverEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _assignDriverUseCase.execute(event.busId, event.driverId);

      // Recargar el bus actualizado
      final updatedBus = await _getBusByIdUseCase.execute(event.busId);
      final updatedBuses = state.buses
          .map((bus) => bus.id == event.busId ? updatedBus : bus)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          buses: updatedBuses,
          filteredBuses: _applySearchFilter(updatedBuses, state.searchQuery),
          selectedBus: updatedBus,
          successMessage: 'Conductor asignado exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error asignando conductor: $e',
        ),
      );
    }
  }

  Future<void> _onUnassignDriver(
    UnassignDriverEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _unassignDriverUseCase.execute(event.busId);

      // Recargar el bus actualizado
      final updatedBus = await _getBusByIdUseCase.execute(event.busId);
      final updatedBuses = state.buses
          .map((bus) => bus.id == event.busId ? updatedBus : bus)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          buses: updatedBuses,
          filteredBuses: _applySearchFilter(updatedBuses, state.searchQuery),
          selectedBus: updatedBus,
          successMessage: 'Conductor desasignado exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error desasignando conductor: $e',
        ),
      );
    }
  }

  void _onSearchBuses(
    SearchBusesEvent event,
    Emitter<BusManagementState> emit,
  ) {
    final filteredBuses = _applySearchFilter(state.buses, event.query);
    emit(
      state.copyWith(searchQuery: event.query, filteredBuses: filteredBuses),
    );
  }

  Future<void> _onLoadBusesByRoute(
    LoadBusesByRouteEvent event,
    Emitter<BusManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final buses = await _getBusesByRouteUseCase.execute(event.routeId);
      emit(
        state.copyWith(isLoading: false, buses: buses, filteredBuses: buses),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error cargando buses por ruta: $e',
        ),
      );
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<BusManagementState> emit,
  ) {
    emit(state.copyWith(searchQuery: '', filteredBuses: state.buses));
  }

  List<BusEntity> _applySearchFilter(List<BusEntity> buses, String query) {
    if (query.isEmpty) return buses;

    final searchTerm = query.toLowerCase();
    return buses.where((bus) {
      return bus.licensePlate.toLowerCase().contains(searchTerm) ||
          bus.id.toLowerCase().contains(searchTerm) ||
          (bus.driverId?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();
  }
}
