/// Clase persistente para gestionar la disponibilidad de walkers
/// Permite registrar horarios disponibles por walker para reservas
Class Demo.PETS.Availability Extends %Persistent
{

/// Walker que está disponible
Property Walker As Demo.PETS.Walkers [ Required ];

/// Fecha de disponibilidad
Property AvailableDate As %Date [ Required ];

/// Hora de inicio del slot disponible
Property StartTime As %Time [ Required ];

/// Hora de fin del slot disponible
Property EndTime As %Time [ Required ];

/// Máximo número de mascotas que puede pasear en este slot
Property MaxPets As %Integer [ InitialExpression = 5, Required ];

/// Número actual de reservas confirmadas para este slot
Property CurrentBookings As %Integer [ InitialExpression = 0 ];

/// Indica si este slot está activo y disponible
Property IsActive As %Boolean [ InitialExpression = 1 ];

Property SpecialRate As %Numeric;

/// Tarifa especial para este slot (opcional)
/// Notas especiales sobre este slot de disponibilidad
Property Notes As %String(MAXLEN = 500);

/// Fecha de creación del registro
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Fecha de última actualización
Property UpdatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Índice único: un walker no puede tener slots solapados
Index WalkerTimeIdx On (Walker, AvailableDate, StartTime) [ Unique ];

/// Índice por fecha para consultas rápidas
Index DateIdx On AvailableDate;

/// Índice por walker para consultas de disponibilidad
Index WalkerIdx On Walker;

/// Índice compuesto para búsquedas eficientes
Index ActiveSlotsIdx On (IsActive, AvailableDate, StartTime);

/// Método para verificar si el slot tiene capacidad disponible
Method HasCapacity() As %Boolean
{
    Return (..CurrentBookings < ..MaxPets) && (..IsActive = 1)
}

/// Método para obtener capacidad restante
Method GetRemainingCapacity() As %Integer
{
    If ..IsActive {
        Return ..MaxPets - ..CurrentBookings
    }
    Return 0
}

/// Método para incrementar el número de reservas
Method IncrementBookings() As %Status
{
    If ..CurrentBookings < ..MaxPets {
        Set ..CurrentBookings = ..CurrentBookings + 1
        Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
        Return ..%Save()
    }
    Return $$$ERROR(5001, "Slot ya está lleno - no se pueden agregar más reservas")
}

/// Método para decrementar el número de reservas (cancelación)
Method DecrementBookings() As %Status
{
    If ..CurrentBookings > 0 {
        Set ..CurrentBookings = ..CurrentBookings - 1
        Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
        Return ..%Save()
    }
    Return $$$ERROR(5001, "No hay reservas para decrementar")
}

/// Método para obtener el precio efectivo del slot
Method GetEffectiveRate() As %Numeric
{
    // Si hay precio especial, usarlo
    If ..SpecialRate > 0 {
        Return ..SpecialRate
    }
    
    // Si no, usar la tarifa del walker
    If $IsObject(..Walker) && (..Walker.HourlyRate > 0) {
        Return ..Walker.HourlyRate
    }
    
    // Si no hay tarifa del walker, usar precio por defecto del sistema
    Return +##class(Demo.PETS.Services.ConfigService).GetSetting("DEFAULT_WALK_PRICE")
}

/// Validaciones antes de guardar
Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
    Set sc = $$$OK
    
    Try {
        // Validar que la fecha no sea en el pasado
        Set today = +$HOROLOG
        If ..AvailableDate < today {
            Return $$$ERROR(5001, "No se puede crear disponibilidad en fechas pasadas")
        }
        
        // Validar que la fecha no sea muy lejana
        Set limits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
        Set maxDaysAhead = limits.maxBookingDaysAhead
        If (..AvailableDate - today) > maxDaysAhead {
            Return $$$ERROR(5001, "Fecha muy lejana - máximo " _ maxDaysAhead _ " días en el futuro")
        }
        
        // Validar que las horas estén en el rango operativo
        Set hours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
        Set startTimeStr = $ZTIME(..StartTime, 1)
        Set endTimeStr = $ZTIME(..EndTime, 1)
        
        If '##class(Demo.PETS.Services.ConfigService).IsValidOperatingTime(startTimeStr) {
            Return $$$ERROR(5001, "Hora de inicio fuera del horario operativo (" _ hours.startTime _ " - " _ hours.endTime _ ")")
        }
        
        If '##class(Demo.PETS.Services.ConfigService).IsValidOperatingTime(endTimeStr) {
            Return $$$ERROR(5001, "Hora de fin fuera del horario operativo (" _ hours.startTime _ " - " _ hours.endTime _ ")")
        }
        
        // Validar que hora de inicio sea antes que hora de fin
        If ..StartTime >= ..EndTime {
            Return $$$ERROR(5001, "Hora de inicio debe ser anterior a hora de fin")
        }
        
        // Validar MaxPets no exceda límite del sistema
        Set systemMaxPets = limits.maxPetsPerSlot
        If ..MaxPets > systemMaxPets {
            Return $$$ERROR(5001, "Máximo de mascotas no puede exceder " _ systemMaxPets)
        }
        
        // Actualizar timestamp
        Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    
    Return sc
}

/// Método de clase para buscar disponibilidad por fecha
ClassMethod FindByDate(searchDate As %Date) As %SQL.StatementResult
{
    Set sql = "SELECT ID, Walker, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes "_
              "FROM Demo_PETS.Availability "_
              "WHERE AvailableDate = ? AND IsActive = 1 "_
              "ORDER BY StartTime, Walker"
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    
    If $$$ISOK(status) {
        Return statement.%Execute(searchDate)
    }
    Return ""
}

/// Método de clase para buscar disponibilidad por walker
ClassMethod FindByWalker(walkerId As %String, startDate As %Date = "", endDate As %Date = "") As %SQL.StatementResult
{
    Set sql = "SELECT ID, AvailableDate, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes "_
              "FROM Demo_PETS.Availability "_
              "WHERE Walker = ? AND IsActive = 1 "
    
    If startDate '= "" {
        Set sql = sql _ "AND AvailableDate >= ? "
    }
    
    If endDate '= "" {
        Set sql = sql _ "AND AvailableDate <= ? "
    }
    
    Set sql = sql _ "ORDER BY AvailableDate, StartTime"
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    
    If $$$ISOK(status) {
        If (startDate '= "") && (endDate '= "") {
            Return statement.%Execute(walkerId, startDate, endDate)
        } ElseIf startDate '= "" {
            Return statement.%Execute(walkerId, startDate)
        } ElseIf endDate '= "" {
            Return statement.%Execute(walkerId, endDate)
        } Else {
            Return statement.%Execute(walkerId)
        }
    }
    Return ""
}

/// Método de clase para buscar slots disponibles con capacidad
ClassMethod FindAvailableSlots(searchDate As %Date = "", walkerId As %String = "") As %SQL.StatementResult
{
    Set sql = "SELECT a.ID, a.Walker, w.Name as WalkerName, a.AvailableDate, "_
              "$ZDATE(a.AvailableDate, 3) as FormattedDate, "_
              "a.StartTime, a.EndTime, a.MaxPets, a.CurrentBookings, "_
              "(a.MaxPets - a.CurrentBookings) as RemainingCapacity, "_
              "a.SpecialRate, w.HourlyRate, a.Notes "_
              "FROM Demo_PETS.Availability a "_
              "JOIN Demo_PETS.Walkers w ON a.Walker = w.ID "_
              "WHERE a.IsActive = 1 AND (a.MaxPets - a.CurrentBookings) > 0 "
    
    If searchDate '= "" {
        Set sql = sql _ "AND a.AvailableDate = ? "
    } Else {
        // Solo mostrar fechas futuras si no se especifica fecha
        Set sql = sql _ "AND a.AvailableDate >= ? "
    }
    
    If walkerId '= "" {
        Set sql = sql _ "AND a.Walker = ? "
    }
    
    Set sql = sql _ "ORDER BY a.AvailableDate, a.StartTime, w.Name"
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    
    If $$$ISOK(status) {
        If (searchDate '= "") && (walkerId '= "") {
            Return statement.%Execute(searchDate, walkerId)
        } ElseIf searchDate '= "" {
            Return statement.%Execute(searchDate)
        } ElseIf walkerId '= "" {
            Set today = +$HOROLOG
            Return statement.%Execute(today, walkerId)
        } Else {
            Set today = +$HOROLOG
            Return statement.%Execute(today)
        }
    }
    Return ""
}

/// Método de clase para crear disponibilidad rápida
ClassMethod CreateQuickAvailability(walkerId As %String, dateStr As %String, startTimeStr As %String, endTimeStr As %String, maxPets As %Integer = 5, specialRate As %Numeric = 0, notes As %String = "") As %Status
{
    Try {
        Set availability = ..%New()
        
        // Convertir walker ID a objeto
        Set walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
        If '$IsObject(walker) {
            Return $$$ERROR(5001, "Walker no encontrado: " _ walkerId)
        }
        Set availability.Walker = walker
        
        // Para simplificar, usar fecha de mañana
        Set availability.AvailableDate = (+$HOROLOG) + 1
        
        // Convertir tiempos a formato IRIS
        Set availability.StartTime = $PIECE($ZTIMEH(startTimeStr _ ":00"), ".", 1)
        Set availability.EndTime = $PIECE($ZTIMEH(endTimeStr _ ":00"), ".", 1)
        
        Set availability.MaxPets = maxPets
        Set availability.SpecialRate = specialRate
        Set availability.Notes = notes
        
        Return availability.%Save()
        
    } Catch ex {
        Return ex.AsStatus()
    }
}

/// Método de clase para obtener estadísticas de disponibilidad
ClassMethod GetAvailabilityStats() As %DynamicObject
{
    Try {
        Set stats = {}
        
        // Total de slots activos
        Set sql = "SELECT COUNT(*) as TotalSlots FROM Demo_PETS.Availability WHERE IsActive = 1"
        Set statement = ##class(%SQL.Statement).%New()
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Do stats.%Set("totalActiveSlots", result.%Get("TotalSlots"))
        }
        
        // Slots con capacidad disponible
        Set sql = "SELECT COUNT(*) as AvailableSlots FROM Demo_PETS.Availability WHERE IsActive = 1 AND (MaxPets - CurrentBookings) > 0"
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Do stats.%Set("availableSlots", result.%Get("AvailableSlots"))
        }
        
        // Slots completamente reservados
        Set sql = "SELECT COUNT(*) as FullSlots FROM Demo_PETS.Availability WHERE IsActive = 1 AND CurrentBookings >= MaxPets"
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Do stats.%Set("fullSlots", result.%Get("FullSlots"))
        }
        
        // Total de reservas
        Set sql = "SELECT SUM(CurrentBookings) as TotalBookings FROM Demo_PETS.Availability WHERE IsActive = 1"
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Do stats.%Set("totalBookings", +result.%Get("TotalBookings"))
        }
        
        Return stats
        
    } Catch ex {
        Return {}
    }
}

/// Método auxiliar para formatear fecha de IRIS a string legible
ClassMethod FormatDate(irisDate As %Date) As %String
{
    Try {
        Return $ZDATE(irisDate, 3) // Formato YYYY-MM-DD
    } Catch ex {
        Return ""
    }
}

/// Método auxiliar para formatear tiempo de IRIS a string legible
ClassMethod FormatTime(irisTime As %Time) As %String
{
    Try {
        Return $ZTIME(irisTime, 1) // Formato HH:MM:SS
    } Catch ex {
        Return ""
    }
}

Storage Default
{
<Data name="AvailabilityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Walker</Value>
</Value>
<Value name="3">
<Value>AvailableDate</Value>
</Value>
<Value name="4">
<Value>StartTime</Value>
</Value>
<Value name="5">
<Value>EndTime</Value>
</Value>
<Value name="6">
<Value>MaxPets</Value>
</Value>
<Value name="7">
<Value>CurrentBookings</Value>
</Value>
<Value name="8">
<Value>IsActive</Value>
</Value>
<Value name="9">
<Value>SpecialRate</Value>
</Value>
<Value name="10">
<Value>Notes</Value>
</Value>
<Value name="11">
<Value>CreatedAt</Value>
</Value>
<Value name="12">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.AvailabilityD</DataLocation>
<DefaultData>AvailabilityDefaultData</DefaultData>
<IdLocation>^Demo.PETS.AvailabilityD</IdLocation>
<IndexLocation>^Demo.PETS.AvailabilityI</IndexLocation>
<StreamLocation>^Demo.PETS.AvailabilityS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
