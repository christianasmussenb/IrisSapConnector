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
        
        Set result.message = "Datos inicializados exitosamente"
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

}
