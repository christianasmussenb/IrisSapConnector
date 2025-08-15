/// Clase principal de templates que unifica todas las plantillas PETS
Class Demo.PETS.Templates.Main Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar página completa de formulario de mascota
ClassMethod GeneratePetFormPage() As %String
{
    Set title = "🐕 Registro de Mascotas"
    Set content = ""
    Set content = content _ "<h1>" _ title _ "</h1>" _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Forms).GeneratePetForm() _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Modals).GenerateResultModal("pet") _ $c(13,10)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Registro de Mascotas", content)
}

/// Generar página completa de formulario de paseador
ClassMethod GenerateWalkerFormPage() As %String
{
    Set title = "🚶 Registro de Paseadores"
    Set content = ""
    Set content = content _ "<h1>" _ title _ "</h1>" _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Forms).GenerateWalkerForm() _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Modals).GenerateResultModal("walker") _ $c(13,10)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Registro de Paseadores", content)
}

/// Generar página completa de formulario de dueño
ClassMethod GenerateOwnerFormPage() As %String
{
    Set title = "👤 Registro de Dueños"
    Set content = ""
    Set content = content _ "<h1>" _ title _ "</h1>" _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Forms).GenerateOwnerForm() _ $c(13,10)
    Set content = content _ ##class(Demo.PETS.Templates.Modals).GenerateResultModal("owner") _ $c(13,10)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Registro de Dueños", content)
}

/// Generar página completa de consulta de mascotas
ClassMethod GeneratePetsQueryPage() As %String
{
    Set title = "🐕 Consulta de Mascotas"
    Set tableHtml = ##class(Demo.PETS.Templates.Tables).GeneratePetsTable()
    Set content = ##class(Demo.PETS.Templates.Tables).GenerateQueryPage(title, tableHtml)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Consulta de Mascotas", content)
}

/// Generar página completa de consulta de paseadores
ClassMethod GenerateWalkersQueryPage() As %String
{
    Set title = "🚶 Consulta de Paseadores"
    Set tableHtml = ##class(Demo.PETS.Templates.Tables).GenerateWalkersTable()
    Set content = ##class(Demo.PETS.Templates.Tables).GenerateQueryPage(title, tableHtml)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Consulta de Paseadores", content)
}

/// Generar página completa de consulta de dueños
ClassMethod GenerateOwnersQueryPage() As %String
{
    Set title = "👤 Consulta de Dueños"
    Set tableHtml = ##class(Demo.PETS.Templates.Tables).GenerateOwnersTable()
    Set content = ##class(Demo.PETS.Templates.Tables).GenerateQueryPage(title, tableHtml)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Consulta de Dueños", content)
}

/// Generar página de inicio con navegación
ClassMethod GenerateHomePage() As %String
{
    Set content = ""
    Set content = content _ "<h1>🐕 Sistema de Paseos de Perros</h1>" _ $c(13,10)
    Set content = content _ "<p>Aplicación web creada con clases de InterSystems IRIS para gestionar servicios de paseos caninos</p>" _ $c(13,10)
    
    Set content = content _ "<div style='display: flex; gap: 30px; margin: 30px 0;'>" _ $c(13,10)
    
    // Sección de inscripciones
    Set content = content _ "<div style='flex: 1; background: #e8f5e8; padding: 25px; border-radius: 8px; border-left: 5px solid #27ae60;'>" _ $c(13,10)
    Set content = content _ "<h3 style='margin-top: 0; color: #27ae60;'>📝 INSCRIPCIONES</h3>" _ $c(13,10)
    Set content = content _ "<p style='margin-bottom: 20px; color: #666;'>Registrar nuevos participantes en el sistema</p>" _ $c(13,10)
    Set content = content _ "<ul style='list-style-type: none; padding: 0;'>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/mascotas", "🐕 Inscribir Mascota", "background: #e74c3c; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/paseadores", "🚶 Inscribir Paseador", "background: #f39c12; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/dueños", "👤 Inscribir Dueño", "background: #8e44ad; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "</ul>" _ $c(13,10)
    Set content = content _ "</div>" _ $c(13,10)
    
    // Sección de consultas
    Set content = content _ "<div style='flex: 1; background: #e3f2fd; padding: 25px; border-radius: 8px; border-left: 5px solid #2196f3;'>" _ $c(13,10)
    Set content = content _ "<h3 style='margin-top: 0; color: #2196f3;'>🔍 CONSULTAS</h3>" _ $c(13,10)
    Set content = content _ "<p style='margin-bottom: 20px; color: #666;'>Ver listados de participantes registrados</p>" _ $c(13,10)
    Set content = content _ "<ul style='list-style-type: none; padding: 0;'>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/consultar-mascotas", "🐕 Ver Mascotas", "background: #e74c3c; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/consultar-paseadores", "🚶 Ver Paseadores", "background: #f39c12; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "<li style='margin: 12px 0;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/consultar-dueños", "👤 Ver Dueños", "background: #8e44ad; color: white; width: 200px; text-align: center;") _ "</li>" _ $c(13,10)
    Set content = content _ "</ul>" _ $c(13,10)
    Set content = content _ "</div>" _ $c(13,10)
    
    Set content = content _ "</div>" _ $c(13,10)
    
    // Sección de herramientas
    Set content = content _ "<div style='margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 4px;'>" _ $c(13,10)
    Set content = content _ "<h4>🛠️ Herramientas del Sistema:</h4>" _ $c(13,10)
    Set content = content _ "<p style='margin-bottom: 15px;'>" _ ##class(Demo.PETS.Templates.Base).GenerateNavButton("/csp/demo2/pruebas-automaticas", "🧪 Pruebas Automáticas", "btn-success") _ " Registrar datos de ejemplo automáticamente</p>" _ $c(13,10)
    Set content = content _ "<h4>Acerca del sistema:</h4>" _ $c(13,10)
    Set content = content _ "<p>Este sistema permite registrar mascotas, paseadores y dueños para facilitar la gestión de servicios de paseos caninos.</p>" _ $c(13,10)
    Set content = content _ "<p><strong>Tecnología:</strong> InterSystems IRIS + ObjectScript + REST + Templates Modulares</p>" _ $c(13,10)
    Set content = content _ "</div>" _ $c(13,10)
    
    Quit ##class(Demo.PETS.Templates.Base).GeneratePage("Demo IRIS REST Service", content)
}

}
