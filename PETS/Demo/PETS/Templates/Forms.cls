/// Templates para formularios de la aplicación PETS
Class Demo.PETS.Templates.Forms Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar campo de formulario genérico
ClassMethod GenerateFormField(type As %String, name As %String, label As %String, required As %Boolean = 0, options As %String = "", placeholder As %String = "", value As %String = "") As %String
{
    Set html = ""
    Set html = html _ "<div class='form-group'>" _ $c(13,10)
    Set html = html _ "<label for='" _ name _ "'>" _ label
    If required {
        Set html = html _ " *"
    }
    Set html = html _ ":</label>" _ $c(13,10)
    
    If type = "select" {
        Set html = html _ "<select id='" _ name _ "' name='" _ name _ "'"
        If required { Set html = html _ " required" }
        Set html = html _ ">" _ $c(13,10)
        Set html = html _ options _ $c(13,10)
        Set html = html _ "</select>" _ $c(13,10)
    } ElseIf type = "textarea" {
        Set html = html _ "<textarea id='" _ name _ "' name='" _ name _ "' rows='4'"
        If placeholder '= "" { Set html = html _ " placeholder='" _ placeholder _ "'" }
        If required { Set html = html _ " required" }
        Set html = html _ ">" _ value _ "</textarea>" _ $c(13,10)
    } Else {
        Set html = html _ "<input type='" _ type _ "' id='" _ name _ "' name='" _ name _ "'"
        If placeholder '= "" { Set html = html _ " placeholder='" _ placeholder _ "'" }
        If value '= "" { Set html = html _ " value='" _ value _ "'" }
        If required { Set html = html _ " required" }
        If type = "number" { Set html = html _ " min='0'" }
        If name = "peso" { Set html = html _ " step='0.1'" }
        If name = "edad" && type = "number" { Set html = html _ " max='25'" }
        Set html = html _ ">" _ $c(13,10)
    }
    
    Set html = html _ "</div>" _ $c(13,10)
    
    Quit html
}

/// Generar formulario completo de mascota
ClassMethod GeneratePetForm() As %String
{
    Set html = ""
    Set html = html _ "<form id='petForm' method='POST' action='/csp/demo2/mascotas'>" _ $c(13,10)
    
    // Campos del formulario de mascota
    Set html = html _ ..GenerateFormField("text", "nombre", "Nombre de la mascota", 1)
    Set html = html _ ..GenerateFormField("text", "raza", "Raza", 0)
    Set html = html _ ..GenerateFormField("number", "edad", "Edad (años)", 0)
    Set html = html _ ..GenerateFormField("number", "peso", "Peso (kg)", 0)
    Set html = html _ ..GenerateFormField("text", "color", "Color", 0)
    
    // Campo de tamaño con opciones
    Set sizeOptions = "<option value='Pequeño'>Pequeño</option><option value='Mediano' selected>Mediano</option><option value='Grande'>Grande</option><option value='Gigante'>Gigante</option>"
    Set html = html _ ..GenerateFormField("select", "tamaño", "Tamaño", 0, sizeOptions)
    
    Set html = html _ ..GenerateFormField("text", "temperamento", "Temperamento", 0, "", "Ej: Amigable, energético")
    Set html = html _ ..GenerateFormField("textarea", "observaciones", "Observaciones", 0, "", "Información adicional sobre la mascota")
    
    // Campo de dueño con datos dinámicos
    Set html = html _ "<div class='form-group'>" _ $c(13,10)
    Set html = html _ "<label for='owner_id'>Dueño *:</label>" _ $c(13,10)
    Set html = html _ "<select id='owner_id' name='owner_id' required>" _ $c(13,10)
    
    // Cargar dueños desde la base de datos
    Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, Name FROM Demo_PETS.Owners WHERE Status = 'Active' ORDER BY Name")
    While rs.%Next() {
        Set html = html _ "<option value='" _ rs.%Get("ID") _ "'>" _ rs.%Get("Name") _ "</option>" _ $c(13,10)
    }
    
    Set html = html _ "</select>" _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    // Botones del formulario
    Set html = html _ "<button type='submit'>Registrar Mascota</button>" _ $c(13,10)
    Set html = html _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/", "Volver al inicio", "btn-back") _ $c(13,10)
    Set html = html _ "</form>" _ $c(13,10)
    
    Quit html
}

/// Generar formulario completo de paseador
ClassMethod GenerateWalkerForm() As %String
{
    Set html = ""
    Set html = html _ "<form id='walkerForm' method='POST' action='/csp/demo2/paseadores'>" _ $c(13,10)
    
    // Campos del formulario de paseador
    Set html = html _ ..GenerateFormField("text", "rut", "RUT", 1, "", "12345678-9")
    Set html = html _ ..GenerateFormField("text", "nombre", "Nombre completo", 1)
    Set html = html _ ..GenerateFormField("tel", "telefono", "Teléfono", 1, "", "555-1234")
    Set html = html _ ..GenerateFormField("email", "email", "Email", 0)
    Set html = html _ ..GenerateFormField("number", "edad", "Edad", 0)
    Set html = html _ ..GenerateFormField("number", "experiencia", "Años de experiencia", 0)
    
    // Campo de disponibilidad con opciones
    Set availabilityOptions = "<option value='Tiempo completo'>Tiempo completo</option><option value='Mañanas'>Mañanas</option><option value='Tardes'>Tardes</option><option value='Fines de semana'>Fines de semana</option>"
    Set html = html _ ..GenerateFormField("select", "disponibilidad", "Disponibilidad", 0, availabilityOptions)
    
    Set html = html _ ..GenerateFormField("number", "tarifa", "Tarifa por hora (USD)", 0, "", "", "15.00")
    Set html = html _ ..GenerateFormField("textarea", "notas", "Notas adicionales", 0, "", "Referencias, certificaciones, etc.")
    
    // Botones del formulario
    Set html = html _ "<button type='submit'>Registrar Paseador</button>" _ $c(13,10)
    Set html = html _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/", "Volver al inicio", "btn-back") _ $c(13,10)
    Set html = html _ "</form>" _ $c(13,10)
    
    Quit html
}

/// Generar formulario completo de dueño
ClassMethod GenerateOwnerForm() As %String
{
    Set html = ""
    Set html = html _ "<form id='ownerForm' method='POST' action='/csp/demo2/dueños'>" _ $c(13,10)
    
    // Campos del formulario de dueño
    Set html = html _ ..GenerateFormField("text", "rut", "RUT", 1, "", "12345678-9")
    Set html = html _ ..GenerateFormField("text", "nombre", "Nombre completo", 1)
    Set html = html _ ..GenerateFormField("tel", "telefono", "Teléfono", 1, "", "555-1234")
    Set html = html _ ..GenerateFormField("email", "email", "Email", 0)
    Set html = html _ ..GenerateFormField("text", "direccion", "Dirección", 0)
    Set html = html _ ..GenerateFormField("number", "mascotas", "Número de mascotas", 0, "", "", "1")
    Set html = html _ ..GenerateFormField("textarea", "preferencias", "Preferencias", 0, "", "Horarios, rutas preferidas, etc.")
    
    // Botones del formulario
    Set html = html _ "<button type='submit'>Registrar Dueño</button>" _ $c(13,10)
    Set html = html _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/", "Volver al inicio", "btn-back") _ $c(13,10)
    Set html = html _ "</form>" _ $c(13,10)
    
    Quit html
}

}
