/// Clase base para servicios del sistema PETS
Class Demo.PETS.Services.Base Extends %RegisteredObject [ Abstract ]
{

/// Codigos de estado estandar
Parameter SUCCESS = "SUCCESS";

Parameter ERROR = "ERROR";

Parameter NOTFOUND = "NOT_FOUND";

Parameter VALIDATIONERROR = "VALIDATION_ERROR";

/// Crear respuesta estandar de servicio
ClassMethod CreateServiceResponse(status As %String = "", message As %String = "", data As %DynamicObject = "", errors As %DynamicArray = "") As %DynamicObject
{
    Set response = {}
    Set response.status = status
    Set response.message = message
    Set response.timestamp = $ZDATETIME($HOROLOG,3)
    
    If $IsObject(data) && (data '= "") {
        Set response.data = data
    }
    
    If $IsObject(errors) && (errors.%Size() > 0) {
        Set response.errors = errors
    }
    
    Return response
}

/// Crear respuesta de exito
ClassMethod SuccessResponse(message As %String = "Operacion exitosa", data As %DynamicObject = "") As %DynamicObject
{
    Return ..CreateServiceResponse(..#SUCCESS, message, data)
}

/// Crear respuesta de error
ClassMethod ErrorResponse(message As %String = "Error en la operacion", errors As %DynamicArray = "") As %DynamicObject
{
    Return ..CreateServiceResponse(..#ERROR, message, "", errors)
}

/// Crear respuesta de validacion
ClassMethod ValidationErrorResponse(message As %String = "Error de validacion", errors As %DynamicArray = "") As %DynamicObject
{
    Return ..CreateServiceResponse(..#VALIDATIONERROR, message, "", errors)
}

/// Crear respuesta de no encontrado
ClassMethod NotFoundResponse(message As %String = "Recurso no encontrado") As %DynamicObject
{
    Return ..CreateServiceResponse(..#NOTFOUND, message)
}

/// Manejar excepciones de manera centralizada
ClassMethod HandleException(exception As %Exception.AbstractException) As %DynamicObject
{
    Set errors = []
    Set errorObj = {}
    Set errorObj.code = exception.Code
    Set errorObj.message = exception.DisplayString()
    Do errors.%Push(errorObj)
    
    Return ..ErrorResponse("Error interno del sistema", errors)
}

/// Validar campo obligatorio
ClassMethod ValidateRequired(value As %String, fieldName As %String) As %String
{
    If (value = "") || ($ZSTRIP(value, "W") = "") {
        Return fieldName _ " es obligatorio"
    }
    Return ""
}

/// Validar email
ClassMethod ValidateEmail(email As %String) As %String
{
    If email = "" Return ""
    
    Set pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    If '$MATCH(email, pattern) {
        Return "Formato de email invalido"
    }
    Return ""
}

/// Validar telefono
ClassMethod ValidatePhone(phone As %String) As %String
{
    If phone = "" Return ""
    
    Set cleanPhone = $TRANSLATE(phone, " ()-+", "")
    If '$MATCH(cleanPhone, "^[0-9]{8,15}$") {
        Return "Formato de telefono invalido"
    }
    Return ""
}

}
