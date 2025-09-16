/// Servicio de Scheduling para PETS - Coordina lógica de negocio entre ConfigService y Availability
/// Implementa supply-driven scheduling donde walkers publican disponibilidad
Class Demo.PETS.Services.SchedulingService Extends %RegisteredObject
{

/// Obtiene todos los slots disponibles para una fecha específica
/// Retorna array con información completa de cada slot
ClassMethod GetAvailableSlots(date As %Date) As %DynamicArray
{
    set result = []
    set config = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
    
    // Query para obtener slots disponibles en la fecha
    set sql = "SELECT Walker, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE AvailableDate = ? AND IsActive = 1 "
            _ "ORDER BY StartTime, Walker"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return result
    }
    
    set resultSet = statement.%Execute(date)
    while resultSet.%Next() {
        set slot = {}
        set slot.walkerId = resultSet.%Get("Walker")
        set slot.startTime = ..FormatTime(resultSet.%Get("StartTime"))
        set slot.endTime = ..FormatTime(resultSet.%Get("EndTime"))
        set slot.maxCapacity = resultSet.%Get("MaxPets")
        set slot.currentBookings = resultSet.%Get("CurrentBookings")
        set slot.availableSlots = resultSet.%Get("MaxPets") - resultSet.%Get("CurrentBookings")
        set slot.pricePerWalk = resultSet.%Get("SpecialRate")
        set slot.notes = resultSet.%Get("Notes")
        set slot.date = ##class(Demo.PETS.Availability).FormatDate(date)
        
        // Agregar información del walker si existe
        set walkerInfo = ..GetWalkerInfo(resultSet.%Get("Walker"))
        if walkerInfo '= "" {
            set slot.walkerName = walkerInfo
        }
        
        do result.%Push(slot)
    }
    
    return result
}

/// Obtiene slots disponibles para un walker específico en una fecha
ClassMethod GetWalkerAvailability(walkerId As %String, date As %Date) As %DynamicArray
{
    set result = []
    
    set sql = "SELECT StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate = ? AND IsActive = 1 "
            _ "ORDER BY StartTime"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return result
    }
    
    set resultSet = statement.%Execute(walkerId, date)
    while resultSet.%Next() {
        set slot = {}
        set slot.startTime = ..FormatTime(resultSet.%Get("StartTime"))
        set slot.endTime = ..FormatTime(resultSet.%Get("EndTime"))
        set slot.maxCapacity = resultSet.%Get("MaxPets")
        set slot.currentBookings = resultSet.%Get("CurrentBookings")
        set slot.availableSlots = resultSet.%Get("MaxPets") - resultSet.%Get("CurrentBookings")
        set slot.pricePerWalk = resultSet.%Get("SpecialRate")
        set slot.notes = resultSet.%Get("Notes")
        set slot.date = ##class(Demo.PETS.Availability).FormatDate(date)
        
        do result.%Push(slot)
    }
    
    return result
}

/// Busca disponibilidad por criterios específicos
ClassMethod SearchAvailability(startDate As %Date, endDate As %Date, timeSlot As %String = "", maxPrice As %Numeric = "") As %DynamicArray
{
    set result = []
    
    // Construcción dinámica de query según criterios
    set sql = "SELECT Walker, AvailableDate, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE AvailableDate BETWEEN ? AND ? AND IsActive = 1"
    
    set params = 2
    if timeSlot '= "" {
        set sql = sql _ " AND StartTime = ?"
        set params = params + 1
    }
    if maxPrice '= "" {
        set sql = sql _ " AND SpecialRate <= ?"
        set params = params + 1
    }
    
    set sql = sql _ " ORDER BY AvailableDate, StartTime, Walker"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return result
    }
    
    // Ejecutar con parámetros dinámicos
    if params = 2 {
        set resultSet = statement.%Execute(startDate, endDate)
    } elseif params = 3 {
        if timeSlot '= "" {
            set resultSet = statement.%Execute(startDate, endDate, timeSlot)
        } else {
            set resultSet = statement.%Execute(startDate, endDate, maxPrice)
        }
    } else {
        set resultSet = statement.%Execute(startDate, endDate, timeSlot, maxPrice)
    }
    
    while resultSet.%Next() {
        set slot = {}
        set slot.walkerId = resultSet.%Get("Walker")
        set slot.date = ##class(Demo.PETS.Availability).FormatDate(resultSet.%Get("AvailableDate"))
        set slot.startTime = ..FormatTime(resultSet.%Get("StartTime"))
        set slot.endTime = ..FormatTime(resultSet.%Get("EndTime"))
        set slot.maxCapacity = resultSet.%Get("MaxPets")
        set slot.currentBookings = resultSet.%Get("CurrentBookings")
        set slot.availableSlots = resultSet.%Get("MaxPets") - resultSet.%Get("CurrentBookings")
        set slot.pricePerWalk = resultSet.%Get("SpecialRate")
        set slot.notes = resultSet.%Get("Notes")
        
        set walkerInfo = ..GetWalkerInfo(resultSet.%Get("Walker"))
        if walkerInfo '= "" {
            set slot.walkerName = walkerInfo
        }
        
        do result.%Push(slot)
    }
    
    return result
}

/// Valida si un horario está dentro de las horas operativas
ClassMethod ValidateOperatingHours(startTime As %Time, endTime As %Time) As %Boolean
{
    Try {
        Set hours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
        
        // Obtener horarios operativos usando %Get
        Set operatingStart = hours.%Get("startTime", "06:00")
        Set operatingEnd = hours.%Get("endTime", "20:00")
        
        // Convertir a segundos para comparación más precisa
        Set opStartSeconds = ..TimeToSeconds(operatingStart)
        Set opEndSeconds = ..TimeToSeconds(operatingEnd)
        
        // Si no tenemos horarios válidos, aceptar cualquier horario razonable (6 AM - 8 PM)
        If (opStartSeconds = 0) || (opEndSeconds = 0) {
            Set opStartSeconds = 6 * 3600  // 06:00
            Set opEndSeconds = 20 * 3600   // 20:00
        }
        
        // Validar que el slot propuesto esté dentro del rango operativo
        If (startTime < opStartSeconds) || (endTime > opEndSeconds) {
            Return 0
        }
        
        Return 1
        
    } Catch ex {
        // En caso de error, ser permisivo con horarios razonables
        If (startTime >= (6*3600)) && (endTime <= (20*3600)) {
            Return 1
        }
        Return 0
    }
}

/// Convierte string de tiempo HH:MM a segundos
ClassMethod TimeToSeconds(timeStr As %String) As %Integer
{
    If timeStr = "" Return 0
    Set h = +$PIECE(timeStr, ":", 1)
    Set m = +$PIECE(timeStr, ":", 2)
    Return (h * 3600) + (m * 60)
}

/// Calcula el precio total para múltiples mascotas usando ConfigService
ClassMethod CalculateTotalPrice(basePrice As %Numeric, petCount As %Integer) As %Numeric
{
    return ##class(Demo.PETS.Services.ConfigService).CalculateWalkPrice(basePrice, petCount)
}

/// Genera slots de tiempo sugeridos para un día usando configuraciones
ClassMethod GenerateSuggestedTimeSlots(date As %Date) As %DynamicArray
{
    return ##class(Demo.PETS.Services.ConfigService).GenerateTimeSlots(date)
}

/// Obtiene estadísticas de disponibilidad para un rango de fechas
ClassMethod GetAvailabilityStats(startDate As %Date, endDate As %Date) As %DynamicObject
{
    set stats = {}
    
    set sql = "SELECT COUNT(*) AS TotalSlots, "
            _ "SUM(MaxPets) AS TotalCapacity, "
            _ "SUM(CurrentBookings) AS TotalBookings, "
            _ "AVG(SpecialRate) AS AvgPrice, "
            _ "COUNT(DISTINCT Walker) AS UniqueWalkers "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE AvailableDate BETWEEN ? AND ? AND IsActive = 1"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return stats
    }
    
    set resultSet = statement.%Execute(startDate, endDate)
    if resultSet.%Next() {
        set stats.totalSlots = resultSet.%Get("TotalSlots")
        set stats.totalCapacity = resultSet.%Get("TotalCapacity")
        set stats.totalBookings = resultSet.%Get("TotalBookings")
        set stats.availableCapacity = resultSet.%Get("TotalCapacity") - resultSet.%Get("TotalBookings")
        set stats.occupancyRate = ""
        if resultSet.%Get("TotalCapacity") > 0 {
            set stats.occupancyRate = $FNUMBER((resultSet.%Get("TotalBookings") / resultSet.%Get("TotalCapacity")) * 100, "", 2) _ "%"
        }
        set stats.averagePrice = ""
        if resultSet.%Get("AvgPrice") '= "" {
            set stats.averagePrice = "$" _ $FNUMBER(resultSet.%Get("AvgPrice"), "", 2)
        }
        set stats.uniqueWalkers = resultSet.%Get("UniqueWalkers")
        set stats.dateRange = ##class(Demo.PETS.Availability).FormatDate(startDate) _ " - " _ ##class(Demo.PETS.Availability).FormatDate(endDate)
    }
    
    return stats
}

/// Verifica si hay conflictos de horario para un walker específico
ClassMethod CheckScheduleConflicts(walkerId As %String, date As %Date, startTime As %Time, endTime As %Time) As %Boolean
{
    // Debug: registrar parámetros de búsqueda
    // Write "DEBUG: Buscando conflictos para Walker=", walkerId, ", Date=", $ZDATE(date, 1), ", Time=", $ZTIME(startTime, 1), "-", $ZTIME(endTime, 1), !
    
    set sql = "SELECT ID, StartTime, EndTime FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate = ? AND IsActive = 1 "
            _ "AND ((StartTime <= ? AND EndTime > ?) OR (StartTime < ? AND EndTime >= ?))"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        // Write "DEBUG: Error preparando SQL: ", $SYSTEM.Status.GetOneErrorText(status), !
        return 0
    }
    
    set resultSet = statement.%Execute(walkerId, date, startTime, startTime, endTime, endTime)
    set hasConflict = resultSet.%Next()
    
    // Debug: mostrar resultados si hay conflicto
    // if hasConflict {
    //     Write "DEBUG: Conflicto encontrado - ID=", resultSet.%Get("ID"), ", Existing=", $ZTIME(resultSet.%Get("StartTime"), 1), "-", $ZTIME(resultSet.%Get("EndTime"), 1), !
    // }
    
    return hasConflict
}

/// Obtiene los próximos slots disponibles para un walker
ClassMethod GetUpcomingSlots(walkerId As %String, days As %Integer = 7) As %DynamicArray
{
    set result = []
    set currentDate = +$HOROLOG
    set endDate = currentDate + days
    
    set sql = "SELECT AvailableDate, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate BETWEEN ? AND ? AND IsActive = 1 "
            _ "ORDER BY AvailableDate, StartTime"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return result
    }
    
    set resultSet = statement.%Execute(walkerId, currentDate, endDate)
    while resultSet.%Next() {
        if (resultSet.%Get("MaxPets") - resultSet.%Get("CurrentBookings")) > 0 {
            set slot = {}
            set slot.date = ##class(Demo.PETS.Availability).FormatDate(resultSet.%Get("AvailableDate"))
            set slot.startTime = ..FormatTime(resultSet.%Get("StartTime"))
            set slot.endTime = ..FormatTime(resultSet.%Get("EndTime"))
            set slot.availableSlots = resultSet.%Get("MaxPets") - resultSet.%Get("CurrentBookings")
            set slot.pricePerWalk = resultSet.%Get("SpecialRate")
            
            do result.%Push(slot)
        }
    }
    
    return result
}

/// Método auxiliar para formatear tiempo (reutiliza lógica de Availability)
ClassMethod FormatTime(timeValue As %Time) As %String
{
    return ##class(Demo.PETS.Availability).FormatTime(timeValue)
}

/// Método auxiliar para obtener información del walker
/// Por ahora retorna el ID, se puede expandir cuando se implemente User management
ClassMethod GetWalkerInfo(walkerId As %String) As %String
{
    // Placeholder - en el futuro conectará con tabla de Usuarios/Walkers
    return "Walker " _ walkerId
}

/// Valida disponibilidad antes de crear/actualizar slots
ClassMethod ValidateAvailabilitySlot(walkerId As %String, date As %Date, startTime As %Time, endTime As %Time, capacity As %Integer) As %DynamicObject
{
    set validation = {}
    set validation.isValid = 1
    set validation.errors = []
    
    // Validar horarios operativos con mensaje informativo
    if '..ValidateOperatingHours(startTime, endTime) {
        set validation.isValid = 0
        set hours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
        set opStart = $GET(hours.startTime, "06:00")
        set opEnd = $GET(hours.endTime, "20:00")
        do validation.errors.%Push("Horario debe estar entre " _ opStart _ " y " _ opEnd _ " (horario operativo)")
    }
    
    // Validar conflictos de horario
    if ..CheckScheduleConflicts(walkerId, date, startTime, endTime) {
        set validation.isValid = 0
        do validation.errors.%Push("Conflicto de horario con slot existente para walker " _ walkerId _ " el " _ $ZDATE(date, 1) _ " de " _ $ZTIME(startTime, 1) _ " a " _ $ZTIME(endTime, 1))
    }
    
    // Validar capacidad usando límites del sistema con mensaje informativo
    set limits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
    set maxAllowed = limits.%Get("maxPetsPerWalk", 5)  // Usar %Get con default
    if capacity > maxAllowed {
        set validation.isValid = 0
        do validation.errors.%Push("Máximo " _ maxAllowed _ " mascotas permitidas por turno")
    }
    
    // Validar que la capacidad sea al menos 1
    if capacity < 1 {
        set validation.isValid = 0
        do validation.errors.%Push("Debe permitir al menos 1 mascota")
    }
    
    // Validar que la fecha no sea en el pasado
    if date < (+$HOROLOG) {
        set validation.isValid = 0
        do validation.errors.%Push("No se puede crear disponibilidad en fechas pasadas")
    }
    
    // Validar que hora inicio < hora fin
    if startTime >= endTime {
        set validation.isValid = 0
        do validation.errors.%Push("La hora de inicio debe ser anterior a la hora de fin")
    }
    
    return validation
}

}
