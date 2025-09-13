import 'package:flutter/material.dart';
import 'package:hackaton_app/core/widgets/dependency_test_widget.dart';
import 'package:provider/provider.dart';
import 'package:hackaton_app/core/providers/app_providers.dart';
import 'package:hackaton_app/core/network/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await FirebaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Viajero App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const DependencyTestWidget(), // ← Cambiar temporalmente
      ),
    );
  }
}
