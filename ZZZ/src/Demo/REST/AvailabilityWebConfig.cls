/// Configuración web para el formulario de disponibilidad
/// Mapea URLs para acceder a la interfaz web de gestión de disponibilidad
Class Demo.REST.AvailabilityWebConfig
{

/// Configura la aplicación web y URL mappings
ClassMethod Setup() As %Status
{
    Set sc = $$$OK
    
    Try {
        // Para simplicidad, usando la app web existente
        Write "Para acceder al formulario de disponibilidad:",!
        Write "URL: http://localhost:52773/csp/user/Demo.REST.AvailabilityForm.cls?walkerId=1",!
        Write "",!
        Write "O directamente desde el portal de gestión:",!
        Write "1. Ir a: http://localhost:52773/csp/sys/UtilHome.csp",!
        Write "2. Navegar a User namespace",!
        Write "3. Ejecutar: Demo.REST.AvailabilityForm",!
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Write "Error in setup: " _ ex.DisplayString()
    }
    
    Return sc
}

/// Método para probar el acceso directo
ClassMethod TestForm() As %Status
{
    Write "=== TESTING Availability Form Access ===",!
    Write "Probando acceso directo...",!
    
    // Simular acceso del walker 1
    Set walkerId = 1
    Write "Walker ID: " _ walkerId,!
    
    // Verificar que el walker existe
    Set walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
    If $IsObject(walker) {
        Write "Walker encontrado: " _ walker.Name,!
        Write "URL de acceso: http://localhost:52773/csp/user/Demo.REST.AvailabilityForm.cls?walkerId=" _ walkerId,!
    } Else {
        Write "Walker no encontrado. Ejecutar Demo.PETS.Walkers::InsertSampleData() primero.",!
    }
    
    Return $$$OK
}

}
