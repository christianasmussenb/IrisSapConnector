/// Clase base para servicios del sistema PETS - Versión simplificada
Class Demo.PETS.Services.BaseSimple Extends %RegisteredObject
{

/// Crear respuesta de éxito
ClassMethod SuccessResponse(message As %String = "Operación exitosa", data As %DynamicObject = "") As %DynamicObject
{
    Set response = {}
    Set response.status = "SUCCESS"
    Set response.message = message
    Set response.timestamp = $ZDATETIME($HOROLOG,3)
    
    If $IsObject(data) && (data '= "") {
        Set response.data = data
    }
    
    Return response
}

/// Crear respuesta de error
ClassMethod ErrorResponse(message As %String = "Error en la operación") As %DynamicObject
{
    Set response = {}
    Set response.status = "ERROR"
    Set response.message = message
    Set response.timestamp = $ZDATETIME($HOROLOG,3)
    
    Return response
}

/// Manejar excepciones
ClassMethod HandleException(exception As %Exception.AbstractException) As %DynamicObject
{
    Return ..ErrorResponse("Error interno: " _ exception.DisplayString())
}

}
