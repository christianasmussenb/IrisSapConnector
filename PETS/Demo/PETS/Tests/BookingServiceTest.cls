/// Suite de pruebas para el sistema de reservas persistente
/// Valida todas las funcionalidades implementadas en Sprint 2.1
Class Demo.PETS.Tests.BookingServiceTest Extends %UnitTest.TestCase
{

/// Configurar datos de prueba antes de ejecutar tests
Method OnBeforeAllTests() As %Status
{
    // Limpiar datos de prueba previos
    &SQL(DELETE FROM Demo_PETS_Scheduling.Bookings WHERE Reference LIKE 'TEST-%')
    
    // Crear datos de prueba
    Do ..CreateTestData()
    
    Return $$$OK
}

/// Limpiar datos de prueba después de todos los tests
Method OnAfterAllTests() As %Status
{
    // Limpiar datos de prueba
    &SQL(DELETE FROM Demo_PETS_Scheduling.Bookings WHERE Reference LIKE 'TEST-%')
    
    Return $$$OK
}

/// Crear datos de prueba necesarios
Method CreateTestData()
{
    // Test Owner
    Set owner = ##class(Demo.PETS.Owner).%New()
    Set owner.Name = "Test Owner"
    Set owner.Email = "testowner@pets.com"
    Set owner.Phone = "555-0001"
    Do owner.%Save()
    Set ..TestOwnerId = owner.%Id()
    
    // Test Pet
    Set pet = ##class(Demo.PETS.Pet).%New()
    Set pet.Name = "Test Dog"
    Set pet.Species = "Dog"
    Set pet.Breed = "Golden Retriever"
    Set pet.OwnerId = ..TestOwnerId
    Do pet.%Save()
    Set ..TestPetId = pet.%Id()
    
    // Test Walker
    Set walker = ##class(Demo.PETS.Walker).%New()
    Set walker.Name = "Test Walker"
    Set walker.Email = "testwalker@pets.com"
    Set walker.Phone = "555-0002"
    Set walker.HourlyRate = 25.00
    Do walker.%Save()
    Set ..TestWalkerId = walker.%Id()
    
    // Test Availability
    Set availability = ##class(Demo.PETS.Scheduling.Availability).%New()
    Set availability.WalkerId = ..TestWalkerId
    Set availability.Date = $ZDATE($HOROLOG + 1, 3)  // Mañana
    Set availability.StartTime = "09:00"
    Set availability.EndTime = "17:00"
    Set availability.Status = "AVAILABLE"
    Do availability.%Save()
    Set ..TestAvailabilityId = availability.%Id()
}

/// Test 1: Crear reserva válida
Method TestCreateBooking()
{
    // Datos de prueba para crear reserva
    Set bookingData = {
        "ownerId": (..TestOwnerId),
        "walkerId": (..TestWalkerId),
        "petId": (..TestPetId),
        "availabilityId": (..TestAvailabilityId),
        "date": ($ZDATE($HOROLOG + 1, 3)),
        "startTime": "10:00",
        "endTime": "11:00",
        "notes": "Test booking creation"
    }
    
    // Crear la reserva
    Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
    
    // Validaciones
    Do $$$AssertTrue(result.success, "La creación de reserva debe ser exitosa")
    Do $$$AssertNotEquals(result.bookingId, "", "Debe retornar un booking ID")
    Do $$$AssertTrue(result.reference '= "", "Debe generar una referencia")
    
    // Verificar que la reserva se guardó correctamente
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(result.bookingId)
    Do $$$AssertTrue($IsObject(booking), "La reserva debe existir en la base de datos")
    Do $$$AssertEquals(booking.Status, "PENDING", "Estado inicial debe ser PENDING")
    Do $$$AssertEquals(booking.OwnerId, ..TestOwnerId, "Owner ID debe coincidir")
    Do $$$AssertEquals(booking.WalkerId, ..TestWalkerId, "Walker ID debe coincidir")
    Do $$$AssertEquals(booking.PetId, ..TestPetId, "Pet ID debe coincidir")
    
    // Guardar ID para otros tests
    Set ..TestBookingId = result.bookingId
    Set ..TestReference = result.reference
}

/// Test 2: Validar datos de reserva
Method TestValidateBooking()
{
    // Test con datos válidos
    Set validData = {
        "ownerId": (..TestOwnerId),
        "walkerId": (..TestWalkerId),
        "petId": (..TestPetId),
        "availabilityId": (..TestAvailabilityId),
        "date": ($ZDATE($HOROLOG + 1, 3)),
        "startTime": "14:00",
        "endTime": "15:00"
    }
    
    Set result = ##class(Demo.PETS.Services.BookingService).ValidateBooking(validData)
    Do $$$AssertTrue(result.valid, "Datos válidos deben pasar validación")
    Do $$$AssertEquals(result.errors.%Size(), 0, "No debe haber errores")
    
    // Test con datos inválidos - hora de inicio después de fin
    Set invalidData = {
        "ownerId": (..TestOwnerId),
        "walkerId": (..TestWalkerId),
        "petId": (..TestPetId),
        "availabilityId": (..TestAvailabilityId),
        "date": ($ZDATE($HOROLOG + 1, 3)),
        "startTime": "16:00",
        "endTime": "15:00"
    }
    
    Set result = ##class(Demo.PETS.Services.BookingService).ValidateBooking(invalidData)
    Do $$$AssertFalse(result.valid, "Datos inválidos no deben pasar validación")
    Do $$$AssertTrue(result.errors.%Size() > 0, "Debe retornar errores")
    
    // Test con campos faltantes
    Set incompleteData = {
        "ownerId": "",
        "walkerId": (..TestWalkerId)
    }
    
    Set result = ##class(Demo.PETS.Services.BookingService).ValidateBooking(incompleteData)
    Do $$$AssertFalse(result.valid, "Datos incompletos no deben pasar validación")
}

/// Test 3: Obtener reservas por owner
Method TestGetBookingsByOwner()
{
    // Primero crear una reserva de prueba
    Do ..TestCreateBooking()
    
    // Obtener reservas del owner
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(..TestOwnerId, "", 10)
    
    Do $$$AssertTrue(result.success, "Debe obtener reservas exitosamente")
    Do $$$AssertTrue(result.count > 0, "Debe encontrar al menos una reserva")
    Do $$$AssertTrue(result.bookings.%Size() > 0, "Lista de reservas no debe estar vacía")
    
    // Verificar estructura de datos
    Set booking = result.bookings.%Get(0)
    Do $$$AssertTrue(booking.id '= "", "Booking debe tener ID")
    Do $$$AssertTrue(booking.reference '= "", "Booking debe tener referencia")
    Do $$$AssertTrue(booking.walkerName '= "", "Debe incluir nombre del walker")
    Do $$$AssertTrue(booking.petName '= "", "Debe incluir nombre de la mascota")
}

/// Test 4: Obtener reservas por walker
Method TestGetBookingsByWalker()
{
    // Usar reserva creada anteriormente
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByWalker(..TestWalkerId, "", 10)
    
    Do $$$AssertTrue(result.success, "Debe obtener reservas exitosamente")
    Do $$$AssertTrue(result.count > 0, "Debe encontrar al menos una reserva")
    
    // Verificar estructura para walker
    Set booking = result.bookings.%Get(0)
    Do $$$AssertTrue(booking.ownerName '= "", "Debe incluir nombre del owner")
    Do $$$AssertTrue(booking.petName '= "", "Debe incluir nombre de la mascota")
    Do $$$AssertEquals(booking.status, "PENDING", "Estado debe ser PENDING")
}

/// Test 5: Cancelar reserva
Method TestCancelBooking()
{
    // Usar reserva creada anteriormente
    Set result = ##class(Demo.PETS.Services.BookingService).CancelBooking(..TestBookingId, "Test cancellation", "OWNER", ..TestOwnerId)
    
    Do $$$AssertTrue(result.success, "Cancelación debe ser exitosa")
    
    // Verificar que el estado cambió
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(..TestBookingId)
    Do $$$AssertEquals(booking.Status, "CANCELLED", "Estado debe ser CANCELLED")
    Do $$$AssertTrue(booking.Notes [ "Test cancellation", "Debe incluir razón de cancelación")
    
    // Test cancelación de reserva inexistente
    Set result = ##class(Demo.PETS.Services.BookingService).CancelBooking("999", "No existe", "OWNER", ..TestOwnerId)
    Do $$$AssertFalse(result.success, "Cancelación de reserva inexistente debe fallar")
    Do $$$AssertTrue(result.error '= "", "Debe retornar mensaje de error")
}

/// Test 6: Filtros de estado
Method TestStatusFilters()
{
    // Crear múltiples reservas con diferentes estados
    For i=1:1:3 {
        Set bookingData = {
            "ownerId": (..TestOwnerId),
            "walkerId": (..TestWalkerId),
            "petId": (..TestPetId),
            "availabilityId": (..TestAvailabilityId),
            "date": ($ZDATE($HOROLOG + i, 3)),
            "startTime": "10:00",
            "endTime": "11:00",
            "notes": ("Test booking " _ i)
        }
        
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
        If i = 1 {
            // Confirmar primera reserva
            Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(result.bookingId)
            Set booking.Status = "CONFIRMED"
            Do booking.%Save()
        }
    }
    
    // Test filtro PENDING
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(..TestOwnerId, "PENDING", 10)
    Do $$$AssertTrue(result.success, "Filtro PENDING debe funcionar")
    Do $$$AssertTrue(result.count >= 2, "Debe encontrar al menos 2 reservas pendientes")
    
    // Test filtro CONFIRMED  
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(..TestOwnerId, "CONFIRMED", 10)
    Do $$$AssertTrue(result.success, "Filtro CONFIRMED debe funcionar")
    Do $$$AssertTrue(result.count >= 1, "Debe encontrar al menos 1 reserva confirmada")
}

/// Test 7: Cálculo de montos
Method TestAmountCalculation()
{
    // Crear reserva de 2 horas (25/hora = $50)
    Set bookingData = {
        "ownerId": (..TestOwnerId),
        "walkerId": (..TestWalkerId),
        "petId": (..TestPetId),
        "availabilityId": (..TestAvailabilityId),
        "date": ($ZDATE($HOROLOG + 2, 3)),
        "startTime": "10:00",
        "endTime": "12:00",
        "notes": "Test amount calculation"
    }
    
    Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
    Do $$$AssertTrue(result.success, "Creación debe ser exitosa")
    
    Set booking = ##class(Demo.PETS.Scheduling.Bookings).%OpenId(result.bookingId)
    Do $$$AssertEquals(booking.Amount, 50.00, "Monto debe ser $50 (2 horas * $25/hora)")
}

/// Test 8: Referencias únicas
Method TestUniqueReferences()
{
    Set references = ""
    
    // Crear múltiples reservas y verificar referencias únicas
    For i=1:1:5 {
        Set bookingData = {
            "ownerId": (..TestOwnerId),
            "walkerId": (..TestWalkerId),
            "petId": (..TestPetId),
            "availabilityId": (..TestAvailabilityId),
            "date": ($ZDATE($HOROLOG + i, 3)),
            "startTime": "14:00",
            "endTime": "15:00"
        }
        
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
        Do $$$AssertTrue(result.success, "Cada creación debe ser exitosa")
        
        // Verificar que la referencia no se repita
        Do $$$AssertFalse(references [ result.reference, "Referencias deben ser únicas")
        Set references = references _ "," _ result.reference
    }
}

/// Test 9: Manejo de errores de transacciones
Method TestTransactionHandling()
{
    // Test con datos que causen error de integridad
    Set invalidData = {
        "ownerId": "999",  // Owner inexistente
        "walkerId": (..TestWalkerId),
        "petId": (..TestPetId),
        "availabilityId": (..TestAvailabilityId),
        "date": ($ZDATE($HOROLOG + 1, 3)),
        "startTime": "10:00",
        "endTime": "11:00"
    }
    
    Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(invalidData)
    Do $$$AssertFalse(result.success, "Debe fallar con owner inexistente")
    Do $$$AssertTrue(result.error '= "", "Debe retornar mensaje de error")
    Do $$$AssertEquals(result.bookingId, "", "No debe retornar booking ID")
}

/// Test 10: Performance con múltiples reservas
Method TestPerformanceWithMultipleBookings()
{
    Set startTime = $ZH
    
    // Crear 50 reservas para test de performance
    For i=1:1:50 {
        Set bookingData = {
            "ownerId": (..TestOwnerId),
            "walkerId": (..TestWalkerId),
            "petId": (..TestPetId),
            "availabilityId": (..TestAvailabilityId),
            "date": ($ZDATE($HOROLOG + (i#7), 3)),
            "startTime": ("1" _ (i#2) _ ":00"),
            "endTime": ("1" _ (i#2+1) _ ":00")
        }
        
        Set result = ##class(Demo.PETS.Services.BookingService).CreateBooking(bookingData)
        Do $$$AssertTrue(result.success, "Cada reserva debe crearse correctamente")
    }
    
    Set endTime = $ZH
    Set duration = endTime - startTime
    
    // Verificar que las 50 reservas se crearon en menos de 5 segundos
    Do $$$AssertTrue(duration < 5, "50 reservas deben crearse en menos de 5 segundos")
    
    // Test obtener todas las reservas
    Set startTime = $ZH
    Set result = ##class(Demo.PETS.Services.BookingService).GetBookingsByOwner(..TestOwnerId, "", 100)
    Set endTime = $ZH
    Set queryDuration = endTime - startTime
    
    Do $$$AssertTrue(result.success, "Consulta debe ser exitosa")
    Do $$$AssertTrue(result.count >= 50, "Debe retornar al menos 50 reservas")
    Do $$$AssertTrue(queryDuration < 2, "Consulta de 50+ reservas debe ser < 2 segundos")
}

// Propiedades para almacenar IDs de test
Property TestOwnerId As %String;

Property TestPetId As %String;

Property TestWalkerId As %String;

Property TestAvailabilityId As %String;

Property TestBookingId As %String;

Property TestReference As %String;

}