/// Interfaz REST para gestión de reservas de walkers
/// Permite a los walkers ver y gestionar sus reservas asignadas
Class Demo.REST.WalkerBookingManager Extends %CSP.REST
{

Parameter CHARSET = "UTF-8";

Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/walker-bookings" Method="GET" Call="WalkerBookingsPage"/>
  <Route Url="/api/walker-bookings/:walkerId" Method="GET" Call="GetWalkerBookingsAPI"/>
  <Route Url="/api/confirm" Method="GET" Call="ConfirmBookingRedirect"/>
  <Route Url="/api/confirm" Method="POST" Call="ConfirmBookingAPI"/>
  <Route Url="/api/complete" Method="GET" Call="CompleteBookingRedirect"/>
  <Route Url="/api/complete" Method="POST" Call="CompleteBookingAPI"/>
</Routes>
}

/// Página principal de reservas del walker
ClassMethod WalkerBookingsPage() As %Status
{
    Set %response.ContentType = "text/html"
    
    // Obtener parámetros
    Set walkerId = $GET(%request.Data("walkerId", 1))
    Set status = $GET(%request.Data("status", 1))
    
    // Validar que tengamos walkerId
    If walkerId = "" {
        Write "<h3>Error: Se requiere el ID del walker</h3>"
        Write "<p>Formato: /csp/pets/walker-bookings?walkerId=WALKER_ID</p>"
        Return $$$OK
    }
    
    // Generar HTML
    Set html = ..GenerateWalkerBookingsHTML(walkerId, status)
    Write html
    
    Return $$$OK
}

/// API: Obtener reservas del walker
ClassMethod GetWalkerBookingsAPI(walkerId As %String) As %Status
{
    Set %response.ContentType = "application/json"
    
    // Obtener filtro de estado si existe
    Set status = $GET(%request.Data("status", 1))
    
    // Usar BookingService para obtener reservas
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByWalker(walkerId, status, 50)
    
    // Convertir a JSON y enviar
    If result.success {
        Write "{"
        Write """success"": true,"
        Write """count"": " _ result.count _ ","
        Write """bookings"": ["
        
        For i=0:1:result.bookings.%Size()-1 {
            Set booking = result.bookings.%Get(i)
            If i > 0 Write ","
            Write "{"
            Write """id"": " _ booking.id _ ","
            Write """reference"": """ _ booking.reference _ ""","
            Write """ownerName"": """ _ booking.ownerName _ ""","
            Write """petName"": """ _ booking.petName _ ""","
            Write """date"": """ _ booking.date _ ""","
            Write """startTime"": """ _ booking.startTime _ ""","
            Write """endTime"": """ _ booking.endTime _ ""","
            Write """amount"": " _ booking.amount _ ","
            Write """status"": """ _ booking.status _ ""","
            Write """notes"": """ _ $ZCONVERT(booking.notes, "O", "JSON") _ ""","
            Write """createdAt"": """ _ booking.createdAt _ """"
            Write "}"
        }
        
        Write "]}"
    } Else {
        Write "{""success"": false, ""error"": """ _ result.error _ """}"
    }
    
    Return $$$OK
}

/// Generar HTML para reservas del walker
ClassMethod GenerateWalkerBookingsHTML(walkerId As %String, status As %String = "") As %String
{
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>Mis Reservas Walker - PETS</title>"
    Set html = html _ "<meta charset='UTF-8'>"
    Set html = html _ "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    Set html = html _ "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Set html = html _ "<link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>"
    Set html = html _ "<style>"
    Set html = html _ ".booking-card { border-left: 4px solid #007bff; margin-bottom: 1rem; }"
    Set html = html _ ".status-pending { border-left-color: #ffc107; }"
    Set html = html _ ".status-confirmed { border-left-color: #28a745; }"
    Set html = html _ ".status-completed { border-left-color: #17a2b8; }"
    Set html = html _ ".status-cancelled { border-left-color: #dc3545; }"
    Set html = html _ ".booking-amount { font-size: 1.2rem; font-weight: bold; color: #28a745; }"
    Set html = html _ ".booking-reference { font-family: monospace; font-size: 0.9rem; color: #6c757d; }"
    Set html = html _ "</style>"
    Set html = html _ "</head><body class='bg-light'>"
    
    // Header
    Set html = html _ "<div class='container mt-4'>"
    Set html = html _ "<div class='row'>"
    Set html = html _ "<div class='col-md-12'>"
    Set html = html _ "<div class='d-flex justify-content-between align-items-center mb-4'>"
    Set html = html _ "<h2><i class='fas fa-walking text-success'></i> Mis Reservas Walker</h2>"
    Set html = html _ "<div>"
    Set html = html _ "<a href='/csp/pets/' class='btn btn-outline-secondary'><i class='fas fa-home'></i> Menú Principal</a>"
    Set html = html _ "</div></div>"
    
    // Filtros de estado
    Set html = html _ "<div class='row mb-4'>"
    Set html = html _ "<div class='col-md-12'>"
    Set html = html _ "<div class='btn-group' role='group'>"
    Set html = html _ "<a href='?walkerId=" _ walkerId _ "' class='btn " _ $SELECT(status="":"btn-primary", 1:"btn-outline-primary") _ "'>Todas</a>"
    Set html = html _ "<a href='?walkerId=" _ walkerId _ "&status=PENDING' class='btn " _ $SELECT(status="PENDING":"btn-warning", 1:"btn-outline-warning") _ "'>Pendientes</a>"
    Set html = html _ "<a href='?walkerId=" _ walkerId _ "&status=CONFIRMED' class='btn " _ $SELECT(status="CONFIRMED":"btn-success", 1:"btn-outline-success") _ "'>Confirmadas</a>"
    Set html = html _ "<a href='?walkerId=" _ walkerId _ "&status=COMPLETED' class='btn " _ $SELECT(status="COMPLETED":"btn-info", 1:"btn-outline-info") _ "'>Completadas</a>"
    Set html = html _ "</div></div></div>"
    
    // Obtener y mostrar reservas directamente
    Set bookings = ##class(Demo.PETS.Services.BookingService).GetBookingsByWalker(walkerId, status, 50)
    
    Set html = html _ "<div class='row'>"
    Set html = html _ "<div class='col-md-12'>"
    
    If bookings.success && (bookings.count > 0) {
        // Mostrar reservas
        For i=0:1:bookings.bookings.%Size()-1 {
            Set booking = bookings.bookings.%Get(i)
            Set statusClass = $CASE(booking.status, "PENDING":"status-pending", "CONFIRMED":"status-confirmed", "COMPLETED":"status-completed", "CANCELLED":"status-cancelled", :"")
            Set statusBadge = $CASE(booking.status, "PENDING":"warning", "CONFIRMED":"success", "COMPLETED":"info", "CANCELLED":"danger", :"secondary")
            Set statusText = $CASE(booking.status, "PENDING":"Pendiente", "CONFIRMED":"Confirmada", "COMPLETED":"Completada", "CANCELLED":"Cancelada", :booking.status)
            
            Set html = html _ "<div class='card booking-card " _ statusClass _ "'>"
            Set html = html _ "<div class='card-body'>"
            Set html = html _ "<div class='row'>"
            Set html = html _ "<div class='col-md-8'>"
            Set html = html _ "<h5 class='card-title'><i class='fas fa-user'></i> " _ booking.ownerName _ " con " _ booking.petName _ "</h5>"
            Set html = html _ "<p class='card-text'><i class='fas fa-calendar'></i> " _ booking.date _ " de " _ booking.startTime _ " a " _ booking.endTime _ "</p>"
            Set html = html _ "<p class='booking-reference'>Ref: " _ booking.reference _ "</p>"
            If booking.notes '= "" {
                Set html = html _ "<p class='text-muted'><i class='fas fa-sticky-note'></i> " _ booking.notes _ "</p>"
            }
            Set html = html _ "</div>"
            Set html = html _ "<div class='col-md-4 text-end'>"
            Set html = html _ "<div class='booking-amount'>$" _ $FNUMBER(booking.amount, "", 2) _ "</div>"
            Set html = html _ "<span class='badge bg-" _ statusBadge _ "'>" _ statusText _ "</span><br>"
            
            // Botones según estado
            If booking.status = "PENDING" {
                Set html = html _ "<a href='#' class='btn btn-sm btn-success mt-2 me-1' onclick='return confirmBooking(" _ booking.id _ ", """ _ walkerId _ """)'><i class='fas fa-check'></i> Confirmar</a>"
            } ElseIf booking.status = "CONFIRMED" {
                Set html = html _ "<a href='#' class='btn btn-sm btn-info mt-2' onclick='return completeBooking(" _ booking.id _ ", """ _ walkerId _ """)'><i class='fas fa-flag-checkered'></i> Completar</a>"
            }
            
            Set html = html _ "</div></div></div></div>"
        }
    } ElseIf bookings.success && (bookings.count = 0) {
        Set html = html _ "<div class='alert alert-info'><i class='fas fa-info-circle'></i> No tienes reservas en este estado.</div>"
    } Else {
        Set html = html _ "<div class='alert alert-danger'>Error cargando reservas: " _ bookings.error _ "</div>"
    }
    
    Set html = html _ "</div></div></div></div>"
    
    // JavaScript simplificado
    Set html = html _ "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js'></script>"
    Set html = html _ "<script>"
    Set html = html _ "function confirmBooking(bookingId, walkerId) {"
    Set html = html _ "  if (!confirm('Confirmar esta reserva?')) return false;"
    Set html = html _ "  window.location = '/csp/pets/walker-bookings/api/confirm?bookingId=' + bookingId + '&walkerId=' + walkerId;"
    Set html = html _ "  return false;"
    Set html = html _ "}"
    Set html = html _ "function completeBooking(bookingId, walkerId) {"
    Set html = html _ "  if (!confirm('Marcar esta reserva como completada?')) return false;"
    Set html = html _ "  var notes = prompt('Notas finales (opcional):') || '';"
    Set html = html _ "  window.location = '/csp/pets/walker-bookings/api/complete?bookingId=' + bookingId + '&walkerId=' + walkerId + '&notes=' + encodeURIComponent(notes);"
    Set html = html _ "  return false;"
    Set html = html _ "}"
    Set html = html _ "</script></body></html>"
    
    Return html
}

/// API: Confirmar reserva
ClassMethod ConfirmBookingAPI(bookingId As %String, walkerId As %String) As %Status
{
    If (bookingId = "") || (walkerId = "") {
        Write "{""success"": false, ""error"": ""Parámetros requeridos""}"
        Return $$$OK
    }
    
    // Obtener la reserva y cambiar estado
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
    If '$IsObject(booking) {
        Write "{""success"": false, ""error"": ""Reserva no encontrada""}"
        Return $$$OK
    }
    
    If booking.WalkerId '= walkerId {
        Write "{""success"": false, ""error"": ""No autorizado para esta reserva""}"
        Return $$$OK
    }
    
    If booking.Status '= "PENDING" {
        Write "{""success"": false, ""error"": ""Solo se pueden confirmar reservas pendientes""}"
        Return $$$OK
    }
    
    // Confirmar
    TSTART
    Set booking.Status = "CONFIRMED"
    Set booking.LastModified = $ZDATETIME($HOROLOG, 3)
    Set sc = booking.%Save()
    If $$$ISERR(sc) {
        TROLLBACK
        Write "{""success"": false, ""error"": ""Error guardando: " _ $SYSTEM.Status.GetErrorText(sc) _ """}"
    } Else {
        TCOMMIT
        Write "{""success"": true, ""message"": ""Reserva confirmada""}"
    }
    
    Return $$$OK
}

/// Ruta de confirmación con redirección
ClassMethod ConfirmBookingRedirect() As %Status
{
    Set %response.ContentType = "text/html"
    
    Set bookingId = $GET(%request.Data("bookingId", 1))
    Set walkerId = $GET(%request.Data("walkerId", 1))
    
    // Procesar confirmación
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
    Set success = 0
    Set message = ""
    
    If $IsObject(booking) && (booking.WalkerId = walkerId) && (booking.Status = "PENDING") {
        TSTART
        Set booking.Status = "CONFIRMED"
        Set booking.LastModified = $ZDATETIME($HOROLOG, 3)
        Set sc = booking.%Save()
        If $$$ISOK(sc) {
            TCOMMIT
            Set success = 1
            Set message = "Reserva confirmada exitosamente"
        } Else {
            TROLLBACK
            Set message = "Error guardando cambios"
        }
    } Else {
        Set message = "No se puede confirmar esta reserva"
    }
    
    // Generar página resultado
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>Confirmación - PETS</title>"
    Set html = html _ "<meta charset='UTF-8'>"
    Set html = html _ "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Set html = html _ "</head><body class='bg-light'><div class='container mt-4'>"
    
    If success {
        Set html = html _ "<div class='alert alert-success'><h4><i class='fas fa-check-circle'></i> Confirmación Exitosa</h4>"
        Set html = html _ "<p>" _ message _ "</p></div>"
    } Else {
        Set html = html _ "<div class='alert alert-danger'><h4><i class='fas fa-exclamation-triangle'></i> Error</h4>"
        Set html = html _ "<p>" _ message _ "</p></div>"
    }
    
    Set html = html _ "<a href='/csp/pets/walker-bookings?walkerId=" _ walkerId _ "' class='btn btn-primary'>Volver a Mis Reservas</a>"
    Set html = html _ "</div>"
    Set html = html _ "<script>setTimeout(() => window.location='/csp/pets/walker-bookings?walkerId=" _ walkerId _ "', 3000);</script>"
    Set html = html _ "</body></html>"
    
    Write html
    Return $$$OK
}

/// API: Completar reserva
ClassMethod CompleteBookingAPI(bookingId As %String, walkerId As %String, notes As %String = "") As %Status
{
    If (bookingId = "") || (walkerId = "") {
        Write "{""success"": false, ""error"": ""Parámetros requeridos""}"
        Return $$$OK
    }
    
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
    If '$IsObject(booking) {
        Write "{""success"": false, ""error"": ""Reserva no encontrada""}"
        Return $$$OK
    }
    
    If booking.WalkerId '= walkerId {
        Write "{""success"": false, ""error"": ""No autorizado""}"
        Return $$$OK
    }
    
    If booking.Status '= "CONFIRMED" {
        Write "{""success"": false, ""error"": ""Solo se pueden completar reservas confirmadas""}"
        Return $$$OK
    }
    
    // Completar
    TSTART
    Set booking.Status = "COMPLETED"
    If notes '= "" Set booking.Notes = notes
    Set booking.LastModified = $ZDATETIME($HOROLOG, 3)
    Set sc = booking.%Save()
    If $$$ISERR(sc) {
        TROLLBACK
        Write "{""success"": false, ""error"": ""Error guardando""}"
    } Else {
        TCOMMIT
        Write "{""success"": true, ""message"": ""Reserva completada""}"
    }
    
    Return $$$OK
}

/// Ruta de completar con redirección
ClassMethod CompleteBookingRedirect() As %Status
{
    Set %response.ContentType = "text/html"
    
    Set bookingId = $GET(%request.Data("bookingId", 1))
    Set walkerId = $GET(%request.Data("walkerId", 1))
    Set notes = $GET(%request.Data("notes", 1))
    
    // Procesar completar
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
    Set success = 0
    Set message = ""
    
    If $IsObject(booking) && (booking.WalkerId = walkerId) && (booking.Status = "CONFIRMED") {
        TSTART
        Set booking.Status = "COMPLETED"
        If notes '= "" Set booking.Notes = notes
        Set booking.LastModified = $ZDATETIME($HOROLOG, 3)
        Set sc = booking.%Save()
        If $$$ISOK(sc) {
            TCOMMIT
            Set success = 1
            Set message = "Reserva completada exitosamente"
        } Else {
            TROLLBACK
            Set message = "Error guardando cambios"
        }
    } Else {
        Set message = "No se puede completar esta reserva"
    }
    
    // Generar página resultado
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>Completado - PETS</title>"
    Set html = html _ "<meta charset='UTF-8'>"
    Set html = html _ "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Set html = html _ "</head><body class='bg-light'><div class='container mt-4'>"
    
    If success {
        Set html = html _ "<div class='alert alert-success'><h4><i class='fas fa-flag-checkered'></i> Reserva Completada</h4>"
        Set html = html _ "<p>" _ message _ "</p></div>"
    } Else {
        Set html = html _ "<div class='alert alert-danger'><h4><i class='fas fa-exclamation-triangle'></i> Error</h4>"
        Set html = html _ "<p>" _ message _ "</p></div>"
    }
    
    Set html = html _ "<a href='/csp/pets/walker-bookings?walkerId=" _ walkerId _ "' class='btn btn-primary'>Volver a Mis Reservas</a>"
    Set html = html _ "</div>"
    Set html = html _ "<script>setTimeout(() => window.location='/csp/pets/walker-bookings?walkerId=" _ walkerId _ "', 3000);</script>"
    Set html = html _ "</body></html>"
    
    Write html
    Return $$$OK
}

}