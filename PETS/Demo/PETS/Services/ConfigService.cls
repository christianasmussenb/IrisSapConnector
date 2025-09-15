/// Servicio para gestión centralizada de configuraciones del sistema
/// Siguiendo la arquitectura modular de servicios especializados
Class Demo.PETS.Services.ConfigService Extends Demo.PETS.Services.Base
{

/// Obtener una configuración por clave
ClassMethod GetSetting(key As %String) As %String
{
    Try {
        Set value = ##class(Demo.PETS.Settings).GetSetting(key)
        Return value
    } Catch ex {
        Do ..LogError("Error obteniendo configuración " _ key, ex.DisplayString())
        Return ""
    }
}

/// Establecer una configuración
ClassMethod SetSetting(key As %String, value As %String, type As %String = "STRING", description As %String = "", category As %String = "GENERAL") As %Status
{
    Try {
        Set sc = ##class(Demo.PETS.Settings).SetSetting(key, value, type, description, category)
        If $$$ISOK(sc) {
            Do ..LogInfo("Configuración actualizada: " _ key _ " = " _ value)
        } Else {
            Do ..LogError("Error actualizando configuración " _ key, $SYSTEM.Status.GetErrorText(sc))
        }
        Return sc
    } Catch ex {
        Do ..LogError("Error estableciendo configuración " _ key, ex.DisplayString())
        Return ex.AsStatus()
    }
}

/// Obtener horarios operativos del sistema
ClassMethod GetOperatingHours() As %DynamicObject
{
    Try {
        Set result = {}
        Set startTime = ..GetSetting("OPERATING_START_TIME")
        Set endTime = ..GetSetting("OPERATING_END_TIME")
        Set slotDuration = +..GetSetting("TIME_SLOT_DURATION")
        
        // Aplicar defaults seguros si las configuraciones están vacías
        If startTime = "" Set startTime = "06:00"
        If endTime = "" Set endTime = "20:00"
        If slotDuration = 0 Set slotDuration = 60  // 60 minutos por slot
        
        Do result.%Set("startTime", startTime)
        Do result.%Set("endTime", endTime)
        Do result.%Set("slotDuration", slotDuration)
        Do result.%Set("startHour", $PIECE(startTime, ":", 1))
        Do result.%Set("endHour", $PIECE(endTime, ":", 1))
        
        Return result
    } Catch ex {
        Do ..LogError("Error obteniendo horarios operativos", ex.DisplayString())
        // Retornar valores por defecto seguros en caso de error
        Set result = {}
        Do result.%Set("startTime", "06:00")
        Do result.%Set("endTime", "20:00")
        Do result.%Set("slotDuration", 60)
        Do result.%Set("startHour", "6")
        Do result.%Set("endHour", "20")
        Return result
    }
}

/// Obtener límites del sistema
ClassMethod GetSystemLimits() As %DynamicObject
{
    Try {
        Set result = {}
        Set maxPetsPerWalk = +..GetSetting("MAX_PETS_PER_SLOT")
        If maxPetsPerWalk = 0 Set maxPetsPerWalk = 5  // Default seguro
        
        // Configurar límites con defaults seguros
        Set maxBookingDays = +..GetSetting("MAX_BOOKING_DAYS_AHEAD")
        If maxBookingDays = 0 Set maxBookingDays = 30  // Default 30 días
        
        Set minBookingHours = +..GetSetting("MIN_BOOKING_HOURS_AHEAD")
        If minBookingHours = 0 Set minBookingHours = 2  // Default 2 horas
        
        Do result.%Set("maxPetsPerSlot", maxPetsPerWalk)
        Do result.%Set("maxPetsPerWalk", maxPetsPerWalk)  // Alias para consistencia
        Do result.%Set("maxBookingDaysAhead", maxBookingDays)
        Do result.%Set("minBookingHoursAhead", minBookingHours)
        
        Return result
    } Catch ex {
        Do ..LogError("Error obteniendo límites del sistema", ex.DisplayString())
        // Retornar valores por defecto seguros
        Set result = {}
        Do result.%Set("maxPetsPerSlot", 5)
        Do result.%Set("maxPetsPerWalk", 5)
        Do result.%Set("maxBookingDaysAhead", 30)
        Do result.%Set("minBookingHoursAhead", 2)
        Return result
    }
}

/// Obtener configuraciones de precios
ClassMethod GetPricingConfig() As %DynamicObject
{
    Try {
        Set result = {}
        Do result.%Set("defaultWalkPrice", +..GetSetting("DEFAULT_WALK_PRICE"))
        Do result.%Set("systemCommissionPercent", +..GetSetting("SYSTEM_COMMISSION_PERCENT"))
        
        Return result
    } Catch ex {
        Do ..LogError("Error obteniendo configuración de precios", ex.DisplayString())
        Return {}
    }
}

/// Obtener configuraciones de cancelación
ClassMethod GetCancellationConfig() As %DynamicObject
{
    Try {
        Set result = {}
        Do result.%Set("cancellationHoursLimit", +..GetSetting("CANCELLATION_HOURS_LIMIT"))
        Do result.%Set("cancellationFeePercent", +..GetSetting("CANCELLATION_FEE_PERCENT"))
        
        Return result
    } Catch ex {
        Do ..LogError("Error obteniendo configuración de cancelación", ex.DisplayString())
        Return {}
    }
}

/// Obtener configuraciones de notificaciones
ClassMethod GetNotificationConfig() As %DynamicObject
{
    Try {
        Set result = {}
        Do result.%Set("sendEmailNotifications", +..GetSetting("SEND_EMAIL_NOTIFICATIONS"))
        Do result.%Set("reminderHoursBefore", +..GetSetting("REMINDER_HOURS_BEFORE"))
        
        Return result
    } Catch ex {
        Do ..LogError("Error obteniendo configuración de notificaciones", ex.DisplayString())
        Return {}
    }
}

/// Obtener todas las configuraciones de una categoría
ClassMethod GetSettingsByCategory(category As %String) As %DynamicObject
{
    Try {
        Return ##class(Demo.PETS.Settings).GetSettingsByCategory(category)
    } Catch ex {
        Do ..LogError("Error obteniendo configuraciones de categoría " _ category, ex.DisplayString())
        Return {}
    }
}

/// Validar horario dentro de rango operativo
ClassMethod IsValidOperatingTime(timeStr As %String) As %Boolean
{
    Try {
        Set hours = ..GetOperatingHours()
        Set startTime = hours.startTime
        Set endTime = hours.endTime
        
        // Convertir tiempo a minutos para comparación fácil
        Set timeMinutes = ..TimeToMinutes(timeStr)
        Set startMinutes = ..TimeToMinutes(startTime)
        Set endMinutes = ..TimeToMinutes(endTime)
        
        Return (timeMinutes >= startMinutes) && (timeMinutes <= endMinutes)
    } Catch ex {
        Do ..LogError("Error validando horario operativo", ex.DisplayString())
        Return 0
    }
}

/// Validar que una fecha esté dentro del rango permitido para reservas
ClassMethod IsValidBookingDate(dateStr As %String) As %Boolean
{
    Try {
        Set limits = ..GetSystemLimits()
        Set maxDaysAhead = limits.maxBookingDaysAhead
        Set minHoursAhead = limits.minBookingHoursAhead
        
        // Convertir fecha string a fecha IRIS
        Set bookingDate = $ZDATEUTH(dateStr, 5) // Formato YYYY-MM-DD
        Set today = +$HOROLOG
        Set daysDiff = bookingDate - today
        
        // Verificar que esté dentro del rango permitido
        If daysDiff < 0 Return 0  // No se puede reservar en el pasado
        If daysDiff > maxDaysAhead Return 0  // Muy lejos en el futuro
        
        // Si es hoy, verificar que sea al menos minHoursAhead horas en el futuro
        If daysDiff = 0 {
            Set currentTime = $PIECE($HOROLOG, ",", 2)
            Set currentHour = currentTime \ 3600
            Set minAllowedHour = currentHour + minHoursAhead
            
            // Esta validación se haría con la hora específica del slot
            // Por ahora retornamos true para fechas válidas
        }
        
        Return 1
    } Catch ex {
        Do ..LogError("Error validando fecha de reserva", ex.DisplayString())
        Return 0
    }
}

/// Calcular precio de un paseo basado en configuraciones
ClassMethod CalculateWalkPrice(petCount As %Integer = 1, walkerId As %String = "", specialRate As %Numeric = 0) As %Numeric
{
    Try {
        Set pricing = ..GetPricingConfig()
        Set basePrice = pricing.defaultWalkPrice
        
        // Si hay tarifa especial, usarla
        If specialRate > 0 {
            Set basePrice = specialRate
        } ElseIf walkerId '= "" {
            // Obtener tarifa específica del walker si existe
            Set walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
            If $IsObject(walker) && (walker.HourlyRate > 0) {
                Set basePrice = walker.HourlyRate
            }
        }
        
        // Precio total = precio base * número de mascotas
        Set totalPrice = basePrice * petCount
        
        Return totalPrice
    } Catch ex {
        Do ..LogError("Error calculando precio de paseo", ex.DisplayString())
        Return +..GetSetting("DEFAULT_WALK_PRICE")
    }
}

/// Calcular comisión del sistema
ClassMethod CalculateSystemCommission(amount As %Numeric) As %Numeric
{
    Try {
        Set pricing = ..GetPricingConfig()
        Set commissionPercent = pricing.systemCommissionPercent
        
        Return (amount * commissionPercent / 100)
    } Catch ex {
        Do ..LogError("Error calculando comisión del sistema", ex.DisplayString())
        Return 0
    }
}

/// Generar slots de tiempo disponibles para un día
ClassMethod GenerateTimeSlots(dateStr As %String) As %DynamicArray
{
    Try {
        Set slots = []
        Set hours = ..GetOperatingHours()
        Set startHour = +hours.startHour
        Set endHour = +hours.endHour
        Set slotDuration = hours.slotDuration
        
        // Generar slots cada slotDuration minutos
        Set currentHour = startHour
        While currentHour < endHour {
            Set timeStr = $JUSTIFY(currentHour, 2, 0) _ ":00:00"
            
            Set slot = {}
            Do slot.%Set("time", timeStr)
            Do slot.%Set("hour", currentHour)
            Do slot.%Set("displayTime", $JUSTIFY(currentHour, 2, 0) _ ":00")
            Do slot.%Set("isValid", ..IsValidOperatingTime(timeStr))
            
            Do slots.%Push(slot)
            
            // Incrementar por slotDuration (asumiendo slots de 1 hora por simplicidad)
            Set currentHour = currentHour + (slotDuration / 60)
        }
        
        Return slots
    } Catch ex {
        Do ..LogError("Error generando slots de tiempo", ex.DisplayString())
        Return []
    }
}

/// Obtener configuración completa del sistema para frontend
ClassMethod GetSystemConfig() As %DynamicObject
{
    Try {
        Set config = {}
        
        Do config.%Set("operatingHours", ..GetOperatingHours())
        Do config.%Set("systemLimits", ..GetSystemLimits())
        Do config.%Set("pricing", ..GetPricingConfig())
        Do config.%Set("cancellation", ..GetCancellationConfig())
        Do config.%Set("notifications", ..GetNotificationConfig())
        
        Return config
    } Catch ex {
        Do ..LogError("Error obteniendo configuración completa del sistema", ex.DisplayString())
        Return {}
    }
}

/// Inicializar todas las configuraciones por defecto
ClassMethod InitializeSystem() As %Status
{
    Try {
        Do ..LogInfo("Inicializando configuraciones del sistema...")
        
        Set sc = ##class(Demo.PETS.Settings).InitializeDefaultSettings()
        If $$$ISOK(sc) {
            Do ..LogInfo("✅ Sistema de configuraciones inicializado correctamente")
        } Else {
            Do ..LogError("❌ Error inicializando configuraciones", $SYSTEM.Status.GetErrorText(sc))
        }
        
        Return sc
    } Catch ex {
        Do ..LogError("Error en InitializeSystem", ex.DisplayString())
        Return ex.AsStatus()
    }
}

/// Método auxiliar para convertir tiempo HH:MM:SS a minutos
ClassMethod TimeToMinutes(timeStr As %String) As %Integer [ Private ]
{
    Set hours = +$PIECE(timeStr, ":", 1)
    Set minutes = +$PIECE(timeStr, ":", 2)
    Return (hours * 60) + minutes
}

/// Método auxiliar para logging de información
ClassMethod LogInfo(message As %String) [ Private ]
{
    Write $ZDATETIME($HOROLOG, 3), " [INFO] ConfigService: ", message, !
}

/// Método auxiliar para logging de errores
ClassMethod LogError(message As %String, details As %String = "") [ Private ]
{
    Write $ZDATETIME($HOROLOG, 3), " [ERROR] ConfigService: ", message
    If details '= "" Write " - ", details
    Write !
}

/// Obtiene días operativos de la semana (0=Domingo, 1=Lunes, etc.)
ClassMethod GetOperatingDays() As %DynamicArray
{
    // Por defecto todos los días están permitidos
    Set days = []
    Do days.%Push(1)  // Domingo
    Do days.%Push(1)  // Lunes  
    Do days.%Push(1)  // Martes
    Do days.%Push(1)  // Miércoles
    Do days.%Push(1)  // Jueves
    Do days.%Push(1)  // Viernes
    Do days.%Push(1)  // Sábado
    
    Return days
}

}
