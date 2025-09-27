// admin_users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Viajeros/domain/repositories/user_repository.dart';
import 'package:Viajeros/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:Viajeros/features/user/presentation/bloc/user_bloc.dart';
import 'package:Viajeros/features/user/presentation/pages/users_list_view.dart';

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
      child: Builder(
        builder: (context) {
          final userBloc = context.read<UserBloc>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Administración de Usuarios'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/home');
                },
                tooltip: 'Regresar al inicio',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    userBloc.add(UsersLoadRequested());
                  },
                  tooltip: 'Actualizar lista',
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
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UsersLoadSuccess || state is UsersSearchSuccess) {
                  // ✅ Pasar el estado completo en lugar de solo la lista
                  return UsersListView(state: state, userBloc: userBloc);
                }

                if (state is UserError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                return const Center(
                  child: Text('No hay usuarios para mostrar'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
