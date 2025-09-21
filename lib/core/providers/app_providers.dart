// lib/core/providers/app_providers.dart
import 'package:hackaton_app/domain/usecases/sign_in_usecase.dart';
import 'package:hackaton_app/domain/usecases/sign_up_usecase.dart';
import 'package:hackaton_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackaton_app/data/repositories/user_repository_impl.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';

import 'package:hackaton_app/domain/usecases/get_current_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/get_user_by_id_usecase.dart';
import 'package:hackaton_app/domain/usecases/create_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/update_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/stream_user_usecase.dart';
import 'package:hackaton_app/domain/repositories/auth_repository.dart';
import 'package:hackaton_app/data/repositories/auth_repository_impl.dart';
import 'package:hackaton_app/features/transport/domain/repositories/transport_repository.dart';
import 'package:hackaton_app/features/transport/data/repositories/transport_repository_impl.dart';
import 'package:hackaton_app/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// NUEVOS IMPORTS PARA TRIP PLANNER
import 'package:hackaton_app/features/trip_planner/domain/repositories/trip_planner_repository.dart';
import 'package:hackaton_app/features/trip_planner/data/repositories/trip_planner_repository_impl.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/plan_trip_usecase.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/save_trip_plan_usecase.dart';
import 'package:hackaton_app/features/trip_planner/domain/usecases/get_saved_trips_usecase.dart';
import 'package:hackaton_app/features/trip_planner/presentation/bloc/trip_planner_bloc.dart';

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
      ),
    ),
  ];
}
