🎯 DIAGRAMA 6: Arquitectura General del Sistema
![graph TB
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
    J --> O](https://)