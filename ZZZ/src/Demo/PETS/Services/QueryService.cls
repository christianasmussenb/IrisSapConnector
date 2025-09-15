/// Servicio de consultas para el sistema PETS
Class Demo.PETS.Services.QueryService Extends Demo.PETS.Services.BaseSimple
{

/// Obtener todas las mascotas
ClassMethod GetAllPets() As %DynamicObject
{
    Try {
        Set pets = []
        Set sql = "SELECT ID, UserID, Name, Breed, Age, Weight, Size, Color, Status FROM Demo_PETS.Pets WHERE Status = 'ACTIVE' ORDER BY Name"
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error preparando consulta de mascotas")
        }
        
        Set result = statement.%Execute()
        While result.%Next() {
            Set pet = {}
            Set pet.id = result.%Get("ID")
            Set pet.userid = result.%Get("UserID")
            Set pet.name = result.%Get("Name")
            Set pet.breed = result.%Get("Breed")
            Set pet.age = result.%Get("Age")
            Set pet.weight = result.%Get("Weight")
            Set pet.size = result.%Get("Size")
            Set pet.color = result.%Get("Color")
            Set pet.status = result.%Get("Status")
            
            Do pets.%Push(pet)
        }
        
        Set data = {}
        Set data.pets = pets
        Set data.total = pets.%Size()
        
        Return ..SuccessResponse("Mascotas obtenidas exitosamente", data)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Obtener todos los paseadores
ClassMethod GetAllWalkers() As %DynamicObject
{
    Try {
        Set walkers = []
        Set sql = "SELECT ID, RUT, Name, Phone, Email, Age, Experience, Availability, HourlyRate, Status FROM Demo_PETS.Walkers WHERE Status IN ('AVAILABLE', 'BUSY') ORDER BY Name"
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error preparando consulta de paseadores")
        }
        
        Set result = statement.%Execute()
        While result.%Next() {
            Set walker = {}
            Set walker.id = result.%Get("ID")
            Set walker.rut = result.%Get("RUT")
            Set walker.name = result.%Get("Name")
            Set walker.phone = result.%Get("Phone")
            Set walker.email = result.%Get("Email")
            Set walker.age = result.%Get("Age")
            Set walker.experience = result.%Get("Experience")
            Set walker.availability = result.%Get("Availability")
            Set walker.hourlyRate = result.%Get("HourlyRate")
            Set walker.status = result.%Get("Status")
            
            Do walkers.%Push(walker)
        }
        
        Set data = {}
        Set data.walkers = walkers
        Set data.total = walkers.%Size()
        
        Return ..SuccessResponse("Paseadores obtenidos exitosamente", data)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Obtener todos los dueños
ClassMethod GetAllOwners() As %DynamicObject
{
    Try {
        Set owners = []
        Set sql = "SELECT ID, RUT, Name, Phone, Email, Address, NumberOfPets, Preferences, Status FROM Demo_PETS.Owners WHERE Status = 'ACTIVE' ORDER BY Name"
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        If $$$ISERR(status) {
            Return ..ErrorResponse("Error preparando consulta de dueños")
        }
        
        Set result = statement.%Execute()
        While result.%Next() {
            Set owner = {}
            Set owner.id = result.%Get("ID")
            Set owner.rut = result.%Get("RUT")
            Set owner.name = result.%Get("Name")
            Set owner.phone = result.%Get("Phone")
            Set owner.email = result.%Get("Email")
            Set owner.address = result.%Get("Address")
            Set owner.numberOfPets = result.%Get("NumberOfPets")
            Set owner.preferences = result.%Get("Preferences")
            Set owner.status = result.%Get("Status")
            
            Do owners.%Push(owner)
        }
        
        Set data = {}
        Set data.owners = owners
        Set data.total = owners.%Size()
        
        Return ..SuccessResponse("Dueños obtenidos exitosamente", data)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Obtener estadísticas generales del sistema
ClassMethod GetSystemStats() As %DynamicObject
{
    Try {
        Set stats = {}
        
        // Contar mascotas
        Set sql = "SELECT COUNT(*) AS Total FROM Demo_PETS.Pets WHERE Status = 'Active'"
        Set statement = ##class(%SQL.Statement).%New()
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.totalPets = result.%Get("Total")
        }
        
        // Contar dueños
        Set sql = "SELECT COUNT(*) AS Total FROM Demo_PETS.Owners WHERE Status = 'Active'"
        Set statement = ##class(%SQL.Statement).%New()
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.totalOwners = result.%Get("Total")
        }
        
        // Contar paseadores
        Set sql = "SELECT COUNT(*) AS Total FROM Demo_PETS.Walkers WHERE Status = 'Active'"
        Set statement = ##class(%SQL.Statement).%New()
        Do statement.%Prepare(sql)
        Set result = statement.%Execute()
        If result.%Next() {
            Set stats.totalWalkers = result.%Get("Total")
        }
        
        Return ..SuccessResponse("Estadísticas obtenidas", stats)
        
    } Catch ex {
        Return ..HandleException(ex)
    }
}

/// Generar HTML para tabla de mascotas
ClassMethod GeneratePetsTableHTML() As %String
{
    Set response = ..GetAllPets()
    If response.status '= "SUCCESS" {
        Return "<p>Error al cargar mascotas: " _ response.message _ "</p>"
    }
    
    Set pets = response.data.pets
    Set html = "<table class='data-table'>"
    Set html = html _ "<thead><tr><th>ID Usuario</th><th>Nombre</th><th>Raza</th><th>Edad</th><th>Peso</th><th>Tamaño</th><th>Color</th></tr></thead>"
    Set html = html _ "<tbody>"
    
    For i=0:1:pets.%Size()-1 {
        Set pet = pets.%Get(i)
        Set html = html _ "<tr>"
        Set html = html _ "<td>" _ pet.userid _ "</td>"
        Set html = html _ "<td>" _ pet.name _ "</td>"
        Set html = html _ "<td>" _ pet.breed _ "</td>"
        Set html = html _ "<td>" _ pet.age _ "</td>"
        Set html = html _ "<td>" _ pet.weight _ "</td>"
        Set html = html _ "<td>" _ pet.size _ "</td>"
        Set html = html _ "<td>" _ pet.color _ "</td>"
        Set html = html _ "</tr>"
    }
    
    Set html = html _ "</tbody></table>"
    Return html
}

/// Generar HTML para tabla de paseadores
ClassMethod GenerateWalkersTableHTML() As %String
{
    Set response = ..GetAllWalkers()
    If response.status '= "SUCCESS" {
        Return "<p>Error al cargar paseadores: " _ response.message _ "</p>"
    }
    
    Set walkers = response.data.walkers
    Set html = "<table class='data-table'>"
    Set html = html _ "<thead><tr><th>RUT</th><th>Nombre</th><th>Teléfono</th><th>Email</th><th>Experiencia</th><th>Tarifa/Hora</th></tr></thead>"
    Set html = html _ "<tbody>"
    
    For i=0:1:walkers.%Size()-1 {
        Set walker = walkers.%Get(i)
        Set html = html _ "<tr>"
        Set html = html _ "<td>" _ walker.rut _ "</td>"
        Set html = html _ "<td>" _ walker.name _ "</td>"
        Set html = html _ "<td>" _ walker.phone _ "</td>"
        Set html = html _ "<td>" _ walker.email _ "</td>"
        Set html = html _ "<td>" _ walker.experience _ " años</td>"
        Set html = html _ "<td>$" _ walker.hourlyRate _ "</td>"
        Set html = html _ "</tr>"
    }
    
    Set html = html _ "</tbody></table>"
    Return html
}

/// Generar HTML para tabla de dueños
ClassMethod GenerateOwnersTableHTML() As %String
{
    Set response = ..GetAllOwners()
    If response.status '= "SUCCESS" {
        Return "<p>Error al cargar dueños: " _ response.message _ "</p>"
    }
    
    Set owners = response.data.owners
    Set html = "<table class='data-table'>"
    Set html = html _ "<thead><tr><th>RUT</th><th>Nombre</th><th>Teléfono</th><th>Email</th><th>Dirección</th><th>Mascotas</th></tr></thead>"
    Set html = html _ "<tbody>"
    
    For i=0:1:owners.%Size()-1 {
        Set owner = owners.%Get(i)
        Set html = html _ "<tr>"
        Set html = html _ "<td>" _ owner.rut _ "</td>"
        Set html = html _ "<td>" _ owner.name _ "</td>"
        Set html = html _ "<td>" _ owner.phone _ "</td>"
        Set html = html _ "<td>" _ owner.email _ "</td>"
        Set html = html _ "<td>" _ owner.address _ "</td>"
        Set html = html _ "<td>" _ owner.numberOfPets _ "</td>"
        Set html = html _ "</tr>"
    }
    
    Set html = html _ "</tbody></table>"
    Return html
}

}
