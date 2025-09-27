// lib/core/providers/app_providers.dart
import 'package:Viajeros/domain/usecases/sign_in_usecase.dart';
import 'package:Viajeros/domain/usecases/sign_up_usecase.dart';
import 'package:Viajeros/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:Viajeros/features/buses/data/repositories/bus_repository_impl.dart';
import 'package:Viajeros/features/buses/domain/repositories/bus_repository.dart';
import 'package:Viajeros/features/buses/domain/usecases/assign_driver_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/create_bus_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/delete_bus_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/get_bus_by_id_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/get_buses_by_route_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/get_buses_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/unassign_driver_usecase.dart';
import 'package:Viajeros/features/buses/domain/usecases/update_bus_usecase.dart';
import 'package:Viajeros/features/buses/presentation/bloc/bus_management_bloc.dart';
import 'package:Viajeros/features/trip_planner/domain/usecases/delete_trip_plan_usecase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Viajeros/data/repositories/user_repository_impl.dart';
import 'package:Viajeros/domain/repositories/user_repository.dart';

import 'package:Viajeros/domain/usecases/get_current_user_usecase.dart';
import 'package:Viajeros/domain/usecases/get_user_by_id_usecase.dart';
import 'package:Viajeros/domain/usecases/create_user_usecase.dart';
import 'package:Viajeros/domain/usecases/update_user_usecase.dart';
import 'package:Viajeros/domain/usecases/stream_user_usecase.dart';
import 'package:Viajeros/domain/repositories/auth_repository.dart';
import 'package:Viajeros/data/repositories/auth_repository_impl.dart';
import 'package:Viajeros/features/transport/domain/repositories/transport_repository.dart';
import 'package:Viajeros/features/transport/data/repositories/transport_repository_impl.dart';
import 'package:Viajeros/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// NUEVOS IMPORTS PARA TRIP PLANNER
import 'package:Viajeros/features/trip_planner/domain/repositories/trip_planner_repository.dart';
import 'package:Viajeros/features/trip_planner/data/repositories/trip_planner_repository_impl.dart';
import 'package:Viajeros/features/trip_planner/domain/usecases/plan_trip_usecase.dart';
import 'package:Viajeros/features/trip_planner/domain/usecases/save_trip_plan_usecase.dart';
import 'package:Viajeros/features/trip_planner/domain/usecases/get_saved_trips_usecase.dart';
import 'package:Viajeros/features/trip_planner/presentation/bloc/trip_planner_bloc.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // ========== PROVEEDORES DE FIREBASE (Primero) ==========
    Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
    Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),

    // ========== REPOSITORIOS (Segundo) ==========
    Provider<UserRepository>(
      create: (context) => UserRepositoryImpl(
        firestore: context.read<FirebaseFirestore>(),
        auth: context.read<FirebaseAuth>(),
      ),
    ),

    Provider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        auth: context.read<FirebaseAuth>(),
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),

    Provider<TransportRepository>(
      create: (context) =>
          TransportRepositoryImpl(firestore: context.read<FirebaseFirestore>()),
    ),

    // NUEVO: Repositorio de Trip Planner
    Provider<TripPlannerRepository>(
      create: (context) => TripPlannerRepositoryImpl(
        firestore: context.read<FirebaseFirestore>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    ),

    Provider<BusRepository>(
      create: (context) => BusRepositoryImpl(
        context.read<FirebaseFirestore>(),
        context.read<UserRepository>(),
      ),
    ),

    // ========== CASOS DE USO (Tercero - ¡ANTES de los Blocs!) ==========
    // Casos de Uso de Auth/User
    Provider<GetCurrentUserUseCase>(
      create: (context) =>
          GetCurrentUserUseCase(userRepository: context.read<UserRepository>()),
    ),
    Provider<GetUserByIdUseCase>(
      create: (context) =>
          GetUserByIdUseCase(userRepository: context.read<UserRepository>()),
    ),
    Provider<CreateUserUseCase>(
      create: (context) =>
          CreateUserUseCase(userRepository: context.read<UserRepository>()),
    ),
    Provider<UpdateUserUseCase>(
      create: (context) =>
          UpdateUserUseCase(userRepository: context.read<UserRepository>()),
    ),
    Provider<StreamUserUseCase>(
      create: (context) =>
          StreamUserUseCase(userRepository: context.read<UserRepository>()),
    ),
    Provider<SignInUseCase>(
      create: (context) =>
          SignInUseCase(authRepository: context.read<AuthRepository>()),
    ),
    Provider<SignUpUseCase>(
      create: (context) =>
          SignUpUseCase(authRepository: context.read<AuthRepository>()),
    ),

    // NUEVOS: Casos de Uso de Trip Planner (¡DEBEN estar ANTES del Bloc!)
    Provider<PlanTripUseCase>(
      create: (context) =>
          PlanTripUseCase(repository: context.read<TripPlannerRepository>()),
    ),
    Provider<DeleteTripPlanUseCase>(
      create: (context) => DeleteTripPlanUseCase(
        repository: context.read<TripPlannerRepository>(),
      ),
    ),
    Provider<SaveTripPlanUseCase>(
      create: (context) => SaveTripPlanUseCase(
        repository: context.read<TripPlannerRepository>(),
      ),
    ),
    Provider<GetSavedTripsUseCase>(
      create: (context) => GetSavedTripsUseCase(
        repository: context.read<TripPlannerRepository>(),
      ),
    ),

    // Casos de uso de buses
    Provider<GetBusesUseCase>(
      create: (context) => GetBusesUseCase(context.read<BusRepository>()),
    ),
    Provider<GetBusByIdUseCase>(
      create: (context) => GetBusByIdUseCase(context.read<BusRepository>()),
    ),
    Provider<CreateBusUseCase>(
      create: (context) => CreateBusUseCase(context.read<BusRepository>()),
    ),
    Provider<UpdateBusUseCase>(
      create: (context) => UpdateBusUseCase(context.read<BusRepository>()),
    ),
    Provider<DeleteBusUseCase>(
      create: (context) => DeleteBusUseCase(context.read<BusRepository>()),
    ),
    Provider<GetBusesByRouteUseCase>(
      create: (context) =>
          GetBusesByRouteUseCase(context.read<BusRepository>()),
    ),
    Provider<AssignDriverUseCase>(
      create: (context) => AssignDriverUseCase(
        context.read<BusRepository>(),
        context.read<UserRepository>(),
      ),
    ),
    Provider<UnassignDriverUseCase>(
      create: (context) => UnassignDriverUseCase(context.read<BusRepository>()),
    ),

    // ========== BLOCS (Cuarto - ÚLTIMO) ==========
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: context.read<AuthRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(AuthCheckRequested()),
    ),

    BlocProvider<TransportBloc>(
      create: (context) => TransportBloc(
        transportRepository: context.read<TransportRepository>(),
      ),
    ),

    // NUEVO: Bloc de Trip Planner (¡DEBE estar DESPUÉS de los casos de uso!)
    BlocProvider<TripPlannerBloc>(
      create: (context) => TripPlannerBloc(
        planTripUseCase: context.read<PlanTripUseCase>(),
        saveTripPlanUseCase: context.read<SaveTripPlanUseCase>(),
        getSavedTripsUseCase: context.read<GetSavedTripsUseCase>(),
        deleteTripPlanUseCase: context
            .read<DeleteTripPlanUseCase>(), // ← AGREGAR
      ),
    ),

    // BLoC de buses
    BlocProvider<BusManagementBloc>(
      create: (context) => BusManagementBloc(
        getBusesUseCase: context.read<GetBusesUseCase>(),
        getBusByIdUseCase: context.read<GetBusByIdUseCase>(),
        createBusUseCase: context.read<CreateBusUseCase>(),
        updateBusUseCase: context.read<UpdateBusUseCase>(),
        deleteBusUseCase: context.read<DeleteBusUseCase>(),
        getBusesByRouteUseCase: context.read<GetBusesByRouteUseCase>(),
        assignDriverUseCase: context.read<AssignDriverUseCase>(),
        unassignDriverUseCase: context.read<UnassignDriverUseCase>(),
      ),
    ),
  ];
}
