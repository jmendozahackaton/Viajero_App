// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';

import '../../../../domain/entities/user_entity.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<UsersLoadRequested>(_onUsersLoadRequested);
    on<UserUpdateRequested>(_onUserUpdateRequested);
    on<UserRoleChanged>(_onUserRoleChanged);
    on<UserStatusChanged>(_onUserStatusChanged);
    on<UserDeleteRequested>(_onUserDeleteRequested);
    on<UsersSearchRequested>(_onUsersSearchRequested);
  }

  Future<void> _onUsersLoadRequested(
    UsersLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      final users = await userRepository.getAllUsers();
      emit(UsersLoadSuccess(users));
    } catch (e) {
      emit(UserError('Error cargando usuarios: ${e.toString()}'));
    }
  }

  Future<void> _onUserUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await userRepository.updateUser(event.user);
      emit(UserOperationSuccess('Usuario actualizado exitosamente'));
      add(UsersLoadRequested()); // Recargar lista
    } catch (e) {
      emit(UserError('Error actualizando usuario: ${e.toString()}'));
    }
  }

  Future<void> _onUserRoleChanged(
    UserRoleChanged event,
    Emitter<UserState> emit,
  ) async {
    try {
      await userRepository.updateUserRole(event.userId, event.newRole);
      emit(UserOperationSuccess('Rol de usuario actualizado'));
      add(UsersLoadRequested());
    } catch (e) {
      emit(UserError('Error cambiando rol: ${e.toString()}'));
    }
  }

  Future<void> _onUserStatusChanged(
    UserStatusChanged event,
    Emitter<UserState> emit,
  ) async {
    try {
      await userRepository.updateUserStatus(event.userId, event.isActive);
      emit(
        UserOperationSuccess(
          event.isActive ? 'Usuario activado' : 'Usuario desactivado',
        ),
      );
      add(UsersLoadRequested());
    } catch (e) {
      emit(UserError('Error cambiando estado: ${e.toString()}'));
    }
  }

  Future<void> _onUserDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await userRepository.deleteUser(event.userId);
      emit(UserOperationSuccess('Usuario eliminado exitosamente'));
      add(UsersLoadRequested());
    } catch (e) {
      emit(UserError('Error eliminando usuario: ${e.toString()}'));
    }
  }

  Future<void> _onUsersSearchRequested(
    UsersSearchRequested event,
    Emitter<UserState> emit,
  ) async {
    if (state is UsersLoadSuccess) {
      final currentState = state as UsersLoadSuccess;
      final query = event.query.toLowerCase();

      final filteredUsers = currentState.users.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.displayName.toLowerCase().contains(query) ||
            user.userType.toLowerCase().contains(query);
      }).toList();

      emit(UsersSearchSuccess(filteredUsers));
    }
  }
}
