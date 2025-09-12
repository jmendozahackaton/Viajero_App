import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackaton_app/data/datasources/firebase_options.dart';
import 'package:hackaton_app/core/network/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viajero App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(child: Text('Viajero App - Configuración exitosa!')),
      ),
    );
  }
}
