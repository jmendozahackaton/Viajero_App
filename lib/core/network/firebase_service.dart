import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/datasources/firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform, // Usa las opciones generadas
    );

    // Configurar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje en primer plano: ${message.notification?.title}');
    });

    // Solicitar permisos de notificación
    await FirebaseMessaging.instance.requestPermission();
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
}
