// user_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';
import 'package:hackaton_app/features/user/presentation/bloc/user_bloc.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserEntity user;
  final UserBloc userBloc;

  const UserDetailsDialog({
    super.key,
    required this.user,
    required this.userBloc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detalles del Usuario'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nombre', user.displayName),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Rol', _getRoleText(user.userType)),
            _buildDetailRow('Estado', user.isActive ? 'Activo' : 'Inactivo'),
            _buildDetailRow('Teléfono', user.phoneNumber ?? 'No especificado'),
            _buildDetailRow('Creado', _formatDate(user.createdAt)),
            _buildDetailRow('Actualizado', _formatDate(user.updatedAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
          Divider(),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
