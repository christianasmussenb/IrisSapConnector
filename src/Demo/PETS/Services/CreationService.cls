/// Service for creating entities in the PETS system
Class Demo.PETS.Services.CreationService Extends Demo.PETS.Services.Base
{

/// Create pet from form data with UserID format (legacy support)
ClassMethod CreatePetFromFormUserID() As %DynamicObject
{
    Try {
        // Extract form data
        Set formData = ##class(Demo.PETS.Services.FormService).ExtractPetFormDataUserID()
        
        // Validate form data
        Set validation = ##class(Demo.PETS.Services.ValidationService).ValidatePetDataUserID(formData)
        If ('validation.isValid) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildValidationErrorResponse(validation.errors)
        }
        
        // Generate unique UserID
        Set userid = ##class(Demo.PETS.Services.UtilityService).GenerateUniqueUserID()
        
        // Verify owner exists
        Set owner = ##class(Demo.PETS.Owners).%OpenId(formData.ownerID)
        If '$IsObject(owner) {
            Set response = {}
            Set response.error = "El dueño especificado no existe"
            Return response
        }
        
        // Create the pet
        Set pet = ##class(Demo.PETS.Pets).%New()
        Set pet.UserID = userid
        Set pet.Name = formData.nombre
        Set pet.Breed = formData.raza
        Set pet.Age = formData.edad
        Set pet.Weight = formData.peso
        Set pet.Size = formData.tamaño
        Set pet.Color = formData.color
        Set pet.Status = "Active"
        Set pet.Temperament = formData.temperamento
        Set pet.Notes = formData.observaciones
        Set pet.Owner = owner
        
        Set sc = pet.%Save()
        If $$$ISERR(sc) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildGenericErrorResponse($System.Status.GetErrorText(sc))
        }
        
        Return ##class(Demo.PETS.Services.ResponseService).BuildPetUserIDSuccessResponse(pet, formData, userid)
        
    } Catch ex {
        Return ##class(Demo.PETS.Services.ResponseService).BuildExceptionErrorResponse(ex)
    }
}

/// Create pet from form data with full validation
ClassMethod CreatePetFromForm() As %DynamicObject
{
    Try {
        // Extract form data
        Set formData = ##class(Demo.PETS.Services.FormService).ExtractPetFormData()
        
        // Validate form data
        Set validation = ##class(Demo.PETS.Services.ValidationService).ValidatePetData(formData)
        If ('validation.isValid) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildValidationErrorResponse(validation.errors)
        }
        
        // Check for duplicate RUT
        If ##class(Demo.PETS.Services.ValidationService).CheckRUTExists(formData.rut, "pet") {
            Return ##class(Demo.PETS.Services.ResponseService).BuildDuplicateRUTErrorResponse("pet")
        }
        
        // Verify owner exists
        Set owner = ##class(Demo.PETS.Owners).GetOwnerByRUT(formData.rutDueno)
        If '$IsObject(owner) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildOwnerNotFoundErrorResponse()
        }
        
        // Create the pet
        Set pet = ##class(Demo.PETS.Pets).%New()
        Set pet.RUT = formData.rut
        Set pet.Name = formData.nombre
        Set pet.Species = formData.especie
        Set pet.Breed = formData.raza
        Set pet.Age = formData.edad
        Set pet.Weight = formData.peso
        Set pet.Color = formData.color
        Set pet.Gender = formData.genero
        Set pet.Description = formData.descripcion
        Set pet.Owner = owner
        Set pet.Status = "Active"
        
        Set sc = pet.%Save()
        If $$$ISERR(sc) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildGenericErrorResponse($System.Status.GetErrorText(sc))
        }
        
        Return ##class(Demo.PETS.Services.ResponseService).BuildPetSuccessResponse(pet, formData)
        
    } Catch ex {
        Return ##class(Demo.PETS.Services.ResponseService).BuildExceptionErrorResponse(ex)
    }
}

/// Create walker from form data with full validation
ClassMethod CreateWalkerFromForm() As %DynamicObject
{
    Try {
        // Extract form data
        Set formData = ##class(Demo.PETS.Services.FormService).ExtractWalkerFormData()
        
        // Validate form data
        Set validation = ##class(Demo.PETS.Services.ValidationService).ValidateWalkerData(formData)
        If ('validation.isValid) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildValidationErrorResponse(validation.errors)
        }
        
        // Check for duplicate RUT
        If ##class(Demo.PETS.Services.ValidationService).CheckRUTExists(formData.rut, "walker") {
            Return ##class(Demo.PETS.Services.ResponseService).BuildDuplicateRUTErrorResponse("walker")
        }
        
        // Create the walker
        Set walker = ##class(Demo.PETS.Walkers).%New()
        Set walker.RUT = formData.rut
        Set walker.Name = formData.nombre
        Set walker.Phone = formData.telefono
        Set walker.Email = formData.email
        Set walker.Age = formData.edad
        Set walker.Experience = formData.experiencia
        Set walker.Availability = formData.disponibilidad
        Set walker.HourlyRate = formData.tarifa
        Set walker.Notes = formData.referencias
        Set walker.Status = "Available"
        
        Set sc = walker.%Save()
        If $$$ISERR(sc) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildGenericErrorResponse($System.Status.GetErrorText(sc))
        }
        
        Return ##class(Demo.PETS.Services.ResponseService).BuildWalkerSuccessResponse(walker, formData)
        
    } Catch ex {
        Return ##class(Demo.PETS.Services.ResponseService).BuildExceptionErrorResponse(ex)
    }
}

/// Create owner from form data with full validation
ClassMethod CreateOwnerFromForm() As %DynamicObject
{
    Try {
        // Extract form data
        Set formData = ##class(Demo.PETS.Services.FormService).ExtractOwnerFormData()
        
        // Validate form data
        Set validation = ##class(Demo.PETS.Services.ValidationService).ValidateOwnerData(formData)
        If ('validation.isValid) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildValidationErrorResponse(validation.errors)
        }
        
        // Check for duplicate RUT
        If ##class(Demo.PETS.Services.ValidationService).CheckRUTExists(formData.rut, "owner") {
            Return ##class(Demo.PETS.Services.ResponseService).BuildDuplicateRUTErrorResponse("owner")
        }
        
        // Create the owner
        Set owner = ##class(Demo.PETS.Owners).%New()
        Set owner.RUT = formData.rut
        Set owner.Name = formData.nombre
        Set owner.Phone = formData.telefono
        Set owner.Email = formData.email
        Set owner.Address = formData.direccion
        Set owner.NumberOfPets = formData.numMascotas
        Set owner.Preferences = formData.preferencias
        Set owner.Status = "Active"
        
        Set sc = owner.%Save()
        If $$$ISERR(sc) {
            Return ##class(Demo.PETS.Services.ResponseService).BuildGenericErrorResponse($System.Status.GetErrorText(sc))
        }
        
        Return ##class(Demo.PETS.Services.ResponseService).BuildOwnerSuccessResponse(owner, formData)
        
    } Catch ex {
        Return ##class(Demo.PETS.Services.ResponseService).BuildExceptionErrorResponse(ex)
    }
}

/// Create new pet (legacy method for backward compatibility)
ClassMethod CreatePet(name As %String, breed As %String, age As %String, weight As %String, ownerId As %String) As %DynamicObject
{
    Try {
        // Validations
        Set errors = []
        
        Set error = ..ValidateRequired(name, "Name")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "name"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(breed, "Breed")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "breed"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(age, "Age")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "age"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(ownerId, "Owner")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "ownerId"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        // Validate that age is numeric
        If (age '= "") && ('$MATCH(age, "^[0-9]+$")) {
            Set errorObj = {}
            Set errorObj.field = "age"
            Set errorObj.message = "Age must be a number"
            Do errors.%Push(errorObj)
        }
        
        If errors.%Size() > 0 {
            Return ..ValidationErrorResponse("Validation errors", errors)
        }
        
        // Verify that owner exists
        Set owner = ##class(Demo.PETS.Owners).%OpenId(ownerId)
        If '$IsObject(owner) {
            Set errorObj = {}
            Set errorObj.field = "ownerId"
            Set errorObj.message = "Selected owner does not exist"
            Do errors.%Push(errorObj)
            Return ..ValidationErrorResponse("Invalid owner", errors)
        }
        
        // Create the pet
        Set pet = ##class(Demo.PETS.Pets).%New()
        Set pet.Name = name
        Set pet.Breed = breed
        Set pet.Age = +age
        If weight '= "" Set pet.Weight = +weight
        Set pet.Owner = owner
        
        Set status = pet.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error saving pet: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set petData = {}
        Set petData.id = pet.%Id()
        Set petData.name = pet.Name
        Set petData.breed = pet.Breed
        Set petData.age = pet.Age
        Set petData.weight = pet.Weight
        Set petData.ownerId = pet.Owner.%Id()
        Set petData.ownerName = pet.Owner.Name
        
        Return ..SuccessResponse("Pet created successfully", petData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Create new walker
ClassMethod CreateWalker(name As %String, phone As %String, email As %String, experience As %String) As %DynamicObject
{
    Try {
        // Validations
        Set errors = []
        
        Set error = ..ValidateRequired(name, "Name")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "name"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(phone, "Phone")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "phone"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidatePhone(phone)
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "phone"
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
            Return ..ValidationErrorResponse("Validation errors", errors)
        }
        
        // Create the walker
        Set walker = ##class(Demo.PETS.Walkers).%New()
        Set walker.Name = name
        Set walker.Phone = phone
        Set walker.Email = email
        Set walker.Notes = experience
        
        Set status = walker.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error saving walker: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set walkerData = {}
        Set walkerData.id = walker.%Id()
        Set walkerData.name = walker.Name
        Set walkerData.phone = walker.Phone
        Set walkerData.email = walker.Email
        Set walkerData.experience = walker.Notes
        
        Return ..SuccessResponse("Walker created successfully", walkerData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Create new owner
ClassMethod CreateOwner(name As %String, phone As %String, email As %String, address As %String) As %DynamicObject
{
    Try {
        // Validations
        Set errors = []
        
        Set error = ..ValidateRequired(name, "Name")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "name"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidateRequired(phone, "Phone")
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "phone"
            Set errorObj.message = error
            Do errors.%Push(errorObj)
        }
        
        Set error = ..ValidatePhone(phone)
        If error '= "" {
            Set errorObj = {}
            Set errorObj.field = "phone"
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
            Return ..ValidationErrorResponse("Validation errors", errors)
        }
        
        // Create the owner
        Set owner = ##class(Demo.PETS.Owners).%New()
        Set owner.Name = name
        Set owner.Phone = phone
        Set owner.Email = email
        Set owner.Address = address
        
        Set status = owner.%Save()
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error saving owner: " _ $SYSTEM.Status.GetErrorText(status))
        }
        
        Set ownerData = {}
        Set ownerData.id = owner.%Id()
        Set ownerData.name = owner.Name
        Set ownerData.phone = owner.Phone
        Set ownerData.email = owner.Email
        Set ownerData.address = owner.Address
        
        Return ..SuccessResponse("Owner created successfully", ownerData)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Initialize test data
ClassMethod InitializeTestData() As %DynamicObject
{
    Try {
        // Clear existing data
        Do ##class(Demo.PETS.Pets).%DeleteExtent()
        Do ##class(Demo.PETS.Walkers).%DeleteExtent()
        Do ##class(Demo.PETS.Owners).%DeleteExtent()
        
        Set totalCreated = 0
        
        // Create test owners
        Set owners = []
        Set owner1 = ..CreateOwner("John Smith", "555-0101", "john@email.com", "123 Main St")
        Do owners.%Push(owner1.data.id)
        
        Set owner2 = ..CreateOwner("Mary Johnson", "555-0102", "mary@email.com", "456 Oak Ave")
        Do owners.%Push(owner2.data.id)
        
        Set owner3 = ..CreateOwner("Robert Brown", "555-0103", "robert@email.com", "789 Pine Rd")
        Do owners.%Push(owner3.data.id)
        
        Set owner4 = ..CreateOwner("Lisa Wilson", "555-0104", "lisa@email.com", "012 Elm St")
        Do owners.%Push(owner4.data.id)
        
        Set totalCreated = totalCreated + 4
        
        // Create test walkers
        Do ..CreateWalker("Peter Martinez", "555-0201", "peter@walkers.com", "5 years experience")
        Do ..CreateWalker("Laura Rodriguez", "555-0202", "laura@walkers.com", "3 years experience")
        Do ..CreateWalker("Michael Torres", "555-0203", "michael@walkers.com", "7 years experience")
        Do ..CreateWalker("Sofia Mendez", "555-0204", "sofia@walkers.com", "2 years experience")
        
        Set totalCreated = totalCreated + 4
        
        // Create test pets
        Do ..CreatePet("Max", "Labrador", "3", "25.5", owners.%Get(0))
        Do ..CreatePet("Luna", "Persian", "2", "4.2", owners.%Get(1))
        Do ..CreatePet("Rocky", "Bulldog", "5", "28.0", owners.%Get(2))
        Do ..CreatePet("Mia", "Siamese", "1", "3.5", owners.%Get(0))
        Do ..CreatePet("Buddy", "Golden Retriever", "4", "30.2", owners.%Get(3))
        
        Set totalCreated = totalCreated + 5
        
        Set data = {}
        Set data.totalCreated = totalCreated
        Set data.owners = 4
        Set data.walkers = 4
        Set data.pets = 5
        
        Return ..SuccessResponse("Test data initialized successfully", data)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

}
