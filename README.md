# 🐕 PETS Management System

Sistema completo de gestión de mascotas y paseadores desarrollado en InterSystems IRIS con ObjectScript.

## 📋 Características

- **Gestión de Mascotas**: Registro completo con información detallada
- **Gestión de Paseadores**: Control de personal especializado
- **Gestión de Dueños**: Base de datos de propietarios
- **Interfaz Web Moderna**: Aplicación web responsive
- **Arquitectura Modular**: CSS, JavaScript y Templates organizados
- **Base de Datos Relacional**: Usando clases persistentes de IRIS

## 🚀 Estructura del Proyecto

```
src/
├── Demo/
│   ├── REST.cls                 # Controlador REST principal
│   └── PETS/
│       ├── Owners.cls           # Clase persistente - Dueños
│       ├── Pets.cls             # Clase persistente - Mascotas
│       ├── Walkers.cls          # Clase persistente - Paseadores
│       ├── CSS/                 # Estilos modulares
│       │   ├── Main.cls
│       │   ├── Base.cls
│       │   ├── Forms.cls
│       │   ├── Tables.cls
│       │   └── Modals.cls
│       ├── JS/                  # JavaScript modular
│       │   ├── Main.cls
│       │   ├── Base.cls
│       │   ├── Forms.cls
│       │   └── Modals.cls
│       ├── Services/            # Servicios de negocio
│       │   ├── QueryService.cls
│       │   ├── CreationService.cls
│       │   ├── Base.cls
│       │   └── BaseSimple.cls
│       └── Templates/           # Templates HTML
│           ├── Base.cls
│           ├── Forms.cls
│           ├── Tables.cls
│           ├── Modals.cls
│           └── Main.cls
```

## 🏃‍♂️ Inicio Rápido

### Instalación con Docker

1. **Construir el contenedor:**
   ```bash
   docker-compose up --build
   ```

2. **Acceder a la aplicación:**
   - Aplicación web: http://localhost:52773/csp/pets/
   - Portal de gestión IRIS: http://localhost:52773/csp/sys/UtilHome.csp

### Instalación Manual

1. **Cargar el módulo:**
   ```objectscript
   zpm "load /path/to/project/ -v"
   ```

2. **Configurar aplicación web:**
   El script `iris.script` configura automáticamente las aplicaciones web necesarias.

## 🎯 Funcionalidades

### 📝 Registro de Entidades

- **Mascotas**: 
  - Información básica (nombre, raza, edad, peso)
  - Características físicas (tamaño, color)
  - Temperamento y observaciones
  - Relación con dueño

- **Paseadores**:
  - Datos personales (RUT, nombre, contacto)
  - Experiencia y disponibilidad
  - Tarifas por hora
  - Estado de disponibilidad

- **Dueños**:
  - Información de contacto completa
  - Número de mascotas
  - Preferencias especiales

### 🔍 Consultas y Reportes

- Listados completos de mascotas, paseadores y dueños
- Filtros y búsquedas avanzadas
- Información de relaciones entre entidades

### 🧪 Herramientas de Desarrollo

- **Pruebas Automáticas**: Carga de datos de ejemplo
- **Inicialización de Datos**: Datos de muestra para pruebas
- **Interfaz de Desarrollo**: Herramientas de debug

## 🌐 Endpoints de la API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/` | Página principal |
| GET | `/mascotas` | Formulario registro mascotas |
| POST | `/guardar-mascota` | Guardar nueva mascota |
| GET | `/paseadores` | Formulario registro paseadores |
| POST | `/guardar-paseador` | Guardar nuevo paseador |
| GET | `/dueños` | Formulario registro dueños |
| POST | `/guardar-dueño` | Guardar nuevo dueño |
| GET | `/consultar-mascotas` | Listado de mascotas |
| GET | `/consultar-paseadores` | Listado de paseadores |
| GET | `/consultar-dueños` | Listado de dueños |
| GET | `/inicializar` | Cargar datos de ejemplo |
| GET | `/pruebas-automaticas` | Suite de pruebas |

## 💾 Modelo de Datos

### Relaciones

```
Owners (1) ←→ (*) Pets
```

- Un dueño puede tener múltiples mascotas
- Cada mascota pertenece a un solo dueño
- Los paseadores son entidades independientes

### Índices

- **Owners**: Índice único en RUT
- **Pets**: Índice único en UserID
- **Walkers**: Índice único en RUT

## 🔧 Desarrollo

### Arquitectura Modular

El sistema utiliza una arquitectura modular con separación clara de responsabilidades:

- **Controladores REST**: Manejo de peticiones HTTP
- **Clases Persistentes**: Modelo de datos
- **Templates**: Generación de HTML
- **CSS/JS Modulares**: Estilos y comportamiento frontend
- **Servicios**: Lógica de negocio

### Agregar Nuevas Funcionalidades

1. **Nueva entidad persistente**: Crear clase en `src/Demo/PETS/`
2. **Nuevo endpoint**: Agregar ruta en `REST.cls`
3. **Nuevos estilos**: Agregar en `CSS/`
4. **Nuevo comportamiento**: Agregar en `JS/`
5. **Nuevos templates**: Agregar en `Templates/`

## 📊 Tecnologías

- **Backend**: InterSystems IRIS, ObjectScript
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Arquitectura**: REST API, MVC Pattern
- **Base de Datos**: IRIS Native Objects
- **Contenedores**: Docker, Docker Compose

## 🎨 UI/UX

- Diseño responsive para dispositivos móviles
- Interfaz moderna con iconos y colores
- Formularios intuitivos con validación
- Modales para retroalimentación inmediata
- Navegación clara y consistente

## 🚦 Estado del Proyecto

✅ **Completado:**
- Clases persistentes principales
- Sistema REST completo
- Templates HTML modulares
- CSS y JavaScript organizados
- Operaciones CRUD básicas
- Formularios de registro
- Listados y consultas

🔄 **En desarrollo:**
- Edición de registros existentes
- Eliminación segura de registros
- Reportes avanzados
- Sistema de autenticación
- API REST completa

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo LICENSE para más detalles.

## 👥 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crear branch de feature (`git checkout -b feature/AmazingFeature`)
3. Commit los cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

---

Desarrollado con ❤️ usando InterSystems IRIS
