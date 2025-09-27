// edit_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:Viajeros/domain/entities/user_entity.dart';
import 'package:Viajeros/features/user/presentation/bloc/user_bloc.dart';

class EditUserDialog extends StatefulWidget {
  final UserEntity user;
  final UserBloc userBloc; // ← RECIBIR EL BLOC

  const EditUserDialog({super.key, required this.user, required this.userBloc});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _selectedRole = widget.user.userType;
    _isActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: [
                  DropdownMenuItem(value: 'passenger', child: Text('Pasajero')),
                  DropdownMenuItem(value: 'driver', child: Text('Conductor')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
                decoration: InputDecoration(labelText: 'Rol'),
              ),
              SwitchListTile(
                title: Text('Usuario Activo'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: Text('Guardar')),
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        displayName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
        userType: _selectedRole,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      widget.userBloc.add(
        UserUpdateRequested(updatedUser),
      ); // ← Usar el bloc recibido
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
