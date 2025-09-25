part of 'bus_management_bloc.dart';

abstract class BusManagementEvent extends Equatable {
  const BusManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadBusesEvent extends BusManagementEvent {
  final bool activeOnly;

  const LoadBusesEvent({this.activeOnly = true});

  @override
  List<Object> get props => [activeOnly];
}

class LoadBusByIdEvent extends BusManagementEvent {
  final String busId;

  const LoadBusByIdEvent({required this.busId});

  @override
  List<Object> get props => [busId];
}

class CreateBusEvent extends BusManagementEvent {
  final BusEntity bus;

  const CreateBusEvent({required this.bus});

  @override
  List<Object> get props => [bus];
}

class UpdateBusEvent extends BusManagementEvent {
  final BusEntity bus;

  const UpdateBusEvent({required this.bus});

  @override
  List<Object> get props => [bus];
}

class DeleteBusEvent extends BusManagementEvent {
  final String busId;

  const DeleteBusEvent({required this.busId});

  @override
  List<Object> get props => [busId];
}

class AssignDriverEvent extends BusManagementEvent {
  final String busId;
  final String driverId;

  const AssignDriverEvent({required this.busId, required this.driverId});

  @override
  List<Object> get props => [busId, driverId];
}

class UnassignDriverEvent extends BusManagementEvent {
  final String busId;

  const UnassignDriverEvent({required this.busId});

  @override
  List<Object> get props => [busId];
}

class SearchBusesEvent extends BusManagementEvent {
  final String query;

  const SearchBusesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class LoadBusesByRouteEvent extends BusManagementEvent {
  final String routeId;

  const LoadBusesByRouteEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}

class ClearSearchEvent extends BusManagementEvent {}
