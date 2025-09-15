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
    set hours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
    set operatingStart = $PIECE(hours.startTime, ":", 1, 2)
    set operatingEnd = $PIECE(hours.endTime, ":", 1, 2)
    
    set startHour = $PIECE(..FormatTime(startTime), ":", 1, 2)
    set endHour = $PIECE(..FormatTime(endTime), ":", 1, 2)
    
    if (startHour < operatingStart) || (endHour > operatingEnd) {
        return 0
    }
    
    return 1
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

/// Verifica si hay conflictos de horario para un walker
ClassMethod CheckScheduleConflicts(walkerId As %String, date As %Date, startTime As %Time, endTime As %Time) As %Boolean
{
    set sql = "SELECT ID FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate = ? AND IsActive = 1 "
            _ "AND ((StartTime <= ? AND EndTime > ?) OR (StartTime < ? AND EndTime >= ?))"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        return 0
    }
    
    set resultSet = statement.%Execute(walkerId, date, startTime, startTime, endTime, endTime)
    return resultSet.%Next()
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
    
    // Validar horarios operativos
    if '..ValidateOperatingHours(startTime, endTime) {
        set validation.isValid = 0
        do validation.errors.%Push("Horario fuera del horario operativo")
    }
    
    // Validar conflictos de horario
    if ..CheckScheduleConflicts(walkerId, date, startTime, endTime) {
        set validation.isValid = 0
        do validation.errors.%Push("Conflicto de horario con slot existente")
    }
    
    // Validar capacidad usando límites del sistema
    set limits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
    if capacity > limits.maxPetsPerWalk {
        set validation.isValid = 0
        do validation.errors.%Push("Capacidad excede límite máximo por paseo: " _ limits.maxPetsPerWalk)
    }
    
    // Validar que la fecha no sea en el pasado
    if date < (+$HOROLOG) {
        set validation.isValid = 0
        do validation.errors.%Push("No se puede crear disponibilidad en fechas pasadas")
    }
    
    return validation
}

}
