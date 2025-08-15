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
    
    // Obtener walker ID desde parámetros (en producción vendría de sesión)
    Set walkerId = $GET(%request.Data("walkerId", 1), 1)
    Set action = $GET(%request.Data("action", 1), "view")
    
    // Procesar acciones POST
    If %request.Method = "POST" {
        Do ..ProcessFormSubmission(walkerId)
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
        }
        
    } Catch ex {
        Write "<div class='alert alert-danger'>Error: " _ ex.DisplayString() _ "</div>"
    }
    
    Return $$$OK
}

/// Procesa adición de nueva disponibilidad
ClassMethod ProcessAddAvailability(walkerId As %Integer) As %Status
{
    Set dateStr = $GET(%request.Data("available_date", 1))
    Set startTime = $GET(%request.Data("start_time", 1))
    Set endTime = $GET(%request.Data("end_time", 1))
    Set maxPets = +$GET(%request.Data("max_pets", 1))
    Set specialRate = +$GET(%request.Data("special_rate", 1))
    Set notes = $GET(%request.Data("notes", 1))
    
    // Convertir fecha
    Set date = $ZDATEUTH(dateStr, 5)  // Formato YYYY-MM-DD
    
    // Convertir tiempos
    Set startTimeSeconds = $ZTIMEH(startTime)
    Set endTimeSeconds = $ZTIMEH(endTime)
    
    // Validar usando SchedulingService
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
        If specialRate > 0 {
            Set avail.SpecialRate = specialRate
        }
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
    
    Return $$$OK
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
    Write "<h1><i class='fas fa-calendar-alt'></i> Gestión de Disponibilidad</h1>"
    Write "<p class='text-muted'>Walker: <strong>" _ walkerName _ "</strong> (ID: " _ walkerId _ ")</p>"
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
    Write "// Validar formulario antes de enviar"
    Write "function validateForm() {"
    Write "  const date = document.getElementById('available_date').value;"
    Write "  const startTime = document.getElementById('start_time').value;"
    Write "  const endTime = document.getElementById('end_time').value;"
    Write "  const maxPets = parseInt(document.getElementById('max_pets').value);"
    Write "  "
    Write "  if (!date || !startTime || !endTime || maxPets < 1) {"
    Write "    alert('Por favor complete todos los campos requeridos.');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  if (startTime >= endTime) {"
    Write "    alert('La hora de inicio debe ser anterior a la hora de fin.');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  if (maxPets > " _ systemLimits.maxPetsPerWalk _ ") {"
    Write "    alert('Máximo " _ systemLimits.maxPetsPerWalk _ " mascotas por slot.');"
    Write "    return false;"
    Write "  }"
    Write "  "
    Write "  return true;"
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
    
    // Fecha
    Write "<div class='col-md-3'>"
    Write "<label for='available_date' class='form-label'>Fecha <span class='text-danger'>*</span></label>"
    Set minDate = $ZDATE($HOROLOG, 3)  // Fecha actual en formato YYYY-MM-DD
    Set maxDate = $ZDATE($HOROLOG + ##class(Demo.PETS.Services.ConfigService).GetSystemLimits().maxBookingDaysAhead, 3)
    Write "<input type='date' class='form-control' id='available_date' name='available_date' required "
    Write "min='" _ minDate _ "' max='" _ maxDate _ "'>"
    Write "</div>"
    
    // Hora inicio
    Write "<div class='col-md-2'>"
    Write "<label for='start_time' class='form-label'>Hora Inicio <span class='text-danger'>*</span></label>"
    Write "<input type='time' class='form-control' id='start_time' name='start_time' required "
    Write "min='" _ operatingHours.startTime _ "' max='" _ operatingHours.endTime _ "'>"
    Write "</div>"
    
    // Hora fin
    Write "<div class='col-md-2'>"
    Write "<label for='end_time' class='form-label'>Hora Fin <span class='text-danger'>*</span></label>"
    Write "<input type='time' class='form-control' id='end_time' name='end_time' required "
    Write "min='" _ operatingHours.startTime _ "' max='" _ operatingHours.endTime _ "'>"
    Write "</div>"
    
    // Máximo mascotas
    Write "<div class='col-md-2'>"
    Write "<label for='max_pets' class='form-label'>Máx. Mascotas <span class='text-danger'>*</span></label>"
    Write "<input type='number' class='form-control' id='max_pets' name='max_pets' required "
    Write "min='1' max='" _ systemLimits.maxPetsPerWalk _ "' value='3'>"
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

/// Renderiza lista de disponibilidades
ClassMethod RenderAvailabilityList(walkerId As %Integer, slots As %DynamicArray) As %Status
{
    Write "<div class='row'>"
    
    // Necesito obtener slots con ID usando query directa
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
    Set resultSet = statement.%Execute(walkerId, currentDate)
    
    While resultSet.%Next() {
        Write "<div class='col-md-6 col-lg-4'>"
        Write "<div class='card availability-card h-100'>"
        Write "<div class='card-body'>"
        
        // Fecha y tiempo
        Set formattedDate = ##class(Demo.PETS.Availability).FormatDate(resultSet.%Get("AvailableDate"))
        Set formattedStartTime = ##class(Demo.PETS.Availability).FormatTime(resultSet.%Get("StartTime"))
        Set formattedEndTime = ##class(Demo.PETS.Availability).FormatTime(resultSet.%Get("EndTime"))
        
        Write "<h6 class='card-title'>"
        Write "<i class='fas fa-calendar'></i> " _ formattedDate
        Write "</h6>"
        Write "<p class='time-slot'>"
        Write "<i class='fas fa-clock'></i> " _ formattedStartTime _ " - " _ formattedEndTime
        Write "</p>"
        
        // Capacidad
        Set maxPets = resultSet.%Get("MaxPets")
        Set currentBookings = resultSet.%Get("CurrentBookings")
        Set availableSlots = maxPets - currentBookings
        
        Write "<p class='capacity-info'>"
        Write "<i class='fas fa-dog'></i> "
        Write "Disponible: " _ availableSlots _ "/" _ maxPets _ " mascotas"
        Write "</p>"
        
        // Precio
        Set specialRate = resultSet.%Get("SpecialRate")
        If specialRate '= "" && (specialRate > 0) {
            Write "<p class='capacity-info'>"
            Write "<i class='fas fa-dollar-sign'></i> $" _ specialRate
            Write "</p>"
        }
        
        // Notas
        Set notes = resultSet.%Get("Notes")
        If notes '= "" {
            Write "<p class='capacity-info'>"
            Write "<i class='fas fa-sticky-note'></i> " _ $E(notes, 1, 50)
            If $L(notes) > 50 Write "..."
            Write "</p>"
        }
        
        // Status
        If resultSet.%Get("IsActive") = 1 {
            Write "<p class='status-active'>"
            Write "<i class='fas fa-check-circle'></i> Activo"
            Write "</p>"
        } Else {
            Write "<p class='status-inactive'>"
            Write "<i class='fas fa-times-circle'></i> Inactivo"
            Write "</p>"
        }
        
        // Botones de acción
        Set slotId = resultSet.%Get("ID")
        Write "<div class='btn-group btn-group-sm' role='group'>"
        Write "<button type='button' class='btn btn-outline-primary' "
        Write "onclick='editSlot(" _ slotId _ ")'>"
        Write "<i class='fas fa-edit'></i> Editar"
        Write "</button>"
        
        If availableSlots = maxPets {
            Write "<button type='button' class='btn btn-outline-danger' "
            Write "onclick='deleteSlot(" _ slotId _ ")'>"
            Write "<i class='fas fa-trash'></i> Eliminar"
            Write "</button>"
        } Else {
            Write "<button type='button' class='btn btn-outline-secondary' disabled title='Tiene reservas'>"
            Write "<i class='fas fa-lock'></i> Reservado (" _ currentBookings _ ")"
            Write "</button>"
        }
        Write "</div>"
        
        Write "</div>"
        Write "</div>"
        Write "</div>"
    }
    
    Write "</div>"
    
    // JavaScript para funciones de edición y eliminación
    Write "<script>"
    Write "function editSlot(slotId) {"
    Write "  // Placeholder para modal de edición"
    Write "  alert('Función de edición en desarrollo. Slot ID: ' + slotId);"
    Write "}"
    Write "function deleteSlot(slotId) {"
    Write "  if (confirm('¿Está seguro de eliminar esta disponibilidad?')) {"
    Write "    var form = document.createElement('form');"
    Write "    form.method = 'POST';"
    Write "    var actionInput = document.createElement('input');"
    Write "    actionInput.type = 'hidden';"
    Write "    actionInput.name = 'form_action';"
    Write "    actionInput.value = 'delete';"
    Write "    var slotInput = document.createElement('input');"
    Write "    slotInput.type = 'hidden';"
    Write "    slotInput.name = 'delete_slot_id';"
    Write "    slotInput.value = slotId;"
    Write "    form.appendChild(actionInput);"
    Write "    form.appendChild(slotInput);"
    Write "    document.body.appendChild(form);"
    Write "    form.submit();"
    Write "  }"
    Write "}"
    Write "</script>"
    
    Return $$$OK
}

}
