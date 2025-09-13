# Modelado de Base de Datos - Viajero App

## Estructura de Colecciones
### 1. users - Gestión de usuarios y permisos
### 2. routes - Definición de rutas de transporte  
### 3. vehicles - Unidades en operación
### 4. stops - Puntos de parada
### 5. trips - Historial de viajes
### 6. reports - Reportes e incidencias
### 7. notifications - Comunicaciones del sistema

## Relaciones y Flujos
[Diagrama de relaciones entre colecciones]

## Reglas de Seguridad
- Autenticación requerida para escritura
- Roles diferenciados (usuario/admin)
- Validación de datos en escritura

## Optimizaciones
- Índices geospaciales para consultas de ubicación
- Índices compuestos para consultas frecuentes
- Estructura denormalizada para performance

## Flujo de Datos en Tiempo Real
- Actualizaciones de ubicación cada 15-30 segundos
- Notificaciones push para eventos críticos
- Sincronización offline para datos esenciales


users ────────────────────── trips
  │                           │
  │                          routes
  │                           │
vehicles ──────────────────── stops
  │                           │
reports ───────────────────── notifications



// Documento: user_{uid}
{
  uid: string,           // ID único de Firebase Auth
  email: string,         // Correo electrónico
  displayName: string,   // Nombre completo
  userType: string,      // 'passenger' o 'admin'
  phoneNumber: string,   // Teléfono (opcional)
  photoURL: string,      // URL de foto (opcional)
  createdAt: timestamp,  // Fecha de creación
  updatedAt: timestamp,  // Fecha de última actualización
  fcmToken: string,      // Token para notificaciones
  preferences: {
    notifications: boolean, // Preferencia de notificaciones
    darkMode: boolean,      // Modo oscuro
    language: string        // Idioma preferido
  }
}

// Documento: route_{id}
{
  id: string,                   // ID único de la ruta
  name: string,                 // Nombre de la ruta (ej: "Ruta 101")
  description: string,          // Descripción detallada
  origin: string,               // Punto de origen
  destination: string,          // Punto de destino
  coordinates: array,           // [{lat: number, lng: number}] - Coordenadas del trazado
  stops: array,                 // [stop_id1, stop_id2, ...] - Paradas en orden
  estimatedTime: number,        // Tiempo estimado en minutos
  distance: number,             // Distancia en km
  fare: number,                 // Tarifa base
  operatingHours: {
    start: string,              // Hora de inicio (ej: "05:00")
    end: string,                // Hora de fin (ej: "22:00")
    frequency: number           // Frecuencia en minutos
  },
  isActive: boolean,            // Ruta activa/inactiva
  createdAt: timestamp,
  updatedAt: timestamp
}

// Documento: vehicle_{id}
{
  id: string,                   // ID único del vehículo
  routeId: string,              // ID de la ruta asignada
  licensePlate: string,         // Placa del vehículo
  driverId: string,             // ID del conductor (reference to users)
  capacity: number,             // Capacidad de pasajeros
  currentLocation: geopoint,    // Ubicación actual
  lastUpdate: timestamp,        // Última actualización de ubicación
  status: string,               // 'active', 'inactive', 'maintenance'
  speed: number,                // Velocidad actual km/h
  direction: number,            // Dirección en grados
  occupancy: number,            // Pasajeros actuales
  nextStop: string,             // Próxima parada (stop_id)
  estimatedArrival: number,     // Tiempo estimado a próxima parada (min)
  isActive: boolean,
  createdAt: timestamp
}

// Documento: stop_{id}
{
  id: string,                   // ID único de la parada
  name: string,                 // Nombre de la parada
  location: geopoint,           // Coordenadas de la parada
  address: string,              // Dirección física
  description: string,          // Descripción adicional
  routes: array,                // [route_id1, route_id2] - Rutas que pasan aquí
  amenities: array,             // ['shelter', 'seating', 'lighting']
  isActive: boolean,
  createdAt: timestamp
}

// Documento: trip_{id}
{
  id: string,                   // ID único del viaje
  userId: string,               // ID del usuario
  routeId: string,              // ID de la ruta
  vehicleId: string,            // ID del vehículo
  startStop: string,            // Parada de inicio
  endStop: string,              // Parada de destino
  startTime: timestamp,         // Hora de inicio
  endTime: timestamp,           // Hora de fin
  estimatedDuration: number,    // Duración estimada (min)
  actualDuration: number,       // Duración real (min)
  status: string,               // 'planned', 'in_progress', 'completed', 'cancelled'
  fare: number,                 // Tarifa pagada
  rating: number,               // Calificación 1-5
  feedback: string,             // Comentarios del usuario
  createdAt: timestamp
}

// Documento: report_{id}
{
  id: string,                   // ID único del reporte
  userId: string,               // ID del usuario que reporta
  type: string,                 // 'delay', 'breakdown', 'safety', 'other'
  vehicleId: string,            // ID del vehículo (si aplica)
  routeId: string,              // ID de la ruta (si aplica)
  location: geopoint,           // Ubicación del incidente
  description: string,          // Descripción detallada
  severity: string,             // 'low', 'medium', 'high', 'critical'
  status: string,               // 'pending', 'in_review', 'resolved'
  images: array,                // URLs de imágenes [url1, url2]
  createdAt: timestamp,
  updatedAt: timestamp,
  resolvedAt: timestamp         // Fecha de resolución
}

// Documento: notification_{id}
{
  id: string,                   // ID único de notificación
  title: string,                // Título de la notificación
  message: string,              // Mensaje detallado
  type: string,                 // 'alert', 'update', 'promotion'
  targetUsers: string,          // 'all', 'specific_route', 'specific_user'
  targetRoute: string,          // ID de ruta (si aplica)
  targetUser: string,           // ID de usuario (si aplica)
  sentAt: timestamp,            // Fecha de envío
  readBy: array,                // [user_id1, user_id2] - Usuarios que leyeron
  createdAt: timestamp
}


// Para consultas eficientes
- routes/coordinates: Geospatial index
- vehicles/currentLocation: Geospatial index  
- stops/location: Geospatial index
- trips/status+startTime: Composite index
- reports/type+status: Composite index