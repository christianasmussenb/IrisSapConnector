/// Servicio de creación para el sistema PETS
Class Demo.PETS.Services.CreationService Extends Demo.PETS.Services.Base
{

/// Crear nueva mascota
ClassMethod CreatePet(nombre As %String, tipo As %String, edad As %String, raza As %String, duenoId As %String) As %DynamicObject
{
    Try {
        // Validaciones
        Set errors = []
        
        Set error = ..ValidateRequired(nombre, "Nombre")
        If error '= "" Do errors.%Push({"field": "nombre", "message": error})
        
        Set error = ..ValidateRequired(tipo, "Tipo")
        If error '= "" Do errors.%Push({"field": "tipo", "message": error})
        
        Set error = ..ValidateRequired(edad, "Edad")
        If error '= "" Do errors.%Push({"field": "edad", "message": error})
        
        Set error = ..ValidateRequired(raza, "Raza")
        If error '= "" Do errors.%Push({"field": "raza", "message": error})
        
        Set error = ..ValidateRequired(duenoId, "Dueño")
        If error '= "" Do errors.%Push({"field": "duenoId", "message": error})
        
        // Validar que la edad sea numérica
        If (edad '= "") && ('$MATCH(edad, "^[0-9]+$")) {
            Set errorObj = {}
            Set errorObj.field = "edad"
            Set errorObj.message = "La edad debe ser un número"
            Do errors.%Push(errorObj)
        }
        
        If errors.%Size() > 0 {
            Return ..ValidationErrorResponse("Errores de validación", errors)
        }
        
        // Verificar que existe el dueño
        Set owner = ##class(Demo.PETS.Dueño).%OpenId(duenoId)
        If '$IsObject(owner) {
            Set errorObj = {}
            Set errorObj.field = "duenoId"
            Set errorObj.message = "El dueño seleccionado no existe"
            Do errors.%Push(errorObj)
            Return ..ValidationErrorResponse("Dueño no válido", errors)
        }
        
        // Crear la mascota
        Set mascota = ##class(Demo.PETS.Mascota).%New()
        Set mascota.Nombre = nombre
        Set mascota.Tipo = tipo
        Set mascota.Edad = +edad
        Set mascota.Raza = raza
        Set mascota.Dueño = owner
        
        Set status = mascota.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error al guardar la mascota: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set petData = {}
        Set petData.id = mascota.%Id()
        Set petData.nombre = mascota.Nombre
        Set petData.tipo = mascota.Tipo
        Set petData.edad = mascota.Edad
        Set petData.raza = mascota.Raza
        Set petData.duenoId = mascota.Dueño.%Id()
        Set petData.duenoNombre = mascota.Dueño.Nombre
        
        Return ..SuccessResponse("Mascota creada exitosamente", petData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Crear nuevo paseador
ClassMethod CreateWalker(nombre As %String, telefono As %String, email As %String, experiencia As %String) As %DynamicObject
{
    Try {
        // Validaciones
        Set errors = []
        
        Set error = ..ValidateRequired(nombre, "Nombre")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "nombre"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(telefono, "Teléfono")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "telefono"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidatePhone(telefono)
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "telefono"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        If email '= "" {
            Set error = ..ValidateEmail(email)
            If error '= "" {
                Set errorObj = {}
                Set errorObj.field = "email"
                Set errorObj.message = error
                Do errors.%Push(errorObj)
            }
        }
        
        If errors.%Size() > 0 {
            Return ..ValidationErrorResponse("Errores de validación", errors)
        }
        
        // Crear el paseador
        Set paseador = ##class(Demo.PETS.Paseador).%New()
        Set paseador.Nombre = nombre
        Set paseador.Telefono = telefono
        Set paseador.Email = email
        Set paseador.Experiencia = experiencia
        
        Set status = paseador.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error al guardar el paseador: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set walkerData = {}
        Set walkerData.id = paseador.%Id()
        Set walkerData.nombre = paseador.Nombre
        Set walkerData.telefono = paseador.Telefono
        Set walkerData.email = paseador.Email
        Set walkerData.experiencia = paseador.Experiencia
        
        Return ..SuccessResponse("Paseador creado exitosamente", walkerData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Crear nuevo dueño
ClassMethod CreateOwner(nombre As %String, telefono As %String, email As %String, direccion As %String) As %DynamicObject
{
    Try {
        // Validaciones
        Set errors = []
        
        Set error = ..ValidateRequired(nombre, "Nombre")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "nombre"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(telefono, "Teléfono")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "telefono"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidatePhone(telefono)
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "telefono"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        If email '= "" {
            Set error = ..ValidateEmail(email)
            If error '= "" {
                Set errorObj = {}
                Set errorObj.field = "email"
                Set errorObj.message = error
                Do errors.%Push(errorObj)
            }
        }
        
        If errors.%Size() > 0 {
            Return ..ValidationErrorResponse("Errores de validación", errors)
        }
        
        // Crear el dueño
        Set dueño = ##class(Demo.PETS.Dueño).%New()
        Set dueño.Nombre = nombre
        Set dueño.Telefono = telefono
        Set dueño.Email = email
        Set dueño.Direccion = direccion
        
        Set status = dueño.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error al guardar el dueño: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set ownerData = {}
        Set ownerData.id = dueño.%Id()
        Set ownerData.nombre = dueño.Nombre
        Set ownerData.telefono = dueño.Telefono
        Set ownerData.email = dueño.Email
        Set ownerData.direccion = dueño.Direccion
        
        Return ..SuccessResponse("Dueño creado exitosamente", ownerData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Inicializar datos de prueba
ClassMethod InitializeTestData() As %DynamicObject
{
    Try {
        // Limpiar datos existentes
        Do ##class(Demo.PETS.Mascota).%DeleteExtent()
        Do ##class(Demo.PETS.Paseador).%DeleteExtent()
        Do ##class(Demo.PETS.Dueño).%DeleteExtent()
        
        Set totalCreated = 0
        
        // Crear dueños de prueba
        Set owners = []
        Set owner1 = ..CreateOwner("Juan Pérez", "555-0101", "juan@email.com", "Calle 123 #456")
        Do owners.%Push(owner1.data.id)
        
        Set owner2 = ..CreateOwner("María García", "555-0102", "maria@email.com", "Avenida 789 #012")
        Do owners.%Push(owner2.data.id)
        
        Set owner3 = ..CreateOwner("Carlos Ruiz", "555-0103", "carlos@email.com", "Plaza 345 #678")
        Do owners.%Push(owner3.data.id)
        
        Set owner4 = ..CreateOwner("Ana López", "555-0104", "ana@email.com", "Boulevard 901 #234")
        Do owners.%Push(owner4.data.id)
        
        Set totalCreated = totalCreated + 4
        
        // Crear paseadores de prueba
        Do ..CreateWalker("Pedro Martínez", "555-0201", "pedro@paseadores.com", "5 años de experiencia")
        Do ..CreateWalker("Laura Rodríguez", "555-0202", "laura@paseadores.com", "3 años de experiencia")
        Do ..CreateWalker("Miguel Torres", "555-0203", "miguel@paseadores.com", "7 años de experiencia")
        Do ..CreateWalker("Sofia Mendez", "555-0204", "sofia@paseadores.com", "2 años de experiencia")
        
        Set totalCreated = totalCreated + 4
        
        // Crear mascotas de prueba
        Do ..CreatePet("Max", "Perro", "3", "Labrador", owners.%Get(0))
        Do ..CreatePet("Luna", "Gato", "2", "Persa", owners.%Get(1))
        Do ..CreatePet("Rocky", "Perro", "5", "Bulldog", owners.%Get(2))
        Do ..CreatePet("Mia", "Gato", "1", "Siamés", owners.%Get(0))
        Do ..CreatePet("Buddy", "Perro", "4", "Golden Retriever", owners.%Get(3))
        
        Set totalCreated = totalCreated + 5
        
        Set data = {}
        Set data.totalCreated = totalCreated
        Set data.owners = 4
        Set data.walkers = 4
        Set data.pets = 5
        
        Return ..SuccessResponse("Datos de prueba inicializados exitosamente", data)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

}
