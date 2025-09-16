/// Página web con calendario visual para gestión de disponibilidad de walkers
/// Interfaz interactiva para que walkers puedan gestionar su disponibilidad de forma visual
Class Demo.REST.WalkerCalendar Extends %CSP.Page
{

/// Permitir acceso sin autenticación
Parameter SECURITYCONTEXT = "%SYS";

/// No requerir login
Parameter PRIVATE = 0;

/// Método principal que renderiza la página del calendario
ClassMethod OnPage() As %Status
{
    Set %response.ContentType = "text/html"
    
    // Obtener parámetros con valores por defecto seguros
    Set walkerId = +$GET(%request.Data("walkerId", 1), 1)
    
    // Obtener fecha actual como backup
    Set currentDate = +$HOROLOG
    Set defaultMonth = +$PIECE($ZDATE(currentDate, 3), "-", 2)
    Set defaultYear = +$PIECE($ZDATE(currentDate, 3), "-", 1)
    
    // Parsear parámetros de URL con validación
    Set paramMonth = $GET(%request.Data("month", 1), "")
    Set paramYear = $GET(%request.Data("year", 1), "")
    
    Set currentMonth = +paramMonth
    Set currentYear = +paramYear
    
    // Validar y corregir mes
    If (currentMonth < 1) || (currentMonth > 12) || (paramMonth = "") {
        Set currentMonth = defaultMonth
    }
    
    // Validar y corregir año
    If (currentYear < 2020) || (currentYear > 2030) || (paramYear = "") {
        Set currentYear = defaultYear
    }
    
    Set view = $GET(%request.Data("view", 1), "month")
    
    // Procesar acciones POST si las hay
    If %request.Method = "POST" {
        Do ..ProcessCalendarAction(walkerId)
    }
    
    // Renderizar página
    Do ..RenderCalendarPage(walkerId, currentMonth, currentYear, view)
    
    Return $$$OK
}

/// Procesa acciones del calendario (crear, editar, eliminar slots)
ClassMethod ProcessCalendarAction(walkerId As %Integer) As %Status
{
    Try {
        Set action = $GET(%request.Data("calendar_action", 1))
        
        If action = "create_slot" {
            Do ..ProcessCreateSlotFromCalendar(walkerId)
        } ElseIf action = "update_slot" {
            Do ..ProcessUpdateSlotFromCalendar(walkerId)
        } ElseIf action = "delete_slot" {
            Do ..ProcessDeleteSlotFromCalendar(walkerId)
        } ElseIf action = "bulk_create" {
            Do ..ProcessBulkCreateSlots(walkerId)
        }
        
    } Catch ex {
        Write "<div class='alert alert-danger'>Error: " _ ex.DisplayString() _ "</div>"
    }
    
    Return $$$OK
}

/// Crea slot desde calendario
ClassMethod ProcessCreateSlotFromCalendar(walkerId As %Integer) As %Status
{
    // Obtener walkerId del formulario si existe, sino usar el parámetro
    Set formWalkerId = +$GET(%request.Data("walker_id", 1))
    If formWalkerId > 0 Set walkerId = formWalkerId
    
    Set dateStr = $GET(%request.Data("slot_date", 1))
    
    // Construir tiempo de inicio desde campos separados
    Set startHour = $GET(%request.Data("slot_start_hour", 1))
    Set startMinute = $GET(%request.Data("slot_start_minute", 1))
    Set startTime = startHour _ ":" _ startMinute
    
    // Construir tiempo de fin desde campos separados  
    Set endHour = $GET(%request.Data("slot_end_hour", 1))
    Set endMinute = $GET(%request.Data("slot_end_minute", 1))
    Set endTime = endHour _ ":" _ endMinute
    
    Set maxPets = +$GET(%request.Data("slot_max_pets", 1))
    Set specialRate = +$GET(%request.Data("slot_special_rate", 1))
    Set notes = $GET(%request.Data("slot_notes", 1))
    
    // Validación básica antes de llamar al validador
    If walkerId <= 0 {
        Write "<div class='alert alert-danger'>Error: Walker ID no válido</div>"
        Return $$$OK
    }
    
    If dateStr = "" {
        Write "<div class='alert alert-danger'>Error: Fecha no proporcionada</div>"
        Return $$$OK
    }
    
    If startTime = "" || endTime = "" {
        Write "<div class='alert alert-danger'>Error: Horarios no proporcionados</div>"
        Return $$$OK
    }
    
    // Usar validador avanzado
    Try {
        Set validation = ##class(Demo.PETS.Services.AvailabilityValidator).ValidateQuick(walkerId, dateStr, startTime, endTime, maxPets)
    } Catch ex {
        Write "<div class='alert alert-danger'>Error en validación: " _ ex.DisplayString() _ "</div>"
        Return $$$OK
    }
    
    If validation.isValid {
        // Convertir y crear slot
        Set date = $ZDATEH(dateStr, 3)  // Usar formato 3 (YYYY-MM-DD)
        Set startTimeSeconds = $ZTIMEH(startTime)
        Set endTimeSeconds = $ZTIMEH(endTime)
        
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
            Write "<div class='alert alert-success'><i class='fas fa-check'></i> Slot creado exitosamente para " _ ##class(Demo.PETS.Availability).FormatDate(date) _ " " _ startTime _ "-" _ endTime _ "</div>"
        } Else {
            Write "<div class='alert alert-danger'>Error al guardar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
        }
    } Else {
        Write "<div class='alert alert-danger'><strong>Errores de validación:</strong><ul>"
        For i=0:1:validation.errors.%Size()-1 {
            Write "<li>" _ validation.errors.%Get(i) _ "</li>"
        }
        Write "</ul></div>"
    }
    
    Return $$$OK
}

/// Procesa creación masiva de slots
ClassMethod ProcessBulkCreateSlots(walkerId As %Integer) As %Status
{
    Set startDateStr = $GET(%request.Data("bulk_start_date", 1))
    Set endDateStr = $GET(%request.Data("bulk_end_date", 1))
    Set timeSlots = $GET(%request.Data("bulk_time_slots", 1))  // JSON array
    Set selectedDays = $GET(%request.Data("bulk_selected_days", 1))  // Comma separated
    Set maxPets = +$GET(%request.Data("bulk_max_pets", 1))
    Set specialRate = +$GET(%request.Data("bulk_special_rate", 1))
    
    Set startDate = $ZDATEH(startDateStr, 3)  // Usar formato 3 (YYYY-MM-DD)
    Set endDate = $ZDATEH(endDateStr, 3)    // Usar formato 3 (YYYY-MM-DD)
    
    Set slotsCreated = 0
    Set slotsSkipped = 0
    
    // Parsear días seleccionados
    Set daysList = []
    For i=1:1:$L(selectedDays, ",") {
        Set day = $P(selectedDays, ",", i)
        If day '= "" Do daysList.%Push(+day)
    }
    
    // Parsear slots de tiempo (formato: "09:00-10:00,14:00-15:00")
    Set timeSlotsList = []
    For i=1:1:$L(timeSlots, ",") {
        Set timeSlot = $P(timeSlots, ",", i)
        If timeSlot '= "" {
            Set startTime = $P(timeSlot, "-", 1)
            Set endTime = $P(timeSlot, "-", 2)
            If startTime '= "" && endTime '= "" {
                Do timeSlotsList.%Push({"start": (startTime), "end": (endTime)})
            }
        }
    }
    
    // Iterar fechas
    For currentDate = startDate:1:endDate {
        Set dayOfWeek = $ZDATE(currentDate, 10)  // 1=Sunday, 2=Monday, etc.
        
        // Verificar si este día está seleccionado
        Set daySelected = 0
        For j=0:1:daysList.%Size()-1 {
            If daysList.%Get(j) = dayOfWeek Set daySelected = 1
        }
        
        If daySelected {
            // Crear slots para este día
            For k=0:1:timeSlotsList.%Size()-1 {
                Set timeSlot = timeSlotsList.%Get(k)
                Set startTime = timeSlot.start
                Set endTime = timeSlot.end
                
                // Validar slot
                Set validation = ##class(Demo.PETS.Services.AvailabilityValidator).ValidateQuick(walkerId, $ZDATE(currentDate, 3), startTime, endTime, maxPets)
                
                If validation.isValid {
                    Set avail = ##class(Demo.PETS.Availability).%New()
                    Set avail.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
                    Set avail.AvailableDate = currentDate
                    Set avail.StartTime = $ZTIMEH(startTime)
                    Set avail.EndTime = $ZTIMEH(endTime)
                    Set avail.MaxPets = maxPets
                    Set avail.CurrentBookings = 0
                    If specialRate > 0 {
                        Set avail.SpecialRate = specialRate
                    }
                    Set avail.Notes = "Creado masivamente"
                    Set avail.IsActive = 1
                    
                    Set status = avail.%Save()
                    If $$$ISOK(status) {
                        Set slotsCreated = slotsCreated + 1
                    }
                } Else {
                    Set slotsSkipped = slotsSkipped + 1
                }
            }
        }
    }
    
    Write "<div class='alert alert-success'><i class='fas fa-calendar-plus'></i> Creación masiva completada: " _ slotsCreated _ " slots creados, " _ slotsSkipped _ " omitidos por validación</div>"
    
    Return $$$OK
}

/// Actualiza slot desde calendario
ClassMethod ProcessUpdateSlotFromCalendar(walkerId As %Integer) As %Status
{
    Set slotId = +$GET(%request.Data("update_slot_id", 1))
    Set maxPets = +$GET(%request.Data("update_max_pets", 1))
    Set specialRate = +$GET(%request.Data("update_special_rate", 1))
    Set notes = $GET(%request.Data("update_notes", 1))
    Set isActive = +$GET(%request.Data("update_is_active", 1), 1)
    
    // Usar validador para actualización
    Set validation = ##class(Demo.PETS.Services.AvailabilityValidator).ValidateSlotUpdate(slotId, maxPets, specialRate, notes, isActive)
    
    If validation.isValid {
        Set avail = ##class(Demo.PETS.Availability).%OpenId(slotId)
        If $IsObject(avail) {
            If maxPets > 0 Set avail.MaxPets = maxPets
            If specialRate > 0 Set avail.SpecialRate = specialRate
            Set avail.Notes = notes
            Set avail.IsActive = isActive
            Set avail.UpdatedAt = $ZDATETIME($HOROLOG,3)
            
            Set status = avail.%Save()
            If $$$ISOK(status) {
                Write "<div class='alert alert-success'><i class='fas fa-edit'></i> Slot actualizado exitosamente</div>"
            } Else {
                Write "<div class='alert alert-danger'>Error al actualizar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
            }
        } Else {
            Write "<div class='alert alert-danger'>Slot no encontrado</div>"
        }
    } Else {
        Write "<div class='alert alert-danger'><strong>Errores de validación:</strong><ul>"
        For i=0:1:validation.errors.%Size()-1 {
            Write "<li>" _ validation.errors.%Get(i) _ "</li>"
        }
        Write "</ul></div>"
    }
    
    Return $$$OK
}

/// Elimina slot desde calendario
ClassMethod ProcessDeleteSlotFromCalendar(walkerId As %Integer) As %Status
{
    Set slotId = +$GET(%request.Data("delete_slot_id", 1))
    
    // Usar validador para eliminación
    Set validation = ##class(Demo.PETS.Services.AvailabilityValidator).ValidateSlotDeletion(slotId)
    
    If validation.isValid {
        Set status = ##class(Demo.PETS.Availability).%DeleteId(slotId)
        If $$$ISOK(status) {
            Write "<div class='alert alert-success'><i class='fas fa-trash'></i> Slot eliminado exitosamente</div>"
        } Else {
            Write "<div class='alert alert-danger'>Error al eliminar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
        }
    } Else {
        Write "<div class='alert alert-danger'><strong>No se puede eliminar:</strong><ul>"
        For i=0:1:validation.errors.%Size()-1 {
            Write "<li>" _ validation.errors.%Get(i) _ "</li>"
        }
        Write "</ul></div>"
    }
    
    Return $$$OK
}

/// Renderiza la página principal del calendario
ClassMethod RenderCalendarPage(walkerId As %Integer, month As %Integer, year As %Integer, view As %String) As %Status
{
    // Obtener información del walker
    Set walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
    Set walkerName = ""
    If $IsObject(walker) {
        Set walkerName = walker.Name
    }
    
    Write "<!DOCTYPE html>"
    Write "<html lang='es'>"
    Write "<head>"
    Write "<meta charset='UTF-8'>"
    Write "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    Write "<title>Calendario - " _ walkerName _ "</title>"
    Write "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Write "<link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>"
    Write "<style>"
    Write ".calendar-container { background: white; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }"
    Write ".calendar-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }"
    Write ".calendar-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }"
    Write ".walker-controls { display: flex; align-items: center; gap: 15px; }"
    Write ".form-select-sm { font-size: 0.875rem; }"
    
    // Estilos para la tabla del calendario mensual
    Write ".calendar-month-table { margin-bottom: 0; }"
    Write ".calendar-month-table th, .calendar-month-table td { border: 1px solid #dee2e6; vertical-align: top; }"
    Write ".calendar-day-header { background: #f8f9fa; padding: 10px; text-align: center; font-weight: bold; color: #495057; }"
    Write ".calendar-day-cell { background: white; height: 120px; padding: 5px; position: relative; cursor: pointer; transition: all 0.3s; }"
    Write ".calendar-day-cell:hover { background: #f8f9fa; }"
    Write ".calendar-day-cell.other-month { background: #f5f5f5; color: #ccc; }"
    Write ".calendar-day-cell.today { background: #e3f2fd; }"
    Write ".calendar-day-cell.has-slots { background: #e8f5e8; }"
    Write ".day-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }"
    Write ".day-number { font-weight: bold; font-size: 14px; }"
    Write ".day-content { min-height: 60px; }"
    Write ".day-actions { position: absolute; top: 5px; right: 5px; }"
    
    // Estilos para la tabla del calendario semanal
    Write ".calendar-week-table { margin-bottom: 0; }"
    Write ".calendar-week-table th, .calendar-week-table td { border: 1px solid #dee2e6; vertical-align: top; }"
    Write ".week-header { text-align: center; padding: 15px 10px; }"
    Write ".week-day-name { font-weight: bold; color: #495057; }"
    Write ".week-day-number { font-size: 1.2em; margin-top: 5px; }"
    Write ".week-day-cell { background: white; height: 300px; padding: 10px; position: relative; cursor: pointer; transition: all 0.3s; width: 14.28%; }"
    Write ".week-day-cell:hover { background: #f8f9fa; }"
    Write ".week-day-cell.today { background: #e3f2fd; }"
    Write ".week-day-cell.has-slots { background: #e8f5e8; }"
    Write ".week-day-content { height: 220px; overflow-y: auto; }"
    Write ".week-day-actions { position: absolute; bottom: 10px; right: 10px; }"
    Write ".no-slots { text-align: center; margin-top: 50px; }"
    
    // Estilos para slots
    Write ".slot-item { background: #007bff; color: white; border-radius: 3px; padding: 2px 4px; margin: 1px 0; font-size: 0.75em; cursor: pointer; }"
    Write ".slot-item:hover { background: #0056b3; }"
    Write ".slot-item.booked { background: #dc3545; }"
    Write ".slot-item.partial { background: #ffc107; color: #000; }"
    Write ".week-slot { margin-bottom: 5px; padding: 5px; }"
    Write ".slot-time { font-weight: bold; }"
    Write ".slot-duration { font-size: 0.9em; }"
    Write ".slot-capacity { font-size: 0.8em; opacity: 0.8; }"
    
    // Botones y controles
    Write ".add-slot-btn { background: #17a2b8; color: white; border: none; border-radius: 3px; padding: 2px 6px; font-size: 12px; }"
    Write ".add-slot-btn:hover { background: #138496; }"
    Write ".modal-lg { max-width: 900px; }"
    Write ".time-slot-badge { display: inline-block; background: #007bff; color: white; border-radius: 15px; padding: 5px 10px; margin: 2px; font-size: 0.8em; }"
    Write "</style>"
    Write "</head>"
    Write "<body class='bg-light'>"
    
    Write "<div class='container-fluid mt-4'>"
    
    // Header con información del walker y navegación
    Do ..RenderCalendarHeader(walkerId, walkerName, month, year, view)
    
    // Calendario principal
    Write "<div class='calendar-container mb-4'>"
    
    If view = "week" {
        Do ..RenderWeekView(walkerId, month, year)
    } Else {
        // Por defecto usar vista mensual
        Do ..RenderMonthView(walkerId, month, year)
    }
    
    Write "</div>"
    
    // Modales para crear/editar slots
    Do ..RenderModals(walkerId, month, year)
    
    Write "</div>"
    
    // JavaScript
    Write "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js'></script>"
    Do ..RenderCalendarJavaScript(walkerId)
    
    Write "</body>"
    Write "</html>"
    
    Return $$$OK
}

/// Renderiza header del calendario con navegación
ClassMethod RenderCalendarHeader(walkerId As %Integer, walkerName As %String, month As %Integer, year As %Integer, view As %String) As %Status
{
    Write "<div class='calendar-header'>"
    Write "<div class='calendar-nav'>"
    Write "<div>"
    Write "<h2><i class='fas fa-calendar-alt'></i> Calendario - " _ walkerName _ "</h2>"
    Write "<small>Gestión de disponibilidad personal</small>"
    Write "</div>"
    
    // Selector de Walker y botón de volver
    Write "<div class='walker-controls'>"
    Write "<div>"
    Write "<label class='form-label text-white mb-1'>Walker:</label>"
    Write "<select class='form-select form-select-sm' id='walkerSelector' onchange='changeWalker(this.value)'>"
    Do ..RenderWalkerOptions(walkerId)
    Write "</select>"
    Write "</div>"
    Write "<a href='/csp/demo2/' class='btn btn-outline-light'>"
    Write "<i class='fas fa-home'></i> Menú Principal"
    Write "</a>"
    Write "</div>"
    
    Write "</div>"
    
    // Navegación de mes
    Write "<div class='d-flex justify-content-center my-3'>"
    Write "<div class='btn-group' role='group'>"
    
    Set prevMonth = month - 1
    Set prevYear = year
    If prevMonth = 0 {
        Set prevMonth = 12
        Set prevYear = prevYear - 1
    }
    
    Set nextMonth = month + 1
    Set nextYear = year
    If nextMonth = 13 {
        Set nextMonth = 1
        Set nextYear = nextYear + 1
    }
    
    Write "<a href='?walkerId=" _ walkerId _ "&month=" _ prevMonth _ "&year=" _ prevYear _ "&view=" _ view _ "' class='btn btn-outline-light'>"
    Write "<i class='fas fa-chevron-left'></i>"
    Write "</a>"
    Write "<span class='btn btn-light'>" _ ..GetMonthName(month) _ " " _ year _ "</span>"
    Write "<a href='?walkerId=" _ walkerId _ "&month=" _ nextMonth _ "&year=" _ nextYear _ "&view=" _ view _ "' class='btn btn-outline-light'>"
    Write "<i class='fas fa-chevron-right'></i>"
    Write "</a>"
    Write "</div>"
    Write "</div>"
    
    // Botones de acción
    Write "<div class='mt-3 d-flex justify-content-between align-items-center'>"
    Write "<div class='btn-group' role='group'>"
    Set monthClass = $SELECT(view="month":"btn-primary", 1:"btn-outline-light")
    Set weekClass = $SELECT(view="week":"btn-primary", 1:"btn-outline-light")
    
    Write "<a href='?walkerId=" _ walkerId _ "&month=" _ month _ "&year=" _ year _ "&view=month' class='btn " _ monthClass _ "'>Mes</a>"
    Write "<a href='?walkerId=" _ walkerId _ "&month=" _ month _ "&year=" _ year _ "&view=week' class='btn " _ weekClass _ "'>Semana</a>"
    Write "</div>"
    
    Write "<div>"
    Write "<button type='button' class='btn btn-success me-2' data-bs-toggle='modal' data-bs-target='#quickAddModal'>"
    Write "<i class='fas fa-plus'></i> Agregar Slot"
    Write "</button>"
    Write "<button type='button' class='btn btn-warning' data-bs-toggle='modal' data-bs-target='#bulkCreateModal'>"
    Write "<i class='fas fa-calendar-plus'></i> Creación Masiva"
    Write "</button>"
    Write "</div>"
    Write "</div>"
    
    Write "</div>"
    
    Return $$$OK
}

/// Renderiza vista mensual del calendario
ClassMethod RenderMonthView(walkerId As %Integer, month As %Integer, year As %Integer) As %Status
{
    // Validar parámetros - usar fecha actual si es inválida
    If (month < 1) || (month > 12) Set month = +$PIECE($ZDATE(+$HOROLOG, 3), "-", 2)
    If (year < 2020) || (year > 2030) Set year = +$PIECE($ZDATE(+$HOROLOG, 3), "-", 1)
    
    // Obtener datos del mes
    Set dateString = year _ "-" _ $TR($J(month,2)," ","0") _ "-01"
    Try {
        Set firstDay = $ZDATEH(dateString, 3)  // Usar formato 3 (YYYY-MM-DD)
    } Catch ex {
        // Si hay error, usar formato 8 (YYYYMMDD)
        Set dateString = year _ $TR($J(month,2)," ","0") _ "01"
        Set firstDay = $ZDATEH(dateString, 8)
    }
    Set firstDayOfWeek = $SYSTEM.SQL.DAYOFWEEK(firstDay)  // 1=Sunday
    Set daysInMonth = ..GetDaysInMonth(month, year)
    
    // Obtener slots del walker para este mes
    Set startDate = firstDay - (firstDayOfWeek - 1)  // Incluir días del mes anterior
    Set endDate = firstDay + daysInMonth + (7 - ((daysInMonth + firstDayOfWeek - 1) # 7))  // Incluir días del mes siguiente
    
    Set slots = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startDate, endDate)
    Set walkerSlots = {}
    
    // Organizar slots por fecha para el walker actual
    For i=0:1:slots.%Size()-1 {
        Set slot = slots.%Get(i)
        If slot.walkerId = walkerId {
            Set dateKey = slot.date
            If 'walkerSlots.%IsDefined(dateKey) {
                Do walkerSlots.%Set(dateKey, ##class(%DynamicArray).%New())
            }
            Do walkerSlots.%Get(dateKey).%Push(slot)
        }
    }
    
    // Crear tabla de calendario
    Write "<div class='calendar-grid'>"
    Write "<table class='table table-bordered calendar-month-table'>"
    
    // Encabezados de días de la semana
    Write "<thead>"
    Write "<tr class='calendar-header-row'>"
    Write "<th class='calendar-day-header'>Dom</th>"
    Write "<th class='calendar-day-header'>Lun</th>"
    Write "<th class='calendar-day-header'>Mar</th>"
    Write "<th class='calendar-day-header'>Mié</th>"
    Write "<th class='calendar-day-header'>Jue</th>"
    Write "<th class='calendar-day-header'>Vie</th>"
    Write "<th class='calendar-day-header'>Sáb</th>"
    Write "</tr>"
    Write "</thead>"
    
    Write "<tbody>"
    
    // Renderizar semanas (filas)
    Set currentDate = startDate
    Set today = +$HOROLOG
    
    For week=1:1:6 {
        Write "<tr class='calendar-week-row'>"
        
        // Renderizar días de la semana (columnas)
        For dayOfWeek=1:1:7 {
            Set currentDateStr = ##class(Demo.PETS.Availability).FormatDate(currentDate)
            Set dayNumber = +$PIECE(currentDateStr, "-", 3)
            Set currentMonth = +$PIECE(currentDateStr, "-", 2)
            
            Set dayClasses = "calendar-day-cell"
            If currentMonth '= month Set dayClasses = dayClasses _ " other-month"
            If currentDate = today Set dayClasses = dayClasses _ " today"
            
            Set daySlots = walkerSlots.%Get(currentDateStr)
            If $IsObject(daySlots) && daySlots.%Size() > 0 {
                Set dayClasses = dayClasses _ " has-slots"
            }
            
            Write "<td class='" _ dayClasses _ "' onclick='openDayModal(""" _ currentDateStr _ """)'>"
            Write "<div class='day-header'>"
            Write "<span class='day-number'>" _ dayNumber _ "</span>"
            Write "</div>"
            
            Write "<div class='day-content'>"
            
            // Mostrar slots del día
            If $IsObject(daySlots) {
                For s=0:1:daySlots.%Size()-1 {
                    Set slot = daySlots.%Get(s)
                    Set slotClass = "slot-item"
                    If slot.availableSlots = 0 {
                        Set slotClass = slotClass _ " booked"
                    } ElseIf slot.availableSlots < slot.maxCapacity {
                        Set slotClass = slotClass _ " partial"
                    }
                    
                    Write "<div class='" _ slotClass _ "' title='" _ slot.startTime _ "-" _ slot.endTime _ " (" _ slot.availableSlots _ "/" _ slot.maxCapacity _ ")'>"
                    Write $E(slot.startTime, 1, 5)
                    Write "</div>"
                }
            }
            
            Write "</div>"
            
            // Botón para agregar slot
            If currentMonth = month && currentDate >= today {
                Write "<div class='day-actions'>"
                Write "<button class='add-slot-btn btn btn-sm btn-light' onclick='event.stopPropagation(); openQuickAdd(""" _ currentDateStr _ """)' title='Agregar slot'>"
                Write "<i class='fas fa-plus'></i>"
                Write "</button>"
                Write "</div>"
            }
            
            Write "</td>"
            Set currentDate = currentDate + 1
        }
        
        Write "</tr>"
        
        If currentDate > (firstDay + daysInMonth + 14) Quit  // No mostrar más de 6 semanas
    }
    
    Write "</tbody>"
    Write "</table>"
    Write "</div>"
    
    Return $$$OK
}

/// Renderiza vista de semana
ClassMethod RenderWeekView(walkerId As %Integer, month As %Integer, year As %Integer) As %Status
{
    // Validar parámetros
    If (month < 1) || (month > 12) Set month = +$PIECE($ZDATE(+$HOROLOG, 3), "-", 2)
    If (year < 2020) || (year > 2030) Set year = +$PIECE($ZDATE(+$HOROLOG, 3), "-", 1)
    
    // Obtener fecha del primer día de la semana actual
    Set today = +$HOROLOG
    Set todayDayOfWeek = $SYSTEM.SQL.DAYOFWEEK(today)  // 1=Sunday
    Set startOfWeek = today - (todayDayOfWeek - 1)  // Domingo de esta semana
    
    // Obtener slots del walker para esta semana
    Set endOfWeek = startOfWeek + 6
    Set slots = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startOfWeek, endOfWeek)
    Set walkerSlots = {}
    
    // Organizar slots por fecha para el walker actual
    For i=0:1:slots.%Size()-1 {
        Set slot = slots.%Get(i)
        If slot.walkerId = walkerId {
            Set dateKey = slot.date
            If 'walkerSlots.%IsDefined(dateKey) {
                Do walkerSlots.%Set(dateKey, ##class(%DynamicArray).%New())
            }
            Do walkerSlots.%Get(dateKey).%Push(slot)
        }
    }
    
    // Crear tabla de calendario semanal
    Write "<div class='calendar-grid'>"
    Write "<table class='table table-bordered calendar-week-table'>"
    
    // Encabezados de días de la semana
    Write "<thead>"
    Write "<tr class='calendar-header-row'>"
    
    Set dayNames(1) = "Domingo"
    Set dayNames(2) = "Lunes"
    Set dayNames(3) = "Martes"
    Set dayNames(4) = "Miércoles"
    Set dayNames(5) = "Jueves"
    Set dayNames(6) = "Viernes"
    Set dayNames(7) = "Sábado"
    
    For dayOfWeek=1:1:7 {
        Set currentDate = startOfWeek + (dayOfWeek - 1)
        Set currentDateStr = ##class(Demo.PETS.Availability).FormatDate(currentDate)
        Set dayNumber = +$PIECE(currentDateStr, "-", 3)
        
        Write "<th class='calendar-day-header week-header'>"
        Write "<div class='week-day-name'>" _ dayNames(dayOfWeek) _ "</div>"
        Write "<div class='week-day-number'>" _ dayNumber _ "</div>"
        Write "</th>"
    }
    Write "</tr>"
    Write "</thead>"
    
    Write "<tbody>"
    Write "<tr class='calendar-week-content'>"
    
    // Renderizar días de la semana (columnas)
    For dayOfWeek=1:1:7 {
        Set currentDate = startOfWeek + (dayOfWeek - 1)
        Set currentDateStr = ##class(Demo.PETS.Availability).FormatDate(currentDate)
        
        Set dayClasses = "calendar-day-cell week-day-cell"
        If currentDate = today Set dayClasses = dayClasses _ " today"
        
        Set daySlots = walkerSlots.%Get(currentDateStr)
        If $IsObject(daySlots) && daySlots.%Size() > 0 {
            Set dayClasses = dayClasses _ " has-slots"
        }
        
        Write "<td class='" _ dayClasses _ "' onclick='openDayModal(""" _ currentDateStr _ """)'>"
        
        Write "<div class='week-day-content'>"
        
        // Mostrar slots del día
        If $IsObject(daySlots) {
            For s=0:1:daySlots.%Size()-1 {
                Set slot = daySlots.%Get(s)
                Set slotClass = "slot-item week-slot"
                If slot.availableSlots = 0 {
                    Set slotClass = slotClass _ " booked"
                } ElseIf slot.availableSlots < slot.maxCapacity {
                    Set slotClass = slotClass _ " partial"
                }
                
                Write "<div class='" _ slotClass _ "' title='" _ slot.startTime _ "-" _ slot.endTime _ " (" _ slot.availableSlots _ "/" _ slot.maxCapacity _ ")'>"
                Write "<div class='slot-time'>" _ slot.startTime _ "</div>"
                Write "<div class='slot-duration'>" _ slot.endTime _ "</div>"
                Write "<div class='slot-capacity'>(" _ slot.availableSlots _ "/" _ slot.maxCapacity _ ")</div>"
                Write "</div>"
            }
        } Else {
            Write "<div class='no-slots text-muted'>Sin slots</div>"
        }
        
        Write "</div>"
        
        // Botón para agregar slot
        If currentDate >= today {
            Write "<div class='week-day-actions'>"
            Write "<button class='add-slot-btn btn btn-sm btn-light' onclick='event.stopPropagation(); openQuickAdd(""" _ currentDateStr _ """)' title='Agregar slot'>"
            Write "<i class='fas fa-plus'></i>"
            Write "</button>"
            Write "</div>"
        }
        
        Write "</td>"
    }
    
    Write "</tr>"
    Write "</tbody>"
    Write "</table>"
    Write "</div>"
    
    Return $$$OK
}

/// Renderiza modales para funcionalidades del calendario
ClassMethod RenderModals(walkerId As %Integer, month As %Integer, year As %Integer) As %Status
{
    // Modal para agregar slot rápido
    Write "<!-- Quick Add Slot Modal -->"
    Write "<div class='modal fade' id='quickAddModal' tabindex='-1'>"
    Write "<div class='modal-dialog modal-lg'>"
    Write "<div class='modal-content'>"
    Write "<div class='modal-header'>"
    Write "<h5 class='modal-title'><i class='fas fa-plus'></i> Agregar Slot Rápido</h5>"
    Write "<button type='button' class='btn-close' data-bs-dismiss='modal'></button>"
    Write "</div>"
    Write "<form method='POST'>"
    Write "<input type='hidden' name='calendar_action' value='create_slot'>"
    Write "<input type='hidden' name='walker_id' value='" _ walkerId _ "'>"
    Write "<div class='modal-body'>"
    
    Write "<div class='row'>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Fecha</label>"
    Set defaultDate = $ZDATE(+$HOROLOG + 1, 3)  // Mañana
    Write "<input type='date' class='form-control' name='slot_date' id='quickAddDate' value='" _ defaultDate _ "' required>"
    Write "</div>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Hora Inicio</label>"
    Write "<div class='row g-1'>"
    Write "<div class='col-6'>"
    Write "<select class='form-select' name='slot_start_hour' required>"
    Write "<option value='06'>06</option>"
    Write "<option value='07'>07</option>"
    Write "<option value='08' selected>08</option>"
    Write "<option value='09'>09</option>"
    Write "<option value='10'>10</option>"
    Write "<option value='11'>11</option>"
    Write "<option value='12'>12</option>"
    Write "<option value='13'>13</option>"
    Write "<option value='14'>14</option>"
    Write "<option value='15'>15</option>"
    Write "<option value='16'>16</option>"
    Write "<option value='17'>17</option>"
    Write "<option value='18'>18</option>"
    Write "<option value='19'>19</option>"
    Write "<option value='20'>20</option>"
    Write "<option value='21'>21</option>"
    Write "<option value='22'>22</option>"
    Write "</select>"
    Write "</div>"
    Write "<div class='col-6'>"
    Write "<select class='form-select' name='slot_start_minute' required>"
    Write "<option value='00' selected>00</option>"
    Write "<option value='15'>15</option>"
    Write "<option value='30'>30</option>"
    Write "<option value='45'>45</option>"
    Write "</select>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Hora Fin</label>"
    Write "<div class='row g-1'>"
    Write "<div class='col-6'>"
    Write "<select class='form-select' name='slot_end_hour' required>"
    Write "<option value='07'>07</option>"
    Write "<option value='08'>08</option>"
    Write "<option value='09' selected>09</option>"
    Write "<option value='10'>10</option>"
    Write "<option value='11'>11</option>"
    Write "<option value='12'>12</option>"
    Write "<option value='13'>13</option>"
    Write "<option value='14'>14</option>"
    Write "<option value='15'>15</option>"
    Write "<option value='16'>16</option>"
    Write "<option value='17'>17</option>"
    Write "<option value='18'>18</option>"
    Write "<option value='19'>19</option>"
    Write "<option value='20'>20</option>"
    Write "<option value='21'>21</option>"
    Write "<option value='22'>22</option>"
    Write "<option value='23'>23</option>"
    Write "</select>"
    Write "</div>"
    Write "<div class='col-6'>"
    Write "<select class='form-select' name='slot_end_minute' required>"
    Write "<option value='00' selected>00</option>"
    Write "<option value='15'>15</option>"
    Write "<option value='30'>30</option>"
    Write "<option value='45'>45</option>"
    Write "</select>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Write "<div class='row mt-3'>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Máx. Mascotas</label>"
    Write "<input type='number' class='form-control' name='slot_max_pets' min='1' max='10' value='3' required>"
    Write "</div>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Tarifa Especial</label>"
    Write "<input type='number' class='form-control' name='slot_special_rate' min='0' step='0.01' placeholder='Opcional'>"
    Write "</div>"
    Write "<div class='col-md-4'>"
    Write "<label class='form-label'>Notas</label>"
    Write "<input type='text' class='form-control' name='slot_notes' maxlength='100' placeholder='Opcional'>"
    Write "</div>"
    Write "</div>"
    
    Write "</div>"
    Write "<div class='modal-footer'>"
    Write "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>"
    Write "<button type='submit' class='btn btn-primary'>Crear Slot</button>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    // Modal para creación masiva
    Write "<!-- Bulk Create Modal -->"
    Write "<div class='modal fade' id='bulkCreateModal' tabindex='-1'>"
    Write "<div class='modal-dialog modal-lg'>"
    Write "<div class='modal-content'>"
    Write "<div class='modal-header'>"
    Write "<h5 class='modal-title'><i class='fas fa-calendar-plus'></i> Creación Masiva de Slots</h5>"
    Write "<button type='button' class='btn-close' data-bs-dismiss='modal'></button>"
    Write "</div>"
    Write "<form method='POST'>"
    Write "<input type='hidden' name='calendar_action' value='bulk_create'>"
    Write "<div class='modal-body'>"
    
    Write "<div class='row'>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Fecha Inicio</label>"
    Write "<input type='date' class='form-control' name='bulk_start_date' value='" _ $ZDATE(+$HOROLOG + 1, 3) _ "' required>"
    Write "</div>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Fecha Fin</label>"
    Write "<input type='date' class='form-control' name='bulk_end_date' value='" _ $ZDATE(+$HOROLOG + 14, 3) _ "' required>"
    Write "</div>"
    Write "</div>"
    
    Write "<div class='mt-3'>"
    Write "<label class='form-label'>Días de la Semana</label>"
    Write "<div class='row'>"
    Set days = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
    For i=0:1:6 {
        Set dayValue = i + 1  // 1=Sunday in $ZDATE
        Write "<div class='col-md-3'>"
        Write "<div class='form-check'>"
        Write "<input class='form-check-input' type='checkbox' name='bulk_day_" _ dayValue _ "' value='" _ dayValue _ "' id='day" _ dayValue _ "'>"
        Write "<label class='form-check-label' for='day" _ dayValue _ "'>" _ days.%Get(i) _ "</label>"
        Write "</div>"
        Write "</div>"
    }
    Write "</div>"
    Write "</div>"
    
    Write "<div class='mt-3'>"
    Write "<label class='form-label'>Horarios (formato: 09:00-10:00,14:00-15:00)</label>"
    Write "<input type='text' class='form-control' name='bulk_time_slots' placeholder='09:00-10:00,14:00-15:00,17:00-18:00 (formato 24h, minutos: :00,:15,:30,:45)' required>"
    Write "<small class='form-text text-muted'>Separa múltiples horarios con comas</small>"
    Write "</div>"
    
    Write "<div class='row mt-3'>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Máx. Mascotas por Slot</label>"
    Write "<input type='number' class='form-control' name='bulk_max_pets' min='1' max='10' value='3' required>"
    Write "</div>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Tarifa Especial</label>"
    Write "<input type='number' class='form-control' name='bulk_special_rate' min='0' step='0.01' placeholder='Opcional'>"
    Write "</div>"
    Write "</div>"
    
    Write "</div>"
    Write "<div class='modal-footer'>"
    Write "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>"
    Write "<button type='submit' class='btn btn-warning'>Crear Slots Masivamente</button>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Return $$$OK
}

/// JavaScript para funcionalidades del calendario
ClassMethod RenderCalendarJavaScript(walkerId As %Integer) As %Status
{
    Write "<script>"
    Write "function changeWalker(newWalkerId) {"
    Write "  const urlParams = new URLSearchParams(window.location.search);"
    Write "  urlParams.set('walkerId', newWalkerId);"
    Write "  // Preservar vista actual, mes y año"
    Write "  if (!urlParams.has('month')) urlParams.set('month', new Date().getMonth() + 1);"
    Write "  if (!urlParams.has('year')) urlParams.set('year', new Date().getFullYear());"
    Write "  if (!urlParams.has('view')) urlParams.set('view', 'month');"
    Write "  window.location.href = window.location.pathname + '?' + urlParams.toString();"
    Write "}"
    Write ""
    Write "function openDayModal(date) {"
    Write "  console.log('Opening day modal for:', date);"
    Write "  // Implementar modal de día completo"
    Write "}"
    Write ""
    Write "function openQuickAdd(date) {"
    Write "  console.log('Opening quick add for date:', date);"
    Write "  var dateInput = document.getElementById('quickAddDate');"
    Write "  if (dateInput) {"
    Write "    dateInput.value = date;"
    Write "  } else {"
    Write "    console.error('quickAddDate input not found');"
    Write "  }"
    Write "  var modalElement = document.getElementById('quickAddModal');"
    Write "  if (modalElement) {"
    Write "    if (typeof bootstrap !== 'undefined') {"
    Write "      var modal = new bootstrap.Modal(modalElement);"
    Write "      modal.show();"
    Write "    } else {"
    Write "      console.error('Bootstrap not loaded');"
    Write "      modalElement.style.display = 'block';"
    Write "      modalElement.classList.add('show');"
    Write "    }"
    Write "  } else {"
    Write "    console.error('quickAddModal not found');"
    Write "  }"
    Write "}"
    Write ""
    Write "// Recopilar días seleccionados para bulk create"
    Write "function collectSelectedDays() {"
    Write "  const form = document.querySelector('#bulkCreateModal form');"
    Write "  const selectedDays = [];"
    Write "  for (let i = 1; i <= 7; i++) {"
    Write "    const checkbox = form.querySelector(`[name='bulk_day_${i}']`);"
    Write "    if (checkbox && checkbox.checked) {"
    Write "      selectedDays.push(i);"
    Write "    }"
    Write "  }"
    Write "  "
    Write "  // Crear input hidden con días seleccionados"
    Write "  let hiddenInput = form.querySelector('[name=""bulk_selected_days""]');"
    Write "  if (!hiddenInput) {"
    Write "    hiddenInput = document.createElement('input');"
    Write "    hiddenInput.type = 'hidden';"
    Write "    hiddenInput.name = 'bulk_selected_days';"
    Write "    form.appendChild(hiddenInput);"
    Write "  }"
    Write "  hiddenInput.value = selectedDays.join(',');"
    Write "}"
    Write ""
    Write "// Agregar event listener al form de bulk create"
    Write "document.addEventListener('DOMContentLoaded', function() {"
    Write "  const bulkForm = document.querySelector('#bulkCreateModal form');"
    Write "  if (bulkForm) {"
    Write "    bulkForm.addEventListener('submit', function(e) {"
    Write "      collectSelectedDays();"
    Write "    });"
    Write "  }"
    Write "});"
    Write "</script>"
    
    Return $$$OK
}

/// Obtiene nombre del mes
ClassMethod GetMonthName(month As %Integer) As %String
{
    If (month < 1) || (month > 12) {
        Return "Mes Inválido"
    }
    
    Set monthNames(1) = "Enero"
    Set monthNames(2) = "Febrero"
    Set monthNames(3) = "Marzo" 
    Set monthNames(4) = "Abril"
    Set monthNames(5) = "Mayo"
    Set monthNames(6) = "Junio"
    Set monthNames(7) = "Julio"
    Set monthNames(8) = "Agosto"
    Set monthNames(9) = "Septiembre"
    Set monthNames(10) = "Octubre"
    Set monthNames(11) = "Noviembre"
    Set monthNames(12) = "Diciembre"
    
    Return monthNames(month)
}

/// Obtiene días en el mes
ClassMethod GetDaysInMonth(month As %Integer, year As %Integer) As %Integer
{
    If month = 2 {
        // Año bisiesto
        If (year # 4 = 0) && ((year # 100 '= 0) || (year # 400 = 0)) {
            Return 29
        } Else {
            Return 28
        }
    } ElseIf (month = 4) || (month = 6) || (month = 9) || (month = 11) {
        Return 30
    } Else {
        Return 31
    }
}

/// Renderiza opciones de walkers para el selector
ClassMethod RenderWalkerOptions(currentWalkerId As %Integer) As %Status
{
    Try {
        Set sql = "SELECT ID, Name FROM Demo_PETS.Walkers ORDER BY Name"
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        
        If $$$ISOK(status) {
            Set resultSet = statement.%Execute()
            While resultSet.%Next() {
                Set walkerId = resultSet.%Get("ID")
                Set walkerName = resultSet.%Get("Name")
                Set selected = $SELECT(walkerId = currentWalkerId:" selected", 1:"")
                Write "<option value='" _ walkerId _ "'" _ selected _ ">" _ walkerName _ "</option>"
            }
        } Else {
            // Fallback si hay error
            Write "<option value='" _ currentWalkerId _ "' selected>Walker " _ currentWalkerId _ "</option>"
        }
        
    } Catch ex {
        // En caso de error, mostrar walker actual
        Write "<option value='" _ currentWalkerId _ "' selected>Walker " _ currentWalkerId _ "</option>"
    }
    
    Return $$$OK
}

}
