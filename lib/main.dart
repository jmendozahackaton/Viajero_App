import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackaton_app/features/transport/data/mock_data/mock_transport_data.dart';
import 'package:hackaton_app/features/transport/data/services/bus_movement_service.dart';
import 'package:provider/provider.dart';
import 'package:hackaton_app/core/providers/app_providers.dart';
import 'package:hackaton_app/core/network/firebase_service.dart';
import 'package:hackaton_app/core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await FirebaseService.initialize();

  // ✅ TEMPORAL: Crear datos de prueba y simular movimiento
  const bool isDevelopment = true;
  if (isDevelopment) {
    try {
      final firestore = FirebaseFirestore.instance;

      // Crear datos de prueba
      final mockData = MockDataService(firestore);
      await mockData.createMockTransportData();
      print('✅ Datos de prueba creados exitosamente');

      // Iniciar simulación de movimiento
      final movementService = BusMovementService(firestore);
      movementService.startSimulatingBusMovements();
      print('✅ Simulación de movimiento iniciada');
    } catch (e) {
      print('⚠️ Error en configuración de desarrollo: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp.router(
        title: 'Viajero App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
