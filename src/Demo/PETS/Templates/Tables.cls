/// Templates para tablas de la aplicación PETS
Class Demo.PETS.Templates.Tables Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar encabezado de tabla
ClassMethod GenerateTableHeader(columns As %String) As %String
{
    Set html = ""
    Set html = html _ "<table>" _ $c(13,10)
    Set html = html _ "<thead>" _ $c(13,10)
    Set html = html _ "<tr>" _ $c(13,10)
    
    // Procesar columnas separadas por comas
    For i=1:1:$Length(columns,",") {
        Set column = $Piece(columns,",",i)
        Set html = html _ "<th>" _ column _ "</th>" _ $c(13,10)
    }
    
    Set html = html _ "</tr>" _ $c(13,10)
    Set html = html _ "</thead>" _ $c(13,10)
    Set html = html _ "<tbody>" _ $c(13,10)
    
    Quit html
}

/// Generar pie de tabla
ClassMethod GenerateTableFooter() As %String
{
    Set html = ""
    Set html = html _ "</tbody>" _ $c(13,10)
    Set html = html _ "</table>" _ $c(13,10)
    
    Quit html
}

/// Generar fila de tabla genérica
ClassMethod GenerateTableRow(values As %String) As %String
{
    Set html = ""
    Set html = html _ "<tr>" _ $c(13,10)
    
    // Procesar valores separados por pipes |
    For i=1:1:$Length(values,"|") {
        Set value = $Piece(values,"|",i)
        Set html = html _ "<td>" _ value _ "</td>" _ $c(13,10)
    }
    
    Set html = html _ "</tr>" _ $c(13,10)
    
    Quit html
}

/// Generar tabla completa de mascotas
ClassMethod GeneratePetsTable() As %String
{
    Set html = ""
    Set columns = "ID,UserID,Nombre,Raza,Edad,Peso,Tamaño,Color,Dueño,Estado"
    Set html = html _ ..GenerateTableHeader(columns)
    
    // Obtener datos de mascotas
    Set sql = "SELECT p.ID, p.UserID, p.Name, p.Breed, p.Age, p.Weight, p.Size, p.Color, o.Name as OwnerName, p.Status FROM Demo_PETS.Pets p LEFT JOIN Demo_PETS.Owners o ON p.Owner = o.ID ORDER BY p.ID"
    Set statement = ##class(%SQL.Statement).%New()
    Set sc = statement.%Prepare(sql)
    Set result = statement.%Execute()
    
    Set rowCount = 0
    While result.%Next() {
        Set rowCount = rowCount + 1
        Set status = result.%Get("Status")
        Set statusClass = ""
        If status = "Active" { Set statusClass = "<span class='status-activo'>" _ status _ "</span>" }
        Else { Set statusClass = "<span class='status-inactivo'>" _ status _ "</span>" }
        
        Set values = result.%Get("ID") _ "|" _ result.%Get("UserID") _ "|" _ result.%Get("Name") _ "|" _ result.%Get("Breed") _ "|" _ result.%Get("Age") _ " años|" _ result.%Get("Weight") _ " kg|" _ result.%Get("Size") _ "|" _ result.%Get("Color") _ "|" _ result.%Get("OwnerName") _ "|" _ statusClass
        Set html = html _ ..GenerateTableRow(values)
    }
    
    If rowCount = 0 {
        Set html = html _ "<tr><td colspan='10' style='text-align:center; color:#666;'>No hay mascotas registradas</td></tr>" _ $c(13,10)
    }
    
    Set html = html _ ..GenerateTableFooter()
    
    Quit html
}

/// Generar tabla completa de paseadores
ClassMethod GenerateWalkersTable() As %String
{
    Set html = ""
    Set columns = "ID,RUT,Nombre,Teléfono,Edad,Experiencia,Disponibilidad,Tarifa/Hora,Estado"
    Set html = html _ ..GenerateTableHeader(columns)
    
    // Obtener datos de paseadores
    Set sql = "SELECT ID, RUT, Name, Phone, Age, Experience, Availability, HourlyRate, Status FROM Demo_PETS.Walkers ORDER BY ID"
    Set statement = ##class(%SQL.Statement).%New()
    Set sc = statement.%Prepare(sql)
    Set result = statement.%Execute()
    
    Set rowCount = 0
    While result.%Next() {
        Set rowCount = rowCount + 1
        Set status = result.%Get("Status")
        Set statusClass = ""
        If status = "Available" { Set statusClass = "<span class='disponible'>" _ status _ "</span>" }
        Else { Set statusClass = "<span class='ocupado'>" _ status _ "</span>" }
        
        Set values = result.%Get("ID") _ "|" _ result.%Get("RUT") _ "|" _ result.%Get("Name") _ "|" _ result.%Get("Phone") _ "|" _ result.%Get("Age") _ " años|" _ result.%Get("Experience") _ " años|" _ result.%Get("Availability") _ "|$" _ result.%Get("HourlyRate") _ "|" _ statusClass
        Set html = html _ ..GenerateTableRow(values)
    }
    
    If rowCount = 0 {
        Set html = html _ "<tr><td colspan='9' style='text-align:center; color:#666;'>No hay paseadores registrados</td></tr>" _ $c(13,10)
    }
    
    Set html = html _ ..GenerateTableFooter()
    
    Quit html
}

/// Generar tabla completa de dueños
ClassMethod GenerateOwnersTable() As %String
{
    Set html = ""
    Set columns = "ID,RUT,Nombre,Teléfono,Email,Dirección,# Mascotas,Estado"
    Set html = html _ ..GenerateTableHeader(columns)
    
    // Obtener datos de dueños
    Set sql = "SELECT ID, RUT, Name, Phone, Email, Address, NumberOfPets, Status FROM Demo_PETS.Owners ORDER BY ID"
    Set statement = ##class(%SQL.Statement).%New()
    Set sc = statement.%Prepare(sql)
    Set result = statement.%Execute()
    
    Set rowCount = 0
    While result.%Next() {
        Set rowCount = rowCount + 1
        Set status = result.%Get("Status")
        Set statusClass = ""
        If status = "Active" { Set statusClass = "<span class='activo'>" _ status _ "</span>" }
        Else { Set statusClass = "<span class='status-inactivo'>" _ status _ "</span>" }
        
        Set values = result.%Get("ID") _ "|" _ result.%Get("RUT") _ "|" _ result.%Get("Name") _ "|" _ result.%Get("Phone") _ "|" _ result.%Get("Email") _ "|" _ result.%Get("Address") _ "|" _ result.%Get("NumberOfPets") _ "|" _ statusClass
        Set html = html _ ..GenerateTableRow(values)
    }
    
    If rowCount = 0 {
        Set html = html _ "<tr><td colspan='8' style='text-align:center; color:#666;'>No hay dueños registrados</td></tr>" _ $c(13,10)
    }
    
    Set html = html _ ..GenerateTableFooter()
    
    Quit html
}

/// Generar página completa de consulta
ClassMethod GenerateQueryPage(title As %String, tableHtml As %String) As %String
{
    Set content = ""
    Set content = content _ "<h1>" _ title _ "</h1>" _ $c(13,10)
    Set content = content _ tableHtml _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/", "🏠 Volver al inicio", "btn-back") _ $c(13,10)
    
    Quit content
}

}
