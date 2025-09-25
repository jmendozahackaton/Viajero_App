import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hackaton_app/domain/entities/user_entity.dart';
import 'package:hackaton_app/features/auth/presentation/blocs/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _signOut(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          GoRouter.of(context).go('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final bool isAdmin = user.userType == 'admin';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Viajero App'),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                actions: [
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        GoRouter.of(context).go('/admin/dashboard');
                      },
                      tooltip: 'Panel de Administración',
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _signOut(context),
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del usuario
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido${isAdmin ? ' Administrador' : ''}!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Nombre: ${user.displayName.isNotEmpty ? user.displayName : 'Usuario'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Email: ${user.email}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Tipo: ${isAdmin ? 'Administrador' : 'Pasajero'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isAdmin ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Funcionalidades principales
                    Text(
                      isAdmin ? 'Panel de Control' : 'Funcionalidades',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        children: _getFeatureCards(context, isAdmin, user),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            Future.delayed(Duration.zero, () {
              GoRouter.of(context).go('/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  List<Widget> _getFeatureCards(
    BuildContext context,
    bool isAdmin,
    UserEntity user,
  ) {
    if (isAdmin) {
      return _getAdminFeatureCards(context);
    } else {
      return _getUserFeatureCards(context);
    }
  }

  List<Widget> _getAdminFeatureCards(BuildContext context) {
    return [
      _buildFeatureCard(
        icon: Icons.people,
        title: 'Gestión de Usuarios',
        color: Colors.purple,
        onTap: () {
          GoRouter.of(context).go('/admin/users');
        },
      ),
      _buildFeatureCard(
        icon: Icons.directions_bus,
        title: 'Gestión de Rutas',
        color: Colors.orange,
        onTap: () {
          GoRouter.of(context).go('/buses');
        },
      ),
      _buildFeatureCard(
        icon: Icons.map,
        title: 'Mapa de Rutas',
        color: Colors.blue,
        onTap: () {
          GoRouter.of(context).go('/transport-map');
        },
      ),
      _buildFeatureCard(
        icon: Icons.analytics,
        title: 'Estadísticas',
        color: Colors.green,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estadísticas en desarrollo')),
          );
        },
      ),
      _buildFeatureCard(
        icon: Icons.settings,
        title: 'Configuración',
        color: Colors.grey,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuración en desarrollo')),
          );
        },
      ),
      _buildFeatureCard(
        icon: Icons.notifications_active,
        title: 'Notificaciones Push',
        color: Colors.red,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificaciones push en desarrollo')),
          );
        },
      ),
    ];
  }

  List<Widget> _getUserFeatureCards(BuildContext context) {
    return [
      _buildFeatureCard(
        icon: Icons.map,
        title: 'Mapa de Rutas',
        color: Colors.blue,
        onTap: () {
          GoRouter.of(context).go('/transport-map');
        },
      ),
      _buildFeatureCard(
        icon: Icons.directions_bus,
        title: 'Planificador de Viaje',
        color: Colors.green,
        onTap: () {
          GoRouter.of(context).go('/trip-planner');
        },
      ),
      _buildFeatureCard(
        icon: Icons.schedule,
        title: 'Horarios',
        color: Colors.orange,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Horarios en desarrollo')),
          );
        },
      ),
      _buildFeatureCard(
        icon: Icons.notifications,
        title: 'Alertas',
        color: Colors.red,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alertas en desarrollo')),
          );
        },
      ),
      _buildFeatureCard(
        icon: Icons.person,
        title: 'Mi Perfil',
        color: Colors.purple,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Perfil en desarrollo')));
        },
      ),
      _buildFeatureCard(
        icon: Icons.history,
        title: 'Historial de Viajes',
        color: Colors.teal,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial en desarrollo')),
          );
        },
      ),
    ];
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
