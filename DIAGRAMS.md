## 📊 Diagramas de Flujo del Sistema

### 🔐 Flujo de Autenticación de Usuario
```mermaid
flowchart TD
    A[Inicio App] --> B[Splash Screen]
    B --> C{¿Usuario autenticado?}
    
    C -->|Sí| D[Home Page]
    C -->|No| E[Login Page]
    
    E --> F[Ingresar Credenciales]
    F --> G{Validar en Firebase Auth}
    
    G -->|Éxito| H[Obtener datos usuario Firestore]
    H --> I[Guardar Device Token]
    I --> D
    
    G -->|Error| J[Mostrar Error]
    J --> E
    
    D --> K{¿Rol de usuario?}
    K -->|Pasajero| L[Dashboard Usuario]
    K -->|Conductor| M[Dashboard Conductor]
    K -->|Administrador| N[Dashboard Admin]
    
    L --> O[Mapa Tiempo Real]
    M --> P[Gestión de Bus]
    N --> Q[Panel Administrativo]

    
### 🗺️ Flujo de Planificación de Viajes
```mermaid
flowchart TD
    A[Usuario selecciona Planificar Viaje] --> B[Ingresar Origen/Destino]
    B --> C[Geolocalizar o Mapa]
    C --> D[Buscar paradas cercanas<br>Radio 500m]
    
    D --> E[Encontrar rutas que conecten<br>paradas origen/destino]
    E --> F{Aplicar algoritmo<br>de matching}
    
    F --> G[Calcular métricas<br>Distancia, Tiempo, Costo]
    G --> H{Filtrar por<br>preferencias usuario}
    
    H --> I[Generar opciones de viaje]
    I --> J{¿Encontró rutas?}
    
    J -->|Sí| K[Mostrar opciones<br>ordenadas por preferencia]
    J -->|No| L[Mostrar mensaje<br>sin rutas disponibles]
    
    K --> M[Usuario selecciona opción]
    M --> N[Mostrar detalles completos<br>y mapa de ruta]
    N --> O[Opción guardar viaje]
    O --> P[Persistir en Firestore]


### 📍 Flujo de Monitoreo en Tiempo Real
```mermaid
flowchart LR
    A[Bus en Movimiento] --> B[Actualizar GPS cada 10s]
    B --> C[Firestore: Update Location]
    
    subgraph Firebase Firestore
        C --> D[Documento Bus<br>currentLocation]
    end
    
    subgraph App Usuario
        E[StreamListener<br>Buses Collection] --> F[Nuevo Snapshot]
        F --> G[Procesar cambios<br>en tiempo real]
        G --> H[Actualizar marcadores<br>en mapa]
        H --> I[Recalcular ETAs]
    end
    
    D --> E
    
    I --> J[Notificaciones Push<br>si bus cercano]
    J --> K[UI Reactiva<br>actualiza interfaz]


⚙️ Flujo CRUD Administrativo - Gestión de Buses
```mermaid
flowchart TD
    A[Admin: Gestión de Buses] --> B{Acción a realizar}
    
    B -->|Crear| C[Formulario Nuevo Bus]
    C --> D[Validar datos<br>Placa única, campos requeridos]
    D --> E{Validación exitosa?}
    E -->|Sí| F[Crear en Firestore]
    E -->|No| G[Mostrar errores]
    G --> C
    
    B -->|Editar| H[Lista Buses Existente]
    H --> I[Seleccionar Bus]
    I --> J[Cargar datos en formulario]
    J --> K[Validar y Actualizar]
    K --> L[Update Firestore]
    
    B -->|Eliminar| M[Lista Buses Existente]
    M --> N[Seleccionar Bus]
    N --> O[Confirmar eliminación]
    O --> P{¿Confirmado?}
    P -->|Sí| Q[Soft Delete<br>isActive: false]
    P -->|No| M
    
    F --> R[Actualizar UI<br>y mostrar confirmación]
    L --> R
    Q --> R


🔔 Flujo de Notificaciones Push
```mermaid
flowchart TD
    A[Evento disparador] --> B{¿Tipo de evento?}
    
    B -->|Bus Cercano| C[Calcular distancia<br>usuario-parada]
    C --> D{¿Distancia < 300m?}
    D -->|Sí| E[Generar notificación<br>'Bus aproximándose']
    D -->|No| F[No notificar]
    
    B -->|ETA Cambio| G[Recalcular tiempo llegada]
    G --> H{¿Cambio > 2 minutos?}
    H -->|Sí| I[Notificar nuevo ETA]
    H -->|No| J[Actualizar silenciosamente]
    
    B -->|Alerta Admin| K[Evento administrativo<br>Bus inactivo, etc.]
    K --> L[Notificar a administradores]
    
    E --> M[OneSignal/FCM]
    I --> M
    L --> M
    
    M --> N[Dispositivo Usuario]
    N --> O{Abrir notificación?}
    O -->|Sí| P[Navegar a app<br>pantalla relevante]
    O -->|No| Q[Notificación en bandeja]


🏗️ Arquitectura General del Sistema
```mermaid
graph TB
    subgraph Capa de Presentación
        A[Flutter UI Widgets] --> B[BLoC Pattern]
        B --> C[Eventos]
        B --> D[Estados]
    end
    
    subgraph Capa de Dominio
        E[Casos de Uso] --> F[Entidades]
        E --> G[Repositorios Interfaces]
    end
    
    subgraph Capa de Datos
        H[Repositorios Implementados] --> I[Modelos de Datos]
        H --> J[Firebase APIs]
    end
    
    subgraph Infraestructura
        K[Firebase Firestore] --> L[Base de Datos NoSQL]
        M[Firebase Auth] --> N[Autenticación]
        O[Google Maps] --> P[Servicios de Mapas]
    end
    
    C --> E
    D --> A
    F --> B
    G --> H
    I --> K
    J --> M
    J --> O
