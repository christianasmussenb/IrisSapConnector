/// Página web para gestión de disponibilidad de walkers
/// Interfaz para que walkers puedan registrar, editar y eliminar su disponibilidad
Class Demo.REST.AvailabilityForm Extends %CSP.Page
{

/// Permitir acceso sin autenticación
Parameter SECURITYCONTEXT = "%SYS";

/// No requerir login
Parameter PRIVATE = 0;

/// Método principal que renderiza la página
ClassMethod OnPage() As %Status
{
    // Headers para contenido HTML
    Set %response.ContentType = "text/html"
    
    // Obtener walker ID desde parámetros o combo de selección
    Set walkerId = $GET(%request.Data("walkerId", 1), 1)
    Set selectedWalkerId = $GET(%request.Data("selected_walker", 1), "")
    
    // Si se seleccionó un walker diferente desde el combo, usar ese ID
    If selectedWalkerId '= "" {
        Set walkerId = +selectedWalkerId
    }
    
    Set action = $GET(%request.Data("action", 1), "view")
    
    // Procesar acciones POST
    If %request.Method = "POST" {
        // Si es cambio de walker, no procesar formulario, solo cambiar selección
        Set formAction = $GET(%request.Data("form_action", 1), "")
        If formAction '= "change_walker" {
            Do ..ProcessFormSubmission(walkerId)
        }
    }
    
    // Renderizar página
    Do ..RenderPage(walkerId, action)
    
    Return $$$OK
}

/// Procesa el envío del formulario
ClassMethod ProcessFormSubmission(walkerId As %Integer) As %Status
{
    Try {
        Set action = $GET(%request.Data("form_action", 1))
        
        If action = "add" {
            Do ..ProcessAddAvailability(walkerId)
        } ElseIf action = "edit" {
            Do ..ProcessEditAvailability(walkerId)
        } ElseIf action = "delete" {
            Do ..ProcessDeleteAvailability(walkerId)
        } ElseIf action = "duplicate" {
            Do ..ProcessDuplicateAvailability(walkerId)
        } ElseIf action = "mass_delete" {
            Do ..ProcessMassDeleteAvailability(walkerId)
        } ElseIf action = "create_template" {
            Do ..ProcessCreateTemplate(walkerId)
        }
        
    } Catch ex {
        Write "<div class='alert alert-danger'>Error: " _ ex.DisplayString() _ "</div>"
    }
    
    Return $$$OK
}

/// Procesa adición de nueva disponibilidad
ClassMethod ProcessAddAvailability(walkerId As %Integer) As %Status
{
    // Leer datos del request
    Set dateStr = $GET(%request.Data("available_date", 1))
    Set startTime = $GET(%request.Data("start_time", 1))
    Set endTime = $GET(%request.Data("end_time", 1))
    Set maxPets = +$GET(%request.Data("max_pets", 1))
    Set specialRate = +$GET(%request.Data("special_rate", 1))
    Set notes = $GET(%request.Data("notes", 1))

        // Normalizar/convertir fecha: soportar "YYYY-MM-DD" (type=date) y "DD/MM/YYYY"
        Set date = ""
        If dateStr'="" {
            // parse sin NEW
            Set y="",m="",d="",us=""
            If dateStr["-" {
                Set y=$PIECE(dateStr,"-",1), m=$PIECE(dateStr,"-",2), d=$PIECE(dateStr,"-",3)
            } ElseIf dateStr["/" {
                Set d=$PIECE(dateStr,"/",1), m=$PIECE(dateStr,"/",2), y=$PIECE(dateStr,"/",3)
            }
            If (y'="")&(m'="")&(d'="") {
                Set us=m_"/"_d_"/"_y
                Set date=$ZDATEH(us,1)
            }
        }
        If date="" {
            Write "<div class='alert alert-danger'>Fecha inválida. Use YYYY-MM-DD o DD/MM/YYYY.</div>"
            Quit $$$OK
        }

        // Normalizar/convertir horas: aceptar HH:MM u HH:MM:SS
        Set startTimeSeconds = "", endTimeSeconds = ""
        If startTime'="" {
            Set h=+$PIECE(startTime,":",1), m=+$PIECE(startTime,":",2), s=+$PIECE(startTime,":",3)
            If s="" Set s=0
            Set startTimeSeconds = (h*3600)+(m*60)+s
        }
        If endTime'="" {
            Set h=+$PIECE(endTime,":",1), m=+$PIECE(endTime,":",2), s=+$PIECE(endTime,":",3)
            If s="" Set s=0
            Set endTimeSeconds = (h*3600)+(m*60)+s
        }
        If (startTimeSeconds="")!(endTimeSeconds="") {
            Write "<div class='alert alert-danger'>Horas inválidas. Use HH:MM.</div>"
            Quit $$$OK
        }
        If startTimeSeconds<endTimeSeconds {
            // ok
        } Else {
            Write "<div class='alert alert-danger'>La hora de inicio debe ser anterior a la hora de fin.</div>"
            Quit $$$OK
        }

        // Validaciones básicas de números
        If maxPets<1 {
            Write "<div class='alert alert-danger'>Máx. Mascotas debe ser mayor o igual a 1.</div>"
            Quit $$$OK
        }
        If specialRate<0 {
            Write "<div class='alert alert-danger'>Tarifa especial inválida.</div>"
            Quit $$$OK
        }

        // Validar usando SchedulingService (reglas de negocio)
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, date, startTimeSeconds, endTimeSeconds, maxPets)
        If validation.isValid {
            // Crear nuevo slot
            Set avail = ##class(Demo.PETS.Availability).%New()
            Set avail.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
            Set avail.AvailableDate = date
            Set avail.StartTime = startTimeSeconds
            Set avail.EndTime = endTimeSeconds
            Set avail.MaxPets = maxPets
            Set avail.CurrentBookings = 0
            If specialRate > 0 Set avail.SpecialRate = specialRate
            Set avail.Notes = notes
            Set avail.IsActive = 1
        Set status = avail.%Save()
        If $$$ISOK(status) {
                Write "<div class='alert alert-success'>Disponibilidad agregada exitosamente!</div>"
            } Else {
                Write "<div class='alert alert-danger'>Error al guardar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
            }
        } Else {
            Write "<div class='alert alert-danger'>Errores de validación:<ul>"
            For i=0:1:validation.errors.%Size()-1 {
                Write "<li>" _ validation.errors.%Get(i) _ "</li>"
            }
            Write "</ul></div>"
        }
        Quit $$$OK
}

/// Procesa edición de disponibilidad existente
ClassMethod ProcessEditAvailability(walkerId As %Integer) As %Status
{
    Set slotId = +$GET(%request.Data("slot_id", 1))
    Set maxPets = +$GET(%request.Data("edit_max_pets", 1))
    Set specialRate = +$GET(%request.Data("edit_special_rate", 1))
    Set notes = $GET(%request.Data("edit_notes", 1))
    Set isActive = +$GET(%request.Data("edit_is_active", 1), 1)
    
    Set avail = ##class(Demo.PETS.Availability).%OpenId(slotId)
    If $IsObject(avail) {
        Set avail.MaxPets = maxPets
        Set avail.SpecialRate = specialRate
        Set avail.Notes = notes
        Set avail.IsActive = isActive
        Set avail.UpdatedAt = $ZDATETIME($HOROLOG,3)
        
        Set status = avail.%Save()
        If $$$ISOK(status) {
            Write "<div class='alert alert-success'>Disponibilidad actualizada exitosamente!</div>"
        } Else {
            Write "<div class='alert alert-danger'>Error al actualizar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
        }
    } Else {
        Write "<div class='alert alert-danger'>Slot de disponibilidad no encontrado.</div>"
    }
    
    Return $$$OK
}

/// Procesa eliminación de disponibilidad
ClassMethod ProcessDeleteAvailability(walkerId As %Integer) As %Status
{
    Set slotId = +$GET(%request.Data("delete_slot_id", 1))
    
    Set avail = ##class(Demo.PETS.Availability).%OpenId(slotId)
    If $IsObject(avail) {
        // Solo permitir eliminar si no hay reservas
        If avail.CurrentBookings = 0 {
            Set status = avail.%DeleteId(slotId)
            If $$$ISOK(status) {
                Write "<div class='alert alert-success'>Disponibilidad eliminada exitosamente!</div>"
            } Else {
                Write "<div class='alert alert-danger'>Error al eliminar: " _ $SYSTEM.Status.GetOneErrorText(status) _ "</div>"
            }
        } Else {
            Write "<div class='alert alert-warning'>No se puede eliminar slot con reservas existentes (" _ avail.CurrentBookings _ " reservas).</div>"
        }
    } Else {
        Write "<div class='alert alert-danger'>Slot de disponibilidad no encontrado.</div>"
    }
    
    Return $$$OK
}

/// Renderiza la página principal
ClassMethod RenderPage(walkerId As %Integer, action As %String) As %Status
{
    // Obtener información del walker
    Set walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
    Set walkerName = ""
    If $IsObject(walker) {
        Set walkerName = walker.Name
    }
    
    // Obtener configuraciones
    Set operatingHours = ##class(Demo.PETS.Services.ConfigService).GetOperatingHours()
    Set systemLimits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
    
    Write "<!DOCTYPE html>"
    Write "<html lang='es'>"
    Write "<head>"
    Write "<meta charset='UTF-8'>"
    Write "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    Write "<title>Gestión de Disponibilidad - " _ walkerName _ "</title>"
    Write "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Write "<link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>"
    Write "<style>"
    Write ".availability-card { margin-bottom: 15px; }"
    Write ".time-slot { font-weight: bold; color: #0d6efd; }"
    Write ".capacity-info { color: #6c757d; font-size: 0.9em; }"
    Write ".status-active { color: #198754; }"
    Write ".status-inactive { color: #dc3545; }"
    Write "</style>"
    Write "</head>"
    Write "<body class='bg-light'>"
    
    Write "<div class='container mt-4'>"
    Write "<div class='row'>"
    Write "<div class='col-12'>"
    
    // Header con título y botón de volver al menú
    Write "<div class='d-flex justify-content-between align-items-center mb-3'>"
    Write "<div>"
    Write "<h1><i class='fas fa-calendar-alt'></i> Gestión de Disponibilidad</h1>"
    Write "</div>"
    Write "<div>"
    Write "<a href='/csp/demo2/' class='btn btn-outline-primary btn-lg'>"
    Write "<i class='fas fa-home'></i> Volver al Menú Principal"
    Write "</a>"
    Write "</div>"
    Write "</div>"
    
    // Combo para seleccionar walker
    Write "<div class='row mb-4'>"
    Write "<div class='col-md-6'>"
    Write "<form method='POST' id='walkerForm'>"
    Write "<input type='hidden' name='form_action' value='change_walker'>"
    Write "<div class='card'>"
    Write "<div class='card-body'>"
    Write "<label for='selected_walker' class='form-label'>"
    Write "<i class='fas fa-user-tie'></i> <strong>Seleccionar Paseador:</strong>"
    Write "</label>"
    Write "<select class='form-select form-select-lg' id='selected_walker' name='selected_walker' "
    Write "onchange='document.getElementById(""walkerForm"").submit();'>"
    
    // Obtener lista de walkers
    Do ..RenderWalkerOptions(walkerId)
    
    Write "</select>"
    Write "<small class='form-text text-muted'>Seleccione el paseador para gestionar su disponibilidad</small>"
    Write "</div>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    
    // Información del walker actual
    Write "<div class='col-md-6'>"
    Write "<div class='alert alert-info h-100 d-flex align-items-center'>"
    Write "<div>"
    Write "<h5 class='mb-1'><i class='fas fa-info-circle'></i> Walker Actual</h5>"
    Write "<p class='mb-0'><strong>" _ walkerName _ "</strong> (ID: " _ walkerId _ ")</p>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Write "<hr>"
    Write "</div>"
    Write "</div>"
    
    // Mostrar formulario de agregar nueva disponibilidad
    Do ..RenderAddForm(walkerId, operatingHours, systemLimits)
    
    // Mostrar disponibilidades existentes
    Do ..RenderExistingAvailability(walkerId)
    
    Write "</div>"
    
    Write "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js'></script>"
    Write "<script>"
    
    Write "// Validar rango de tiempo en tiempo real"
    Write "function validateTimeRange() {"
    Write "  const startTime = document.getElementById('start_time').value;"
    Write "  const endTime = document.getElementById('end_time').value;"
    Write "  const endInput = document.getElementById('end_time');"
    Write "  "
    Write "  if (startTime && endTime) {"
    Write "    if (startTime >= endTime) {"
    Write "      endInput.setCustomValidity('La hora de fin debe ser posterior a la de inicio');"
    Write "      endInput.classList.add('is-invalid');"
    Write "    } else {"
    Write "      endInput.setCustomValidity('');"
    Write "      endInput.classList.remove('is-invalid');"
    Write "      endInput.classList.add('is-valid');"
    Write "    }"
    Write "  }"
    Write "}"
    Write ""
    
    Write "// Validar formulario antes de enviar - MEJORADO"
    Write "function validateForm() {"
    Write "  const date = document.getElementById('available_date').value;"
    Write "  const startTime = document.getElementById('start_time').value;"
    Write "  const endTime = document.getElementById('end_time').value;"
    Write "  const maxPets = parseInt(document.getElementById('max_pets').value);"
    Write "  "
    Write "  // Validar campos requeridos"
    Write "  if (!date || !startTime || !endTime || maxPets < 1) {"
    Write "    alert('❌ Por favor complete todos los campos requeridos.');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  // Validar fecha futura"
    Write "  const selectedDate = new Date(date);"
    Write "  const tomorrow = new Date();"
    Write "  tomorrow.setDate(tomorrow.getDate() + 1);"
    Write "  tomorrow.setHours(0,0,0,0);"
    Write "  "
    Write "  if (selectedDate < tomorrow) {"
    Write "    alert('❌ Debe seleccionar una fecha futura (desde mañana).');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  // Validar hora inicio < hora fin"
    Write "  if (startTime >= endTime) {"
    Write "    alert('❌ La hora de INICIO debe ser ANTERIOR a la hora de FIN.\\n\\nEjemplo correcto:\\n🕘 Inicio: 09:00\\n🕐 Fin: 12:00');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  // Validar máximo mascotas"
    Write "  if (maxPets > " _ systemLimits.%Get("maxPetsPerWalk", 5) _ ") {"
    Write "    alert('❌ Máximo " _ systemLimits.%Get("maxPetsPerWalk", 5) _ " mascotas por slot.');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  // Confirmación visual antes de guardar"
    Write "  const dateFormatted = new Date(date).toLocaleDateString('es-ES');"
    Write "  const confirmation = `✅ Confirmar disponibilidad:\\n\\n📅 Fecha: ${dateFormatted}\\n🕘 De: ${startTime} a ${endTime}\\n🐕 Máx mascotas: ${maxPets}\\n\\n¿Guardar esta disponibilidad?`;"
    Write "  "
    Write "  return confirm(confirmation);"
    Write "}"
    
    Write "</script>"
    
    Write "</body>"
    Write "</html>"
    
    Return $$$OK
}

/// Renderiza formulario para agregar nueva disponibilidad
ClassMethod RenderAddForm(walkerId As %Integer, operatingHours As %DynamicObject, systemLimits As %DynamicObject) As %Status
{
    Write "<div class='row mb-4'>"
    Write "<div class='col-12'>"
    Write "<div class='card'>"
    Write "<div class='card-header bg-primary text-white'>"
    Write "<h5><i class='fas fa-plus'></i> Agregar Nueva Disponibilidad</h5>"
    Write "</div>"
    Write "<div class='card-body'>"
    
    Write "<form method='POST' onsubmit='return validateForm()'>"
    Write "<input type='hidden' name='form_action' value='add'>"
    Write "<div class='row'>"
    
    // Fecha - CORREGIDO: permitir fechas futuras desde HOY con límites seguros
    Write "<div class='col-md-3'>"
    Write "<label for='available_date' class='form-label'>Fecha <span class='text-danger'>*</span></label>"
    Set minDate = $ZDATE($HOROLOG, 3)  // DESDE HOY (no mañana) para mayor flexibilidad
    Set systemLimits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
    Set maxDays = systemLimits.%Get("maxBookingDaysAhead", 30)  // Default 30 días
    
    // Asegurarse de que maxDays sea positivo y razonable
    If maxDays <= 0 Set maxDays = 30
    If maxDays > 365 Set maxDays = 365  // Máximo 1 año
    
    Set maxDate = $ZDATE($HOROLOG + maxDays, 3)
    Write "<input type='date' class='form-control' id='available_date' name='available_date' required "
    Write "min='" _ minDate _ "' max='" _ maxDate _ "' "
    Write "title='Seleccione una fecha (desde hoy hasta " _ maxDays _ " días adelante)'>"
    Write "<small class='form-text text-muted'>Desde: " _ $ZDATE($HOROLOG, 1) _ " hasta: " _ $ZDATE($HOROLOG + maxDays, 1) _ "</small>"
    Write "</div>"
    
    // Hora inicio - MEJORADO: con validación y ayuda visual
    Write "<div class='col-md-2'>"
    Write "<label for='start_time' class='form-label'>🕐 Hora Inicio <span class='text-danger'>*</span></label>"
    Write "<input type='time' class='form-control' id='start_time' name='start_time' required "
    Write "min='" _ operatingHours.%Get("startTime", "06:00") _ "' max='" _ operatingHours.%Get("endTime", "20:00") _ "' "
    Write "onchange='validateTimeRange()' title='Hora de inicio del turno'>"
    Write "<small class='form-text text-muted'>Ej: 09:00</small>"
    Write "</div>"
    
    // Hora fin - MEJORADO: con validación y ayuda visual  
    Write "<div class='col-md-2'>"
    Write "<label for='end_time' class='form-label'>🕐 Hora Fin <span class='text-danger'>*</span></label>"
    Write "<input type='time' class='form-control' id='end_time' name='end_time' required "
    Write "min='" _ operatingHours.%Get("startTime", "06:00") _ "' max='" _ operatingHours.%Get("endTime", "20:00") _ "' "
    Write "onchange='validateTimeRange()' title='Hora de fin del turno (debe ser posterior al inicio)'>"
    Write "<small class='form-text text-muted'>Ej: 12:00 (posterior al inicio)</small>"
    Write "</div>"
    
    // Máximo mascotas
    Write "<div class='col-md-2'>"
    Write "<label for='max_pets' class='form-label'>Máx. Mascotas <span class='text-danger'>*</span></label>"
    Write "<input type='number' class='form-control' id='max_pets' name='max_pets' required "
    Write "min='1' max='" _ systemLimits.%Get("maxPetsPerWalk", 5) _ "' value='3'>"
    Write "</div>"
    
    // Tarifa especial
    Write "<div class='col-md-3'>"
    Write "<label for='special_rate' class='form-label'>Tarifa Especial ($)</label>"
    Write "<input type='number' class='form-control' id='special_rate' name='special_rate' "
    Write "min='0' step='0.01' placeholder='Opcional'>"
    Write "</div>"
    
    Write "</div>"
    
    // Notas
    Write "<div class='row mt-3'>"
    Write "<div class='col-12'>"
    Write "<label for='notes' class='form-label'>Notas</label>"
    Write "<textarea class='form-control' id='notes' name='notes' rows='2' maxlength='500' "
    Write "placeholder='Información adicional sobre este slot...'></textarea>"
    Write "</div>"
    Write "</div>"
    
    // Botón enviar
    Write "<div class='row mt-3'>"
    Write "<div class='col-12'>"
    Write "<button type='submit' class='btn btn-primary'>"
    Write "<i class='fas fa-save'></i> Agregar Disponibilidad"
    Write "</button>"
    Write "</div>"
    Write "</div>"
    
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Return $$$OK
}

/// Renderiza disponibilidades existentes
ClassMethod RenderExistingAvailability(walkerId As %Integer) As %Status
{
    Set currentDate = +$HOROLOG
    Set endDate = currentDate + 30  // Próximos 30 días
    
    Set slots = ##class(Demo.PETS.Services.SchedulingService).GetWalkerAvailability(walkerId, currentDate)
    
    Write "<div class='row'>"
    Write "<div class='col-12'>"
    Write "<div class='card'>"
    Write "<div class='card-header bg-secondary text-white d-flex justify-content-between align-items-center'>"
    Write "<h5><i class='fas fa-list'></i> Mi Disponibilidad Actual</h5>"
    Write "<small>Próximos 30 días</small>"
    Write "</div>"
    Write "<div class='card-body'>"
    
    If slots.%Size() = 0 {
        Write "<div class='alert alert-info'>"
        Write "<i class='fas fa-info-circle'></i> No tienes disponibilidad registrada aún."
        Write "</div>"
    } Else {
        Do ..RenderAvailabilityList(walkerId, slots)
    }
    
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Return $$$OK
}

/// Renderiza lista de disponibilidades con funciones CRUD (T1.2.5)
ClassMethod RenderAvailabilityList(walkerId As %Integer, slots As %DynamicArray) As %Status
{
    // Botones de acción masiva
    Write "<div class='row mb-3'>"
    Write "<div class='col-12'>"
    Write "<div class='d-flex gap-2 mb-3'>"
    Write "<button type='button' class='btn btn-warning' onclick='selectAllSlots()'><i class='fas fa-check-square'></i> Seleccionar Todo</button>"
    Write "<button type='button' class='btn btn-outline-warning' onclick='unselectAllSlots()'><i class='fas fa-square'></i> Deseleccionar</button>"
    Write "<button type='button' class='btn btn-danger' onclick='deleteSelectedSlots()'><i class='fas fa-trash'></i> Eliminar Seleccionados</button>"
    Write "<button type='button' class='btn btn-info' data-bs-toggle='modal' data-bs-target='#templateModal'><i class='fas fa-calendar-plus'></i> Crear Plantilla</button>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    
    Write "<div class='row'>"
    
    // Query directa para obtener slots con ID
    Set sql = "SELECT ID, AvailableDate, StartTime, EndTime, MaxPets, CurrentBookings, SpecialRate, Notes, IsActive "
            _ "FROM Demo_PETS.Availability "
            _ "WHERE Walker = ? AND AvailableDate >= ? AND IsActive = 1 "
            _ "ORDER BY AvailableDate, StartTime"
    
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    If $$$ISERR(status) {
        Write "<div class='alert alert-danger'>Error al cargar disponibilidad</div>"
        Return $$$OK
    }
    
    Set currentDate = +$HOROLOG
    Set result = statement.%Execute(walkerId, currentDate)
    
    Set count = 0
    While result.%Next() {
        Set count = count + 1
        Set slotId = result.%Get("ID")
        Set availableDate = result.%Get("AvailableDate")
        Set startTime = result.%Get("StartTime")
        Set endTime = result.%Get("EndTime")
        Set maxPets = result.%Get("MaxPets")
        Set currentBookings = result.%Get("CurrentBookings")
        Set specialRate = result.%Get("SpecialRate")
        Set notes = result.%Get("Notes")
        
        Set dateStr = $ZDATE(availableDate, 5)
        Set startTimeStr = $ZTIME(startTime)
        Set endTimeStr = $ZTIME(endTime)
        
        Write "<div class='col-md-6 col-lg-4'>"
        Write "<div class='availability-card card'>"
        Write "<div class='card-header d-flex justify-content-between align-items-center'>"
        Write "<div>"
        Write "<input type='checkbox' class='slot-checkbox me-2' value='" _ slotId _ "' data-slot-id='" _ slotId _ "'>"
        Write "<strong>" _ dateStr _ "</strong>"
        Write "</div>"
        Write "<div class='btn-group btn-group-sm' role='group'>"
        Write "<button type='button' class='btn btn-outline-primary' onclick='editSlot(" _ slotId _ ")'><i class='fas fa-edit'></i></button>"
        Write "<button type='button' class='btn btn-outline-success' onclick='duplicateSlot(" _ slotId _ ")'><i class='fas fa-copy'></i></button>"
        Write "<button type='button' class='btn btn-outline-danger' onclick='deleteSlot(" _ slotId _ ")'><i class='fas fa-trash'></i></button>"
        Write "</div>"
        Write "</div>"
        Write "<div class='card-body'>"
        Write "<p class='time-slot'><i class='fas fa-clock'></i> " _ startTimeStr _ " - " _ endTimeStr _ "</p>"
        Write "<p class='capacity-info'><i class='fas fa-dog'></i> Capacidad: " _ maxPets _ " pets"
        If currentBookings > 0 {
            Write " (" _ currentBookings _ " reservados)"
        }
        Write "</p>"
        
        If specialRate > 0 {
            Write "<p class='text-warning'><i class='fas fa-dollar-sign'></i> Tarifa especial: $" _ specialRate _ "</p>"
        }
        
        If notes '= "" {
            Write "<p class='text-muted small'><i class='fas fa-sticky-note'></i> " _ notes _ "</p>"
        }
        
        // Indicador de estado
        If currentBookings = 0 {
            Write "<span class='badge bg-success status-active'>Disponible</span>"
        } ElseIf currentBookings < maxPets {
            Write "<span class='badge bg-warning'>Parcialmente ocupado</span>"
        } Else {
            Write "<span class='badge bg-danger'>Completo</span>"
        }
        
        Write "</div>"
        Write "</div>"
        Write "</div>"
    }
    
    If count = 0 {
        Write "<div class='col-12'>"
        Write "<div class='alert alert-info'>"
        Write "<i class='fas fa-info-circle'></i> No tienes disponibilidad registrada en los próximos 30 días."
        Write "</div>"
        Write "</div>"
    }
    
    Write "</div>"
    
    // Agregar modales para edición y duplicación
    Do ..RenderEditModal()
    Do ..RenderDuplicateModal()
    Do ..RenderTemplateModal()
    
    // JS común para acciones CRUD avanzadas
    Write "<script>"
    Write "function selectAllSlots(){document.querySelectorAll('.slot-checkbox').forEach(cb=>cb.checked=true);}"
    Write "function unselectAllSlots(){document.querySelectorAll('.slot-checkbox').forEach(cb=>cb.checked=false);}"
    Write "function deleteSelectedSlots(){"
    Write "  const ids=[...document.querySelectorAll('.slot-checkbox:checked')].map(cb=>cb.value);"
    Write "  if(ids.length===0){alert('No hay slots seleccionados');return;}"
    Write "  if(!confirm('¿Eliminar '+ids.length+' slots seleccionados?')) return;"
    Write "  const f=document.createElement('form');f.method='POST';"
    Write "  const a=document.createElement('input');a.type='hidden';a.name='form_action';a.value='mass_delete';f.appendChild(a);"
    Write "  const s=document.createElement('input');s.type='hidden';s.name='selected_slots';s.value=ids.join(',');f.appendChild(s);"
    Write "  document.body.appendChild(f);f.submit();"
    Write "}"
    Write "function deleteSlot(id){if(confirm('¿Está seguro de eliminar esta disponibilidad?')){const f=document.createElement('form');f.method='POST';const a=document.createElement('input');a.type='hidden';a.name='form_action';a.value='delete';f.appendChild(a);const s=document.createElement('input');s.type='hidden';s.name='delete_slot_id';s.value=id;f.appendChild(s);document.body.appendChild(f);f.submit();}}"
    Write "function duplicateSlot(id){document.getElementById('duplicateSourceId').value=id;new bootstrap.Modal(document.getElementById('duplicateModal')).show();}"
    Write "function editSlot(id){document.getElementById('edit_slot_id').value=id;new bootstrap.Modal(document.getElementById('editModal')).show();}"
    Write "document.addEventListener('DOMContentLoaded',()=>{const tf=document.getElementById('templateForm');if(tf){tf.addEventListener('submit',function(e){const cbs=[...this.querySelectorAll('input[name=\\'template_weekday_option\\']:checked')];if(cbs.length===0){e.preventDefault();alert('Selecciona al menos un día');return false;}const hidden=this.querySelector('input[name=\\'template_weekdays\\']')||document.createElement('input');hidden.type='hidden';hidden.name='template_weekdays';hidden.value=cbs.map(x=>x.value).join(',');this.appendChild(hidden);});}});"
    Write "</script>"
    
    Return $$$OK
}

/// Modal de edición rápida (capacidad, tarifa, notas, estado)
ClassMethod RenderEditModal() As %Status
{
    Write "<div class='modal fade' id='editModal' tabindex='-1'>"
    Write "<div class='modal-dialog'>"
    Write "<div class='modal-content'>"
    Write "<div class='modal-header bg-warning text-dark'>"
    Write "<h5 class='modal-title'><i class='fas fa-edit'></i> Editar Disponibilidad</h5>"
    Write "<button type='button' class='btn-close' data-bs-dismiss='modal'></button>"
    Write "</div>"
    Write "<form method='POST'>"
    Write "<input type='hidden' name='form_action' value='edit'>"
    Write "<input type='hidden' id='edit_slot_id' name='slot_id'>"
    Write "<div class='modal-body'>"
    Write "<div class='mb-3'>"
    Write "<label class='form-label'>Máx. Mascotas</label>"
    Write "<input type='number' class='form-control' name='edit_max_pets' min='1' max='5' required>"
    Write "</div>"
    Write "<div class='mb-3'>"
    Write "<label class='form-label'>Tarifa Especial ($)</label>"
    Write "<input type='number' class='form-control' name='edit_special_rate' min='0' step='0.01'>"
    Write "</div>"
    Write "<div class='mb-3'>"
    Write "<label class='form-label'>Notas</label>"
    Write "<textarea class='form-control' name='edit_notes' rows='2' maxlength='500'></textarea>"
    Write "</div>"
    Write "<div class='form-check'>"
    Write "<input class='form-check-input' type='checkbox' value='1' id='edit_is_active' name='edit_is_active' checked>"
    Write "<label class='form-check-label' for='edit_is_active'>Activo</label>"
    Write "</div>"
    Write "</div>"
    Write "<div class='modal-footer'>"
    Write "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>"
    Write "<button type='submit' class='btn btn-warning'>Guardar Cambios</button>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Return $$$OK
}

/// Modal para duplicar slot a múltiples fechas
ClassMethod RenderDuplicateModal() As %Status
{
    Write "<div class='modal fade' id='duplicateModal' tabindex='-1'>"
    Write "<div class='modal-dialog'>"
    Write "<div class='modal-content'>"
    Write "<div class='modal-header bg-info text-white'>"
    Write "<h5 class='modal-title'><i class='fas fa-copy'></i> Duplicar Disponibilidad</h5>"
    Write "<button type='button' class='btn-close btn-close-white' data-bs-dismiss='modal'></button>"
    Write "</div>"
    Write "<form method='POST'>"
    Write "<input type='hidden' name='form_action' value='duplicate'>"
    Write "<input type='hidden' id='duplicateSourceId' name='source_slot_id'>"
    Write "<div class='modal-body'>"
    Write "<div class='mb-3'>"
    Write "<label class='form-label'>Fechas destino (YYYY-MM-DD, separadas por coma)</label>"
    Write "<input type='text' class='form-control' name='target_dates' placeholder='2025-08-20, 2025-08-21' required>"
    Write "</div>"
    Write "</div>"
    Write "<div class='modal-footer'>"
    Write "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>"
    Write "<button type='submit' class='btn btn-info'>Duplicar</button>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Return $$$OK
}

/// Modal para crear plantilla recurrente
ClassMethod RenderTemplateModal() As %Status
{
    Write "<div class='modal fade' id='templateModal' tabindex='-1'>"
    Write "<div class='modal-dialog modal-lg'>"
    Write "<div class='modal-content'>"
    Write "<div class='modal-header bg-success text-white'>"
    Write "<h5 class='modal-title'><i class='fas fa-calendar-plus'></i> Crear Plantilla Recurrente</h5>"
    Write "<button type='button' class='btn-close btn-close-white' data-bs-dismiss='modal'></button>"
    Write "</div>"
    Write "<form id='templateForm' method='POST'>"
    Write "<input type='hidden' name='form_action' value='create_template'>"
    Write "<div class='modal-body'>"
    Write "<div class='row'>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Nombre de la Plantilla</label>"
    Write "<input type='text' class='form-control' name='template_name' required placeholder='Ej: Horario Matutino'>"
    Write "</div>"
    Write "<div class='col-md-3'>"
    Write "<label class='form-label'>Hora Inicio</label>"
    Write "<input type='time' class='form-control' name='template_start_time' required>"
    Write "</div>"
    Write "<div class='col-md-3'>"
    Write "<label class='form-label'>Hora Fin</label>"
    Write "<input type='time' class='form-control' name='template_end_time' required>"
    Write "</div>"
    Write "</div>"
    Write "<div class='row mt-3'>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Capacidad Máxima</label>"
    Write "<input type='number' class='form-control' name='template_max_pets' min='1' max='5' value='3' required>"
    Write "</div>"
    Write "<div class='col-md-6'>"
    Write "<label class='form-label'>Aplicar por</label>"
    Write "<select class='form-control' name='template_weeks' required>"
    Write "<option value='2'>2 semanas</option>"
    Write "<option value='4' selected>4 semanas (1 mes)</option>"
    Write "<option value='8'>8 semanas (2 meses)</option>"
    Write "</select>"
    Write "</div>"
    Write "</div>"
    Write "<div class='row mt-3'>"
    Write "<div class='col-12'>"
    Write "<label class='form-label'>Días de la Semana</label>"
    Write "<div class='d-flex flex-wrap gap-3'>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='1' id='mon'><label class='form-check-label' for='mon'>Lunes</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='2' id='tue'><label class='form-check-label' for='tue'>Martes</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='3' id='wed'><label class='form-check-label' for='wed'>Miércoles</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='4' id='thu'><label class='form-check-label' for='thu'>Jueves</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='5' id='fri'><label class='form-check-label' for='fri'>Viernes</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='6' id='sat'><label class='form-check-label' for='sat'>Sábado</label></div>"
    Write "<div class='form-check'><input class='form-check-input' type='checkbox' name='template_weekday_option' value='7' id='sun'><label class='form-check-label' for='sun'>Domingo</label></div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Write "<div class='modal-footer'>"
    Write "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>"
    Write "<button type='submit' class='btn btn-success'>Crear Plantilla</button>"
    Write "</div>"
    Write "</form>"
    Write "</div>"
    Write "</div>"
    Write "</div>"
    Return $$$OK
}

/// Procesa duplicación de slot a múltiples fechas (T1.2.5)
ClassMethod ProcessDuplicateAvailability(walkerId As %Integer) As %Status
{
    Set sourceSlotId = +$GET(%request.Data("source_slot_id", 1))
    Set targetDates = $GET(%request.Data("target_dates", 1))  // Lista de fechas separadas por coma
    
    // Validar slot fuente existe
    Set sourceSlot = ##class(Demo.PETS.Availability).%OpenId(sourceSlotId)
    If '$IsObject(sourceSlot) {
        Write "<div class='alert alert-danger'>Slot fuente no encontrado</div>"
        Return $$$OK
    }
    
    // Validar que pertenece al walker
    If sourceSlot.Walker.%Id() '= walkerId {
        Write "<div class='alert alert-danger'>No tienes permisos para duplicar este slot</div>"
        Return $$$OK
    }
    
    Set duplicated = 0
    Set errors = 0
    
    // Procesar cada fecha objetivo
    For i=1:1:$LENGTH(targetDates, ",") {
        Set targetDateStr = $ZSTRIP($PIECE(targetDates, ",", i), "<>W")
        Continue:targetDateStr=""
        
        Try {
            Set targetDate = $ZDATEUTH(targetDateStr, 5)
            
            // Verificar si ya existe slot en esa fecha/hora
            Set existsQuery = ##class(%SQL.Statement).%New()
            Set sql = "SELECT ID FROM Demo_PETS.Availability WHERE Walker = ? AND AvailableDate = ? AND StartTime = ? AND EndTime = ?"
            Do existsQuery.%Prepare(sql)
            Set result = existsQuery.%Execute(walkerId, targetDate, sourceSlot.StartTime, sourceSlot.EndTime)
            
            If result.%Next() {
                // Ya existe, omitir
                Continue
            }
            
            // Crear duplicado
            Set newSlot = ##class(Demo.PETS.Availability).%New()
            Set newSlot.Walker = sourceSlot.Walker
            Set newSlot.AvailableDate = targetDate
            Set newSlot.StartTime = sourceSlot.StartTime
            Set newSlot.EndTime = sourceSlot.EndTime
            Set newSlot.MaxPets = sourceSlot.MaxPets
            Set newSlot.SpecialRate = sourceSlot.SpecialRate
            Set newSlot.Notes = sourceSlot.Notes _ " (Duplicado)"
            Set newSlot.IsActive = 1
            Set newSlot.CurrentBookings = 0
            
            Set status = newSlot.%Save()
            If $$$ISOK(status) {
                Set duplicated = duplicated + 1
            } Else {
                Set errors = errors + 1
            }
            
        } Catch ex {
            Set errors = errors + 1
        }
    }
    
    Write "<div class='alert alert-success'><i class='fas fa-copy'></i> Duplicación completada: " _ duplicated _ " slots creados, " _ errors _ " errores</div>"
    
    Return $$$OK
}

/// Procesa eliminación masiva de slots (T1.2.5)
ClassMethod ProcessMassDeleteAvailability(walkerId As %Integer) As %Status
{
    Set selectedIds = $GET(%request.Data("selected_slots", 1))
    
    If selectedIds = "" {
        Write "<div class='alert alert-warning'>No se seleccionaron slots para eliminar</div>"
        Return $$$OK
    }
    
    Set deleted = 0
    Set errors = 0
    
    // Procesar cada ID seleccionado
    For i=1:1:$LENGTH(selectedIds, ",") {
        Set slotId = +$PIECE(selectedIds, ",", i)
        Continue:slotId=0
        
        Try {
            Set slot = ##class(Demo.PETS.Availability).%OpenId(slotId)
            If $IsObject(slot) && (slot.Walker.%Id() = walkerId) {
                // Verificar que no tenga bookings
                If slot.CurrentBookings = 0 {
                    Set status = ##class(Demo.PETS.Availability).%DeleteId(slotId)
                    If $$$ISOK(status) {
                        Set deleted = deleted + 1
                    } Else {
                        Set errors = errors + 1
                    }
                } Else {
                    Set errors = errors + 1
                }
            }
        } Catch ex {
            Set errors = errors + 1
        }
    }
    
    Write "<div class='alert alert-success'><i class='fas fa-trash'></i> Eliminación masiva completada: " _ deleted _ " slots eliminados, " _ errors _ " errores/omitidos</div>"
    
    Return $$$OK
}

/// Procesa creación de plantilla recurrente (T1.2.5)
ClassMethod ProcessCreateTemplate(walkerId As %Integer) As %Status
{
    Set templateName = $GET(%request.Data("template_name", 1))
    Set startTime = $GET(%request.Data("template_start_time", 1))
    Set endTime = $GET(%request.Data("template_end_time", 1))
    Set maxPets = +$GET(%request.Data("template_max_pets", 1))
    Set weekdays = $GET(%request.Data("template_weekdays", 1))  // 1,2,3,4,5 (lun-vie)
    Set weeksCount = +$GET(%request.Data("template_weeks", 1), 4)  // 4 semanas por defecto
    
    // Validaciones básicas
    If templateName = "" {
        Write "<div class='alert alert-danger'>Nombre de plantilla requerido</div>"
        Return $$$OK
    }
    
    Set startTimeSeconds = $ZTIMEH(startTime)
    Set endTimeSeconds = $ZTIMEH(endTime)
    
    If startTimeSeconds >= endTimeSeconds {
        Write "<div class='alert alert-danger'>Hora de inicio debe ser anterior a hora de fin</div>"
        Return $$$OK
    }
    
    Set created = 0
    Set skipped = 0
    Set currentDate = +$HOROLOG
    
    // Crear slots para las próximas N semanas
    For week=0:1:(weeksCount-1) {
        For day=1:1:7 {
            Set targetDate = currentDate + (week * 7) + day - 1
            Set dayOfWeek = $ZDATE(targetDate, 10)  // 1=Sunday, 2=Monday, etc.
            
            // Convertir a formato Monday=1, Tuesday=2, etc.
            Set adjustedDay = dayOfWeek - 1
            If adjustedDay = 0 Set adjustedDay = 7  // Sunday = 7
            
            // Verificar si este día está en los días seleccionados
            If $FIND(weekdays, adjustedDay) {
                Try {
                    // Verificar si ya existe
                    Set existsQuery = ##class(%SQL.Statement).%New()
                    Set sql = "SELECT ID FROM Demo_PETS.Availability WHERE Walker = ? AND AvailableDate = ? AND StartTime = ? AND EndTime = ?"
                    Do existsQuery.%Prepare(sql)
                    Set result = existsQuery.%Execute(walkerId, targetDate, startTimeSeconds, endTimeSeconds)
                    
                    If result.%Next() {
                        Set skipped = skipped + 1
                        Continue
                    }
                    
                    // Crear slot
                    Set newSlot = ##class(Demo.PETS.Availability).%New()
                    Set newSlot.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
                    Set newSlot.AvailableDate = targetDate
                    Set newSlot.StartTime = startTimeSeconds
                    Set newSlot.EndTime = endTimeSeconds
                    Set newSlot.MaxPets = maxPets
                    Set newSlot.Notes = "Plantilla: " _ templateName
                    Set newSlot.IsActive = 1
                    Set newSlot.CurrentBookings = 0
                    
                    Set status = newSlot.%Save()
                    If $$$ISOK(status) {
                        Set created = created + 1
                    }
                    
                } Catch ex {
                    // Continuar con siguiente
                }
            }
        }
    }
    
    Write "<div class='alert alert-success'><i class='fas fa-calendar-plus'></i> Plantilla '" _ templateName _ "' aplicada: " _ created _ " slots creados, " _ skipped _ " omitidos</div>"
    
    Return $$$OK
}

/// Renderiza las opciones del combo de selección de walker
ClassMethod RenderWalkerOptions(currentWalkerId As %Integer) As %Status
{
    Try {
        // Consultar todos los walkers activos
        Set sql = ##class(%SQL.Statement).%New()
        Set query = "SELECT ID, Name, Phone, Email FROM Demo_PETS.Walkers ORDER BY Name"
        Do sql.%Prepare(query)
        Set result = sql.%Execute()
        
        // Opción por defecto
        Write "<option value=''>-- Seleccione un Paseador --</option>"
        
        // Iterar sobre los walkers
        While result.%Next() {
            Set walkerId = result.%Get("ID")
            Set walkerName = result.%Get("Name")
            Set walkerPhone = result.%Get("Phone")
            Set walkerEmail = result.%Get("Email")
            
            // Marcar como seleccionado si es el walker actual
            Set selected = ""
            If walkerId = currentWalkerId {
                Set selected = " selected"
            }
            
            // Crear información adicional para el tooltip
            Set walkerInfo = walkerName
            If walkerPhone '= "" {
                Set walkerInfo = walkerInfo _ " | " _ walkerPhone
            }
            If walkerEmail '= "" {
                Set walkerInfo = walkerInfo _ " | " _ walkerEmail
            }
            
            Write "<option value='" _ walkerId _ "'" _ selected _ " title='" _ walkerInfo _ "'>"
            Write walkerName _ " (ID: " _ walkerId _ ")"
            Write "</option>"
        }
        
    } Catch ex {
        Write "<option value=''>Error cargando paseadores: " _ ex.DisplayString() _ "</option>"
    }
    
    Return $$$OK
}

}
