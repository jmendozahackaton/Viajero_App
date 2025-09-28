# 🚌 Viajero App - Sistema de Monitoreo de Transporte Público

[![Flutter](https://img.shields.io/badge/Flutter-3.19-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3-blue.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-11.0-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Solución innovadora para mejorar la eficiencia, seguridad y transparencia del sistema de transporte público en tiempo real.**

---

## 📖 Tabla de Contenidos

- [🎯 Descripción del Proyecto](#-descripción-del-proyecto)
- [✨ Características Principales](#-características-principales)
- [🏗️ Arquitectura del Sistema](#️-arquitectura-del-sistema)
- [🚀 Comenzando](#-comenzando)
  - [Prerrequisitos](#prerrequisitos)
  - [Instalación](#instalación)
  - [Configuración Firebase](#configuración-firebase)
- [📱 Funcionalidades](#-funcionalidades)
- [🛠️ Tecnologías Utilizadas](#️-tecnologías-utilizadas)
- [🏛️ Estructura del Proyecto](#️-estructura-del-proyecto)
- [👥 Roles de Usuario](#-roles-de-usuario)
- [🔧 Desarrollo](#-desarrollo)
- [📊 Estado del Proyecto](#-estado-del-proyecto)
- [🤝 Contribución](#-contribución)
- [📄 Licencia](#-licencia)

---

## 🎯 Descripción del Proyecto

**Viajero App** es una solución integral desarrollada para el **Hackathon Nicaragua 2025** bajo la temática **"Disruptivo 2025"**. La aplicación aborda los desafíos del transporte público mediante tecnología innovadora que beneficia tanto a usuarios como a autoridades reguladoras.

### 🎪 Contexto del Reto
- **Problema**: Ineficiencia en sistemas de transporte público, falta de información en tiempo real para usuarios y limitadas herramientas de monitoreo para autoridades.
- **Solución**: Plataforma móvil que proporciona monitoreo en tiempo real, planificación inteligente de viajes y gestión administrativa completa.

---

## ✨ Características Principales

### 👤 Para Usuarios (Pasajeros)
- 🗺️ **Mapa Interactivo** en tiempo real con rutas, buses y paradas
- ⏱️ **Tiempos de Llegada Estimados** (ETA) precisos
- 🚏 **Planificador de Viajes** inteligente con múltiples opciones
- 🔔 **Notificaciones Push** de buses cercanos y alertas
- 📍 **Geolocalización** automática y búsqueda de paradas cercanas
- 💰 **Cálculo de Tarifas** y comparación de opciones

### 👨💼 Para Administradores (IRTRAMMA)
- 📊 **Dashboard** de monitoreo en tiempo real
- 🚌 **Gestión Completa de Flota** (CRUD de buses y conductores)
- 🛣️ **Administración de Rutas** y paradas
- 👥 **Gestión de Usuarios** y roles
- 📈 **Reportes Analíticos** y KPIs de operación
- 🔄 **Actualizaciones en Tiempo Real** de ubicaciones

---

## 🏗️ Arquitectura del Sistema

### 🏛️ Clean Architecture Implementada

lib/
├── core/ # Componentes transversales
│ ├── constants/ # Constantes de la aplicación
│ ├── routes/ # Navegación (GoRouter)
│ ├── providers/ # Inyección de dependencias
│ └── utils/ # Utilidades compartidas
├── domain/ # Lógica de negocio
│ ├── entities/ # Entidades de dominio
│ ├── repositories/# Contratos abstractos
│ └── usecases/ # Casos de uso específicos
├── data/ # Acceso a datos
│ ├── models/ # Modelos de datos
│ └── repositories/# Implementación de repositorios
└── features/ # Características específicas
├── auth/ # Autenticación
├── buses/ # Gestión de buses
├── routes/ # Gestión de rutas
├── trips/ # Planificación de viajes
└── admin/ # Panel administrativo

### 🔄 Flujo de Datos
1. **Presentación** → Widgets y BLoC
2. **Dominio** → Casos de uso y entidades
3. **Datos** → Repositorios y modelos
4. **Infraestructura** → Firebase Firestore/Auth

---

## 🚀 Comenzando

### Prerrequisitos
- **Flutter SDK** ≥ 3.19.0
- **Dart** ≥ 3.3.0
- **Android Studio** o **VS Code**
- **Dispositivo Android/iOS** o emulador
- **Cuenta Firebase** con proyecto configurado

### Instalación

1. **Clonar el repositorio**
git clone https://github.com/jmendozahackaton/Viajero_App.git
cd Viajero_App

2. Instalar dependencias

flutter pub get

3. Configurar variables de entorno

cp .env.example .env

### Editar .env con tus configuraciones de Firebase
Ejecutar la aplicación

flutter run

Configuración Firebase

Crear proyecto en Firebase Console

Habilitar Authentication y Firestore


Descargar archivos de configuración:

google-services.json (Android)

GoogleService-Info.plist (iOS)

Colocar archivos en las carpetas correspondientes

Configurar reglas de seguridad en Firestore

## 📱 Funcionalidades
Módulo de Autenticación

✅ Registro de usuarios con email/contraseña

✅ Login seguro con Firebase Auth

✅ Gestión de sesiones persistentes

✅ Recuperación de contraseñas


Módulo de Mapas y Geolocalización

✅ Mapa interactivo con Google Maps

✅ Marcadores de buses en tiempo real

✅ Paradas de buses georreferenciadas

✅ Rutas visualizadas con polilíneas


Módulo de Planificación de Viajes

✅ Algoritmo inteligente de matching de rutas

✅ Cálculo de distancias y tiempos optimizados

✅ Múltiples criterios de preferencia

✅ Historial de viajes guardados


Módulo Administrativo

✅ CRUD completo de buses y rutas

✅ Gestión de usuarios y permisos

✅ Dashboard con métricas en tiempo real

✅ Sistema de reportes automáticos

## 🛠️ Tecnologías Utilizadas
Frontend

Flutter 3.19 - Framework principal

Dart 3.3 - Lenguaje de programación

BLoC Pattern - Gestión de estado

GoRouter - Navegación declarativa


Backend & Base de Datos

Firebase Firestore - Base de datos NoSQL

Firebase Authentication - Autenticación segura

Cloud Functions - Lógica de backend (opcional)


APIs y Servicios

Google Maps SDK - Mapas y geolocalización

Geolocator - Servicios de ubicación

OneSignal - Notificaciones push

Desarrollo y Calidad

Provider - Inyección de dependencias

Equatable - Comparación de objetos

Mockito - Testing unitario

## 🏛️ Estructura del Proyecto

lib/
├── core/
│   ├── constants/      # AppConstants, RouteNames
│   ├── routes/         # AppRouter, RouteGuard
│   ├── providers/      # Dependency Injection
│   ├── utils/          # Helpers, Validators
│   └── widgets/        # Componentes reutilizables
├── domain/
│   ├── entities/       # UserEntity, BusEntity, RouteEntity
│   ├── repositories/   # Abstract repos
│   └── usecases/       # Business logic
├── data/
│   ├── models/         # Data models
│   └── repositories/   # Concrete implementations
└── features/
    ├── auth/           # Authentication flow
    ├── buses/          # Bus management
    ├── routes/         # Route management
    ├── trips/          # Trip planning
    ├── admin/          # Admin dashboard
    └── map/            # Interactive map

## 👥 Roles de Usuario
👤 Pasajero (Usuario Regular)

Consultar rutas y horarios

Planificar viajes

Recibir notificaciones

Ver buses en tiempo real

## 🚗 Conductor (Usuario Privilegiado)
Actualizar ubicación en tiempo real

Gestionar estado del bus

Recibir alertas de ruta

## 👨💼 Administrador (IRTRAMMA)
Gestión completa del sistema

Monitoreo en tiempo real

Generación de reportes

Administración de usuarios

🔧 Desarrollo

Comandos útiles

# Ejecutar en modo desarrollo
flutter run

# Generar APK de release
flutter build apk --release

# Ejecutar tests
flutter test

# Generar análisis de código
flutter analyze

# Formatear código
dart format .

Configuración de entorno de desarrollo

VS Code con extensiones Flutter y Dart

Android Studio con emulador configurado

Git para control de versiones

Firebase CLI para despliegues

## 📊 Estado del Proyecto
✅ Completado

Arquitectura Clean Architecture + BLoC

Autenticación completa con Firebase

Mapa interactivo con Google Maps

Sistema de planificación de viajes

CRUD completo de buses y rutas

Notificaciones en tiempo real

Dashboard administrativo

## 🚧 En Desarrollo
Optimización de performance

Tests unitarios completos

Documentación avanzada

## 📋 Próximas Features
Integración con APIs de transporte real

Modo offline con sincronización

Análisis predictivo de rutas

Sistema de pagos integrado

## 🤝 Contribución
¡Las contribuciones son bienvenidas! Para contribuir:

Fork el proyecto

Crea una rama para tu feature (git checkout -b feature/AmazingFeature)

Commit tus cambios (git commit -m 'Add some AmazingFeature')

Push a la rama (git push origin feature/AmazingFeature)

Abre un Pull Request

Guías de contribución

Sigue el patrón de código establecido

Mantén la cobertura de tests

Documenta nuevas funcionalidades

Usa mensajes de commit descriptivos

## 📄 Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para más detalles.

## 👨‍💻 Desarrollado por
Equipo Viajero App - Hackathon Nicaragua 2025

INNOVATION TEAMS

📧 Contacto: jmendozahackaton

## 🙏 Agradecimientos
Hackathon Nicaragua 2025 por la oportunidad

Comunidad Flutter por el apoyo y recursos

Firebase Google por la infraestructura

Contribuidores que han apoyado el proyecto



<div align="center">
🚀 ¡Viajero App - Transformando el transporte público!
</div> ```