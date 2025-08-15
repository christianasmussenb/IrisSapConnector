# 🐕 PETS Management System

Sistema completo de gestión de mascotas y paseadores desarrollado en InterSystems IRIS con ObjectScript y **arquitectura modular avanzada**.

## 📋 Características

- **Gestión de Mascotas**: Registro completo con información detallada (nombre, raza, edad, peso, temperamento)
- **Gestión de Paseadores**: Control de personal especializado con experiencia y tarifas
- **Gestión de Dueños**: Base de datos de propietarios con información de contacto
- **Interfaz Web Moderna**: Aplicación web responsive con formularios interactivos
- **Arquitectura Modular Completa**: Servicios especializados para cada responsabilidad
- **Base de Datos Relacional**: Usando clases persistentes de IRIS con relaciones uno-a-muchos
- **API REST Simplificada**: Controlador limpio con delegación a servicios de negocio
- **Sistema de Validaciones Centralizadas**: Validación consistente y reutilizable

## 🚀 Estado del Proyecto

### ✅ **Sistema Completamente Funcional**

El sistema está **DESPLEGADO y FUNCIONANDO** en IRIS con:

- **6 Dueños** registrados en `Demo_PETS.Owners`
- **7 Mascotas** registradas en `Demo_PETS.Pets` 
- **6 Paseadores** registrados en `Demo_PETS.Walkers`
- **25 Clases** cargadas y compiladas exitosamente
- **2 Aplicaciones Web** configuradas y activas
- **Arquitectura Modular** con servicios especializados

### 🌐 **URLs de Acceso (ACTIVO)**

```
🏠 Aplicación Principal:
http://localhost:52773/csp/pets/

🏠 Aplicación Compatibilidad:
http://localhost:52773/csp/demo2/

📝 Formularios de Registro:
http://localhost:52773/csp/pets/mascotas
http://localhost:52773/csp/pets/paseadores  
http://localhost:52773/csp/pets/dueños

🔍 Consultas de Datos:
http://localhost:52773/csp/pets/consultar-mascotas
http://localhost:52773/csp/pets/consultar-paseadores
http://localhost:52773/csp/pets/consultar-dueños

🧪 Herramientas del Sistema:
http://localhost:52773/csp/pets/inicializar
http://localhost:52773/csp/pets/pruebas-automaticas
```

## 🗂️ Estructura del Proyecto en IRIS

### **📁 Ubicación en IRIS:**
- **Namespace:** `USER`
- **Contenedor:** `irish` (puerto 52773)
- **Base de Datos:** Tablas SQL autogeneradas

### **🏗️ Arquitectura de Clases:**

```
Demo.REST                          # Controlador REST principal

Demo.PETS/
├── Owners.cls                     # 🏠 Clase persistente - Dueños
├── Pets.cls                       # 🐕 Clase persistente - Mascotas  
├── Walkers.cls                    # 🚶 Clase persistente - Paseadores
│
├── CSS/                           # 🎨 Estilos modulares
│   ├── Main.cls                   # CSS principal unificado
│   ├── Base.cls                   # Estilos base del sistema
│   ├── Forms.cls                  # Estilos de formularios
│   ├── Tables.cls                 # Estilos de tablas
│   └── Modals.cls                 # Estilos de modales
│
├── JS/                            # ⚡ JavaScript modular
│   ├── Main.cls                   # JavaScript principal unificado
│   ├── Base.cls                   # Funciones base
│   ├── Forms.cls                  # Manejo de formularios
│   └── Modals.cls                 # Manejo de modales
│
├── Services/                      # 🔧 Servicios de negocio
│   ├── Base.cls                   # Clase base de servicios
│   ├── BaseSimple.cls             # Servicios simples
│   ├── CreationService.cls        # Servicios de creación y formularios
│   ├── FormService.cls            # Extracción de datos de formularios
│   ├── ValidationService.cls      # Validaciones de negocio
│   ├── ResponseService.cls        # Construcción de respuestas JSON
│   └── QueryService.cls           # Servicios de consulta
│
└── Templates/                     # 📄 Templates HTML
    ├── Base.cls                   # Templates base (header/footer)
    ├── Forms.cls                  # Templates de formularios
    ├── Tables.cls                 # Templates de tablas
    ├── Modals.cls                 # Templates de modales
    └── Main.cls                   # Templates principales
```

### **🗄️ Tablas SQL Generadas:**

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| `Demo_PETS.Owners` | 6 | Información de dueños de mascotas |
| `Demo_PETS.Pets` | 7 | Registro de mascotas con relación a dueños |
| `Demo_PETS.Walkers` | 6 | Paseadores registrados en el sistema |

### **🔗 Relaciones de Base de Datos:**

```
Demo_PETS.Owners (1) ←→ (*) Demo_PETS.Pets
```

- Un dueño puede tener múltiples mascotas
- Cada mascota pertenece a un solo dueño
- Los paseadores son entidades independientes
- Índices únicos en RUT (Owners/Walkers) y UserID (Pets)

## 🏃‍♂️ Inicio Rápido

### **✅ Sistema Ya Desplegado**

El sistema ya está funcionando. Solo necesitas acceder a:
```
http://localhost:52773/csp/pets/
```

### **🐳 Si necesitas reconstruir:**

```bash
# Clonar repositorio
git clone https://github.com/christianasmussenb/IrisSapConnector.git
cd IrisSapConnector

# Construir y ejecutar
docker-compose up --build

# Acceder a la aplicación
open http://localhost:52773/csp/pets/
```

### **📦 Instalación en IRIS existente:**

```objectscript
USER> do $System.OBJ.LoadDir("/path/to/src","ck",,1)
USER> do ##class(Demo.PETS.Owners).InsertSampleData()
USER> do ##class(Demo.PETS.Pets).InsertSampleData()
USER> do ##class(Demo.PETS.Walkers).InsertSampleData()
```

## 🎯 Funcionalidades Implementadas

### ✅ **Operaciones CRUD Completas**

#### **📝 Registro de Entidades:**
- **Mascotas**: 
  - ✅ Información básica (name, breed, age, weight)
  - ✅ Características físicas (size, color, temperament)
  - ✅ Observaciones y notas especiales
  - ✅ Relación obligatoria con dueño
  - ✅ UserID único autogenerado (formato: PET-YYYY-NNNN)

- **Paseadores**:
  - ✅ Datos personales (RUT, name, phone, email)
  - ✅ Experiencia y disponibilidad
  - ✅ Tarifas por hora y estado
  - ✅ Validación de RUT único

- **Dueños**:
  - ✅ Información de contacto completa
  - ✅ Dirección y número de mascotas
  - ✅ Preferencias especiales
  - ✅ Validación de RUT único

#### **🔍 Consultas y Reportes:**
- ✅ Listados completos con diseño responsive
- ✅ Tablas HTML con información detallada
- ✅ Relaciones entre entidades mostradas
- ✅ Contadores de registros en tiempo real

#### **🧪 Herramientas de Desarrollo:**
- ✅ **Datos de Muestra**: Carga automática de datos de ejemplo
- ✅ **Pruebas Automáticas**: Suite de pruebas para validar funcionalidad
- ✅ **Inicialización**: Reset y carga de datos clean
- ✅ **Validación**: Sistema robusto de validación de datos

## 🌐 API REST Endpoints

| Método | Endpoint | Descripción | Estado |
|--------|----------|-------------|--------|
| GET | `/` | Página principal del sistema | ✅ Activo |
| GET | `/mascotas` | Formulario registro mascotas | ✅ Activo |
| POST | `/guardar-mascota` | Guardar nueva mascota | ✅ Activo |
| GET | `/paseadores` | Formulario registro paseadores | ✅ Activo |
| POST | `/guardar-paseador` | Guardar nuevo paseador | ✅ Activo |
| GET | `/dueños` | Formulario registro dueños | ✅ Activo |
| POST | `/guardar-dueño` | Guardar nuevo dueño | ✅ Activo |
| GET | `/consultar-mascotas` | Listado de mascotas | ✅ Activo |
| GET | `/consultar-paseadores` | Listado de paseadores | ✅ Activo |
| GET | `/consultar-dueños` | Listado de dueños | ✅ Activo |
| GET | `/inicializar` | Cargar datos de ejemplo | ✅ Activo |
| GET | `/pruebas-automaticas` | Suite de pruebas | ✅ Activo |

## 💾 Acceso a Datos

### **🔍 Consultas SQL Directas:**

```sql
-- Listar todos los dueños
SELECT * FROM Demo_PETS.Owners;

-- Listar mascotas con información del dueño
SELECT p.Name as PetName, p.Breed, p.Age, o.Name as OwnerName 
FROM Demo_PETS.Pets p 
JOIN Demo_PETS.Owners o ON p.Owner = o.ID;

-- Contar registros por tipo
SELECT COUNT(*) as TotalOwners FROM Demo_PETS.Owners;
SELECT COUNT(*) as TotalPets FROM Demo_PETS.Pets;
SELECT COUNT(*) as TotalWalkers FROM Demo_PETS.Walkers;
```

### **⚡ Acceso desde ObjectScript:**

```objectscript
// Crear nuevo dueño
USER> set owner = ##class(Demo.PETS.Owners).%New()
USER> set owner.Name = "John Doe"
USER> set owner.RUT = "12345678-9"
USER> do owner.%Save()

// Buscar mascota por ID
USER> set pet = ##class(Demo.PETS.Pets).%OpenId(1)
USER> write pet.Name

// Listar datos de muestra
USER> do ##class(Demo.PETS.Owners).InsertSampleData()
```

## 🔧 Desarrollo y Arquitectura

### **🏗️ Patrón de Diseño Modular**

El sistema implementa un **patrón MVC modular** con separación clara:

- **Modelo**: Clases persistentes (`Owners`, `Pets`, `Walkers`)
- **Vista**: Templates HTML modulares + CSS/JS organizados
- **Controlador**: `Demo.REST` con routing automático y delegación a servicios
- **Servicios**: Lógica de negocio separada en capas especializadas

### **🎯 Arquitectura de Servicios Especializados**

#### **📝 FormService**
- **Responsabilidad**: Extracción y procesamiento de datos de formularios HTTP
- **Métodos**: `ExtractPetFormData()`, `ExtractWalkerFormData()`, `ExtractOwnerFormData()`
- **Beneficio**: Centraliza la lógica de mapeo request → objeto de datos

#### **✅ ValidationService**
- **Responsabilidad**: Validaciones de negocio y reglas de datos
- **Métodos**: `ValidatePetData()`, `ValidateWalkerData()`, `ValidateOwnerData()`, `CheckRUTExists()`
- **Beneficio**: Validaciones reutilizables y consistentes

#### **📤 ResponseService**
- **Responsabilidad**: Construcción de respuestas JSON estructuradas
- **Métodos**: `BuildSuccessResponse()`, `BuildErrorResponse()`, `BuildValidationErrorResponse()`
- **Beneficio**: Respuestas consistentes y manejo centralizado de errores

#### **🏭 CreationService**
- **Responsabilidad**: Orquestación de procesos de creación completos
- **Métodos**: `CreatePetFromForm()`, `CreateWalkerFromForm()`, `CreateOwnerFromForm()`
- **Beneficio**: Flujo completo desde formulario hasta persistencia

### **🔄 Controlador REST Simplificado**

**ANTES** (Lógica Mezclada):
```objectscript
ClassMethod GuardarPaseador() As %Status
{
  // 50+ líneas con:
  // - Extracción de datos
  // - Validaciones inline
  // - Verificación de duplicados
  // - Creación de objetos
  // - Construcción de respuestas
  // - Manejo de errores
}
```

**DESPUÉS** (Delegación Limpia):
```objectscript
ClassMethod GuardarPaseador() As %Status
{
  Set %response.ContentType = "application/json; charset=utf-8"
  Set result = ##class(Demo.PETS.Services.CreationService).CreateWalkerFromForm()
  Write result.%ToJSON()
  Return $$$OK
}
```

### **🎨 Sistema de Templates**

- **Templates Base**: Header/Footer reutilizables
- **Templates Formularios**: Generación automática de forms
- **Templates Tablas**: Listados con estilos consistentes
- **Templates Modales**: Feedback visual uniforme

### **⚡ JavaScript Modular**

- **Autoconfiguración**: Detección automática de tipo de página
- **Manejo de Forms**: Validación y envío AJAX
- **Modales Dinámicos**: Feedback visual en tiempo real
- **Compatibilidad**: Funciones legacy mantenidas

### **🎨 CSS Modular**

- **Sistema de Componentes**: Estilos reutilizables
- **Responsive Design**: Adaptable a móviles y desktop
- **Temas Consistentes**: Colores y tipografía unificados

## 📊 Datos del Sistema (Estado Actual)

### **📈 Estadísticas en Vivo:**
- **Dueños Registrados**: 6
- **Mascotas Activas**: 7  
- **Paseadores Disponibles**: 6
- **Relaciones Establecidas**: 7 (mascota-dueño)

### **🔄 Datos de Ejemplo Incluidos:**

**Dueños de Muestra:**
- Ana García (RUT: 12345678-9)
- Luis Martínez (RUT: 98765432-1) 
- Carmen Silva (RUT: 11223344-5)
- Roberto López (RUT: 55667788-9)
- + 2 adicionales

**Mascotas de Muestra:**
- Max (Labrador, 3 años) → Ana García
- Luna (Golden Retriever, 2 años) → Luis Martínez  
- Rocky (Bulldog, 5 años) → Carmen Silva
- + 4 adicionales con relaciones establecidas

**Paseadores de Muestra:**
- María González (3 años exp., $15/hora)
- Carlos Ruiz (5 años exp., $18/hora)
- Sofia López (2 años exp., $12/hora)
- + 3 adicionales

## 🚦 Roadmap y Mejoras Futuras

### **🔄 En Desarrollo:**
- [x] **Modularización Completa**: Servicios especializados implementados
- [x] **Separación de Responsabilidades**: Controller, Services, Validation, Response
- [x] **Arquitectura Escalable**: Servicios reutilizables y mantenibles
- [ ] Edición de registros existentes
- [ ] Eliminación segura con confirmación
- [ ] Sistema de búsqueda y filtros
- [ ] Reportes avanzados en PDF
- [ ] Dashboard con métricas

### **🎯 Planificado:**
- [ ] Sistema de autenticación y usuarios
- [ ] API REST completa (PUT, DELETE)
- [ ] Integración con calendarios
- [ ] Sistema de notificaciones
- [ ] App móvil nativa

## 💡 Casos de Uso

### **🏢 Empresarial:**
- **Veterinarias**: Gestión de pacientes y propietarios
- **Pet Hotels**: Control de huéspedes y servicios
- **Servicios de Paseo**: Administración de clientes y personal

### **🏠 Personal:**
- **Criadores**: Registro de linajes y propietarios
- **Rescates**: Gestión de adopciones
- **Clubs Caninos**: Administración de miembros

## � Tecnologías

- **Backend**: InterSystems IRIS 2024+, ObjectScript
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Arquitectura**: REST API, MVC Pattern, Modular Design
- **Base de Datos**: IRIS Native Objects con SQL automático
- **Contenedores**: Docker, Docker Compose
- **Versionado**: Git, GitHub

## 🔒 Seguridad y Validaciones

### **✅ Validaciones Implementadas:**
- Campos obligatorios en backend y frontend
- Validación de formatos (email, teléfono, RUT)
- Prevención de duplicados (RUT único)
- Sanitización de datos de entrada
- Manejo de errores robusto
- **Servicios de Validación Centralizados** para consistencia

### **🛡️ Seguridad:**
- Autenticación básica de IRIS
- Escape de caracteres en SQL
- Validación de tipos de datos
- Manejo seguro de excepciones
- **Delegación de Lógica de Negocio** a servicios especializados

## 📊 Métricas de Código

### **🏗️ Arquitectura Modularizada:**
- **25 Clases Totales** (incluyendo servicios especializados)
- **4 Servicios de Negocio** nuevos implementados
- **Reducción 90%** en líneas de código del controlador REST
- **100% Reutilización** de validaciones y respuestas
- **Separación Completa** entre presentación y lógica de negocio

### **📈 Beneficios de Modularización:**
- **Mantenibilidad**: Lógica centralizada en servicios especializados
- **Testabilidad**: Servicios independientes fáciles de probar
- **Escalabilidad**: Arquitectura preparada para crecimiento
- **Reutilización**: Servicios utilizables desde múltiples controladores
- **Legibilidad**: Código más claro y propósito específico

## 🤝 Contribuir

### **🔧 Entorno de Desarrollo:**

```bash
# Desarrollo local
git clone https://github.com/christianasmussenb/IrisSapConnector.git
cd IrisSapConnector

# Hacer cambios en src/
# Copiar al contenedor para pruebas:
docker cp src irish:/tmp/pets-src-dev
docker exec -it irish iris session iris
USER> do $System.OBJ.LoadDir("/tmp/pets-src-dev","ck",,1)
```

### **📝 Pull Requests:**
1. Fork el proyecto
2. Crear branch de feature (`git checkout -b feature/AmazingFeature`)
3. Commit los cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📞 Soporte

### **🆘 Resolución de Problemas:**

**Problema**: No se puede acceder a http://localhost:52773/csp/pets/
```bash
# Verificar que el contenedor esté ejecutándose
docker ps | grep irish

# Verificar aplicaciones web en IRIS
docker exec -it irish iris session iris
%SYS> do $SYSTEM.Security.Applications.Get("/csp/pets")
```

**Problema**: Clases no se cargan
```bash
# Recargar clases manualmente
docker cp src irish:/tmp/pets-reload
docker exec -it irish iris session iris
USER> do $System.OBJ.LoadDir("/tmp/pets-reload","ck",,1)
```

### **📧 Contacto:**
- **Issues**: [GitHub Issues](https://github.com/christianasmussenb/IrisSapConnector/issues)
- **Discussions**: [GitHub Discussions](https://github.com/christianasmussenb/IrisSapConnector/discussions)

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo [LICENSE](LICENSE) para más detalles.

---

## 🎉 ¡Sistema en Producción!

**El PETS Management System está completamente funcional y listo para usar.**

**🚀 Accede ahora: http://localhost:52773/csp/pets/**

### 🎉 **Últimas Mejoras Implementadas:**

- ✅ **Arquitectura Modular Completa**: Servicios especializados para todas las operaciones
- ✅ **FormService**: Extracción centralizada de datos de formularios
- ✅ **ValidationService**: Validaciones de negocio reutilizables
- ✅ **ResponseService**: Respuestas JSON consistentes y estructuradas
- ✅ **CreationService Expandido**: Flujos completos de creación desde formularios
- ✅ **REST Controller Simplificado**: Delegación limpia a servicios especializados

Desarrollado con ❤️ usando InterSystems IRIS | Última actualización: Agosto 2025 - Modularización Completa
