import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackaton_app/features/admin_panel/presentation/pages/admin_dashboard_page.dart';
import 'package:hackaton_app/features/auth/presentation/pages/splash_page.dart';
import 'package:hackaton_app/features/auth/presentation/pages/login_page.dart';
import 'package:hackaton_app/features/auth/presentation/pages/signup_page.dart';
import 'package:hackaton_app/features/home/presentation/pages/home_page.dart';
import 'package:hackaton_app/features/transport/presentation/pages/transport_map_page.dart';
import 'package:hackaton_app/features/user/presentation/pages/admin_users_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/transport-map',
        name: 'transport-map',
        builder: (context, state) => const TransportMapPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: Ruta no encontrada ${state.error}')),
    ),
  );
}
