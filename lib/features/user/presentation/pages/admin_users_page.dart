// admin_users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackaton_app/domain/repositories/user_repository.dart';
import 'package:hackaton_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:hackaton_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:hackaton_app/features/user/presentation/pages/users_list_view.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated || authState.user.userType != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso Denegado')),
        body: const Center(
          child: Text('No tienes permisos para acceder a esta sección.'),
        ),
      );
    }
    return BlocProvider(
      create: (context) =>
          UserBloc(userRepository: context.read<UserRepository>())
            ..add(UsersLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración de Usuarios'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<UserBloc>().add(UsersLoadRequested());
              },
            ),
          ],
        ),
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final userBloc = context.read<UserBloc>();
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UsersLoadSuccess || state is UsersSearchSuccess) {
              final users = state is UsersLoadSuccess
                  ? state.users
                  : (state as UsersSearchSuccess).filteredUsers;

              return UsersListView(users: users, userBloc: userBloc);
            }

            return const Center(child: Text('No hay usuarios para mostrar'));
          },
        ),
      ),
    );
  }
}
