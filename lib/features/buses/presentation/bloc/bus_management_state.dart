part of 'bus_management_bloc.dart';

class BusManagementState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<BusEntity> buses;
  final BusEntity? selectedBus;
  final List<BusEntity> filteredBuses;
  final String searchQuery;
  final List<BusDriverEntity> availableDrivers;

  const BusManagementState({
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    required this.buses,
    this.selectedBus,
    required this.filteredBuses,
    required this.searchQuery,
    required this.availableDrivers,
  });

  factory BusManagementState.initial() {
    return const BusManagementState(
      isLoading: false,
      buses: [],
      filteredBuses: [],
      searchQuery: '',
      availableDrivers: [],
    );
  }

  BusManagementState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<BusEntity>? buses,
    BusEntity? selectedBus,
    List<BusEntity>? filteredBuses,
    String? searchQuery,
    List<BusDriverEntity>? availableDrivers,
  }) {
    return BusManagementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      buses: buses ?? this.buses,
      selectedBus: selectedBus ?? this.selectedBus,
      filteredBuses: filteredBuses ?? this.filteredBuses,
      searchQuery: searchQuery ?? this.searchQuery,
      availableDrivers: availableDrivers ?? this.availableDrivers,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    buses,
    selectedBus,
    filteredBuses,
    searchQuery,
    availableDrivers,
  ];
}
