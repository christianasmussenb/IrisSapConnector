# 📅 PLAN DE IMPLEMENTACIÓN - SISTEMA DE PROGRAMACIÓN DE PASEOS

**Fecha de Inicio:** 15 de agosto de 2025  
**Proyecto:** PETS Management System - Módulo de Programación de Paseos  
**Estado:** 🚀 PLANIFICACIÓN INICIAL

---

## 🎯 **REQUERIMIENTOS PRINCIPALES**

### **Core Funcionalidades Solicitadas:**

1. **📅 Disponibilidad de Walkers**
   - Registro de disponibilidad por día/hora (próximos 30 días)
   - Gestión de horarios flexibles por walker
   - Capacidad máxima: 5 pets por walker/día/hora

2. **🔒 Sistema de Rese#### **T1#### **T1.1.4 - Crear Availability.cls** ✅
- **Propósito**: Modelo de datos para disponibilidad de walkers
- **Ubicación**: `/src/Demo/PETS/Availability.cls`
- **Contenido**: Walker, fecha, hora, capacidad, estado
- **Estado**: ✅ COMPLETADO - Clase compilada con 15 métodos funcionales
- **Correcciones**: Formato de fechas y %Numeric syntax corregidos
- **Datos**: 1 slot de prueba creado (María González, 2025-08-16, 09:00-10:00)- Crear Availability.cls** ✅
- **Propósito**: Modelo de datos para disponibilidad de walkers
- **Ubicación**: `/src/Demo/PETS/Availability.cls`
- **Contenido**: Walker, fecha, hora, capacidad, estado
- **Estado**: ✅ COMPLETADO - Clase compilada, 15 métodos implementados, datos de prueba creados

#### **T1.1.5 - Crear SchedulingService.cls** 🔧
- **Propósito**: Lógica de negocio para horarios
- **Ubicación**: `/src/Demo/PETS/Services/SchedulingService.cls`
- **Contenido**: Validaciones, CRUD de availability, consultas
- **Estado**: ⏳ PENDIENTE **📅 Calendario Visual para Owners**: Vista mensual tipo calendario con horarios disponibles
   - **⏰ Configuración de Horarios**: Parámetros app-level (ej: 07:00 - 23:00)
   - **🎯 Selección Flexible**: Owners seleccionan ventanas de tiempo deseadas
   - **🔍 Matching de Walkers**: Búsqueda automática de walkers con disponibilidad
   - Validación de capacidad máxima (5 pets por slot)
   - Reservas para próximos 30 días

3. **💰 Sistema de Cuentas**
   - Cuenta de Walker: Ingresos por paseos realizados
   - Cuenta de Owner: Cargos por paseos de sus pets
   - Actualización automática tras confirmación

4. **✅ Confirmación de Paseos**
   - Walker confirma paseo completado
   - Trigger para actualización de cuentas
   - Cambio de estado de reserva

5. **📊 Consultas en Línea**
   - Estado de cuentas de Walker
   - Estado de cuentas de Owner
   - Historial de transacciones

6. **📧 Sistema de Notificaciones**
   - Confirmación de reserva (logs)
   - Notificación de paseo completado (logs)
   - Comunicación Walker ↔ Owner

---

## 🔍 **ANÁLISIS Y FUNCIONALIDADES ADICIONALES PROPUESTAS**

### **Funcionalidades Necesarias (Core Extensions):**

1. **📅 Calendario Visual Interactivo**
   - Vista mensual tipo calendario para owners
   - Formato: Filas = horarios (configurable), Columnas = días semana
   - Selección multi-celda de ventanas de tiempo
   - Configuración global de horarios operativos (07:00 - 23:00)

2. **🎯 Sistema de Matching Inteligente**
   - Owner selecciona ventanas de tiempo deseadas
   - Sistema busca walkers con disponibilidad en esos slots
   - Algoritmo de matching basado en preferencias y disponibilidad
   - Lista de walkers compatibles con rating y tarifas

3. **❌ Gestión de Cancelaciones**
   - Cancelación por Owner (con políticas de tiempo)
   - Cancelación por Walker (con penalizaciones)
   - Liberación automática de slots

3. **❌ Gestión de Cancelaciones**
   - Cancelación por Owner (con políticas de tiempo)
   - Cancelación por Walker (con penalizaciones)
   - Liberación automática de slots

4. **⏰ Políticas de Tiempo**
   - Ventana de cancelación sin penalización
   - Políticas de no-show
   - Recordatorios automáticos

5. **📈 Estados de Reserva**
   - `PROGRAMADA` → `CONFIRMADA` → `EN_PROGRESO` → `COMPLETADA` → `PAGADA`
   - `CANCELADA` → `REEMBOLSADA`
   - `NO_SHOW` → `PENALIZADA`

### **Funcionalidades Deseadas (Enhancement):**

1. **⭐ Sistema de Evaluaciones**
   - Rating de Walker por Owner
   - Rating de Pet por Walker
   - Historial de calificaciones

2. **📊 Dashboard Avanzado**
   - Panel de control para Walkers
   - Panel de control para Owners
   - Estadísticas y métricas

3. **💸 Gestión Financiera Avanzada**
   - Diferentes tarifas por tipo de pet
   - Descuentos por volumen
   - Comisiones del sistema

4. **🔔 Notificaciones Inteligentes**
   - Recordatorios 24h/2h antes
   - Notificaciones push (futuro)
   - Alertas de clima (futuro)

### **Funcionalidades Futuras (Roadmap):**

1. **💳 Sistema de Pagos**
   - Integración con pasarelas de pago
   - Facturación automática
   - Gestión de reembolsos

2. **📍 Geolocalización**
   - Tracking en tiempo real
   - Rutas de paseo
   - Reportes de ubicación

3. **📱 App Mobile**
   - App nativa para Walkers
   - App para Owners
   - Comunicación en tiempo real

---

## 🏗️ **ARQUITECTURA DE CLASES PROPUESTA**

### **Nuevas Clases Persistentes:**

```
Demo.PETS.Scheduling/
├── Availability.cls          # Disponibilidad de walkers
├── Bookings.cls             # Reservas de paseos (supply-driven)
├── WalkSessions.cls         # Sesiones de paseo
├── WalkerAccounts.cls       # Cuentas de walkers
├── OwnerAccounts.cls        # Cuentas de owners
├── Transactions.cls         # Transacciones financieras
├── Notifications.cls        # Log de notificaciones
├── AppSettings.cls          # Configuraciones globales
└── Reviews.cls              # Evaluaciones (futuro)

# ITERACIÓN 2 (Futuro):
├── BookingRequests.cls      # Solicitudes demand-driven (Iteración 2)
└── MatchingResults.cls      # Resultados de matching (Iteración 2)
```

### **Nuevos Servicios (siguiendo arquitectura modular):**

```
Demo.PETS.Services/
├── SchedulingService.cls    # Gestión de horarios de walkers
├── BookingService.cls       # Gestión de reservas supply-driven
├── AccountingService.cls    # Gestión de cuentas
├── NotificationService.cls  # Gestión de notificaciones
├── ConfirmationService.cls  # Confirmaciones de paseos
├── CancellationService.cls  # Gestión de cancelaciones
├── ReportingService.cls     # Reportes y consultas
├── PricingService.cls       # Gestión de precios
├── ConfigService.cls        # Configuraciones de app
└── CalendarService.cls      # Calendario visual supply-driven

# ITERACIÓN 2 (Futuro):
├── MatchingService.cls      # Algoritmos demand-driven (Iteración 2)
└── RequestService.cls       # Gestión de solicitudes (Iteración 2)
```

### **Extensiones a Clases Existentes:**

```
Demo.REST.cls                # Nuevos endpoints para scheduling
Demo.PETS.Walkers.cls        # Tarifa base, rating promedio
Demo.PETS.Pets.cls           # Preferencias de paseo, tarifa especial
Demo.PETS.Owners.cls         # Límite de crédito, método de pago
```

---

## 📋 **BACKLOG PRIORIZADO**

### **� ENFOQUE DE IMPLEMENTACIÓN - DOS ITERACIONES**

#### **🎯 ITERACIÓN 1 - OFERTA-DEMANDA (Supply-Driven)**
**Flujo**: Walkers publican disponibilidad → Owners seleccionan de la oferta disponible
- ✅ **Ventaja**: Implementación más directa
- ✅ **Base sólida**: Validación real de disponibilidad
- ✅ **Menos complejidad**: Sin matching algorithms inicialmente

#### **🎯 ITERACIÓN 2 - DEMANDA-OFERTA (Demand-Driven)** 
**Flujo**: Owners definen horarios deseados → Sistema busca walkers compatibles
- 🔮 **Futuro**: Implementación posterior
- 🎨 **UX Superior**: Más flexibilidad para owners
- 🧠 **Inteligente**: Matching algorithms y scoring

---

### **�🚀 FASE 1 - CORE SCHEDULING (Semana 1) - ITERACIÓN 1**

#### **Sprint 1.1 - Configuración y Disponibilidad Base**
- [ ] **T1.1.1** - Crear clase `AppSettings.cls` para configuraciones globales
- [ ] **T1.1.2** - Crear `ConfigService.cls` para gestión de parámetros
- [ ] **T1.1.3** - Configurar horarios operativos (07:00 - 23:00) parametrizable
- [ ] **T1.1.4** - Crear clase `Availability.cls` con validaciones
- [ ] **T1.1.5** - Crear `SchedulingService.cls` para gestión de horarios

#### **Sprint 1.2 - Registro de Disponibilidad por Walkers**
- [ ] **T1.2.1** - Formulario web para walkers registren disponibilidad
- [ ] **T1.2.2** - Endpoint REST para guardar disponibilidad de walkers
- [ ] **T1.2.3** - Validación de límite 30 días y horarios lógicos
- [ ] **T1.2.4** - Calendario visual para walkers (gestión de sus horarios)
- [ ] **T1.2.5** - CRUD completo de disponibilidad por walker

#### **Sprint 1.3 - Vista de Disponibilidad para Owners (Supply-Driven)**
- [ ] **T1.3.1** - Calendario mensual mostrando disponibilidad de TODOS los walkers
- [ ] **T1.3.2** - Formato: Filas=horarios, Columnas=días, Celdas=walkers disponibles
- [ ] **T1.3.3** - Owner puede seleccionar slot específico de walker específico
- [ ] **T1.3.4** - Validación de capacidad (máximo 5 pets por walker/slot)
- [ ] **T1.3.5** - Confirmación inmediata de booking sobre disponibilidad real

### **💰 FASE 2 - SISTEMA FINANCIERO (Semana 2) - ITERACIÓN 1**

#### **Sprint 2.1 - Sistema de Bookings Directo**
- [ ] **T2.1.1** - Crear clase `Bookings.cls` con estados (supply-driven)
- [ ] **T2.1.2** - Crear `BookingService.cls` para bookings directos
- [ ] **T2.1.3** - Flujo: Owner selecciona slot disponible → Booking inmediato
- [ ] **T2.1.4** - Validación en tiempo real de disponibilidad
- [ ] **T2.1.5** - Actualización automática de slots ocupados

#### **Sprint 2.2 - Cuentas Base**
- [ ] **T2.2.1** - Crear `WalkerAccounts.cls` y `OwnerAccounts.cls`
- [ ] **T2.2.2** - Crear `Transactions.cls` para historial
- [ ] **T2.2.3** - Crear `AccountingService.cls` para lógica financiera
- [ ] **T2.2.4** - Cálculo automático de tarifas por paseo
- [ ] **T2.2.5** - Sistema de débitos/créditos

#### **Sprint 2.3 - Confirmaciones y Actualizaciones**
- [ ] **T2.3.1** - Crear `ConfirmationService.cls`
- [ ] **T2.3.2** - Endpoint para walker confirme paseo completado
- [ ] **T2.3.3** - Trigger automático para actualizar cuentas
- [ ] **T2.3.4** - Estados de reserva avanzados
- [ ] **T2.3.5** - Validaciones de confirmación

### **📊 FASE 3 - CONSULTAS Y REPORTES (Semana 3)**

#### **Sprint 3.1 - Dashboards**
- [ ] **T3.1.1** - Crear `ReportingService.cls`
- [ ] **T3.1.2** - Dashboard para walkers (ingresos, próximos paseos)
- [ ] **T3.1.3** - Dashboard para owners (gastos, historial)
- [ ] **T3.1.4** - Consultas en línea de estados de cuenta
- [ ] **T3.1.5** - Reportes financieros básicos

#### **Sprint 3.2 - Notificaciones**
- [ ] **T3.2.1** - Crear `Notifications.cls` y `NotificationService.cls`
- [ ] **T3.2.2** - Sistema de logs para notificaciones
- [ ] **T3.2.3** - Confirmaciones de reserva (log)
- [ ] **T3.2.4** - Notificaciones de paseo completado (log)
- [ ] **T3.2.5** - Templates de notificaciones

### **🔧 FASE 4 - FEATURES AVANZADAS (Semana 4) - ITERACIÓN 1**

#### **Sprint 4.1 - Cancelaciones**
- [ ] **T4.1.1** - Crear `CancellationService.cls`
- [ ] **T4.1.2** - Políticas de cancelación configurable
- [ ] **T4.1.3** - Gestión de reembolsos automáticos
- [ ] **T4.1.4** - Interfaz web para cancelaciones
- [ ] **T4.1.5** - Liberación automática de slots cancelados

#### **Sprint 4.2 - Mejoras de UX Supply-Driven**
- [ ] **T4.2.1** - Optimización de calendario de disponibilidad
- [ ] **T4.2.2** - Filtros por walker (rating, tarifa, experiencia)
- [ ] **T4.2.3** - Vista de agenda personal para owners y walkers
- [ ] **T4.2.4** - Exportación de reportes básicos
- [ ] **T4.2.5** - Responsive design para mobile

---

### **🚀 ITERACIÓN 2 - DEMAND-DRIVEN (Futuro - Post Semana 4)**

#### **Fase 5 - Sistema de Matching Inteligente**

#### **Sprint 5.1 - Solicitudes de Owners**
- [ ] **T5.1.1** - Crear clase `BookingRequests.cls` para demanda
- [ ] **T5.1.2** - Calendario de selección libre para owners
- [ ] **T5.1.3** - Interfaz multi-celda sin restricción de oferta
- [ ] **T5.1.4** - Guardar "wish list" de horarios deseados
- [ ] **T5.1.5** - Estados de solicitud (PENDING, MATCHED, EXPIRED)

#### **Sprint 5.2 - Algoritmos de Matching**
- [ ] **T5.2.1** - Crear `MatchingService.cls` para matching inteligente
- [ ] **T5.2.2** - Algoritmo de búsqueda por ventanas de tiempo
- [ ] **T5.2.3** - Sistema de scoring (rating + disponibilidad + precio)
- [ ] **T5.2.4** - Sugerencias de walkers compatibles
- [ ] **T5.2.5** - Negociación de horarios (walker puede proponer alternativas)

#### **Sprint 5.3 - UX Avanzada Demand-Driven**
- [ ] **T5.3.1** - Dashboard de solicitudes para owners
- [ ] **T5.3.2** - Dashboard de oportunidades para walkers
- [ ] **T5.3.3** - Sistema de notificaciones proactivas
- [ ] **T5.3.4** - Matching automático con preferencias
- [ ] **T5.3.5** - Analytics de demanda vs oferta

---

## 🗃️ **MODELO DE DATOS DETALLADO**

### **AppSettings (Configuraciones Globales)**

```objectscript
Class Demo.PETS.Scheduling.AppSettings Extends %Persistent
{
    Property SettingKey As %String(MAXLEN = 100) [ Unique ];
    Property SettingValue As %String(MAXLEN = 500);
    Property SettingType As %String; // TIME, INTEGER, STRING, BOOLEAN
    Property Description As %Text;
    Property CreatedAt As %TimeStamp;
    Property UpdatedAt As %TimeStamp;
    
    // Configuraciones por defecto:
    // OPERATING_START_TIME = "07:00:00"
    // OPERATING_END_TIME = "23:00:00"
    // TIME_SLOT_DURATION = "60" (minutos)
    // MAX_PETS_PER_SLOT = "5"
    // MAX_BOOKING_DAYS_AHEAD = "30"
}
```

### **BookingRequests (Solicitudes de Tiempo - ITERACIÓN 2)**

```objectscript
// ITERACIÓN 2 - DEMAND-DRIVEN (Futuro)
Class Demo.PETS.Scheduling.BookingRequests Extends %Persistent
{
    Property Owner As Demo.PETS.Owners;
    Property Pet As Demo.PETS.Pets;
    Property RequestedMonth As %Integer; // 1-12
    Property RequestedYear As %Integer;
    Property SelectedTimeSlots As %Text; // JSON array de slots deseados
    Property Status As %String; // PENDING, MATCHED, BOOKED, EXPIRED
    Property MatchedWalkers As %Text; // JSON array de walkers compatibles
    Property CreatedAt As %TimeStamp;
    Property ExpiresAt As %TimeStamp;
}
```

### **Availability (Disponibilidad de Walkers - ITERACIÓN 1)**

```objectscript
Class Demo.PETS.Scheduling.Availability Extends %Persistent
{
    Property Walker As Demo.PETS.Walkers;
    Property AvailableDate As %Date;
    Property StartTime As %Time;
    Property EndTime As %Time;
    Property MaxPets As %Integer [ InitialExpression = 5 ];
    Property CurrentBookings As %Integer [ InitialExpression = 0 ];
    Property IsActive As %Boolean [ InitialExpression = 1 ];
    Property CreatedAt As %TimeStamp;
    Property UpdatedAt As %TimeStamp;
}
```

### **Bookings (Reservas de Paseos - Supply-Driven)**

```objectscript
Class Demo.PETS.Scheduling.Bookings Extends %Persistent
{
    Property Owner As Demo.PETS.Owners;
    Property Pet As Demo.PETS.Pets;
    Property Walker As Demo.PETS.Walkers;
    Property Availability As Demo.PETS.Scheduling.Availability; // Referencia directa
    Property BookingDate As %Date;
    Property StartTime As %Time;
    Property EndTime As %Time;
    Property Status As %String; // PROGRAMADA, CONFIRMADA, COMPLETADA, CANCELADA
    Property Amount As %Numeric(10,2);
    Property SpecialInstructions As %Text;
    Property BookingType As %String [ InitialExpression = "SUPPLY_DRIVEN" ];
    Property CreatedAt As %TimeStamp;
    Property ConfirmedAt As %TimeStamp;
    Property CompletedAt As %TimeStamp;
}
```

### **WalkerAccounts (Cuentas de Walkers)**

```objectscript
Class Demo.PETS.Scheduling.WalkerAccounts Extends %Persistent
{
    Property Walker As Demo.PETS.Walkers;
    Property TotalEarnings As %Numeric(10,2) [ InitialExpression = 0 ];
    Property PendingPayments As %Numeric(10,2) [ InitialExpression = 0 ];
    Property PaidOut As %Numeric(10,2) [ InitialExpression = 0 ];
    Property LastTransactionDate As %TimeStamp;
    Property CreatedAt As %TimeStamp;
    Property UpdatedAt As %TimeStamp;
}
```

### **Transactions (Historial de Transacciones)**

```objectscript
Class Demo.PETS.Scheduling.Transactions Extends %Persistent
{
    Property Booking As Demo.PETS.Scheduling.Bookings;
    Property Walker As Demo.PETS.Walkers;
    Property Owner As Demo.PETS.Owners;
    Property Type As %String; // BOOKING_CHARGE, WALKER_PAYMENT, CANCELLATION_FEE
    Property Amount As %Numeric(10,2);
    Property Description As %Text;
    Property Status As %String; // PENDING, COMPLETED, REFUNDED
    Property ProcessedAt As %TimeStamp;
    Property CreatedAt As %TimeStamp;
}
```

---

## 🔧 **CONSIDERACIONES TÉCNICAS**

### **Integración con Arquitectura Existente:**

1. **Servicios Modulares**: Seguir el patrón de 8 servicios especializados
2. **Controller REST**: Extender endpoints existentes manteniendo simplicidad
3. **Templates**: Reutilizar sistema de templates existente
4. **Validaciones**: Integrar con ValidationService existente
5. **Responses**: Usar ResponseService para consistencia

### **Validaciones Críticas:**

1. **Disponibilidad**: No solapar horarios, máximo 30 días futuro
2. **Reservas**: Verificar disponibilidad real-time, límite 5 pets
3. **Confirmaciones**: Solo walker puede confirmar sus propios paseos
4. **Cuentas**: Transacciones atómicas, no double-spending
5. **Cancelaciones**: Políticas de tiempo respetadas

### **Performance Considerations:**

1. **Índices**: Por fecha, walker, owner para consultas rápidas
2. **Caching**: Disponibilidad frecuentemente consultada
3. **Batch Operations**: Procesamiento masivo de notificaciones
4. **Archive**: Datos históricos > 90 días a tablas de archivo

---

## 📊 **MÉTRICAS DE ÉXITO**

### **KPIs Funcionales:**
- [ ] 100% de disponibilidades registrables sin conflictos
- [ ] 100% de reservas con validación de capacidad
- [ ] 0% de errores en cálculos financieros
- [ ] 100% de confirmaciones gatillan updates correctos
- [ ] 100% de consultas < 500ms tiempo respuesta

### **KPIs Técnicos:**
- [ ] 0 errores de compilación IRIS
- [ ] 100% coverage en validaciones críticas
- [ ] < 2s tiempo de carga de dashboards
- [ ] 100% transacciones atómicas exitosas

---

## 🎯 **PRÓXIMOS PASOS INMEDIATOS**

### **Día 1 (Hoy - 15 Ago):**
1. ✅ Crear este plan.md
2. ✅ Agregar calendario visual y sistema de matching
3. [ ] Revisar y aprobar arquitectura actualizada
4. [ ] Definir configuraciones iniciales de horarios operativos

### **Día 2:**
1. [ ] Implementar Sprint 1.1 - Configuración y Availability base
2. [ ] Crear AppSettings y ConfigService  
3. [ ] Testing de configuraciones parametrizables

### **Día 3:**
1. [ ] Implementar Sprint 1.2 - Registro de disponibilidad por walkers
2. [ ] Formularios para walkers publiquen su disponibilidad
3. [ ] Testing de registro de horarios

### **Día 4:**
1. [ ] Implementar Sprint 1.3 - Vista supply-driven para owners
2. [ ] Calendario mostrando disponibilidad existente
3. [ ] Testing de selección directa de slots disponibles

### **Día 5:**
1. [ ] Implementar Sprint 2.1 - Bookings directos
2. [ ] Flujo completo owner selecciona → booking inmediato  
3. [ ] Testing de transacciones atomicas

---

## 📝 **LOG DE PROGRESO**

**15 Ago 2025 - 🚀 INICIO**
- ✅ Plan inicial creado
- ✅ Arquitectura diseñada  
- ✅ Backlog priorizado
- ✅ **DECISIÓN ESTRATÉGICA**: Implementación en 2 iteraciones distintas
- ✅ **ITERACIÓN 1**: Supply-Driven (walkers publican → owners seleccionan)
- ✅ **ITERACIÓN 2**: Demand-Driven (owners solicitan → sistema busca walkers)
- ✅ **PRIORIDAD**: Comenzar con supply-driven por simplicidad y validación
- ✅ **ARQUITECTURA**: Separación clara entre ambos enfoques
- ✅ **PLAN APROBADO**: Listo para comenzar desarrollo
- 🎯 **EN PROGRESO**: Iniciando Sprint 1.1 - Configuración Base

---

## 🚀 **ACTIVIDADES INMEDIATAS - SPRINT 1.1**

### **📋 TAREAS PRIORITARIAS (Próximas 2-3 horas):**

#### **T1.1.1 - Crear AppSettings.cls** ✅
- **Propósito**: Configuraciones globales parametrizables
- **Ubicación**: `/src/Demo/PETS/Settings.cls` (renombrado por límites IRIS)
- **Contenido**: Horarios operativos, límites, configuraciones
- **Estado**: ✅ COMPLETADO - Clase compilada y configuraciones inicializadas

#### **T1.1.2 - Crear ConfigService.cls** ✅
- **Propósito**: Servicio para gestionar configuraciones
- **Ubicación**: `/src/Demo/PETS/Services/ConfigService.cls`
- **Contenido**: CRUD de settings, validaciones, defaults
- **Estado**: ✅ COMPLETADO - Servicio compilado y funcional

#### **T1.1.3 - Configurar Horarios Operativos** ✅
- **Propósito**: Establecer parámetros base del sistema
- **Parámetros**: OPERATING_START_TIME, OPERATING_END_TIME, TIME_SLOT_DURATION
- **Valores**: 07:00-23:00, slots de 60min, máx 5 pets/slot
- **Estado**: ✅ COMPLETADO - Configuraciones establecidas y probadas

#### **T1.1.4 - Crear Availability.cls** �
- **Propósito**: Modelo de datos para disponibilidad de walkers
- **Ubicación**: `/src/Demo/PETS/Scheduling/Availability.cls`
- **Contenido**: Walker, fecha, hora, capacidad, estado
- **Estado**: ⏳ PENDIENTE

#### **T1.1.5 - Crear SchedulingService.cls** 🗓️
- **Propósito**: Lógica de negocio para horarios
- **Ubicación**: `/src/Demo/PETS/Services/SchedulingService.cls`
- **Contenido**: Validaciones, CRUD de availability, consultas
- **Estado**: ⏳ PENDIENTE

---

**Notas:**
- Este plan será actualizado conforme avancemos
- Cada tarea completada se marcará con ✅
- Decisiones importantes se documentarán aquí
- Cambios de scope se reflejarán en el backlog

**🎯 Ready para comenzar desarrollo - Esperando aprobación del plan** 🚀
