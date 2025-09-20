// user_event.dart
part of 'user_bloc.dart';

sealed class UserEvent {}

final class UsersLoadRequested extends UserEvent {}

final class UserUpdateRequested extends UserEvent {
  final UserEntity user;

  UserUpdateRequested(this.user);
}

final class UserRoleChanged extends UserEvent {
  final String userId;
  final String newRole;

  UserRoleChanged(this.userId, this.newRole);
}

final class UserStatusChanged extends UserEvent {
  final String userId;
  final bool isActive;

  UserStatusChanged(this.userId, this.isActive);
}

final class UserDeleteRequested extends UserEvent {
  final String userId;

  UserDeleteRequested(this.userId);
}

final class UsersSearchRequested extends UserEvent {
  final String query;

  UsersSearchRequested(this.query);
}
