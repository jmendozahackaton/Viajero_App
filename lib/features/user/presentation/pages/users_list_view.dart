// users_list_view.dart
import 'package:flutter/material.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';
import 'package:hackaton_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:hackaton_app/features/user/presentation/pages/user_list_tile.dart';

class UsersListView extends StatelessWidget {
  final List<UserEntity> users;
  final UserBloc userBloc; // ← RECIBIR EL BLOC

  const UsersListView({super.key, required this.users, required this.userBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              userBloc.add(UsersSearchRequested(query));
            },
          ),
        ),

        // Lista de usuarios
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(user: user, userBloc: userBloc);
            },
          ),
        ),
      ],
    );
  }
}
