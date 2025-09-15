/// Validador avanzado para slots de disponibilidad
/// Implementa todas las reglas de negocio y validaciones temporales
Class Demo.PETS.Services.AvailabilityValidator Extends %RegisteredObject
{

/// Validar disponibilidad completa con todas las reglas
ClassMethod ValidateSlotComplete(walkerId As %String, date As %Date, startTime As %Time, endTime As %Time, capacity As %Integer, specialRate As %Numeric = "") As %DynamicObject
{
    Set validation = {}
    Set validation.isValid = 1
    Set validation.errors = []
    Set validation.warnings = []
    
    // Validación 1: Walker existe
    If '##class(Demo.PETS.Walkers).%ExistsId(walkerId) {
        Set validation.isValid = 0
        Do validation.errors.%Push("Walker ID " _ walkerId _ " no existe")
        Return validation
    }
    
    // Validación 2: Fechas lógicas - no en el pasado
    Set currentDate = +$HOROLOG
    If date < currentDate {
        Set validation.isValid = 0
        Do validation.errors.%Push("No se puede crear disponibilidad en fechas pasadas")
    }
    
    // Validación 3: Límite máximo de 30 días hacia adelante
    Set maxBookingDays = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits().maxBookingDaysAhead
    If date > (currentDate + maxBookingDays) {
        Set validation.isValid = 0
        Do validation.errors.%Push("La fecha excede el límite máximo de " _ maxBookingDays _ " días hacia adelante")
    }
    
    // Validación 4: Horarios lógicos - inicio antes que fin
    If startTime >= endTime {
        Set validation.isValid = 0
        Do validation.errors.%Push("La hora de inicio debe ser anterior a la hora de fin")
    }
    
    // Validación 5: Duración mínima del slot (15 minutos)
    Set duration = endTime - startTime
    If duration < 900 {  // 900 segundos = 15 minutos
        Set validation.isValid = 0
        Do validation.errors.%Push("La duración mínima del slot debe ser 15 minutos")
    }
    
    // Validación 6: Duración máxima del slot (8 horas)
    If duration > 28800 {  // 28800 segundos = 8 horas
        Set validation.isValid = 0
        Do validation.errors.%Push("La duración máxima del slot es 8 horas")
    }
    
    // Validación 7: Horarios dentro del horario operativo
    Set operatingHours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
    Set operatingStart = $ZTIMEH(operatingHours.startTime)
    Set operatingEnd = $ZTIMEH(operatingHours.endTime)
    
    If startTime < operatingStart {
        Set validation.isValid = 0
        Do validation.errors.%Push("Hora de inicio fuera del horario operativo (" _ operatingHours.startTime _ " - " _ operatingHours.endTime _ ")")
    }
    
    If endTime > operatingEnd {
        Set validation.isValid = 0
        Do validation.errors.%Push("Hora de fin fuera del horario operativo (" _ operatingHours.startTime _ " - " _ operatingHours.endTime _ ")")
    }
    
    // Validación 8: Capacidad dentro de límites del sistema
    Set systemLimits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
    If capacity <= 0 {
        Set validation.isValid = 0
        Do validation.errors.%Push("La capacidad debe ser mayor a 0")
    }
    
    If capacity > systemLimits.maxPetsPerWalk {
        Set validation.isValid = 0
        Do validation.errors.%Push("Capacidad excede límite máximo por paseo: " _ systemLimits.maxPetsPerWalk)
    }
    
    // Validación 9: Conflictos de horario con slots existentes
    If ..HasScheduleConflict(walkerId, date, startTime, endTime) {
        Set validation.isValid = 0
        Do validation.errors.%Push("Conflicto de horario con slot existente")
    }
    
    // Validación 10: Tarifa especial lógica
    If specialRate '= "" {
        If specialRate < 0 {
            Set validation.isValid = 0
            Do validation.errors.%Push("La tarifa especial no puede ser negativa")
        }
        
        If specialRate > 1000 {
            Do validation.warnings.%Push("Tarifa especial muy alta ($" _ specialRate _ "), verificar si es correcta")
        }
    }
    
    // Validación 11: Límite diario de slots por walker
    Set dailySlots = ..CountWalkerDailySlots(walkerId, date)
    Set maxDailySlots = 10  // Máximo 10 slots por día
    If dailySlots >= maxDailySlots {
        Set validation.isValid = 0
        Do validation.errors.%Push("Walker ya tiene " _ dailySlots _ " slots en esta fecha (máximo " _ maxDailySlots _ ")")
    }
    
    // Validación 12: Días de la semana permitidos
    Set dayOfWeek = $ZDATE(date, 10)  // 1=Sunday, 2=Monday, etc.
    Set allowedDays = ##class(Demo.PETS.Services.ConfigService).GetOperatingDays()
    If 'allowedDays.%Get(dayOfWeek - 1) {
        Set validation.isValid = 0
        Do validation.errors.%Push("No se permite registrar disponibilidad en este día de la semana")
    }
    
    // Agregar metadata de validación
    Set validation.walkerId = walkerId
    Set validation.date = ##class(Demo.PETS.Availability).FormatDate(date)
    Set validation.timeSlot = ##class(Demo.PETS.Availability).FormatTime(startTime) _ " - " _ ##class(Demo.PETS.Availability).FormatTime(endTime)
    Set validation.capacity = capacity
    Set validation.duration = ..FormatDuration(duration)
    Set validation.validatedAt = $ZDATETIME($HOROLOG,3)
    
    Return validation
}

/// Verifica conflictos de horario específicos
ClassMethod HasScheduleConflict(walkerId As %String, date As %Date, startTime As %Time, endTime As %Time, excludeSlotId As %Integer = "") As %Boolean
{
    Set sql = "SELECT ID FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate = ? AND IsActive = 1 "
            _ "AND ((StartTime <= ? AND EndTime > ?) OR (StartTime < ? AND EndTime >= ?))"
    
    If excludeSlotId '= "" {
        Set sql = sql _ " AND ID != ?"
    }
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    If $$$ISERR(status) {
        Return 0
    }
    
    If excludeSlotId '= "" {
        Set resultSet = statement.%Execute(walkerId, date, startTime, startTime, endTime, endTime, excludeSlotId)
    } Else {
        Set resultSet = statement.%Execute(walkerId, date, startTime, startTime, endTime, endTime)
    }
    
    Return resultSet.%Next()
}

/// Cuenta slots diarios de un walker
ClassMethod CountWalkerDailySlots(walkerId As %String, date As %Date) As %Integer
{
    Set sql = "SELECT COUNT(*) AS SlotCount FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate = ? AND IsActive = 1"
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    If $$$ISERR(status) {
        Return 0
    }
    
    Set resultSet = statement.%Execute(walkerId, date)
    If resultSet.%Next() {
        Return resultSet.%Get("SlotCount")
    }
    
    Return 0
}

/// Valida actualización de slot existente
ClassMethod ValidateSlotUpdate(slotId As %Integer, newMaxPets As %Integer = "", newSpecialRate As %Numeric = "", newNotes As %String = "", newIsActive As %Boolean = "") As %DynamicObject
{
    Set validation = {}
    Set validation.isValid = 1
    Set validation.errors = []
    Set validation.warnings = []
    
    // Verificar que el slot existe
    Set slot = ##class(Demo.PETS.Availability).%OpenId(slotId)
    If '$IsObject(slot) {
        Set validation.isValid = 0
        Do validation.errors.%Push("Slot de disponibilidad no encontrado")
        Return validation
    }
    
    // Validar capacidad si se proporciona
    If newMaxPets '= "" {
        If newMaxPets <= 0 {
            Set validation.isValid = 0
            Do validation.errors.%Push("La capacidad debe ser mayor a 0")
        }
        
        If newMaxPets < slot.CurrentBookings {
            Set validation.isValid = 0
            Do validation.errors.%Push("No se puede reducir capacidad por debajo de reservas existentes (" _ slot.CurrentBookings _ ")")
        }
        
        Set systemLimits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
        If newMaxPets > systemLimits.maxPetsPerWalk {
            Set validation.isValid = 0
            Do validation.errors.%Push("Capacidad excede límite máximo: " _ systemLimits.maxPetsPerWalk)
        }
    }
    
    // Validar tarifa especial
    If newSpecialRate '= "" {
        If newSpecialRate < 0 {
            Set validation.isValid = 0
            Do validation.errors.%Push("La tarifa especial no puede ser negativa")
        }
    }
    
    // Validar desactivación
    If newIsActive '= "" && 'newIsActive {
        If slot.CurrentBookings > 0 {
            Set validation.isValid = 0
            Do validation.errors.%Push("No se puede desactivar slot con reservas existentes (" _ slot.CurrentBookings _ ")")
        }
    }
    
    // Advertencia sobre cambios en slots próximos
    Set daysToSlot = slot.AvailableDate - (+$HOROLOG)
    If daysToSlot <= 1 && slot.CurrentBookings > 0 {
        Do validation.warnings.%Push("Modificando slot con reservas para mañana o hoy - notificar a los clientes")
    }
    
    Set validation.slotId = slotId
    Set validation.currentBookings = slot.CurrentBookings
    Set validation.validatedAt = $ZDATETIME($HOROLOG,3)
    
    Return validation
}

/// Valida eliminación de slot
ClassMethod ValidateSlotDeletion(slotId As %Integer) As %DynamicObject
{
    Set validation = {}
    Set validation.isValid = 1
    Set validation.errors = []
    Set validation.warnings = []
    
    // Verificar que el slot existe
    Set slot = ##class(Demo.PETS.Availability).%OpenId(slotId)
    If '$IsObject(slot) {
        Set validation.isValid = 0
        Do validation.errors.%Push("Slot de disponibilidad no encontrado")
        Return validation
    }
    
    // No permitir eliminación con reservas
    If slot.CurrentBookings > 0 {
        Set validation.isValid = 0
        Do validation.errors.%Push("No se puede eliminar slot con reservas existentes (" _ slot.CurrentBookings _ ")")
    }
    
    // Advertencia sobre eliminación de slots próximos
    Set daysToSlot = slot.AvailableDate - (+$HOROLOG)
    If daysToSlot <= 3 {
        Do validation.warnings.%Push("Eliminando slot próximo (en " _ daysToSlot _ " días) - podría afectar planificación de clientes")
    }
    
    Set validation.slotId = slotId
    Set validation.slotDate = ##class(Demo.PETS.Availability).FormatDate(slot.AvailableDate)
    Set validation.slotTime = ##class(Demo.PETS.Availability).FormatTime(slot.StartTime) _ " - " _ ##class(Demo.PETS.Availability).FormatTime(slot.EndTime)
    Set validation.validatedAt = $ZDATETIME($HOROLOG,3)
    
    Return validation
}

/// Formatea duración en formato legible
ClassMethod FormatDuration(seconds As %Integer) As %String
{
    Set hours = seconds \ 3600
    Set minutes = (seconds # 3600) \ 60
    
    If hours > 0 {
        Return hours _ "h " _ minutes _ "m"
    } Else {
        Return minutes _ "m"
    }
}

/// Validador express para formularios web (versión simplificada)
ClassMethod ValidateQuick(walkerId As %String, dateStr As %String, startTime As %String, endTime As %String, maxPets As %Integer) As %DynamicObject
{
    Set validation = {}
    Set validation.isValid = 1
    Set validation.errors = []
    
    Try {
        // Convertir fecha
        Set date = $ZDATEUTH(dateStr, 5)  // YYYY-MM-DD
        
        // Convertir tiempos
        Set startTimeSeconds = $ZTIMEH(startTime)
        Set endTimeSeconds = $ZTIMEH(endTime)
        
        // Usar validador completo
        Set fullValidation = ..ValidateSlotComplete(walkerId, date, startTimeSeconds, endTimeSeconds, maxPets)
        
        // Simplificar respuesta para formularios
        Set validation.isValid = fullValidation.isValid
        Set validation.errors = fullValidation.errors
        Set validation.summary = fullValidation.errors.%Size() _ " error(s) found"
        
    } Catch ex {
        Set validation.isValid = 0
        Do validation.errors.%Push("Error de formato en los datos: " _ ex.DisplayString())
    }
    
    Return validation
}

}
