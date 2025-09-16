/// Sistema de Reservas Persistente - Sprint 2.1
/// Clase para gestionar bookings entre owners y walkers
Class Demo.PETS.Scheduling.Bookings Extends %Persistent
{

/// Owner que hace la reserva
Property Owner As Demo.PETS.Owners [ Required ];

/// Mascota que será paseada
Property Pet As Demo.PETS.Pets [ Required ];

/// Walker asignado al paseo
Property Walker As Demo.PETS.Walkers [ Required ];

/// Referencia al slot de disponibilidad original
Property Availability As Demo.PETS.Availability [ Required ];

/// Fecha del paseo
Property BookingDate As %Date [ Required ];

/// Hora de inicio del paseo
Property StartTime As %Time [ Required ];

/// Hora de finalización del paseo
Property EndTime As %Time [ Required ];

/// Estado de la reserva: PENDING, CONFIRMED, COMPLETED, CANCELLED
Property Status As %String [ Required, InitialExpression = "PENDING" ];

/// Monto de la reserva
Property Amount As %Numeric;

/// Moneda de la transacción
Property Currency As %String [ InitialExpression = "USD" ];

/// Instrucciones especiales del owner
Property SpecialInstructions As %Text;

/// Tipo de booking: SUPPLY_DRIVEN (Sprint 2.1)
Property BookingType As %String [ InitialExpression = "SUPPLY_DRIVEN" ];

/// Referencia única para tracking
Property BookingReference As %String;

/// Usuario que creó la reserva
Property CreatedBy As %String;

/// Usuario que canceló (si aplica)
Property CancelledBy As %String;

/// Razón de cancelación
Property CancellationReason As %Text;

/// Fecha y hora de creación
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Fecha y hora de confirmación por walker
Property ConfirmedAt As %TimeStamp;

/// Fecha y hora de completado
Property CompletedAt As %TimeStamp;

/// Fecha y hora de cancelación
Property CancelledAt As %TimeStamp;

/// Última actualización
Property UpdatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

// ÍNDICES PARA PERFORMANCE

/// Índice por owner para consultas rápidas
Index OwnerIdx On Owner;

/// Índice por walker para agenda
Index WalkerIdx On Walker;

/// Índice por estado para filtros
Index StatusIdx On Status;

/// Índice por fecha para consultas temporales
Index DateIdx On BookingDate;

/// Índice por availability para validaciones
Index AvailabilityIdx On Availability;

/// Índice único por referencia de booking
Index ReferenceIdx On BookingReference [ Unique ];

/// Índice compuesto para consultas complejas
Index OwnerStatusIdx On (Owner, Status);

/// Índice compuesto para walker por fecha
Index WalkerDateIdx On (Walker, BookingDate);

/// Índice para bookings activos (sin condición por compatibilidad)
Index ActiveBookingsIdx On (Status, BookingDate);

// MÉTODOS DE CLASE

/// Genera una referencia única para el booking
ClassMethod GenerateBookingReference() As %String
{
    Set timestamp = $TRANSLATE($ZDATETIME($HOROLOG, 3), " :-", "")
    Set random = $RANDOM(9999) + 1000
    Return "BOOK-" _ timestamp _ "-" _ random
}

/// Calcula el monto basado en configuración del walker y duración
Method CalculateAmount() As %Numeric
{
    Try {
        // Obtener tarifa base del walker (asumiendo que existe)
        Set walker = ..Walker
        If '$IsObject(walker) Return 0
        
        // Calcular duración en horas
        Set duration = (..EndTime - ..StartTime) / 3600
        If duration <= 0 Set duration = 1
        
        // Tarifa base por hora (placeholder - se puede configurar)
        Set baseRate = 25.00
        
        // Si hay tarifa especial en Availability, usarla
        Set availability = ..Availability
        If $IsObject(availability) && (availability.SpecialRate > 0) {
            Set baseRate = availability.SpecialRate
        }
        
        Return duration * baseRate
        
    } Catch ex {
        Return 0
    }
}

/// Verifica si el booking se puede modificar
Method IsModifiable() As %Boolean
{
    // Solo se pueden modificar bookings PENDING
    If ..Status '= "PENDING" Return 0
    
    // No se pueden modificar bookings del pasado
    Set today = +$HOROLOG
    If ..BookingDate < today Return 0
    
    // Si es hoy, verificar que no haya pasado la hora
    If ..BookingDate = today {
        Set currentTime = $PIECE($HOROLOG, ",", 2)
        If ..StartTime <= currentTime Return 0
    }
    
    Return 1
}

/// Actualiza el estado del booking con auditoría
Method UpdateStatus(newStatus As %String, userId As %String = "") As %Status
{
    Set sc = $$$OK
    Try {
        Set oldStatus = ..Status
        Set ..Status = newStatus
        Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
        
        // Actualizar timestamps específicos según el estado
        If newStatus = "CONFIRMED" {
            Set ..ConfirmedAt = $ZDATETIME($HOROLOG, 3)
        } ElseIf newStatus = "COMPLETED" {
            Set ..CompletedAt = $ZDATETIME($HOROLOG, 3)
        } ElseIf newStatus = "CANCELLED" {
            Set ..CancelledAt = $ZDATETIME($HOROLOG, 3)
            If userId '= "" Set ..CancelledBy = userId
        }
        
        Set sc = ..%Save()
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    
    Return sc
}

/// Obtiene información resumida del time slot
Method GetTimeSlotInfo() As %DynamicObject
{
    Set info = {}
    
    Try {
        Set info.date = $ZDATE(..BookingDate, 3)
        Set info.startTime = $ZTIME(..StartTime)
        Set info.endTime = $ZTIME(..EndTime)
        Set info.duration = $FNUMBER((..EndTime - ..StartTime) / 3600, "", 1) _ " hora(s)"
        Set info.status = ..Status
        Set info.reference = ..BookingReference
        
        // Información del walker
        If $IsObject(..Walker) {
            Set info.walker = {}
            Set info.walker.name = ..Walker.Name
            Set info.walker.id = ..Walker.%Id()
        }
        
        // Información del owner
        If $IsObject(..Owner) {
            Set info.owner = {}
            Set info.owner.name = ..Owner.Name
            Set info.owner.id = ..Owner.%Id()
        }
        
        // Información de la mascota
        If $IsObject(..Pet) {
            Set info.pet = {}
            Set info.pet.name = ..Pet.Name
            Set info.pet.id = ..Pet.%Id()
        }
        
    } Catch ex {
        Set info.error = ex.DisplayString()
    }
    
    Return info
}

/// Validaciones antes de guardar
Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
    Set sc = $$$OK
    
    Try {
        // Generar referencia si es nuevo
        If insert && (..BookingReference = "") {
            Set ..BookingReference = ..GenerateBookingReference()
        }
        
        // Calcular amount si no está establecido
        If ..Amount = "" || (..Amount = 0) {
            Set ..Amount = ..CalculateAmount()
        }
        
        // Actualizar UpdatedAt
        If 'insert {
            Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
        }
        
        // Validar que los tiempos sean consistentes
        If ..StartTime >= ..EndTime {
            Return $$$ERROR($$$GeneralError, "Hora de inicio debe ser menor a hora de fin")
        }
        
        // Validar que la fecha no sea en el pasado
        If insert && (..BookingDate < +$HOROLOG) {
            Return $$$ERROR($$$GeneralError, "No se pueden crear bookings en fechas pasadas")
        }
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    
    Return sc
}

/// Cleanup después de guardar
Method %OnAfterSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
    Set sc = $$$OK
    
    Try {
        // Si es un insert exitoso y está PENDING, actualizar availability
        If insert && (..Status = "PENDING") && $IsObject(..Availability) {
            Set availability = ..Availability
            Set availability.CurrentBookings = availability.CurrentBookings + 1
            Set sc = availability.%Save()
        }
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    
    Return sc
}

/// Storage definition
Storage Default
{
<Data name="BookingsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Owner</Value>
</Value>
<Value name="3">
<Value>Pet</Value>
</Value>
<Value name="4">
<Value>Walker</Value>
</Value>
<Value name="5">
<Value>Availability</Value>
</Value>
<Value name="6">
<Value>BookingDate</Value>
</Value>
<Value name="7">
<Value>StartTime</Value>
</Value>
<Value name="8">
<Value>EndTime</Value>
</Value>
<Value name="9">
<Value>Status</Value>
</Value>
<Value name="10">
<Value>Amount</Value>
</Value>
<Value name="11">
<Value>Currency</Value>
</Value>
<Value name="12">
<Value>SpecialInstructions</Value>
</Value>
<Value name="13">
<Value>BookingType</Value>
</Value>
<Value name="14">
<Value>BookingReference</Value>
</Value>
<Value name="15">
<Value>CreatedBy</Value>
</Value>
<Value name="16">
<Value>CancelledBy</Value>
</Value>
<Value name="17">
<Value>CancellationReason</Value>
</Value>
<Value name="18">
<Value>CreatedAt</Value>
</Value>
<Value name="19">
<Value>ConfirmedAt</Value>
</Value>
<Value name="20">
<Value>CompletedAt</Value>
</Value>
<Value name="21">
<Value>CancelledAt</Value>
</Value>
<Value name="22">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.Scheduling.BookingsD</DataLocation>
<DefaultData>BookingsDefaultData</DefaultData>
<IdLocation>^Demo.PETS.Scheduling.BookingsD</IdLocation>
<IndexLocation>^Demo.PETS.Scheduling.BookingsI</IndexLocation>
<StreamLocation>^Demo.PETS.Scheduling.BookingsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}