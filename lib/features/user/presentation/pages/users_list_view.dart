// users_list_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';
import 'package:Viajeros/features/user/presentation/bloc/user_bloc.dart';
import 'package:Viajeros/features/user/presentation/pages/user_list_tile.dart';

class UsersListView extends StatefulWidget {
  final UserState state;
  final UserBloc userBloc;

  const UsersListView({super.key, required this.state, required this.userBloc});

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Inicializar el texto de búsqueda si ya hay un estado de búsqueda
    if (widget.state is UsersSearchSuccess) {
      // Puedes mantener esto o dejarlo vacío dependiendo de tu lógica
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();

    // Configurar un nuevo timer con debounce de 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.userBloc.add(UsersSearchRequested(query));
    });
  }

  @override
  void didUpdateWidget(UsersListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el estado cambió de búsqueda a lista completa, limpiar el campo de búsqueda
    if (widget.state is UsersLoadSuccess &&
        oldWidget.state is UsersSearchSuccess) {
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<UserEntity> usersToShow = [];
    String currentSearchQuery = '';

    if (widget.state is UsersLoadSuccess) {
      usersToShow = (widget.state as UsersLoadSuccess).users;
    } else if (widget.state is UsersSearchSuccess) {
      final searchState = widget.state as UsersSearchSuccess;
      usersToShow = searchState.filteredUsers;
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, email o tipo...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.userBloc.add(UsersSearchRequested(''));
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // Indicador de carga durante búsqueda (opcional)
        if (widget.state is UserLoading) const LinearProgressIndicator(),

        // Lista de usuarios
        Expanded(
          child: usersToShow.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: usersToShow.length,
                  itemBuilder: (context, index) {
                    final user = usersToShow[index];
                    return UserListTile(user: user, userBloc: widget.userBloc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (widget.state is UsersSearchSuccess &&
        (widget.state as UsersSearchSuccess).filteredUsers.isEmpty) {
      return const Center(
        child: Text('No se encontraron usuarios con esos criterios'),
      );
    } else {
      return const Center(child: Text('No hay usuarios para mostrar'));
    }
  }
}
