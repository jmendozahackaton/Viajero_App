import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '/services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? usuarioEditar;

  const UserFormScreen({super.key, this.usuarioEditar});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  String _rol = "Pasajero";
  bool _activo = true;
  bool _guardando = false;

  final List<String> roles = ["Pasajero", "Conductor", "IRTRAMMA", "Admin"];
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  @override
  void initState() {
    super.initState();
    // Si estamos editando, cargar datos existentes
    if (widget.usuarioEditar != null) {
      _nombreController.text = widget.usuarioEditar!.nombre;
      _emailController.text = widget.usuarioEditar!.email;
      _rol = widget.usuarioEditar!.rol;
      _activo = widget.usuarioEditar!.activo;
    }
  }

  Future<void> _guardarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _guardando = true);

      try {
        final user = UserModel(
          userId: widget.usuarioEditar?.userId ?? _generateUserId(),
          email: _emailController.text.trim(),
          nombre: _nombreController.text.trim(),
          rol: _rol,
          activo: _activo,
        );

        await _userService.saveUser(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.usuarioEditar == null
                    ? "Usuario creado exitosamente"
                    : "Usuario actualizado exitosamente",
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _guardando = false);
        }
      }
    }
  }

  String _generateUserId() {
    return "UID${DateTime.now().microsecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.usuarioEditar == null ? "Nuevo Usuario" : "Editar Usuario",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese el nombre" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese el correo";
                  }
                  if (!_emailRegex.hasMatch(value)) {
                    return "Ingrese un correo válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(
                  labelText: "Rol",
                  border: OutlineInputBorder(),
                ),
                items: roles
                    .map(
                      (rol) => DropdownMenuItem(value: rol, child: Text(rol)),
                    )
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (value) {
                        setState(() {
                          _rol = value!;
                        });
                      },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Activo"),
                value: _activo,
                onChanged: _guardando
                    ? null
                    : (value) {
                        setState(() {
                          _activo = value;
                        });
                      },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarUsuario,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando
                      ? "Guardando..."
                      : widget.usuarioEditar == null
                      ? "Guardar Usuario"
                      : "Actualizar Usuario",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
