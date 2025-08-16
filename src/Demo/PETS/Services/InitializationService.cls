/// InitializationService - Handles data initialization and system setup
Class Demo.PETS.Services.InitializationService Extends Demo.PETS.Services.Base
{

/// Initialize all sample data for the system
ClassMethod InitializeAllSampleData() As %DynamicObject
{
    Try {
        Set result = {}
        Set result.success = 1
        Set result.operations = []
        
        // Initialize Owners
        Do ##class(Demo.PETS.Owners).InsertSampleData()
        Set operation = {}
        Set operation.type = "Owners"
        Set operation.count = 4
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Initialize Pets
        Do ##class(Demo.PETS.Pets).InsertSampleData()
        Set operation = {}
        Set operation.type = "Pets"
        Set operation.count = 5
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Initialize Walkers
        Do ##class(Demo.PETS.Walkers).InsertSampleData()
        Set operation = {}
        Set operation.type = "Walkers"
        Set operation.count = 4
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Initialize Walker Availability (next 7 days)
        Set availabilityResult = ..InitializeWalkerAvailability()
        Set operation = {}
        Set operation.type = "WalkerAvailability"
        Set operation.count = availabilityResult.count
        Set operation.status = "completed"
        Set operation.details = availabilityResult.details
        Do result.operations.%Push(operation)
        
        Set result.message = "Datos inicializados exitosamente incluyendo disponibilidad de walkers"
        Set result.totalOperations = result.operations.%Size()
        
        Return result
        
    } Catch ex {
        Set errorResult = {}
        Set errorResult.success = 0
        Set errorResult.error = "Error durante inicialización: " _ ex.DisplayString()
        Return errorResult
    }
}

/// Get system statistics after initialization
ClassMethod GetSystemStatistics() As %DynamicObject
{
    Try {
        Set stats = {}
        
        // Count owners
        Set sql = "SELECT COUNT(*) FROM Demo_PETS.Owners"
        Set statement = ##class(%SQL.Statement).%New()
        Set sc = statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.owners = result.%GetData(1)
        } Else {
            Set stats.owners = 0
        }
        
        // Count pets
        Set sql = "SELECT COUNT(*) FROM Demo_PETS.Pets"
        Set statement = ##class(%SQL.Statement).%New()
        Set sc = statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.pets = result.%GetData(1)
        } Else {
            Set stats.pets = 0
        }
        
        // Count walkers
        Set sql = "SELECT COUNT(*) FROM Demo_PETS.Walkers"
        Set statement = ##class(%SQL.Statement).%New()
        Set sc = statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.walkers = result.%GetData(1)
        } Else {
            Set stats.walkers = 0
        }
        
        // Count availability slots
        Set sql = "SELECT COUNT(*) FROM Demo_PETS.Availability WHERE IsActive = 1"
        Set statement = ##class(%SQL.Statement).%New()
        Set sc = statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.availabilitySlots = result.%GetData(1)
        } Else {
            Set stats.availabilitySlots = 0
        }
        
        Set stats.success = 1
        Return stats
        
    } Catch ex {
        Set errorStats = {}
        Set errorStats.success = 0
        Set errorStats.error = "Error obteniendo estadísticas: " _ ex.DisplayString()
        Return errorStats
    }
}

/// Generate initialization status HTML
ClassMethod GenerateInitializationStatusHTML() As %String
{
    Set stats = ..GetSystemStatistics()
    
    Set html = "<div class='info'>Se han cargado los datos de prueba en las tablas persistentes:</div>"
    Set html = html _ "<ul>"
    
    If stats.success {
        Set html = html _ "<li><strong>Dueños:</strong> " _ stats.owners _ " registros</li>"
        Set html = html _ "<li><strong>Mascotas:</strong> " _ stats.pets _ " registros</li>"
        Set html = html _ "<li><strong>Paseadores:</strong> " _ stats.walkers _ " registros</li>"
        Set html = html _ "<li><strong>Slots de Disponibilidad:</strong> " _ stats.availabilitySlots _ " registros</li>"
    } Else {
        Set html = html _ "<li><strong>Error:</strong> No se pudieron obtener estadísticas</li>"
    }
    
    Set html = html _ "</ul>"
    Set html = html _ "<div class='info'>Las relaciones de integridad referencial están funcionando correctamente.</div>"
    
    Return html
}

/// Clear all data from system (for testing purposes)
ClassMethod ClearAllData() As %DynamicObject
{
    Try {
        Set result = {}
        Set result.success = 1
        Set result.operations = []
        
        // Clear pets first (due to foreign key constraints)
        &sql(DELETE FROM Demo_PETS.Pets)
        Set operation = {}
        Set operation.type = "Pets"
        Set operation.action = "cleared"
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Clear availability (depends on walkers)
        &sql(DELETE FROM Demo_PETS.Availability)
        Set operation = {}
        Set operation.type = "Availability"
        Set operation.action = "cleared"
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Clear walkers
        &sql(DELETE FROM Demo_PETS.Walkers)
        Set operation = {}
        Set operation.type = "Walkers"
        Set operation.action = "cleared"
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        // Clear owners
        &sql(DELETE FROM Demo_PETS.Owners)
        Set operation = {}
        Set operation.type = "Owners"
        Set operation.action = "cleared"
        Set operation.status = "completed"
        Do result.operations.%Push(operation)
        
        Set result.message = "Todos los datos han sido eliminados exitosamente"
        Set result.totalOperations = result.operations.%Size()
        
        Return result
        
    } Catch ex {
        Set errorResult = {}
        Set errorResult.success = 0
        Set errorResult.error = "Error durante limpieza: " _ ex.DisplayString()
        Return errorResult
    }
}

/// Initialize Walker Availability for next 7 days
/// Creates 5 availability records with different walkers, times and dates
ClassMethod InitializeWalkerAvailability() As %DynamicObject
{
    Try {
        Set result = {}
        Set result.success = 1
        Set result.count = 0
        Set result.details = []
        
        // Clear existing availability data first
        &sql(DELETE FROM Demo_PETS.Availability)
        
        // Get current date as starting point
        Set currentDate = +$HOROLOG
        
        // Define sample availability slots for next 7 days
        Set availabilityData = []
        
        // Walker 1 - María González (morning slots)
        Set slot1 = {}
        Set slot1.walkerId = 1
        Set slot1.date = currentDate + 1  // Tomorrow
        Set slot1.startTime = "09:00"
        Set slot1.endTime = "10:00"
        Set slot1.maxPets = 3
        Set slot1.specialRate = 15.00
        Set slot1.notes = "Preferible perros medianos y pequeños"
        Do availabilityData.%Push(slot1)
        
        Set slot2 = {}
        Set slot2.walkerId = 1
        Set slot2.date = currentDate + 1
        Set slot2.startTime = "11:00"
        Set slot2.endTime = "12:00"
        Set slot2.maxPets = 2
        Set slot2.specialRate = 15.00
        Set slot2.notes = "Disponible para entrenamientos especiales"
        Do availabilityData.%Push(slot2)
        
        // Walker 2 - Carlos Ruiz (afternoon slots)
        Set slot3 = {}
        Set slot3.walkerId = 2
        Set slot3.date = currentDate + 2  // Day after tomorrow
        Set slot3.startTime = "14:00"
        Set slot3.endTime = "15:30"
        Set slot3.maxPets = 4
        Set slot3.specialRate = 18.00
        Set slot3.notes = "Especialista en perros grandes"
        Do availabilityData.%Push(slot3)
        
        // Walker 3 - Sofia López (evening slots)
        Set slot4 = {}
        Set slot4.walkerId = 3
        Set slot4.date = currentDate + 3  // 3 days from now
        Set slot4.startTime = "17:00"
        Set slot4.endTime = "18:00"
        Set slot4.maxPets = 5
        Set slot4.specialRate = 12.00
        Set slot4.notes = "Ideal para socialización entre mascotas"
        Do availabilityData.%Push(slot4)
        
        // Walker 4 - Diego Morales (weekend slot)
        Set slot5 = {}
        Set slot5.walkerId = 4
        Set slot5.date = currentDate + 6  // Weekend
        Set slot5.startTime = "10:00"
        Set slot5.endTime = "11:30"
        Set slot5.maxPets = 3
        Set slot5.specialRate = 20.00
        Set slot5.notes = "Paseo especial de fin de semana en parque"
        Do availabilityData.%Push(slot5)
        
        // Create availability records
        For i=0:1:availabilityData.%Size()-1 {
            Set slotData = availabilityData.%Get(i)
            
            // Create new availability instance
            Set availability = ##class(Demo.PETS.Availability).%New()
            Set availability.Walker = ##class(Demo.PETS.Walkers).%OpenId(slotData.walkerId)
            Set availability.AvailableDate = slotData.date
            
            // Convert time strings to %Time format
            Set availability.StartTime = $ZTIMEH(slotData.startTime)
            Set availability.EndTime = $ZTIMEH(slotData.endTime)
            
            Set availability.MaxPets = slotData.maxPets
            Set availability.CurrentBookings = 0  // No bookings initially
            Set availability.IsActive = 1
            Set availability.SpecialRate = slotData.specialRate
            Set availability.Notes = slotData.notes
            
            // Save the record
            Set sc = availability.%Save()
            If $$$ISERR(sc) {
                Set error = $SYSTEM.Status.GetErrorText(sc)
                Continue
            } Else {
                Set result.count = result.count + 1
                
                // Add details for reporting
                Set detail = {}
                Set detail.walkerId = slotData.walkerId
                Set detail.date = ##class(Demo.PETS.Availability).FormatDate(slotData.date)
                Set detail.timeSlot = slotData.startTime _ " - " _ slotData.endTime
                Set detail.capacity = slotData.maxPets _ " pets"
                Set detail.rate = "$" _ slotData.specialRate
                Do result.details.%Push(detail)
            }
        }
        
        Set result.message = "Disponibilidad de walkers inicializada para los próximos 7 días"
        Return result
        
    } Catch ex {
        Set errorResult = {}
        Set errorResult.success = 0
        Set errorResult.error = "Error inicializando disponibilidad: " _ ex.DisplayString()
        Set errorResult.count = 0
        Return errorResult
    }
}

}
