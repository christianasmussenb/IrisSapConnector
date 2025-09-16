/// Script de pruebas específicas para validar funcionalidad del sistema de reservas
/// Ejecuta casos de prueba reales con datos del sistema
Class Demo.PETS.Tests.FunctionalityTests Extends %RegisteredObject
{

/// Ejecutar todas las pruebas de funcionalidad
ClassMethod RunAllTests() As %Status
{
    Write "=== PRUEBAS ESPECÍFICAS DE FUNCIONALIDAD - SISTEMA DE RESERVAS ===", !
    Write "Fecha: ", $ZDATE($HOROLOG, 3), " ", $ZTIME($PIECE($HOROLOG, ",", 2)), !
    Write "==================================================================", !
    
    Set testsPassed = 0
    Set testsTotal = 0
    
    // Test 1: Validar modelo de datos persistente
    Set testsTotal = testsTotal + 1
    Write !, "TEST 1: Validación del Modelo Persistente", !
    Write "----------------------------------------", !
    If ..TestPersistentModel() {
        Write "✅ PASÓ: Modelo persistente funciona correctamente", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Problemas en el modelo persistente", !
    }
    
    // Test 2: Creación de reserva completa
    Set testsTotal = testsTotal + 1
    Write !, "TEST 2: Creación de Reserva Completa", !
    Write "-----------------------------------", !
    If ..TestBookingCreation() {
        Write "✅ PASÓ: Creación de reserva exitosa", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Error en creación de reserva", !
    }
    
    // Test 3: Validaciones de negocio
    Set testsTotal = testsTotal + 1
    Write !, "TEST 3: Validaciones de Reglas de Negocio", !
    Write "----------------------------------------", !
    If ..TestBusinessValidations() {
        Write "✅ PASÓ: Validaciones funcionan correctamente", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Problemas en validaciones", !
    }
    
    // Test 4: Flujo de estados de reserva
    Set testsTotal = testsTotal + 1
    Write !, "TEST 4: Flujo de Estados (PENDING→CONFIRMED→COMPLETED)", !
    Write "----------------------------------------------------", !
    If ..TestBookingStateFlow() {
        Write "✅ PASÓ: Flujo de estados correcto", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Problemas en flujo de estados", !
    }
    
    // Test 5: Consultas con filtros
    Set testsTotal = testsTotal + 1
    Write !, "TEST 5: Consultas con Filtros", !
    Write "-----------------------------", !
    If ..TestFilteredQueries() {
        Write "✅ PASÓ: Filtros funcionan correctamente", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Problemas en filtros", !
    }
    
    // Test 6: Cálculos de montos
    Set testsTotal = testsTotal + 1
    Write !, "TEST 6: Cálculos de Montos", !
    Write "-------------------------", !
    If ..TestAmountCalculations() {
        Write "✅ PASÓ: Cálculos correctos", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Errores en cálculos", !
    }
    
    // Test 7: Transacciones y consistencia
    Set testsTotal = testsTotal + 1
    Write !, "TEST 7: Integridad Transaccional", !
    Write "-------------------------------", !
    If ..TestTransactionIntegrity() {
        Write "✅ PASÓ: Transacciones consistentes", !
        Set testsPassed = testsPassed + 1
    } Else {
        Write "❌ FALLÓ: Problemas transaccionales", !
    }
    
    // Resumen final
    Write !, "==================================================================", !
    Write "RESUMEN DE PRUEBAS:", !
    Write "Pruebas ejecutadas: ", testsTotal, !
    Write "Pruebas exitosas: ", testsPassed, !
    Write "Pruebas fallidas: ", (testsTotal - testsPassed), !
    Write "Porcentaje éxito: ", $FNUMBER((testsPassed/testsTotal)*100, "", 1), "%", !
    
    If testsPassed = testsTotal {
        Write "🎉 TODAS LAS PRUEBAS PASARON - SISTEMA FUNCIONAL", !
    } Else {
        Write "⚠️  ALGUNAS PRUEBAS FALLARON - REVISAR IMPLEMENTACIÓN", !
    }
    
    Return $$$OK
}

/// Test 1: Verificar que el modelo persistente funciona
ClassMethod TestPersistentModel() As %Boolean
{
    Try {
        // Crear una instancia de reserva
        Set booking = ##class(Demo.PETS.Scheduling.Bookings).%New()
        
        // Establecer propiedades básicas
        Set booking.OwnerId = "TEST_OWNER"
        Set booking.WalkerId = "TEST_WALKER"
        Set booking.PetId = "TEST_PET"
        Set booking.Date = $ZDATE($HOROLOG, 3)
        Set booking.StartTime = "10:00"
        Set booking.EndTime = "11:00"
        Set booking.Amount = 25.00
        Set booking.Status = "PENDING"
        
        // Verificar métodos especiales
        Set reference = booking.GenerateBookingReference()
        Write "  - Referencia generada: ", reference, !
        If reference = "" {
            Write "  ❌ Error: No se generó referencia", !
            Return 0
        }
        
        Set calculatedAmount = booking.CalculateAmount()
        Write "  - Monto calculado: $", $FNUMBER(calculatedAmount, "", 2), !
        If calculatedAmount <= 0 {
            Write "  ❌ Error: Cálculo de monto incorrecto", !
            Return 0
        }
        
        // Verificar método de información de slot
        Set slotInfo = booking.GetTimeSlotInfo()
        Write "  - Info de slot: ", slotInfo, !
        If slotInfo = "" {
            Write "  ❌ Error: No se obtuvo info del slot", !
            Return 0
        }
        
        Write "  ✅ Modelo persistente validado correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 2: Probar creación completa de reserva usando BookingService
ClassMethod TestBookingCreation() As %Boolean
{
    Try {
        // Preparar datos de prueba
        Set bookingData = {
            "ownerId": "FUNC_TEST_OWNER_001",
            "walkerId": "FUNC_TEST_WALKER_001", 
            "petId": "FUNC_TEST_PET_001",
            "availabilityId": "FUNC_TEST_AVAIL_001",
            "date": ($ZDATE($HOROLOG + 1, 3)),
            "startTime": "14:00",
            "endTime": "15:00",
            "notes": "Prueba funcional de creación"
        }
        
        Write "  - Creando reserva con BookingService...", !
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
        
        If 'result.success {
            Write "  ❌ Error en creación: ", result.error, !
            Return 0
        }
        
        Write "  - Booking ID: ", result.bookingId, !
        Write "  - Referencia: ", result.reference, !
        
        // Verificar que la reserva existe en BD
        Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(result.bookingId)
        If '$IsObject(booking) {
            Write "  ❌ Error: Reserva no encontrada en BD", !
            Return 0
        }
        
        Write "  - Estado en BD: ", booking.Status, !
        Write "  - Monto en BD: $", $FNUMBER(booking.Amount, "", 2), !
        
        // Limpiar datos de prueba
        Do booking.%DeleteId(result.bookingId)
        
        Write "  ✅ Creación de reserva validada exitosamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 3: Probar validaciones de reglas de negocio
ClassMethod TestBusinessValidations() As %Boolean
{
    Try {
        Write "  - Probando validación de datos completos...", !
        
        // Datos incompletos (sin ownerId)
        Set invalidData1 = {
            "walkerId": "TEST_WALKER",
            "petId": "TEST_PET",
            "date": ($ZDATE($HOROLOG + 1, 3)),
            "startTime": "10:00",
            "endTime": "11:00"
        }
        
        Set result1 = ##class(Demo.PETS.Services.BookingService).ValidateBooking(invalidData1)
        If result1.valid {
            Write "  ❌ Error: Datos incompletos pasaron validación", !
            Return 0
        }
        Write "    ✓ Rechazó datos incompletos correctamente", !
        
        // Datos con horario inválido (inicio después de fin)
        Set invalidData2 = {
            "ownerId": "TEST_OWNER",
            "walkerId": "TEST_WALKER",
            "petId": "TEST_PET",
            "date": ($ZDATE($HOROLOG + 1, 3)),
            "startTime": "15:00",
            "endTime": "14:00"
        }
        
        Set result2 = ##class(Demo.PETS.Services.BookingService).ValidateBooking(invalidData2)
        If result2.valid {
            Write "  ❌ Error: Horario inválido pasó validación", !
            Return 0
        }
        Write "    ✓ Rechazó horario inválido correctamente", !
        
        // Datos válidos
        Set validData = {
            "ownerId": "TEST_OWNER",
            "walkerId": "TEST_WALKER",
            "petId": "TEST_PET",
            "availabilityId": "TEST_AVAIL",
            "date": ($ZDATE($HOROLOG + 1, 3)),
            "startTime": "10:00",
            "endTime": "11:00"
        }
        
        Set result3 = ##class(Demo.PETS.Services.BookingService).ValidateBooking(validData)
        If 'result3.valid {
            Write "  ❌ Error: Datos válidos no pasaron validación", !
            For i=0:1:result3.errors.%Size()-1 {
                Write "      Error: ", result3.errors.%Get(i), !
            }
            Return 0
        }
        Write "    ✓ Aceptó datos válidos correctamente", !
        
        Write "  ✅ Validaciones de negocio funcionan correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 4: Probar flujo completo de estados de reserva
ClassMethod TestBookingStateFlow() As %Boolean
{
    Try {
        // Crear reserva de prueba
        Set booking = ##class(Demo.PETS.Scheduling.Bookings).%New()
        Set booking.OwnerId = "FLOW_TEST_OWNER"
        Set booking.WalkerId = "FLOW_TEST_WALKER"
        Set booking.PetId = "FLOW_TEST_PET"
        Set booking.Date = $ZDATE($HOROLOG + 1, 3)
        Set booking.StartTime = "10:00"
        Set booking.EndTime = "11:00"
        Set booking.Amount = 25.00
        Set booking.Status = "PENDING"
        Set booking.Reference = booking.GenerateBookingReference()
        Do booking.%Save()
        Set bookingId = booking.%Id()
        
        Write "  - Reserva creada con ID: ", bookingId, " Estado: ", booking.Status, !
        
        // Estado 1: PENDING → CONFIRMED
        Do booking.UpdateStatus("CONFIRMED", "Confirmado por walker")
        Write "  - Actualizado a CONFIRMED", !
        
        // Recargar y verificar
        Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
        If booking.Status '= "CONFIRMED" {
            Write "  ❌ Error: Estado no cambió a CONFIRMED", !
            Return 0
        }
        
        // Estado 2: CONFIRMED → COMPLETED  
        Do booking.UpdateStatus("COMPLETED", "Servicio completado exitosamente")
        Write "  - Actualizado a COMPLETED", !
        
        // Verificar estado final
        Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(bookingId)
        If booking.Status '= "COMPLETED" {
            Write "  ❌ Error: Estado no cambió a COMPLETED", !
            Return 0
        }
        
        Write "  - Estado final: ", booking.Status, !
        Write "  - Notas: ", booking.Notes, !
        
        // Limpiar
        Do booking.%DeleteId(bookingId)
        
        Write "  ✅ Flujo de estados validado correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 5: Probar consultas con filtros
ClassMethod TestFilteredQueries() As %Boolean
{
    Try {
        // Crear varias reservas con diferentes estados para probar filtros
        Set testBookings = ""
        For i=1:1:3 {
            Set booking = ##class(Demo.PETS.Scheduling.Bookings).%New()
            Set booking.OwnerId = "FILTER_TEST_OWNER"
            Set booking.WalkerId = "FILTER_TEST_WALKER_" _ i
            Set booking.PetId = "FILTER_TEST_PET"
            Set booking.Date = $ZDATE($HOROLOG + i, 3)
            Set booking.StartTime = "1" _ i _ ":00"
            Set booking.EndTime = "1" _ (i+1) _ ":00"
            Set booking.Amount = 25.00 * i
            Set booking.Status = $CASE(i, 1:"PENDING", 2:"CONFIRMED", 3:"COMPLETED")
            Set booking.Reference = booking.GenerateBookingReference()
            Do booking.%Save()
            Set testBookings = testBookings _ "," _ booking.%Id()
        }
        
        Write "  - Creadas 3 reservas de prueba con estados diferentes", !
        
        // Test filtro por Owner - todas las reservas
        Set result1 = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner("FILTER_TEST_OWNER", "", 10)
        If 'result1.success || (result1.count < 3) {
            Write "  ❌ Error: No se obtuvieron todas las reservas del owner", !
            Return 0
        }
        Write "    ✓ Filtro por Owner: encontradas ", result1.count, " reservas", !
        
        // Test filtro por estado PENDING
        Set result2 = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner("FILTER_TEST_OWNER", "PENDING", 10)
        If 'result2.success || (result2.count '= 1) {
            Write "  ❌ Error: Filtro PENDING no funcionó (esperado: 1, obtenido: ", result2.count, ")", !
            Return 0
        }
        Write "    ✓ Filtro PENDING: encontrada ", result2.count, " reserva", !
        
        // Test filtro por walker
        Set result3 = ##class(Demo.PETS.Services.BookingService).GetBookingsByWalker("FILTER_TEST_WALKER_1", "", 10)
        If 'result3.success || (result3.count '= 1) {
            Write "  ❌ Error: Filtro por walker no funcionó", !
            Return 0
        }
        Write "    ✓ Filtro por Walker: encontrada ", result3.count, " reserva", !
        
        // Limpiar datos de prueba
        For i=1:1:$LENGTH(testBookings, ",") {
            Set bookingId = $PIECE(testBookings, ",", i)
            If bookingId '= "" Do ##class(Demo.PETS.Scheduling.Bookings).%DeleteId(bookingId)
        }
        
        Write "  ✅ Filtros de consulta validados correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 6: Probar cálculos de montos
ClassMethod TestAmountCalculations() As %Boolean
{
    Try {
        // Test cálculo para 1 hora a $25/hora = $25
        Set booking1 = ##class(Demo.PETS.Scheduling.Bookings).%New()
        Set booking1.StartTime = "10:00"
        Set booking1.EndTime = "11:00"
        Set booking1.HourlyRate = 25.00
        Set amount1 = booking1.CalculateAmount()
        
        If amount1 '= 25.00 {
            Write "  ❌ Error: Cálculo 1 hora falló (esperado: 25.00, obtenido: ", amount1, ")", !
            Return 0
        }
        Write "  - Cálculo 1 hora: $", $FNUMBER(amount1, "", 2), " ✓", !
        
        // Test cálculo para 2.5 horas a $30/hora = $75
        Set booking2 = ##class(Demo.PETS.Scheduling.Bookings).%New()
        Set booking2.StartTime = "09:30"
        Set booking2.EndTime = "12:00"
        Set booking2.HourlyRate = 30.00
        Set amount2 = booking2.CalculateAmount()
        
        If amount2 '= 75.00 {
            Write "  ❌ Error: Cálculo 2.5 horas falló (esperado: 75.00, obtenido: ", amount2, ")", !
            Return 0
        }
        Write "  - Cálculo 2.5 horas: $", $FNUMBER(amount2, "", 2), " ✓", !
        
        // Test cálculo para 30 minutos a $40/hora = $20
        Set booking3 = ##class(Demo.PETS.Scheduling.Bookings).%New()
        Set booking3.StartTime = "14:00"
        Set booking3.EndTime = "14:30"
        Set booking3.HourlyRate = 40.00
        Set amount3 = booking3.CalculateAmount()
        
        If amount3 '= 20.00 {
            Write "  ❌ Error: Cálculo 30 min falló (esperado: 20.00, obtenido: ", amount3, ")", !
            Return 0
        }
        Write "  - Cálculo 30 minutos: $", $FNUMBER(amount3, "", 2), " ✓", !
        
        Write "  ✅ Cálculos de montos validados correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Test 7: Probar integridad transaccional
ClassMethod TestTransactionIntegrity() As %Boolean
{
    Try {
        Write "  - Probando rollback en caso de error...", !
        
        // Intentar crear reserva con datos que causen error
        Set invalidBookingData = {
            "ownerId": "INVALID_OWNER_999",
            "walkerId": "INVALID_WALKER_999", 
            "petId": "INVALID_PET_999",
            "availabilityId": "INVALID_AVAIL_999",
            "date": "fecha-invalida",
            "startTime": "25:99",  // Hora inválida
            "endTime": "26:99",
            "notes": "Test de transacción fallida"
        }
        
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(invalidBookingData)
        
        If result.success {
            Write "  ❌ Error: Transacción no falló como esperado", !
            Return 0
        }
        
        Write "    ✓ Transacción falló correctamente: ", result.error, !
        
        // Verificar que no se creó ningún registro incompleto
        &SQL(SELECT COUNT(*) INTO :count FROM Demo_PETS_Scheduling.Bookings WHERE OwnerId = 'INVALID_OWNER_999')
        If count > 0 {
            Write "  ❌ Error: Se encontraron registros huérfanos después del rollback", !
            Return 0
        }
        
        Write "    ✓ No hay registros huérfanos - rollback correcto", !
        
        Write "  ✅ Integridad transaccional validada correctamente", !
        Return 1
        
    } Catch ex {
        Write "  ❌ Excepción: ", ex.DisplayString(), !
        Return 0
    }
}

/// Ejecutar prueba individual por nombre
ClassMethod RunSingleTest(testName As %String) As %Status
{
    Write "=== EJECUTANDO PRUEBA INDIVIDUAL: ", testName, " ===", !
    
    If testName = "model" {
        Do ..TestPersistentModel()
    } ElseIf testName = "creation" {
        Do ..TestBookingCreation()
    } ElseIf testName = "validation" {
        Do ..TestBusinessValidations()
    } ElseIf testName = "states" {
        Do ..TestBookingStateFlow()
    } ElseIf testName = "filters" {
        Do ..TestFilteredQueries()
    } ElseIf testName = "amounts" {
        Do ..TestAmountCalculations()
    } ElseIf testName = "transactions" {
        Do ..TestTransactionIntegrity()
    } Else {
        Write "Pruebas disponibles: model, creation, validation, states, filters, amounts, transactions", !
    }
    
    Return $$$OK
}

/// Limpiar todos los datos de prueba del sistema
ClassMethod CleanupTestData() As %Status
{
    Write "Limpiando datos de prueba...", !
    
    &SQL(DELETE FROM Demo_PETS_Scheduling.Bookings WHERE 
         OwnerId LIKE '%TEST%' OR 
         WalkerId LIKE '%TEST%' OR 
         PetId LIKE '%TEST%' OR
         Reference LIKE 'TEST-%' OR
         Reference LIKE 'FUNC-%' OR
         Reference LIKE 'BOOK-%')
    
    Write "Registros eliminados: ", %ROWCOUNT, !
    Write "Limpieza completada.", !
    
    Return $$$OK
}

}