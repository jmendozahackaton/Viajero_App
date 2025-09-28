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