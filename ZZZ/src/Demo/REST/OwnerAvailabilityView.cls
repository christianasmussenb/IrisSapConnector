/// Vista de Disponibilidad para Owners - Sprint 1.3
/// Permite a los owners ver y seleccionar disponibilidad de walkers (Supply-Driven)
Class Demo.REST.OwnerAvailabilityView Extends %CSP.REST
{

Parameter CHARSET = "UTF-8";

Parameter CONTENTTYPE = "text/html";

/// Ruta principal para la vista de disponibilidad de owners
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/" Method="GET" Call="ShowAvailabilityCalendar"/>
  <Route Url="/calendar" Method="GET" Call="ShowAvailabilityCalendar"/>
  <Route Url="/calendar/:year/:month" Method="GET" Call="ShowMonthlyView"/>
  <Route Url="/select-slot" Method="POST" Call="SelectSlot"/>
  <Route Url="/book-slot" Method="POST" Call="BookSlot"/>
  <Route Url="/api/availability/:year/:month" Method="GET" Call="GetAvailabilityData"/>
</Routes>
}

/// Muestra el calendario principal de disponibilidad para owners
ClassMethod ShowAvailabilityCalendar() As %Status
{
    Set %response.ContentType = "text/html; charset=utf-8"
    
    // Obtener fecha actual
    Set currentDate = +$HOROLOG
    Set year = $PIECE($ZDATE(currentDate, 8), "-", 1)
    Set month = $PIECE($ZDATE(currentDate, 8), "-", 2)
    
    // Generar HTML del calendario
    Set html = ..GenerateCalendarHTML(year, month)
    
    Write html
    Return $$$OK
}

/// Muestra vista mensual específica
ClassMethod ShowMonthlyView(year As %String, month As %String) As %Status
{
    Set %response.ContentType = "text/html; charset=utf-8"
    
    // Validar parámetros
    If (+year < 2025) || (+year > 2030) Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    If (+month < 1) || (+month > 12) Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    
    Set html = ..GenerateCalendarHTML(year, month)
    Write html
    Return $$$OK
}

/// Genera el HTML del calendario de disponibilidad
ClassMethod GenerateCalendarHTML(year As %String, month As %String) As %String
{
    // Validar y establecer valores por defecto si son nulos
    If (year = "") || '$ISVALIDNUM(year) || (+year < 2020) || (+year > 2030) {
        Set currentDate = +$HOROLOG
        Set year = $PIECE($ZDATE(currentDate, 8), "-", 1)
    }
    If (month = "") || '$ISVALIDNUM(month) || (+month < 1) || (+month > 12) {
        Set currentDate = +$HOROLOG
        Set month = $PIECE($ZDATE(currentDate, 8), "-", 2)
    }
    
    Set html = "<!DOCTYPE html><html><head>"
    Set html = html _ "<title>PETS - Disponibilidad de Walkers</title>"
    Set html = html _ "<meta charset='UTF-8'>"
    Set html = html _ "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    Set html = html _ ..GetCalendarCSS()
    Set html = html _ "</head><body>"
    
    // Header
    Set html = html _ "<div class='header'>"
    Set html = html _ "<h1>🐕 PETS - Disponibilidad de Paseadores</h1>"
    Set html = html _ "<p class='subtitle'>Selecciona el horario y paseador de tu preferencia</p>"
    Set html = html _ "</div>"
    
    // Navegación de meses
    Set html = html _ ..GenerateMonthNavigation(year, month)
    
    // Calendario principal
    Set html = html _ "<div class='calendar-container'>"
    Set html = html _ ..GenerateMonthCalendar(year, month)
    Set html = html _ "</div>"
    
    // Modal para selección de slot
    Set html = html _ ..GenerateSlotModal()
    
    // JavaScript
    Set html = html _ ..GetCalendarJavaScript()
    
    Set html = html _ "</body></html>"
    Return html
}

/// Genera la navegación entre meses
ClassMethod GenerateMonthNavigation(year As %String, month As %String) As %String
{
    Try {
        // Validar parámetros nulos o vacíos
        If (year = "") || ($GET(year) = "") {
            Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
        }
        If (month = "") || ($GET(month) = "") {
            Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
        }
        
        // Validar parámetros y convertir a números
        Set yearNum = +year
        Set monthNum = +month
        
        // Validar que la conversión fue exitosa
        If yearNum = 0 Set yearNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
        If monthNum = 0 Set monthNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    
    // Validar rangos
    If (yearNum < 2020) || (yearNum > 2030) {
        Set yearNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    }
    If (monthNum < 1) || (monthNum > 12) {
        Set monthNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    }
    
    // Calcular mes anterior
    Set prevMonth = monthNum - 1
    Set prevYear = yearNum
    If prevMonth < 1 {
        Set prevMonth = 12
        Set prevYear = yearNum - 1
    }
    
    // Calcular mes siguiente
    Set nextMonth = monthNum + 1
    Set nextYear = yearNum
    If nextMonth > 12 {
        Set nextMonth = 1
        Set nextYear = yearNum + 1
    }
    
    Set monthNames = $LISTBUILD("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                                "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
    
    // Validar índices antes de acceder a la lista
    If (monthNum < 1) || (monthNum > 12) Set monthNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    If (prevMonth < 1) || (prevMonth > 12) Set prevMonth = 12
    If (nextMonth < 1) || (nextMonth > 12) Set nextMonth = 1
    
    // Validar de nuevo después de los ajustes
    If (monthNum < 1) || (monthNum > 12) Set monthNum = 8  // Agosto por defecto
    If (prevMonth < 1) || (prevMonth > 12) Set prevMonth = 7  // Julio por defecto
    If (nextMonth < 1) || (nextMonth > 12) Set nextMonth = 9  // Septiembre por defecto
    
    // Asegurar que los valores no sean NULL
    If $GET(monthNum) = "" Set monthNum = 8
    If $GET(prevMonth) = "" Set prevMonth = 7
    If $GET(nextMonth) = "" Set nextMonth = 9
    
    Set monthName = $LIST(monthNames, monthNum)
    Set prevMonthName = $LIST(monthNames, prevMonth)
    Set nextMonthName = $LIST(monthNames, nextMonth)
    
    // Validar que los nombres no sean NULL
    If $GET(monthName) = "" Set monthName = "Agosto"
    If $GET(prevMonthName) = "" Set prevMonthName = "Julio" 
    If $GET(nextMonthName) = "" Set nextMonthName = "Septiembre"
    
    // Validar que los años no sean NULL
    If $GET(prevYear) = "" Set prevYear = 2025
    If $GET(nextYear) = "" Set nextYear = 2025
    If $GET(yearNum) = "" Set yearNum = 2025
    
    Set nav = "<div class='month-navigation'>"
    Set nav = nav _ "<button onclick='navigateMonth(" _ prevYear _ ", " _ prevMonth _ ")' class='nav-btn'>← " _ prevMonthName _ "</button>"
    Set nav = nav _ "<h2 class='current-month'>" _ monthName _ " " _ yearNum _ "</h2>"
    Set nav = nav _ "<button onclick='navigateMonth(" _ nextYear _ ", " _ nextMonth _ ")' class='nav-btn'>" _ nextMonthName _ " →</button>"
    Set nav = nav _ "</div>"
    
    Return nav
    
    } Catch ex {
        // Si hay cualquier error, devolver navegación básica con fecha actual
        Set currentDate = +$HOROLOG
        Set currentYear = $PIECE($ZDATE(currentDate, 8), "-", 1)
        Set currentMonth = $PIECE($ZDATE(currentDate, 8), "-", 2)
        Set currentMonthName = "Agosto"
        
        Set nav = "<div class='month-navigation'>"
        Set nav = nav _ "<button onclick='navigateMonth(" _ currentYear _ ", " _ (+currentMonth - 1) _ ")' class='nav-btn'>← Mes Anterior</button>"
        Set nav = nav _ "<h2 class='current-month'>" _ currentMonthName _ " " _ currentYear _ "</h2>"
        Set nav = nav _ "<button onclick='navigateMonth(" _ currentYear _ ", " _ (+currentMonth + 1) _ ")' class='nav-btn'>Mes Siguiente →</button>"
        Set nav = nav _ "</div>"
        
        Return nav
    }
}

/// Genera el calendario mensual con disponibilidad
ClassMethod GenerateMonthCalendar(year As %String, month As %String) As %String
{
    Try {
        // Validar parámetros nulos o vacíos
        If (year = "") || ($GET(year) = "") {
            Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
        }
        If (month = "") || ($GET(month) = "") {
            Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
        }
        
        // Validar y convertir parámetros
        Set yearNum = +year
        Set monthNum = +month
        
        // Validar que la conversión fue exitosa
        If yearNum = 0 Set yearNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
        If monthNum = 0 Set monthNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
        
        // Validar rangos antes de usar $ZDATEH
        If (yearNum < 1841) || (yearNum > 9999) Set yearNum = 2025
        If (monthNum < 1) || (monthNum > 12) Set monthNum = 8
        
        // Formatear mes con ceros iniciales
        Set monthStr = $TR($JUSTIFY(monthNum,2)," ","0")
        
        // Construir fecha de inicio de forma segura
        Set dateString = yearNum _ "-" _ monthStr _ "-01"
        Set startDate = $ZDATEH(dateString, 8)
    Set endDate = ..GetLastDayOfMonth(yearNum, monthNum)
    
    // Obtener disponibilidad para el mes
    Set availability = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startDate, endDate)
    
    Set calendar = "<div class='calendar-grid'>"
    
    // Headers de días de la semana
    Set calendar = calendar _ "<div class='calendar-header'>"
    Set dayNames = $LISTBUILD("Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb")
    For i=1:1:7 {
        Set calendar = calendar _ "<div class='day-header'>" _ $LIST(dayNames, i) _ "</div>"
    }
    Set calendar = calendar _ "</div>"
    
    // Calcular día de la semana del primer día
    Set firstDayWeek = $ZDATE(startDate, 10) // 0=Domingo, 6=Sábado
    
    // Espacios en blanco antes del primer día
    Set calendar = calendar _ "<div class='calendar-body'>"
    For i=1:1:firstDayWeek {
        Set calendar = calendar _ "<div class='calendar-day empty'></div>"
    }
    
    // Días del mes
    Set daysInMonth = endDate - startDate + 1
    For day=1:1:daysInMonth {
        Set currentDate = startDate + day - 1
        Set dateStr = $ZDATE(currentDate, 8)
        
        Set calendar = calendar _ "<div class='calendar-day' data-date='" _ dateStr _ "'>"
        Set calendar = calendar _ "<div class='day-number'>" _ day _ "</div>"
        
        // Obtener slots para este día
        Set daySlots = ..GetSlotsForDate(availability, currentDate)
        If daySlots.%Size() > 0 {
            Set calendar = calendar _ "<div class='day-slots'>"
            For j=0:1:daySlots.%Size()-1 {
                Set slot = daySlots.%Get(j)
                Set slotClass = "slot"
                If slot.availableSlots > 3 {
                    Set slotClass = slotClass _ " high-availability"
                } ElseIf slot.availableSlots > 0 {
                    Set slotClass = slotClass _ " medium-availability" 
                } Else {
                    Set slotClass = slotClass _ " no-availability"
                }
                
                Set calendar = calendar _ "<div class='" _ slotClass _ "' "
                Set calendar = calendar _ "onclick='selectSlot(""" _ dateStr _ """, """ _ slot.startTime _ """, """ _ slot.walkerId _ """)' "
                Set calendar = calendar _ "title='Walker " _ slot.walkerName _ " - " _ slot.startTime _ " (" _ slot.availableSlots _ " disponibles)'>"
                Set calendar = calendar _ $PIECE(slot.startTime, ":", 1, 2) _ "</div>"
            }
            Set calendar = calendar _ "</div>"
        }
        
        Set calendar = calendar _ "</div>"
    }
    
    Set calendar = calendar _ "</div></div>"
    Return calendar
    
    } Catch ex {
        // Si hay cualquier error, devolver calendario básico
        Set errorCalendar = "<div class='calendar-grid'>"
        Set errorCalendar = errorCalendar _ "<div class='calendar-header'>"
        Set errorCalendar = errorCalendar _ "<div class='day-header'>Error</div>"
        Set errorCalendar = errorCalendar _ "</div>"
        Set errorCalendar = errorCalendar _ "<div class='calendar-body'>"
        Set errorCalendar = errorCalendar _ "<div class='calendar-day'>Error cargando calendario</div>"
        Set errorCalendar = errorCalendar _ "</div></div>"
        Return errorCalendar
    }
}

/// Obtiene los slots para una fecha específica
ClassMethod GetSlotsForDate(availability As %DynamicArray, date As %Date) As %DynamicArray
{
    Set result = []
    Set targetDateStr = ##class(Demo.PETS.Availability).FormatDate(date)
    
    For i=0:1:availability.%Size()-1 {
        Set slot = availability.%Get(i)
        If slot.date = targetDateStr {
            Do result.%Push(slot)
        }
    }
    
    Return result
}

/// Calcula el último día del mes
ClassMethod GetLastDayOfMonth(year As %String, month As %String) As %Date
{
    // Validar parámetros nulos o vacíos
    If (year = "") || ($GET(year) = "") {
        Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    }
    If (month = "") || ($GET(month) = "") {
        Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    }
    
    // Validar y convertir parámetros
    Set yearNum = +year
    Set monthNum = +month
    
    // Validar que la conversión fue exitosa
    If yearNum = 0 Set yearNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    If monthNum = 0 Set monthNum = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    
    // Calcular mes siguiente
    Set nextMonth = monthNum + 1
    Set nextYear = yearNum
    If nextMonth > 12 {
        Set nextMonth = 1
        Set nextYear = yearNum + 1
    }
    
    Set firstNextMonth = $ZDATEH(nextYear _ "-" _ $TR($JUSTIFY(nextMonth,2)," ","0") _ "-01", 8)
    Return firstNextMonth - 1
}

/// Modal para seleccionar slot
ClassMethod GenerateSlotModal() As %String
{
    Set modal = "<div id='slotModal' class='modal'>"
    Set modal = modal _ "<div class='modal-content'>"
    Set modal = modal _ "<div class='modal-header'>"
    Set modal = modal _ "<h3>Reservar Paseo</h3>"
    Set modal = modal _ "<span class='close' onclick='closeModal()'>&times;</span>"
    Set modal = modal _ "</div>"
    Set modal = modal _ "<div class='modal-body'>"
    Set modal = modal _ "<div id='slotDetails'></div>"
    Set modal = modal _ "<div class='booking-form'>"
    Set modal = modal _ "<label for='petSelect'>Selecciona tu mascota:</label>"
    Set modal = modal _ "<select id='petSelect' required>"
    Set modal = modal _ "<option value=''>-- Selecciona una mascota --</option>"
    Set modal = modal _ "</select>"
    Set modal = modal _ "<div class='form-actions'>"
    Set modal = modal _ "<button onclick='confirmBooking()' class='btn-primary'>Confirmar Reserva</button>"
    Set modal = modal _ "<button onclick='closeModal()' class='btn-secondary'>Cancelar</button>"
    Set modal = modal _ "</div>"
    Set modal = modal _ "</div>"
    Set modal = modal _ "</div>"
    Set modal = modal _ "</div>"
    Set modal = modal _ "</div>"
    
    Return modal
}

/// Seleccionar un slot específico
ClassMethod SelectSlot() As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    // Obtener parámetros POST
    Set date = %request.Get("date")
    Set time = %request.Get("time") 
    Set walkerId = %request.Get("walkerId")
    
    // Obtener detalles del slot
    Set slotDetails = ##class(Demo.PETS.Services.SchedulingService).GetAvailableSlots($ZDATEH(date, 8))
    Set selectedSlot = {}
    
    For i=0:1:slotDetails.%Size()-1 {
        Set slot = slotDetails.%Get(i)
        If (slot.walkerId = walkerId) && (slot.startTime = time) {
            Set selectedSlot = slot
            Quit
        }
    }
    
    // Obtener lista de mascotas usando QueryService
    Set petsResponse = ##class(Demo.PETS.Services.QueryService).GetAllPets()
    Set petsList = []
    If petsResponse.success {
        Set petsList = petsResponse.data.pets
    }
    
    Set result = {}
    Set result.success = 1
    Set result.slot = selectedSlot
    Set result.pets = petsList
    
    Write result.%ToJSON()
    Return $$$OK
}

/// Reservar un slot
ClassMethod BookSlot() As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    Try {
        // Obtener parámetros
        Set date = %request.Get("date")
        Set time = %request.Get("time")
        Set walkerId = %request.Get("walkerId") 
        Set petId = %request.Get("petId")
        
        // Validar disponibilidad
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, $ZDATEH(date, 8), $ZTIMEH(time), $ZTIMEH(time) + 3600)
        
        If 'validation.isValid {
            Set result = {}
            Set result.success = 0
            Set result.error = "Slot no disponible"
            Set result.details = validation.errors
            Write result.%ToJSON()
            Return $$$OK
        }
        
        // Crear booking (placeholder - se implementará en Sprint 2.1)
        Set result = {}
        Set result.success = 1
        Set result.message = "Reserva confirmada exitosamente"
        Set result.bookingId = "BOOK-" _ $RANDOM(9999) + 1000
        Set result.details = {}
        Set result.details.date = date
        Set result.details.time = time
        Set result.details.walker = "Walker " _ walkerId
        Set result.details.pet = "Pet ID " _ petId
        
        Write result.%ToJSON()
        Return $$$OK
        
    } Catch ex {
        Set errorResult = {}
        Set errorResult.success = 0
        Set errorResult.error = "Error procesando reserva: " _ ex.DisplayString()
        Write errorResult.%ToJSON()
        Return $$$OK
    }
}

/// API para obtener datos de disponibilidad
ClassMethod GetAvailabilityData(year As %String, month As %String) As %Status
{
    Set %response.ContentType = "application/json; charset=utf-8"
    
    // Validar parámetros nulos o vacíos
    If (year = "") || ($GET(year) = "") {
        Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    }
    If (month = "") || ($GET(month) = "") {
        Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    }
    
    // Validar que sean números válidos
    If '+year Set year = $PIECE($ZDATE(+$HOROLOG, 8), "-", 1)
    If '+month Set month = $PIECE($ZDATE(+$HOROLOG, 8), "-", 2)
    
    Set startDate = $ZDATEH(year _ "-" _ $TR($JUSTIFY(month,2)," ","0") _ "-01", 8)
    Set endDate = ..GetLastDayOfMonth(year, month)
    
    Set availability = ##class(Demo.PETS.Services.SchedulingService).SearchAvailability(startDate, endDate)
    
    Set result = {}
    Set result.success = 1
    Set result.month = month
    Set result.year = year
    Set result.availability = availability
    
    Write result.%ToJSON()
    Return $$$OK
}

/// CSS para el calendario
ClassMethod GetCalendarCSS() As %String
{
    Set css = "<style>"
    Set css = css _ "body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }"
    Set css = css _ ".header { text-align: center; margin-bottom: 30px; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }"
    Set css = css _ ".header h1 { color: #2c3e50; margin: 0; }"
    Set css = css _ ".subtitle { color: #7f8c8d; margin: 10px 0 0 0; }"
    Set css = css _ ".month-navigation { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background: white; padding: 15px; border-radius: 10px; }"
    Set css = css _ ".nav-btn { background: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }"
    Set css = css _ ".nav-btn:hover { background: #2980b9; }"
    Set css = css _ ".current-month { color: #2c3e50; margin: 0; }"
    Set css = css _ ".calendar-container { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }"
    Set css = css _ ".calendar-grid { display: grid; grid-template-rows: auto 1fr; }"
    Set css = css _ ".calendar-header { display: grid; grid-template-columns: repeat(7, 1fr); background: #34495e; }"
    Set css = css _ ".day-header { padding: 15px; text-align: center; color: white; font-weight: bold; }"
    Set css = css _ ".calendar-body { display: grid; grid-template-columns: repeat(7, 1fr); }"
    Set css = css _ ".calendar-day { min-height: 120px; border: 1px solid #ecf0f1; padding: 10px; position: relative; }"
    Set css = css _ ".calendar-day:hover { background: #f8f9fa; }"
    Set css = css _ ".calendar-day.empty { background: #f8f9fa; }"
    Set css = css _ ".day-number { font-weight: bold; color: #2c3e50; margin-bottom: 5px; }"
    Set css = css _ ".day-slots { display: flex; flex-wrap: wrap; gap: 2px; }"
    Set css = css _ ".slot { background: #e74c3c; color: white; padding: 2px 4px; border-radius: 3px; font-size: 10px; cursor: pointer; }"
    Set css = css _ ".slot.high-availability { background: #27ae60; }"
    Set css = css _ ".slot.medium-availability { background: #f39c12; }"
    Set css = css _ ".slot.no-availability { background: #95a5a6; cursor: not-allowed; }"
    Set css = css _ ".slot:hover:not(.no-availability) { opacity: 0.8; }"
    
    // Modal styles
    Set css = css _ ".modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }"
    Set css = css _ ".modal-content { background: white; margin: 10% auto; padding: 0; width: 500px; border-radius: 10px; }"
    Set css = css _ ".modal-header { background: #3498db; color: white; padding: 20px; border-radius: 10px 10px 0 0; display: flex; justify-content: space-between; align-items: center; }"
    Set css = css _ ".modal-body { padding: 20px; }"
    Set css = css _ ".close { font-size: 28px; cursor: pointer; }"
    Set css = css _ ".booking-form label { display: block; margin-top: 15px; margin-bottom: 5px; font-weight: bold; }"
    Set css = css _ ".booking-form select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }"
    Set css = css _ ".form-actions { margin-top: 20px; text-align: center; }"
    Set css = css _ ".btn-primary { background: #27ae60; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 0 5px; }"
    Set css = css _ ".btn-secondary { background: #95a5a6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 0 5px; }"
    Set css = css _ "</style>"
    
    Return css
}

/// JavaScript para el calendario
ClassMethod GetCalendarJavaScript() As %String
{
    Set js = "<script>"
    Set js = js _ "function navigateMonth(year, month) {"
    Set js = js _ "  window.location.href = '/csp/pets/owner-availability/calendar/' + year + '/' + month;"
    Set js = js _ "}"
    
    Set js = js _ "function selectSlot(date, time, walkerId) {"
    Set js = js _ "  const modal = document.getElementById('slotModal');"
    Set js = js _ "  modal.style.display = 'block';"
    Set js = js _ "  "
    Set js = js _ "  fetch('/csp/pets/owner-availability/select-slot', {"
    Set js = js _ "    method: 'POST',"
    Set js = js _ "    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },"
    Set js = js _ "    body: 'date=' + date + '&time=' + time + '&walkerId=' + walkerId"
    Set js = js _ "  })"
    Set js = js _ "  .then(response => response.json())"
    Set js = js _ "  .then(data => {"
    Set js = js _ "    if (data.success) {"
    Set js = js _ "      displaySlotDetails(data.slot, data.pets, date, time, walkerId);"
    Set js = js _ "    }"
    Set js = js _ "  });"
    Set js = js _ "}"
    
    Set js = js _ "function displaySlotDetails(slot, pets, date, time, walkerId) {"
    Set js = js _ "  const details = document.getElementById('slotDetails');"
    Set js = js _ "  details.innerHTML = '<div><strong>Fecha:</strong> ' + date + '</div>' +"
    Set js = js _ "    '<div><strong>Horario:</strong> ' + slot.startTime + ' - ' + slot.endTime + '</div>' +"
    Set js = js _ "    '<div><strong>Paseador:</strong> ' + slot.walkerName + '</div>' +"
    Set js = js _ "    '<div><strong>Precio:</strong> $' + slot.pricePerWalk + '</div>' +"
    Set js = js _ "    '<div><strong>Disponible:</strong> ' + slot.availableSlots + ' mascotas</div>';"
    Set js = js _ "  "
    Set js = js _ "  const petSelect = document.getElementById('petSelect');"
    Set js = js _ "  petSelect.innerHTML = '<option value="""">-- Selecciona una mascota --</option>';"
    Set js = js _ "  for (let i = 0; i < pets.length; i++) {"
    Set js = js _ "    petSelect.innerHTML += '<option value=""' + pets[i].id + '"">' + pets[i].name + ' (' + pets[i].breed + ')</option>';"
    Set js = js _ "  }"
    Set js = js _ "  "
    Set js = js _ "  petSelect.dataset.date = date;"
    Set js = js _ "  petSelect.dataset.time = time;"
    Set js = js _ "  petSelect.dataset.walkerId = walkerId;"
    Set js = js _ "}"
    
    Set js = js _ "function confirmBooking() {"
    Set js = js _ "  const petSelect = document.getElementById('petSelect');"
    Set js = js _ "  if (!petSelect.value) {"
    Set js = js _ "    alert('Por favor selecciona una mascota');"
    Set js = js _ "    return;"
    Set js = js _ "  }"
    Set js = js _ "  "
    Set js = js _ "  fetch('/csp/pets/owner-availability/book-slot', {"
    Set js = js _ "    method: 'POST',"
    Set js = js _ "    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },"
    Set js = js _ "    body: 'date=' + petSelect.dataset.date + '&time=' + petSelect.dataset.time + '&walkerId=' + petSelect.dataset.walkerId + '&petId=' + petSelect.value"
    Set js = js _ "  })"
    Set js = js _ "  .then(response => response.json())"
    Set js = js _ "  .then(data => {"
    Set js = js _ "    if (data.success) {"
    Set js = js _ "      alert('¡Reserva confirmada! ID: ' + data.bookingId);"
    Set js = js _ "      closeModal();"
    Set js = js _ "      location.reload();"
    Set js = js _ "    } else {"
    Set js = js _ "      alert('Error: ' + data.error);"
    Set js = js _ "    }"
    Set js = js _ "  });"
    Set js = js _ "}"
    
    Set js = js _ "function closeModal() {"
    Set js = js _ "  document.getElementById('slotModal').style.display = 'none';"
    Set js = js _ "}"
    
    Set js = js _ "</script>"
    Return js
}

}
