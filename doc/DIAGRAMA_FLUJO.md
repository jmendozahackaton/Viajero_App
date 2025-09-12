# Diagrama de Flujo del Sistema

## Flujo de Usuario Final
```mermaid
graph TD
    A[Inicio App] --> B[Pantalla Inicial]
    B --> C{¿Usuario autenticado?}
    C -->|No| D[Login/Registro]
    C -->|Sí| E[Mapa Principal]
    D --> E
    E --> F[Ver rutas disponibles]
    F --> G[Seleccionar ruta]
    G --> H[Ver detalles y tiempos]
    H --> I[Planificar viaje]
    I --> J[Recibir notificaciones]
    J --> K[Finalizar viaje]