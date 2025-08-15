/// ValidationService - Handles common validation logic
Class Demo.PETS.Services.ValidationService Extends Demo.PETS.Services.Base
{

/// Validate pet form data (UserID format)
ClassMethod ValidatePetDataUserID(formData As %DynamicObject) As %DynamicObject
{
    Set result = {}
    Set result.isValid = 1
    Set result.errors = []
    
    // Required field validations
    If (formData.nombre = "") {
        Do result.errors.%Push("Nombre es requerido")
        Set result.isValid = 0
    }
    
    // Business rule validations
    If (formData.edad < 0) {
        Do result.errors.%Push("Edad debe ser mayor o igual a 0")
        Set result.isValid = 0
    }
    
    If (formData.peso <= 0) {
        Do result.errors.%Push("Peso debe ser mayor a 0")
        Set result.isValid = 0
    }
    
    // Validate owner exists
    If (formData.ownerID <= 0) {
        Do result.errors.%Push("Debe especificar un dueño válido")
        Set result.isValid = 0
    }
    
    Return result
}

/// Validate pet form data
ClassMethod ValidatePetData(formData As %DynamicObject) As %DynamicObject
{
    Set result = {}
    Set result.isValid = 1
    Set result.errors = []
    
    // Required field validations
    If (formData.rut = "") {
        Do result.errors.%Push("RUT es requerido")
        Set result.isValid = 0
    }
    
    If (formData.nombre = "") {
        Do result.errors.%Push("Nombre es requerido")
        Set result.isValid = 0
    }
    
    If (formData.especie = "") {
        Do result.errors.%Push("Especie es requerida")
        Set result.isValid = 0
    }
    
    If (formData.rutDueno = "") {
        Do result.errors.%Push("RUT del dueño es requerido")
        Set result.isValid = 0
    }
    
    // Business rule validations
    If (formData.edad < 0) {
        Do result.errors.%Push("Edad debe ser mayor o igual a 0")
        Set result.isValid = 0
    }
    
    If (formData.peso <= 0) {
        Do result.errors.%Push("Peso debe ser mayor a 0")
        Set result.isValid = 0
    }
    
    Return result
}

/// Validate walker form data
ClassMethod ValidateWalkerData(formData As %DynamicObject) As %DynamicObject
{
    Set result = {}
    Set result.isValid = 1
    Set result.errors = []
    
    // Required field validations
    If (formData.rut = "") {
        Do result.errors.%Push("RUT es requerido")
        Set result.isValid = 0
    }
    
    If (formData.nombre = "") {
        Do result.errors.%Push("Nombre es requerido")
        Set result.isValid = 0
    }
    
    If (formData.telefono = "") {
        Do result.errors.%Push("Teléfono es requerido")
        Set result.isValid = 0
    }
    
    // Business rule validations
    If (formData.edad < 18) {
        Do result.errors.%Push("Edad mínima 18 años")
        Set result.isValid = 0
    }
    
    Return result
}

/// Validate owner form data
ClassMethod ValidateOwnerData(formData As %DynamicObject) As %DynamicObject
{
    Set result = {}
    Set result.isValid = 1
    Set result.errors = []
    
    // Required field validations
    If (formData.rut = "") {
        Do result.errors.%Push("RUT es requerido")
        Set result.isValid = 0
    }
    
    If (formData.nombre = "") {
        Do result.errors.%Push("Nombre es requerido")
        Set result.isValid = 0
    }
    
    If (formData.telefono = "") {
        Do result.errors.%Push("Teléfono es requerido")
        Set result.isValid = 0
    }
    
    Return result
}

/// Check if RUT already exists for any entity type
ClassMethod CheckRUTExists(rut As %String, entityType As %String) As %Boolean
{
    If (entityType = "pet") {
        Set existing = ##class(Demo.PETS.Pets).GetPetByRUT(rut)
        Return $IsObject(existing)
    }
    
    If (entityType = "walker") {
        Set existing = ##class(Demo.PETS.Walkers).GetWalkerByRUT(rut)
        Return $IsObject(existing)
    }
    
    If (entityType = "owner") {
        Set existing = ##class(Demo.PETS.Owners).GetOwnerByRUT(rut)
        Return $IsObject(existing)
    }
    
    Return 0
}

}
