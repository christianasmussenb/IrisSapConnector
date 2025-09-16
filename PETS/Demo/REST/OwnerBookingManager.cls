/// Interfaz de Gestión de Reservas para Owners - Sprint 2.1
/// Permite a los owners ver y gestionar sus reservas
Class Demo.REST.OwnerBookingManager Extends %CSP.REST
{

Parameter CHARSET = "UTF-8";

Parameter CONTENTTYPE = "text/html";

/// Rutas para gestión de reservas de owners
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/" Method="GET" Call="ShowMyBookings"/>
  <Route Url="/my-bookings" Method="GET" Call="ShowMyBookings"/>
  <Route Url="/my-bookings/:status" Method="GET" Call="ShowMyBookingsByStatus"/>
  <Route Url="/booking/:id" Method="GET" Call="ShowBookingDetails"/>
  <Route Url="/cancel" Method="POST" Call="CancelBooking"/>
  <Route Url="/api/my-bookings/:ownerId" Method="GET" Call="GetMyBookingsAPI"/>
  <Route Url="/api/cancel" Method="POST" Call="CancelBookingAPI"/>
</Routes>
}

/// Página principal - Mis Reservas
ClassMethod ShowMyBookings() As %Status
{
    Set %response.ContentType = "text/html; charset=utf-8"
    
    // Por ahora usar un ownerId de ejemplo - en producción vendría de sesión
    Set ownerId = %request.Get("ownerId", "1")
    
    Set html = ..GenerateMyBookingsHTML(ownerId)
    Write html
    Return $$$OK
}

/// Mostrar reservas por estado específico
ClassMethod ShowMyBookingsByStatus(status As %String) As %Status
{
    Set %response.ContentType = "text/html; charset=utf-8"
    
    Set ownerId = %request.Get("ownerId", "1")
    Set html = ..GenerateMyBookingsHTML(ownerId, status)
    Write html
    Return $$$OK
}

/// API para obtener reservas del owner
ClassMethod GetMyBookingsAPI(ownerId As %String) As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    Set status = %request.Get("status", "")
    Set limit = %request.Get("limit", 50)
    
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(ownerId, status, limit)
    Write result.%ToJSON()
    Return $$$OK
}

/// API para cancelar reserva
ClassMethod CancelBookingAPI() As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    Try {
        Set bookingId = %request.Get("bookingId")
        Set ownerId = %request.Get("ownerId")
        Set reason = %request.Get("reason", "Cancelado por el owner")
        
        Set result = ##class(Demo.PETS.Services.BookingService).CancelBooking(bookingId, "OWNER-" _ ownerId, reason)
        Write result.%ToJSON()
        Return $$$OK
        
    } Catch ex {
        Set error = {}
        Set error.success = 0
        Set error.error = ex.DisplayString()
        Write error.%ToJSON()
        Return $$$OK
    }
}

/// Generar HTML para "Mis Reservas"
ClassMethod GenerateMyBookingsHTML(ownerId As %String, status As %String = "") As %String
{
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>Mis Reservas - PETS</title>"
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
    Set html = html _ "<h2><i class='fas fa-calendar-check text-primary'></i> Mis Reservas</h2>"
    Set html = html _ "<div>"
    Set html = html _ "<a href='/csp/pets/' class='btn btn-outline-secondary me-2'><i class='fas fa-home'></i> Menú Principal</a>"
    Set html = html _ "<a href='/csp/pets/owner-availability' class='btn btn-primary'><i class='fas fa-plus'></i> Nueva Reserva</a>"
    Set html = html _ "</div></div>"
    
    // Filtros de estado
    Set html = html _ "<div class='row mb-4'>"
    Set html = html _ "<div class='col-md-12'>"
    Set html = html _ "<div class='btn-group' role='group'>"
    Set html = html _ "<a href='?ownerId=" _ ownerId _ "' class='btn " _ $SELECT(status="":"btn-primary", 1:"btn-outline-primary") _ "'>Todas</a>"
    Set html = html _ "<a href='?ownerId=" _ ownerId _ "&status=PENDING' class='btn " _ $SELECT(status="PENDING":"btn-warning", 1:"btn-outline-warning") _ "'>Pendientes</a>"
    Set html = html _ "<a href='?ownerId=" _ ownerId _ "&status=CONFIRMED' class='btn " _ $SELECT(status="CONFIRMED":"btn-success", 1:"btn-outline-success") _ "'>Confirmadas</a>"
    Set html = html _ "<a href='?ownerId=" _ ownerId _ "&status=COMPLETED' class='btn " _ $SELECT(status="COMPLETED":"btn-info", 1:"btn-outline-info") _ "'>Completadas</a>"
    Set html = html _ "<a href='?ownerId=" _ ownerId _ "&status=CANCELLED' class='btn " _ $SELECT(status="CANCELLED":"btn-danger", 1:"btn-outline-danger") _ "'>Canceladas</a>"
    Set html = html _ "</div></div></div>"
    
    // Obtener y mostrar reservas directamente
    Set bookings = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(ownerId, status, 50)
    
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
            Set html = html _ "<h5 class='card-title'><i class='fas fa-dog'></i> " _ booking.petName _ " con " _ booking.walkerName _ "</h5>"
            Set html = html _ "<p class='card-text'><i class='fas fa-calendar'></i> " _ booking.date _ " de " _ booking.startTime _ " a " _ booking.endTime _ "</p>"
            Set html = html _ "<p class='booking-reference'>Ref: " _ booking.reference _ "</p>"
            Set html = html _ "</div>"
            Set html = html _ "<div class='col-md-4 text-end'>"
            Set html = html _ "<div class='booking-amount'>$" _ $FNUMBER(booking.amount, "", 2) _ "</div>"
            Set html = html _ "<span class='badge bg-" _ statusBadge _ "'>" _ statusText _ "</span>"
            If booking.status = "PENDING" {
                Set html = html _ "<br><a href='#' class='btn btn-sm btn-outline-danger mt-2' onclick='return cancelBooking(" _ booking.id _ ", """ _ ownerId _ """)'><i class='fas fa-times'></i> Cancelar</a>"
            }
            Set html = html _ "</div></div></div></div>"
        }
    } ElseIf bookings.success && (bookings.count = 0) {
        Set html = html _ "<div class='alert alert-info'><i class='fas fa-info-circle'></i> No tienes reservas en este estado.</div>"
    } Else {
        Set html = html _ "<div class='alert alert-danger'>Error cargando reservas: " _ bookings.error _ "</div>"
    }
    
    Set html = html _ "</div></div></div></div>"
    
    // JavaScript simplificado para cancelaciones
    Set html = html _ "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js'></script>"
    Set html = html _ "<script>"
    Set html = html _ "function cancelBooking(bookingId, ownerId) {"
    Set html = html _ "  if (!confirm('Esta seguro de que quiere cancelar esta reserva?')) return false;"
    Set html = html _ "  var reason = prompt('Razon de cancelacion (opcional):') || 'Cancelado por el owner';"
    Set html = html _ "  window.location = '/csp/pets/my-bookings/api/cancel?bookingId=' + bookingId + '&ownerId=' + ownerId + '&reason=' + encodeURIComponent(reason);"
    Set html = html _ "  return false;"
    Set html = html _ "}"
    Set html = html _ "</script></body></html>"
    
    Return html
}

/// Ruta de cancelación que redirige después de procesar
ClassMethod CancelBookingRedirect() As %Status
{
    Set %response.ContentType = "text/html"
    
    // Obtener parámetros de query string
    Set bookingId = $GET(%request.Data("bookingId", 1))
    Set ownerId = $GET(%request.Data("ownerId", 1))
    Set reason = $GET(%request.Data("reason", 1))
    
    If reason = "" Set reason = "Cancelado por el owner"
    
    // Cancelar la reserva
    Set result = ##class(Demo.PETS.Services.BookingService).CancelBooking(bookingId, reason, "OWNER", ownerId)
    
    // Generar página de resultado
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>Cancelación - PETS</title>"
    Set html = html _ "<meta charset='UTF-8'>"
    Set html = html _ "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>"
    Set html = html _ "</head><body class='bg-light'><div class='container mt-4'>"
    
    If result.success {
        Set html = html _ "<div class='alert alert-success'><h4><i class='fas fa-check-circle'></i> Reserva Cancelada</h4>"
        Set html = html _ "<p>La reserva ha sido cancelada exitosamente.</p></div>"
    } Else {
        Set html = html _ "<div class='alert alert-danger'><h4><i class='fas fa-exclamation-triangle'></i> Error</h4>"
        Set html = html _ "<p>No se pudo cancelar la reserva: " _ result.error _ "</p></div>"
    }
    
    Set html = html _ "<a href='/csp/pets/my-bookings?ownerId=" _ ownerId _ "' class='btn btn-primary'>Volver a Mis Reservas</a>"
    Set html = html _ "</div>"
    Set html = html _ "<script>setTimeout(() => window.location='/csp/pets/my-bookings?ownerId=" _ ownerId _ "', 3000);</script>"
    Set html = html _ "</body></html>"
    
    Write html
    Return $$$OK
}

}