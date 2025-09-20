// user_state.dart
part of 'user_bloc.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UsersLoadSuccess extends UserState {
  final List<UserEntity> users;

  UsersLoadSuccess(this.users);
}

final class UserOperationSuccess extends UserState {
  final String message;

  UserOperationSuccess(this.message);
}

final class UserError extends UserState {
  final String message;

  UserError(this.message);
}

final class UsersSearchSuccess extends UserState {
  final List<UserEntity> filteredUsers;

  UsersSearchSuccess(this.filteredUsers);
}
