/// API REST para gestión de disponibilidad de walkers
/// Proporciona endpoints RESTful para operaciones CRUD de disponibilidad
Class Demo.REST.AvailabilityAPI Extends %CSP.REST
{

/// Permitir acceso sin autenticación
Parameter SECURITYCONTEXT = "%SYS";

/// No requerir login
Parameter PRIVATE = 0;

/// Define URL mappings para los endpoints REST
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- Endpoints para disponibilidad -->
    <Route Url="/walker/:walkerId/availability" Method="GET" Call="GetWalkerAvailability" />
    <Route Url="/walker/:walkerId/availability" Method="POST" Call="CreateAvailability" />
    <Route Url="/walker/:walkerId/availability/:slotId" Method="PUT" Call="UpdateAvailability" />
    <Route Url="/walker/:walkerId/availability/:slotId" Method="DELETE" Call="DeleteAvailability" />
    
    <!-- Endpoints de consulta general -->
    <Route Url="/availability/date/:date" Method="GET" Call="GetAvailabilityByDate" />
    <Route Url="/availability/search" Method="GET" Call="SearchAvailability" />
    <Route Url="/availability/stats" Method="GET" Call="GetAvailabilityStats" />
    
    <!-- Endpoints de validación -->
    <Route Url="/availability/validate" Method="POST" Call="ValidateSlot" />
    <Route Url="/availability/suggestions/:walkerId" Method="GET" Call="GetSuggestedSlots" />
    
    <!-- Endpoints de configuración -->
    <Route Url="/config/operating-hours" Method="GET" Call="GetOperatingHours" />
    <Route Url="/config/system-limits" Method="GET" Call="GetSystemLimits" />
</Routes>
}

/// Obtiene disponibilidad de un walker específico
ClassMethod GetWalkerAvailability() As %Status
{
    Set walkerId = %urlparam("walkerId")
    Set startDate = $GET(%request.Data("startDate", 1), +$HOROLOG)
    Set endDate = $GET(%request.Data("endDate", 1), +$HOROLOG + 30)
    
    Try {
        // Validar walker existe
        If '##class(Demo.PETS.Walkers).%ExistsId(walkerId) {
            Set %response.Status = "404 Not Found"
            Set response = {"error": "Walker not found", "walkerId": (walkerId)}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Obtener disponibilidad usando SchedulingService
        Set slots = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startDate, endDate)
        
        // Filtrar solo slots de este walker
        Set walkerSlots = []
        For i=0:1:slots.%Size()-1 {
            Set slot = slots.%Get(i)
            If slot.walkerId = walkerId {
                Do walkerSlots.%Push(slot)
            }
        }
        
        Set response = {
            "status": "success",
            "walkerId": (walkerId),
            "dateRange": {
                "start": (##class(Demo.PETS.Availability).FormatDate(startDate)),
                "end": (##class(Demo.PETS.Availability).FormatDate(endDate))
            },
            "totalSlots": (walkerSlots.%Size()),
            "slots": (walkerSlots)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Crea nueva disponibilidad para un walker
ClassMethod CreateAvailability() As %Status
{
    Set walkerId = %urlparam("walkerId")
    
    Try {
        // Validar walker existe
        If '##class(Demo.PETS.Walkers).%ExistsId(walkerId) {
            Set %response.Status = "404 Not Found"
            Set response = {"error": "Walker not found", "walkerId": (walkerId)}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Leer datos JSON del body
        Set jsonData = {}
        If %request.Content '= "" {
            Set jsonData = ##class(%DynamicAbstractObject).%FromJSON(%request.Content)
        }
        
        // Extraer parámetros
        Set dateStr = jsonData.date
        Set startTime = jsonData.startTime
        Set endTime = jsonData.endTime
        Set maxPets = +jsonData.maxPets
        Set specialRate = +$GET(jsonData.specialRate, 0)
        Set notes = $GET(jsonData.notes, "")
        
        // Validar parámetros requeridos
        If (dateStr = "") || (startTime = "") || (endTime = "") || (maxPets <= 0) {
            Set %response.Status = "400 Bad Request"
            Set response = {"error": "Missing required parameters", "required": ["date", "startTime", "endTime", "maxPets"]}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Convertir fecha y tiempos
        Set date = $ZDATEUTH(dateStr, 5)  // YYYY-MM-DD format
        Set startTimeSeconds = $ZTIMEH(startTime)
        Set endTimeSeconds = $ZTIMEH(endTime)
        
        // Validar usando SchedulingService
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, date, startTimeSeconds, endTimeSeconds, maxPets)
        
        If 'validation.isValid {
            Set %response.Status = "400 Bad Request"
            Set response = {
                "error": "Validation failed",
                "errors": (validation.errors)
            }
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Crear nuevo slot
        Set avail = ##class(Demo.PETS.Availability).%New()
        Set avail.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
        Set avail.AvailableDate = date
        Set avail.StartTime = startTimeSeconds
        Set avail.EndTime = endTimeSeconds
        Set avail.MaxPets = maxPets
        Set avail.CurrentBookings = 0
        If specialRate > 0 {
            Set avail.SpecialRate = specialRate
        }
        Set avail.Notes = notes
        Set avail.IsActive = 1
        
        Set status = avail.%Save()
        If $$$ISOK(status) {
            Set %response.Status = "201 Created"
            Set response = {
                "status": "success",
                "message": "Availability slot created successfully",
                "slotId": (avail.%Id()),
                "data": {
                    "walkerId": (walkerId),
                    "date": (##class(Demo.PETS.Availability).FormatDate(date)),
                    "startTime": (##class(Demo.PETS.Availability).FormatTime(startTimeSeconds)),
                    "endTime": (##class(Demo.PETS.Availability).FormatTime(endTimeSeconds)),
                    "maxPets": (maxPets),
                    "specialRate": (specialRate),
                    "notes": (notes)
                }
            }
        } Else {
            Set %response.Status = "500 Internal Server Error"
            Set response = {
                "error": "Failed to save availability",
                "message": ($SYSTEM.Status.GetOneErrorText(status))
            }
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Actualiza disponibilidad existente
ClassMethod UpdateAvailability() As %Status
{
    Set walkerId = %urlparam("walkerId")
    Set slotId = %urlparam("slotId")
    
    Try {
        // Validar slot existe
        Set avail = ##class(Demo.PETS.Availability).%OpenId(slotId)
        If '$IsObject(avail) {
            Set %response.Status = "404 Not Found"
            Set response = {"error": "Availability slot not found", "slotId": (slotId)}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Validar que pertenece al walker
        If avail.Walker.%Id() '= walkerId {
            Set %response.Status = "403 Forbidden"
            Set response = {"error": "Slot does not belong to this walker"}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Leer datos JSON del body
        Set jsonData = {}
        If %request.Content '= "" {
            Set jsonData = ##class(%DynamicAbstractObject).%FromJSON(%request.Content)
        }
        
        // Actualizar campos permitidos
        If jsonData.maxPets '= "" {
            Set avail.MaxPets = +jsonData.maxPets
        }
        If jsonData.specialRate '= "" {
            Set avail.SpecialRate = +jsonData.specialRate
        }
        If jsonData.notes '= "" {
            Set avail.Notes = jsonData.notes
        }
        If jsonData.isActive '= "" {
            Set avail.IsActive = +jsonData.isActive
        }
        
        Set avail.UpdatedAt = $ZDATETIME($HOROLOG,3)
        
        Set status = avail.%Save()
        If $$$ISOK(status) {
            Set response = {
                "status": "success",
                "message": "Availability slot updated successfully",
                "slotId": (slotId),
                "data": {
                    "maxPets": (avail.MaxPets),
                    "specialRate": (avail.SpecialRate),
                    "notes": (avail.Notes),
                    "isActive": (avail.IsActive),
                    "updatedAt": (avail.UpdatedAt)
                }
            }
        } Else {
            Set %response.Status = "500 Internal Server Error"
            Set response = {
                "error": "Failed to update availability",
                "message": ($SYSTEM.Status.GetOneErrorText(status))
            }
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Elimina disponibilidad existente
ClassMethod DeleteAvailability() As %Status
{
    Set walkerId = %urlparam("walkerId")
    Set slotId = %urlparam("slotId")
    
    Try {
        // Validar slot existe
        Set avail = ##class(Demo.PETS.Availability).%OpenId(slotId)
        If '$IsObject(avail) {
            Set %response.Status = "404 Not Found"
            Set response = {"error": "Availability slot not found", "slotId": (slotId)}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Validar que pertenece al walker
        If avail.Walker.%Id() '= walkerId {
            Set %response.Status = "403 Forbidden"
            Set response = {"error": "Slot does not belong to this walker"}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        // Validar que no tiene reservas
        If avail.CurrentBookings > 0 {
            Set %response.Status = "409 Conflict"
            Set response = {
                "error": "Cannot delete slot with existing bookings",
                "currentBookings": (avail.CurrentBookings)
            }
            Write response.%ToJSON()
            Return $$$OK
        }
        
        Set status = ##class(Demo.PETS.Availability).%DeleteId(slotId)
        If $$$ISOK(status) {
            Set response = {
                "status": "success",
                "message": "Availability slot deleted successfully",
                "slotId": (slotId)
            }
        } Else {
            Set %response.Status = "500 Internal Server Error"
            Set response = {
                "error": "Failed to delete availability",
                "message": ($SYSTEM.Status.GetOneErrorText(status))
            }
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Obtiene disponibilidad por fecha específica
ClassMethod GetAvailabilityByDate() As %Status
{
    Set dateParam = %urlparam("date")
    
    Try {
        Set date = $ZDATEUTH(dateParam, 5)  // YYYY-MM-DD format
        Set slots = ##class(Demo.PETS.Services.SchedulingService).GetAvailableSlots(date)
        
        Set response = {
            "status": "success",
            "date": (##class(Demo.PETS.Availability).FormatDate(date)),
            "totalSlots": (slots.%Size()),
            "slots": (slots)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Búsqueda de disponibilidad con filtros
ClassMethod SearchAvailability() As %Status
{
    Set startDate = $GET(%request.Data("startDate", 1), +$HOROLOG)
    Set endDate = $GET(%request.Data("endDate", 1), +$HOROLOG + 7)
    Set timeSlot = $GET(%request.Data("timeSlot", 1), "")
    Set maxPrice = $GET(%request.Data("maxPrice", 1), "")
    
    Try {
        If startDate > (+$HOROLOG + 365) || endDate < +$HOROLOG {
            Set %response.Status = "400 Bad Request"
            Set response = {"error": "Invalid date range"}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        Set slots = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startDate, endDate, timeSlot, maxPrice)
        
        Set response = {
            "status": "success",
            "dateRange": {
                "start": (##class(Demo.PETS.Availability).FormatDate(startDate)),
                "end": (##class(Demo.PETS.Availability).FormatDate(endDate))
            },
            "filters": {
                "timeSlot": (timeSlot),
                "maxPrice": (maxPrice)
            },
            "totalSlots": (slots.%Size()),
            "slots": (slots)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Obtiene estadísticas de disponibilidad
ClassMethod GetAvailabilityStats() As %Status
{
    Set startDate = $GET(%request.Data("startDate", 1), +$HOROLOG)
    Set endDate = $GET(%request.Data("endDate", 1), +$HOROLOG + 30)
    
    Try {
        Set stats = ##class(Demo.PETS.Services.SchedulingService).GetAvailabilityStats(startDate, endDate)
        
        Set response = {
            "status": "success",
            "stats": (stats)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Valida un slot antes de crearlo
ClassMethod ValidateSlot() As %Status
{
    Try {
        // Leer datos JSON del body
        Set jsonData = {}
        If %request.Content '= "" {
            Set jsonData = ##class(%DynamicAbstractObject).%FromJSON(%request.Content)
        }
        
        Set walkerId = jsonData.walkerId
        Set dateStr = jsonData.date
        Set startTime = jsonData.startTime
        Set endTime = jsonData.endTime
        Set maxPets = +jsonData.maxPets
        
        If (walkerId = "") || (dateStr = "") || (startTime = "") || (endTime = "") || (maxPets <= 0) {
            Set %response.Status = "400 Bad Request"
            Set response = {"error": "Missing required parameters"}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        Set date = $ZDATEUTH(dateStr, 5)
        Set startTimeSeconds = $ZTIMEH(startTime)
        Set endTimeSeconds = $ZTIMEH(endTime)
        
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, date, startTimeSeconds, endTimeSeconds, maxPets)
        
        Set response = {
            "status": "success",
            "validation": (validation)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Obtiene slots sugeridos para un walker
ClassMethod GetSuggestedSlots() As %Status
{
    Set walkerId = %urlparam("walkerId")
    Set date = $GET(%request.Data("date", 1), +$HOROLOG + 1)  // Mañana por defecto
    
    Try {
        If '##class(Demo.PETS.Walkers).%ExistsId(walkerId) {
            Set %response.Status = "404 Not Found"
            Set response = {"error": "Walker not found"}
            Write response.%ToJSON()
            Return $$$OK
        }
        
        Set suggestions = ##class(Demo.PETS.Services.SchedulingService).GenerateSuggestedTimeSlots(date)
        
        Set response = {
            "status": "success",
            "walkerId": (walkerId),
            "date": (##class(Demo.PETS.Availability).FormatDate(date)),
            "suggestions": (suggestions)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Obtiene horarios operativos
ClassMethod GetOperatingHours() As %Status
{
    Try {
        Set hours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
        
        Set response = {
            "status": "success",
            "operatingHours": (hours)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

/// Obtiene límites del sistema
ClassMethod GetSystemLimits() As %Status
{
    Try {
        Set limits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
        
        Set response = {
            "status": "success",
            "systemLimits": (limits)
        }
        
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
        
    } Catch ex {
        Set %response.Status = "500 Internal Server Error"
        Set response = {"error": "Internal error", "message": (ex.DisplayString())}
        Set %response.ContentType = "application/json"
        Write response.%ToJSON()
    }
    
    Return $$$OK
}

}
