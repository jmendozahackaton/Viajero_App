// user_list_tile.dart
import 'package:flutter/material.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';
import 'package:hackaton_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:hackaton_app/features/user/presentation/pages/edit_user_dialog.dart';
import 'package:hackaton_app/features/user/presentation/pages/user_details_dialog.dart';

class UserListTile extends StatelessWidget {
  final UserEntity user;
  final UserBloc userBloc; // ← RECIBIR EL BLOC

  const UserListTile({super.key, required this.user, required this.userBloc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null ? Icon(Icons.person) : null,
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('Rol: ${_getRoleText(user.userType)}'),
            Text('Estado: ${user.isActive ? 'Activo' : 'Inactivo'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(value, context, userBloc),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(
              value: 'toggle_status',
              child: Text(user.isActive ? 'Desactivar' : 'Activar'),
            ),
            if (user.userType != 'admin')
              PopupMenuItem(value: 'make_admin', child: Text('Hacer Admin')),
            if (user.userType == 'admin')
              PopupMenuItem(
                value: 'make_passenger',
                child: Text('Hacer Pasajero'),
              ),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: () => _showUserDetails(context, user, userBloc),
      ),
    );
  }

  String _getRoleText(String userType) {
    switch (userType) {
      case 'admin':
        return 'Administrador';
      case 'driver':
        return 'Conductor';
      default:
        return 'Pasajero';
    }
  }

  void _handleMenuSelection(
    String value,
    BuildContext context,
    UserBloc userBloc,
  ) {
    switch (value) {
      case 'edit':
        _showEditUserDialog(context, user, userBloc); // ← Pasar bloc
        break;
      case 'toggle_status':
        _toggleUserStatus(context, userBloc); // ← Pasar bloc
        break;
      case 'make_admin':
        _changeUserRole(context, 'admin', userBloc); // ← Pasar bloc
        break;
      case 'make_passenger':
        _changeUserRole(context, 'passenger', userBloc); // ← Pasar bloc
        break;
      case 'delete':
        _showDeleteConfirmation(context, userBloc); // ← Pasar bloc
        break;
    }
  }

  void _toggleUserStatus(BuildContext context, UserBloc userBloc) {
    userBloc.add(
      UserStatusChanged(user.uid, !user.isActive),
    ); // ← Usar el bloc recibido
  }

  void _changeUserRole(
    BuildContext context,
    String newRole,
    UserBloc userBloc,
  ) {
    userBloc.add(UserRoleChanged(user.uid, newRole)); // ← Usar el bloc recibido
  }

  void _showDeleteConfirmation(BuildContext context, UserBloc userBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar a ${user.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                userBloc.add(
                  UserDeleteRequested(user.uid),
                ); // ← Usar el bloc recibido
                Navigator.pop(context);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    UserEntity user,
    UserBloc userBloc,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          EditUserDialog(user: user, userBloc: userBloc), // ← Pasar bloc
    );
  }

  void _showUserDetails(
    BuildContext context,
    UserEntity user,
    UserBloc userBloc,
  ) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user, userBloc: userBloc),
    );
  }
}
