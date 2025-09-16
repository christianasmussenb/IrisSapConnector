# 🚀 SPRINT 2.1 - SISTEMA DE BOOKINGS PERSISTENTE

**Fecha:** 16 de septiembre de 2025  
**Duración Estimada:** 8-12 horas  
**Prioridad:** 🔴 ALTA  
**Estado:** 📋 PLANIFICADO  

---

## 🎯 **OBJETIVO PRINCIPAL**

Implementar un sistema persistente de reservas (bookings) que reemplace el sistema placeholder actual en `OwnerAvailabilityView.cls`, permitiendo gestión completa de reservas entre owners y walkers con almacenamiento en base de datos.

---

## 📊 **ANÁLISIS DE ESTADO ACTUAL**

### ✅ **Sistema Actual Completado (Sprint 1.1-1.4):**

#### **Clases Base Existentes:**
- ✅ **`Demo.PETS.Availability.cls`** - Disponibilidad de walkers (399 líneas)
- ✅ **`Demo.PETS.Owners.cls`** - Gestión de propietarios
- ✅ **`Demo.PETS.Pets.cls`** - Gestión de mascotas  
- ✅ **`Demo.PETS.Walkers.cls`** - Gestión de paseadores
- ✅ **`Demo.REST.OwnerAvailabilityView.cls`** - Interfaz calendario (617 líneas)

#### **Servicios Operativos:**
- ✅ **`Demo.PETS.Services.ConfigService.cls`** - Configuración centralizada
- ✅ **`Demo.PETS.Services.SchedulingService.cls`** - Validación de horarios
- ✅ **`Demo.PETS.Services.AvailabilityValidator.cls`** - Validaciones especializadas
- ✅ **Suite de Testing** - Pruebas automatizadas funcionales

#### **Sistema Placeholder Actual:**
```objectscript
// En OwnerAvailabilityView.cls línea 418+
ClassMethod BookSlot() As %Status {
    // Crear booking (placeholder - se implementará en Sprint 2.1)
    Set result = {}
    Set result.success = 1
    Set result.message = "Reserva confirmada exitosamente"
    Set result.bookingId = "BOOK-" _ $RANDOM(9999) + 1000
    // ... resto del placeholder
}
```

### 🎯 **Gap a Resolver:**
1. **No hay persistencia** - Las reservas no se almacenan
2. **No hay gestión de estados** - Sin tracking PENDING/CONFIRMED/CANCELLED
3. **No hay actualización de disponibilidad** - Slots no se marcan como ocupados
4. **No hay interfaces de gestión** - Owners/walkers no pueden ver sus bookings

---

## 📋 **TAREAS SPRINT 2.1**

### **T2.1.1 - Crear Modelo Bookings.cls** ⏱️ 2-3 horas
**Archivo:** `/PETS/Demo/PETS/Scheduling/Bookings.cls`

#### **Especificaciones:**
```objectscript
Class Demo.PETS.Scheduling.Bookings Extends %Persistent
{
    // Relaciones principales
    Property Owner As Demo.PETS.Owners [ Required ];
    Property Pet As Demo.PETS.Pets [ Required ];
    Property Walker As Demo.PETS.Walkers [ Required ];
    Property Availability As Demo.PETS.Availability [ Required ];
    
    // Datos de la reserva
    Property BookingDate As %Date [ Required ];
    Property StartTime As %Time [ Required ];
    Property EndTime As %Time [ Required ];
    Property Status As %String [ Required ]; // PENDING, CONFIRMED, COMPLETED, CANCELLED
    
    // Información financiera
    Property Amount As %Numeric(10,2);
    Property Currency As %String [ InitialExpression = "USD" ];
    
    // Metadatos
    Property SpecialInstructions As %Text;
    Property BookingType As %String [ InitialExpression = "SUPPLY_DRIVEN" ];
    Property BookingReference As %String; // ID único para referencias
    
    // Timestamps
    Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];
    Property ConfirmedAt As %TimeStamp;
    Property CompletedAt As %TimeStamp;
    Property CancelledAt As %TimeStamp;
    
    // Índices para performance
    Index OwnerIdx On Owner;
    Index WalkerIdx On Walker;
    Index StatusIdx On Status;
    Index DateIdx On BookingDate;
    Index AvailabilityIdx On Availability;
    Index ReferenceIdx On BookingReference [ Unique ];
}
```

#### **Métodos Requeridos:**
- `GenerateBookingReference()` - Generar ID único
- `UpdateStatus(status, userId)` - Cambiar estado con audit
- `CalculateAmount()` - Calcular tarifa automáticamente
- `IsModifiable()` - Verificar si se puede modificar
- `GetTimeSlotInfo()` - Información del slot reservado

---

### **T2.1.2 - Crear BookingService.cls** ⏱️ 3-4 horas
**Archivo:** `/PETS/Demo/PETS/Services/BookingService.cls`

#### **Métodos Core:**

```objectscript
ClassMethod CreateBooking(ownerId, petId, walkerId, availabilityId, instructions) As %DynamicObject
{
    // 1. Validar disponibilidad en tiempo real
    // 2. Crear registro Booking con status PENDING
    // 3. Actualizar CurrentBookings en Availability
    // 4. Generar reference único
    // 5. Retornar respuesta estandarizada
}

ClassMethod ValidateBooking(availabilityId) As %DynamicObject  
{
    // 1. Verificar que availability existe y está activa
    // 2. Verificar que no se supere MaxPets
    // 3. Verificar que walker está activo
    // 4. Verificar políticas de tiempo (no pasado, dentro límites)
    // 5. Retornar validation result
}

ClassMethod CancelBooking(bookingId, userId, reason) As %DynamicObject
{
    // 1. Verificar que booking existe y es modificable  
    // 2. Actualizar status a CANCELLED
    // 3. Liberar slot (decrementar CurrentBookings)
    // 4. Registrar timestamp y razón
    // 5. Retornar confirmación
}

ClassMethod GetBookingsByOwner(ownerId, status, limit) As %DynamicObject
ClassMethod GetBookingsByWalker(walkerId, status, limit) As %DynamicObject  
ClassMethod GetBookingsByDate(date, walkerId) As %DynamicObject
ClassMethod ConfirmBooking(bookingId, walkerId) As %DynamicObject
```

#### **Validaciones Críticas:**
- ✅ Verificar disponibilidad real-time antes de crear
- ✅ Prevenir double-booking con locks transaccionales
- ✅ Validar ownership (owner solo puede cancelar sus bookings)
- ✅ Verificar timing (no reservar en el pasado)
- ✅ Límites de capacidad por slot

---

### **T2.1.3 - Integrar con OwnerAvailabilityView** ⏱️ 2-3 horas

#### **Cambios en `BookSlot()` method:**
```objectscript
ClassMethod BookSlot() As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    Try {
        // Obtener parámetros (existing)
        Set date = %request.Get("date")
        Set time = %request.Get("time") 
        Set walkerId = %request.Get("walkerId")
        Set petId = %request.Get("petId")
        Set ownerId = %request.Get("ownerId")
        Set instructions = %request.Get("instructions")
        
        // NUEVO: Usar BookingService en lugar de placeholder
        Set availabilityId = ..FindAvailabilitySlot(walkerId, date, time)
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(ownerId, petId, walkerId, availabilityId, instructions)
        
        Write result.%ToJSON()
        Return $$$OK
        
    } Catch ex {
        // Error handling
        Set error = {}
        Set error.success = 0
        Set error.error = ex.DisplayString()
        Write error.%ToJSON()
        Return $$$OK
    }
}
```

#### **Nuevos Methods Requeridos:**
- `FindAvailabilitySlot(walkerId, date, time)` - Localizar availability record
- `UpdateCalendarDisplay()` - Refrescar slots ocupados en UI
- `GetRealTimeAvailability()` - Verificar slots actuales vs reservados

---

### **T2.1.4 - Crear Interfaces Gestión Reservas** ⏱️ 2-3 horas

#### **A. Vista para Owners: `/PETS/Demo/REST/OwnerBookingManager.cls`**
```objectscript
Class Demo.REST.OwnerBookingManager Extends %CSP.REST
{
    // Rutas:
    // GET /my-bookings -> Listar reservas del owner
    // POST /cancel -> Cancelar reserva
    // GET /booking/:id -> Ver detalles de reserva
}
```

#### **B. Vista para Walkers: `/PETS/Demo/REST/WalkerBookingManager.cls`**  
```objectscript
Class Demo.REST.WalkerBookingManager Extends %CSP.REST
{
    // Rutas:
    // GET /my-schedule -> Ver agenda del walker
    // POST /confirm -> Confirmar reserva pendiente
    // POST /complete -> Marcar paseo como completado
}
```

#### **C. Dashboard Integration en `Demo.REST.cls`:**
- Agregar rutas para acceso a booking management
- Links desde página principal a "Mis Reservas" y "Mi Agenda"

---

### **T2.1.5 - Testing y Validación** ⏱️ 1-2 horas

#### **Suite de Pruebas: `BookingServiceTest.cls`**
```objectscript
Class Demo.PETS.Services.BookingServiceTest Extends Demo.PETS.Services.Base
{
    // Casos de prueba críticos:
    ClassMethod TestCreateBookingSuccess()
    ClassMethod TestCreateBookingOverbooking()  
    ClassMethod TestCancelBookingSuccess()
    ClassMethod TestValidateBookingAvailable()
    ClassMethod TestValidateBookingFull()
    ClassMethod TestDoubleBookingPrevention()
}
```

#### **Pruebas de Integración:**
- ✅ Crear booking desde calendario UI
- ✅ Verificar persistencia en base de datos
- ✅ Verificar actualización de CurrentBookings
- ✅ Verificar que slots ocupados no aparecen disponibles
- ✅ Cancelación y liberación de slots

---

## 🗺️ **FLUJO DE IMPLEMENTACIÓN**

### **Fase 1: Fundaciones (Día 1 - 4-5 horas)**
1. ⏰ **09:00-10:30** → Crear `Bookings.cls` con propiedades y métodos base
2. ⏰ **10:30-12:00** → Implementar `BookingService.cls` métodos core  
3. ⏰ **14:00-15:30** → Testing unitario de modelos y servicios
4. ⏰ **15:30-17:00** → Debugging y refinamiento

### **Fase 2: Integración (Día 2 - 4-5 horas)**
1. ⏰ **09:00-10:30** → Modificar `OwnerAvailabilityView.BookSlot()`
2. ⏰ **10:30-12:00** → Implementar interfaces de gestión para owners/walkers
3. ⏰ **14:00-15:30** → Testing end-to-end de flujo completo
4. ⏰ **15:30-17:00** → Validación UI y debugging final

---

## 📊 **MÉTRICAS DE ÉXITO**

### **Funcionales:**
- [ ] ✅ 100% de bookings se persisten correctamente
- [ ] ✅ 0% double-booking (slots no se sobrevenden)  
- [ ] ✅ 100% de cancelaciones liberan slots apropiadamente
- [ ] ✅ Owners pueden ver todas sus reservas
- [ ] ✅ Walkers pueden gestionar su agenda

### **Técnicas:**
- [ ] ✅ 0 errores de compilación IRIS
- [ ] ✅ 100% test coverage en BookingService
- [ ] ✅ < 500ms tiempo respuesta para operaciones CRUD
- [ ] ✅ Transacciones atómicas para crear/cancelar bookings

### **UX:**
- [ ] ✅ Calendario muestra slots ocupados correctamente
- [ ] ✅ Confirmaciones claras de reservas exitosas/fallidas
- [ ] ✅ Interfaces intuitivas para gestión de reservas
- [ ] ✅ Estados de booking visibles y comprensibles

---

## 🔧 **CONSIDERACIONES TÉCNICAS**

### **Performance:**
- Usar índices apropiados para consultas frecuentes
- Implementar paginación en listados de bookings  
- Cache de availability data para reducir queries

### **Concurrencia:**
- Locks transaccionales para prevenir double-booking
- Validación real-time antes de commit
- Rollback automático en caso de conflictos

### **Escalabilidad:**
- Estructura preparada para múltiples tipos de booking
- Referencias únicas para integración futura
- Timestamps completos para auditoría

---

## 🚀 **ENTREGABLES FINALES**

### **Clases Nuevas:**
1. `/PETS/Demo/PETS/Scheduling/Bookings.cls` - Modelo persistente
2. `/PETS/Demo/PETS/Services/BookingService.cls` - Lógica de negocio  
3. `/PETS/Demo/REST/OwnerBookingManager.cls` - Interface owners
4. `/PETS/Demo/REST/WalkerBookingManager.cls` - Interface walkers
5. `/PETS/Demo/PETS/Services/BookingServiceTest.cls` - Suite pruebas

### **Clases Modificadas:**
1. `/PETS/Demo/REST/OwnerAvailabilityView.cls` - Reemplazar placeholder
2. `/PETS/Demo/REST.cls` - Agregar rutas booking management

### **URLs Nuevas Funcionales:**
- `http://localhost:52773/csp/pets/my-bookings` - Reservas owner
- `http://localhost:52773/csp/pets/my-schedule` - Agenda walker  
- `http://localhost:52773/csp/pets/owner-availability` - **MEJORADO** (sin placeholder)

---

**🎯 RESULTADO ESPERADO:** Sistema completo de reservas persistentes integrado con el calendario existente, permitiendo gestión full-lifecycle de bookings owner ↔ walker con interfaces web profesionales.

**📈 PROGRESO:** Sprint 2.1 completará la funcionalidad core de reservas, estableciendo base sólida para Sprint 2.2 (sistema financiero) y Sprint 2.3 (confirmaciones avanzadas).