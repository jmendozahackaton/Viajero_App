import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackaton_app/data/repositories/user_repository_impl.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/domain/usecases/get_current_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/get_user_by_id_usecase.dart';
import 'package:hackaton_app/domain/usecases/create_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/update_user_usecase.dart';
import 'package:hackaton_app/domain/usecases/stream_user_usecase.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Proveedores de Firebase
    Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
    Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),

    // Repositorios
    Provider<UserRepository>(
      create: (context) => UserRepositoryImpl(
        firestore: context.read<FirebaseFirestore>(),
        auth: context.read<FirebaseAuth>(),
      ),
    ),

    // Casos de Uso
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
  ];
}
