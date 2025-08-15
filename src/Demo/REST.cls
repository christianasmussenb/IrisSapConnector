Class Demo.REST Extends %CSP.REST
{

/// Generar CSS inline desde clases modulares
ClassMethod GenerateCSSLink() As %String
{
  Set css = ##class(Demo.PETS.CSS.Main).GenerateAllCSS()
  Quit "<style>" _ css _ "</style>"
}

/// Generar JavaScript inline desde clases modulares
ClassMethod GenerateJSLink() As %String
{
  Set js = ##class(Demo.PETS.JS.Main).GenerateAllJS()
  Quit "<script>" _ js _ "</script>"
}

/// Método para inicializar datos de prueba
ClassMethod InicializarDatos() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Delegate to InitializationService for business logic
  Set initResult = ##class(Demo.PETS.Services.InitializationService).InitializeAllSampleData()
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Datos Inicializados")
  Write "<div class='container'>"
  Write "<h1>✅ Datos Inicializados Exitosamente</h1>"
  
  If initResult.success {
    Write ##class(Demo.PETS.Services.InitializationService).GenerateInitializationStatusHTML()
  } Else {
    Write "<div class='error'>Error durante la inicialización: " _ initResult.error _ "</div>"
  }
  
  Write "<a href='/csp/demo2/' style='background:#3498db; color:white; padding:10px 20px; text-decoration:none; border-radius:4px;'>🏠 Volver al inicio</a>"
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

/// Pruebas automáticas de inscripciones
ClassMethod PruebasAutomaticas() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Pruebas Automáticas - Sistema PETS")
  Write "<div class='container'>"
  Write "<h1>🧪 Pruebas Automáticas del Sistema PETS</h1>"
  Write "<p>Estas pruebas registrarán automáticamente datos de ejemplo para dueños, paseadores y mascotas.</p>"
  
  Write "<div id='test-results'>"
  Write "<h2>📊 Resultados de las Pruebas:</h2>"
  Write "</div>"
  
  Write "<button id='runTests' onclick='runAllTests()' style='background:#27ae60; color:white; padding:15px 30px; border:none; border-radius:5px; font-size:16px; cursor:pointer; margin:20px 0;'>▶️ Ejecutar Todas las Pruebas</button>"
  Write "<a href='/csp/demo2/' style='background:#95a5a6; color:white; padding:12px 20px; text-decoration:none; border-radius:4px; margin-left:20px;'>🏠 Volver al Inicio</a>"
  
  // Generate JavaScript using TestingService
  Write "<script>"
  Write ##class(Demo.PETS.Services.TestingService).GenerateTestingJavaScript()
  Write "</script>"
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

XData UrlMap
{
<Routes>
  <Route Url="/" Method="GET" Call="Home"/>
  <Route Url="/inicializar" Method="GET" Call="InicializarDatos"/>
  <Route Url="/pruebas-automaticas" Method="GET" Call="PruebasAutomaticas"/>
  <Route Url="/mascotas" Method="GET" Call="MascotasForm"/>
  <Route Url="/mascotas" Method="POST" Call="GuardarMascota"/>
  <Route Url="/guardar-mascota" Method="POST" Call="GuardarMascota"/>
  <Route Url="/paseadores" Method="GET" Call="PaseadoresForm"/>
  <Route Url="/paseadores" Method="POST" Call="GuardarPaseador"/>
  <Route Url="/guardar-paseador" Method="POST" Call="GuardarPaseador"/>
  <Route Url="/dueños" Method="GET" Call="DueñosForm"/>
  <Route Url="/dueños" Method="POST" Call="GuardarDueño"/>
  <Route Url="/guardar-dueño" Method="POST" Call="GuardarDueño"/>
  <Route Url="/consultar-mascotas" Method="GET" Call="ConsultarMascotas"/>
  <Route Url="/consultar-paseadores" Method="GET" Call="ConsultarPaseadores"/>
  <Route Url="/consultar-dueños" Method="GET" Call="ConsultarDueños"/>
</Routes>
}

ClassMethod Home() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular  
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Sistema de Paseos de Perros")
  Write "<div class='container'>"
  Write "<h1>🐕 Sistema de Paseos de Perros</h1>"
  Write "<p>Aplicación web creada con clases de InterSystems IRIS para gestionar servicios de paseos caninos</p>"
  
  Write "<div style='display: flex; gap: 30px; margin: 30px 0;'>"
  
  Write "<div style='flex: 1; background: #e8f5e8; padding: 25px; border-radius: 8px; border-left: 5px solid #27ae60;'>"
  Write "<h3 style='margin-top: 0; color: #27ae60;'>📝 INSCRIPCIONES</h3>"
  Write "<p style='margin-bottom: 20px; color: #666;'>Registrar nuevos participantes en el sistema</p>"
  Write "<ul style='list-style-type: none; padding: 0;'>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/mascotas' style='display: inline-block; padding: 12px 18px; background: #e74c3c; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>🐕 Inscribir Mascota</a></li>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/paseadores' style='display: inline-block; padding: 12px 18px; background: #f39c12; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>🚶 Inscribir Paseador</a></li>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/dueños' style='display: inline-block; padding: 12px 18px; background: #8e44ad; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>👤 Inscribir Dueño</a></li>"
  Write "</ul>"
  Write "</div>"
  
  Write "<div style='flex: 1; background: #e3f2fd; padding: 25px; border-radius: 8px; border-left: 5px solid #2196f3;'>"
  Write "<h3 style='margin-top: 0; color: #2196f3;'>🔍 CONSULTAS</h3>"
  Write "<p style='margin-bottom: 20px; color: #666;'>Ver listados de participantes registrados</p>"
  Write "<ul style='list-style-type: none; padding: 0;'>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/consultar-mascotas' style='display: inline-block; padding: 12px 18px; background: #e74c3c; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>🐾 Ver Mascotas</a></li>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/consultar-paseadores' style='display: inline-block; padding: 12px 18px; background: #f39c12; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>🚶 Ver Paseadores</a></li>"
  Write "<li style='margin: 12px 0;'><a href='/csp/demo2/consultar-dueños' style='display: inline-block; padding: 12px 18px; background: #8e44ad; color: white; text-decoration: none; border-radius: 6px; width: 200px; text-align: center;'>👤 Ver Dueños</a></li>"
  Write "</ul>"
  Write "</div>"
  
  Write "</div>"
  Write "<div style='margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 4px;'>"
  Write "<h4>🛠️ Herramientas del Sistema:</h4>"
  Write "<p style='margin-bottom: 15px;'><a href='/csp/demo2/pruebas-automaticas' style='background:#27ae60; color:white; padding:12px 20px; text-decoration:none; border-radius:4px; margin-right:10px;'>🧪 Pruebas Automáticas</a> Registrar datos de ejemplo automáticamente</p>"
  Write "<h4>Acerca del sistema:</h4>"
  Write "<p>Este sistema permite registrar mascotas, paseadores y dueños para facilitar la gestión de servicios de paseos caninos.</p>"
  Write "<p><strong>Tecnología:</strong> InterSystems IRIS + ObjectScript + REST</p>"
  Write "</div>"
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod MascotasForm() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Registro de Mascotas")
  Write "<div class='container'>"
  Write "<h1>🐕 Registro de Mascotas</h1>"
  
  // Generar formulario usando la clase Templates.Forms
  Write ##class(Demo.PETS.Templates.Forms).GeneratePetForm()
  
  // Generar modal usando la clase Templates.Modals
  Write ##class(Demo.PETS.Templates.Modals).GenerateResultModal()
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod GuardarMascota() As %Status
{
  Set %response.ContentType = "application/json; charset=utf-8"
  
  // Delegate to CreationService for business logic (UserID format)
  Set result = ##class(Demo.PETS.Services.CreationService).CreatePetFromFormUserID()
  Write result.%ToJSON()
  
  Return $$$OK
}

ClassMethod PaseadoresForm() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Registro de Paseadores")
  Write "<div class='container'>"
  Write "<h1>🚶 Registro de Paseadores</h1>"
  
  // Generar formulario usando la clase Templates.Forms
  Write ##class(Demo.PETS.Templates.Forms).GenerateWalkerForm()
  
  // Generar modal usando la clase Templates.Modals
  Write ##class(Demo.PETS.Templates.Modals).GenerateResultModal()
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod GuardarPaseador() As %Status
{
  Set %response.ContentType = "application/json; charset=utf-8"
  
  // Delegate to CreationService for business logic
  Set result = ##class(Demo.PETS.Services.CreationService).CreateWalkerFromForm()
  Write result.%ToJSON()
  
  Return $$$OK
}

ClassMethod DueñosForm() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Registro de Dueños")
  Write "<div class='container'>"
  Write "<h1>👤 Registro de Dueños</h1>"
  
  // Generar formulario usando la clase Templates.Forms
  Write ##class(Demo.PETS.Templates.Forms).GenerateOwnerForm()
  
  // Generar modal usando la clase Templates.Modals
  Write ##class(Demo.PETS.Templates.Modals).GenerateResultModal()
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod GuardarDueño() As %Status
{
  Set %response.ContentType = "application/json; charset=utf-8"
  
  // Delegate to CreationService for business logic
  Set result = ##class(Demo.PETS.Services.CreationService).CreateOwnerFromForm()
  Write result.%ToJSON()
  
  Return $$$OK
}

ClassMethod ConsultarMascotas() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Consulta de Mascotas")
  Write "<div class='container'>"
  Write "<h1>🐕 Mascotas Registradas</h1>"
  
  // Usar el servicio de consultas para generar la tabla
  Write ##class(Demo.PETS.Services.QueryService).GeneratePetsTableHTML()
  
  // Botones de navegación
  Write "<div style='margin-top: 20px;'>"
  Write "<a href='/csp/demo2/' class='btn-back'>🏠 Volver al inicio</a>"
  Write "<a href='/csp/demo2/mascotas' style='background:#e74c3c; color:white; text-decoration:none; padding:10px 20px; border-radius:4px; margin-left:10px;'>➕ Inscribir Nueva Mascota</a>"
  Write "</div>"
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod ConsultarPaseadores() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Consulta de Paseadores")
  Write "<div class='container'>"
  Write "<h1>🚶 Paseadores Registrados</h1>"
  
  // Usar el servicio de consultas para generar la tabla
  Write ##class(Demo.PETS.Services.QueryService).GenerateWalkersTableHTML()
  
  // Botones de navegación
  Write "<div style='margin-top: 20px;'>"
  Write "<a href='/csp/demo2/' class='btn-back'>🏠 Volver al inicio</a>"
  Write "<a href='/csp/demo2/paseadores' style='background:#f39c12; color:white; text-decoration:none; padding:10px 20px; border-radius:4px; margin-left:10px;'>➕ Inscribir Nuevo Paseador</a>"
  Write "</div>"
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

ClassMethod ConsultarDueños() As %Status
{
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Consulta de Dueños")
  Write "<div class='container'>"
  Write "<h1>👤 Dueños Registrados</h1>"
  
  // Generar tabla usando la clase Templates.Tables
  Write ##class(Demo.PETS.Templates.Tables).GenerateOwnersTable()
  
  // Botones de navegación
  Write "<div style='margin-top: 20px;'>"
  Write "<a href='/csp/demo2/' class='btn-back'>🏠 Volver al inicio</a>"
  Write "<a href='/csp/demo2/dueños' style='background:#8e44ad; color:white; text-decoration:none; padding:10px 20px; border-radius:4px; margin-left:10px;'>➕ Inscribir Nuevo Dueño</a>"
  Write "</div>"
  
  Write "</div>"
  Write ##class(Demo.PETS.Templates.Base).GenerateFooter()
  
  Return $$$OK
}

}
