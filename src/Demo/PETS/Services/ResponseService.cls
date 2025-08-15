/// ResponseService - Handles JSON response building
Class Demo.PETS.Services.ResponseService Extends Demo.PETS.Services.Base
{

/// Build success response for pet creation
ClassMethod BuildPetSuccessResponse(pet As Demo.PETS.Pets, formData As %DynamicObject) As %DynamicObject
{
    Set response = {}
    Set response.mensaje = "Mascota registrada exitosamente!"
    Set response.id = pet.%Id()
    Set response.rut = formData.rut
    Set response.nombre = formData.nombre
    Set response.especie = formData.especie
    Set response.raza = formData.raza
    Set response.edad = formData.edad
    Set response.peso = formData.peso
    Set response.color = formData.color
    Set response.genero = formData.genero
    Set response.descripcion = formData.descripcion
    Set response."rut_dueno" = formData.rutDueno
    Set response.estado = "OK"
    
    Return response
}

/// Build success response for walker creation
ClassMethod BuildWalkerSuccessResponse(walker As Demo.PETS.Walkers, formData As %DynamicObject) As %DynamicObject
{
    Set response = {}
    Set response.mensaje = "Paseador registrado exitosamente!"
    Set response.id = walker.%Id()
    Set response.rut = formData.rut
    Set response.nombre = formData.nombre
    Set response.telefono = formData.telefono
    Set response.email = formData.email
    Set response.edad = formData.edad
    Set response.experiencia = formData.experiencia
    Set response.disponibilidad = formData.disponibilidad
    Set response.tarifa = formData.tarifa
    Set response.referencias = formData.referencias
    Set response.estado = "OK"
    
    Return response
}

/// Build success response for owner creation
ClassMethod BuildOwnerSuccessResponse(owner As Demo.PETS.Owners, formData As %DynamicObject) As %DynamicObject
{
    Set response = {}
    Set response.mensaje = "Dueno registrado exitosamente!"
    Set response.id = owner.%Id()
    Set response.rut = formData.rut
    Set response.nombre = formData.nombre
    Set response.telefono = formData.telefono
    Set response.email = formData.email
    Set response.direccion = formData.direccion
    Set response."num_mascotas" = formData.numMascotas
    Set response.preferencias = formData.preferencias
    Set response.estado = "OK"
    
    Return response
}

/// Build error response with validation errors
ClassMethod BuildValidationErrorResponse(errors As %DynamicArray) As %DynamicObject
{
    Set response = {}
    Set errorMessage = ""
    Set iterator = errors.%GetIterator()
    
    While iterator.%GetNext(,.error) {
        If (errorMessage '= "") {
            Set errorMessage = errorMessage _ ", "
        }
        Set errorMessage = errorMessage _ error
    }
    
    Set response.error = errorMessage
    Return response
}

/// Build error response for duplicate RUT
ClassMethod BuildDuplicateRUTErrorResponse(entityType As %String) As %DynamicObject
{
    Set response = {}
    
    If (entityType = "pet") {
        Set response.error = "Ya existe una mascota registrada con este RUT"
    } ElseIf (entityType = "walker") {
        Set response.error = "Ya existe un paseador registrado con este RUT"
    } ElseIf (entityType = "owner") {
        Set response.error = "Ya existe un dueño registrado con este RUT"
    } Else {
        Set response.error = "RUT ya existe en el sistema"
    }
    
    Return response
}

/// Build error response for owner not found
ClassMethod BuildOwnerNotFoundErrorResponse() As %DynamicObject
{
    Set response = {}
    Set response.error = "No se encontró un dueño registrado con el RUT proporcionado"
    Return response
}

/// Build generic error response
ClassMethod BuildGenericErrorResponse(errorText As %String) As %DynamicObject
{
    Set response = {}
    Set response.error = "Error al guardar: " _ errorText
    Return response
}

/// Build exception error response
ClassMethod BuildExceptionErrorResponse(exception As %Exception.AbstractException) As %DynamicObject
{
    Set response = {}
    Set response.error = "Error al guardar: " _ exception.DisplayString()
    Return response
}

}
