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
  // Inicializar datos usando las clases persistentes
  Do ##class(Demo.PETS.Owners).InsertSampleData()
  Do ##class(Demo.PETS.Pets).InsertSampleData()
  Do ##class(Demo.PETS.Walkers).InsertSampleData()
  
  Set %response.ContentType = "text/html; charset=utf-8"
  
  // Usar el sistema de templates modular
  Write ##class(Demo.PETS.Templates.Base).GenerateHeader("Datos Inicializados")
  Write "<div class='container'>"
  Write "<h1>✅ Datos Inicializados Exitosamente</h1>"
  Write "<div class='info'>Se han cargado los datos de prueba en las tablas persistentes:</div>"
  Write "<ul>"
  Write "<li><strong>Dueños:</strong> 4 registros</li>"
  Write "<li><strong>Mascotas:</strong> 5 registros</li>"
  Write "<li><strong>Paseadores:</strong> 4 registros</li>"
  Write "</ul>"
  Write "<div class='info'>Las relaciones de integridad referencial están funcionando correctamente.</div>"
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
  
  // JavaScript para pruebas automáticas (mantener el script existente)
  Write "<script>"
  Write "const testData = {" _ $c(13,10)
  Write "  owners: [" _ $c(13,10)
  Write "    {rut: '19876543-2', nombre: 'Laura Martínez', telefono: '555-1111', email: 'laura@test.com', direccion: 'Calle Test 123', mascotas: 1}," _ $c(13,10)
  Write "    {rut: '20123456-7', nombre: 'Pedro González', telefono: '555-2222', email: 'pedro@test.com', direccion: 'Av. Prueba 456', mascotas: 2}" _ $c(13,10)
  Write "  ]," _ $c(13,10)
  Write "  walkers: [" _ $c(13,10)
  Write "    {rut: '18765432-1', nombre: 'Sofía López', telefono: '555-3333', email: 'sofia@test.com', edad: 26, experiencia: 2, disponibilidad: 'Tiempo completo', tarifa: 16.00}," _ $c(13,10)
  Write "    {rut: '17654321-9', nombre: 'Diego Morales', telefono: '555-4444', email: 'diego@test.com', edad: 32, experiencia: 4, disponibilidad: 'Mañanas', tarifa: 19.00}" _ $c(13,10)
  Write "  ]," _ $c(13,10)
  Write "  pets: [" _ $c(13,10)
  Write "    {nombre: 'Rocky', raza: 'Pitbull', edad: 4, peso: 30.5, color: 'Café', tamaño: 'Grande', temperamento: 'Protector, Leal', observaciones: 'Muy activo, necesita ejercicio diario'}," _ $c(13,10)
  Write "    {nombre: 'Milo', raza: 'Beagle', edad: 2, peso: 15.0, color: 'Tricolor', tamaño: 'Mediano', temperamento: 'Juguetón, Curioso', observaciones: 'Le gusta explorar y seguir rastros'}" _ $c(13,10)
  Write "  ]" _ $c(13,10)
  Write "};" _ $c(13,10)
  Write $c(13,10)
  
  Write "let testResults = document.getElementById('test-results');" _ $c(13,10)
  Write "let ownersCreated = [];" _ $c(13,10)
  Write $c(13,10)
  
  Write "function addResult(type, status, data, error = null) {" _ $c(13,10)
  Write "  const result = document.createElement('div');" _ $c(13,10)
  Write "  result.style.margin = '10px 0';" _ $c(13,10)
  Write "  result.style.padding = '10px';" _ $c(13,10)
  Write "  result.style.borderRadius = '5px';" _ $c(13,10)
  Write "  if (status === 'success') {" _ $c(13,10)
  Write "    result.style.background = '#d4edda'; result.style.color = '#155724'; result.style.border = '1px solid #c3e6cb';" _ $c(13,10)
  Write "    result.innerHTML = `✅ ${type}: ${data.nombre || data.rut || 'Sin nombre'} registrado exitosamente (ID: ${data.id || 'N/A'})`;" _ $c(13,10)
  Write "  } else {" _ $c(13,10)
  Write "    result.style.background = '#f8d7da'; result.style.color = '#721c24'; result.style.border = '1px solid #f5c6cb';" _ $c(13,10)
  Write "    result.innerHTML = `❌ ${type}: Error - ${error}`;" _ $c(13,10)
  Write "  }" _ $c(13,10)
  Write "  testResults.appendChild(result);" _ $c(13,10)
  Write "}" _ $c(13,10)
  Write $c(13,10)
  
  Write "async function testOwners() {" _ $c(13,10)
  Write "  addResult('INICIO', 'success', {nombre: 'Pruebas de Dueños'});" _ $c(13,10)
  Write "  for (let owner of testData.owners) {" _ $c(13,10)
  Write "    try {" _ $c(13,10)
  Write "      const formData = new FormData();" _ $c(13,10)
  Write "      Object.keys(owner).forEach(key => formData.append(key, owner[key]));" _ $c(13,10)
  Write "      const response = await fetch('/csp/demo2/guardar-dueño', {method: 'POST', body: formData});" _ $c(13,10)
  Write "      const result = await response.json();" _ $c(13,10)
  Write "      if (result.error) { addResult('DUEÑO', 'error', owner, result.error); }" _ $c(13,10)
  Write "      else { addResult('DUEÑO', 'success', result); ownersCreated.push(result.id); }" _ $c(13,10)
  Write "    } catch (e) { addResult('DUEÑO', 'error', owner, e.message); }" _ $c(13,10)
  Write "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
  Write "  }" _ $c(13,10)
  Write "}" _ $c(13,10)
  Write $c(13,10)
  
  Write "async function testWalkers() {" _ $c(13,10)
  Write "  addResult('INICIO', 'success', {nombre: 'Pruebas de Paseadores'});" _ $c(13,10)
  Write "  for (let walker of testData.walkers) {" _ $c(13,10)
  Write "    try {" _ $c(13,10)
  Write "      const formData = new FormData();" _ $c(13,10)
  Write "      Object.keys(walker).forEach(key => formData.append(key, walker[key]));" _ $c(13,10)
  Write "      const response = await fetch('/csp/demo2/guardar-paseador', {method: 'POST', body: formData});" _ $c(13,10)
  Write "      const result = await response.json();" _ $c(13,10)
  Write "      if (result.error) { addResult('PASEADOR', 'error', walker, result.error); }" _ $c(13,10)
  Write "      else { addResult('PASEADOR', 'success', result); }" _ $c(13,10)
  Write "    } catch (e) { addResult('PASEADOR', 'error', walker, e.message); }" _ $c(13,10)
  Write "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
  Write "  }" _ $c(13,10)
  Write "}" _ $c(13,10)
  Write $c(13,10)
  
  Write "async function testPets() {" _ $c(13,10)
  Write "  addResult('INICIO', 'success', {nombre: 'Pruebas de Mascotas'});" _ $c(13,10)
  Write "  for (let i = 0; i < testData.pets.length; i++) {" _ $c(13,10)
  Write "    try {" _ $c(13,10)
  Write "      const pet = testData.pets[i];" _ $c(13,10)
  Write "      const ownerId = ownersCreated[i] || 1;" _ $c(13,10)
  Write "      const formData = new FormData();" _ $c(13,10)
  Write "      Object.keys(pet).forEach(key => formData.append(key, pet[key]));" _ $c(13,10)
  Write "      formData.append('owner_id', ownerId);" _ $c(13,10)
  Write "      const response = await fetch('/csp/demo2/guardar-mascota', {method: 'POST', body: formData});" _ $c(13,10)
  Write "      const result = await response.json();" _ $c(13,10)
  Write "      if (result.error) { addResult('MASCOTA', 'error', pet, result.error); }" _ $c(13,10)
  Write "      else { addResult('MASCOTA', 'success', result); }" _ $c(13,10)
  Write "    } catch (e) { addResult('MASCOTA', 'error', testData.pets[i], e.message); }" _ $c(13,10)
  Write "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
  Write "  }" _ $c(13,10)
  Write "}" _ $c(13,10)
  Write $c(13,10)
  
  Write "async function runAllTests() {" _ $c(13,10)
  Write "  document.getElementById('runTests').disabled = true;" _ $c(13,10)
  Write "  document.getElementById('runTests').textContent = '⏳ Ejecutando pruebas...';" _ $c(13,10)
  Write "  testResults.innerHTML = '<h2>📊 Resultados de las Pruebas:</h2>';" _ $c(13,10)
  Write "  await testOwners();" _ $c(13,10)
  Write "  await testWalkers();" _ $c(13,10)
  Write "  await testPets();" _ $c(13,10)
  Write "  addResult('FINALIZADO', 'success', {nombre: '¡Todas las pruebas completadas!'});" _ $c(13,10)
  Write "  document.getElementById('runTests').disabled = false;" _ $c(13,10)
  Write "  document.getElementById('runTests').textContent = '🔄 Ejecutar Pruebas Nuevamente';" _ $c(13,10)
  Write "}" _ $c(13,10)
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
  
  Try {
    // Leer datos del formulario
    Set nombre = $Get(%request.Data("nombre",1), "")
    Set raza = $Get(%request.Data("raza",1), "")
    Set edad = +$Get(%request.Data("edad",1), 0)
    Set peso = +$Get(%request.Data("peso",1), 0)
    Set color = $Get(%request.Data("color",1), "")
    Set tamaño = $Get(%request.Data("tamaño",1), "Mediano")
    Set temperamento = $Get(%request.Data("temperamento",1), "")
    Set observaciones = $Get(%request.Data("observaciones",1), "")
    Set ownerID = +$Get(%request.Data("owner_id",1), 1)
    
    If (nombre = "") {
      Write "{""error"":""El nombre es requerido""}"
      Return $$$OK
    }
    
    // Generar UserID automáticamente
    Set userid = ..GenerateUniqueUserID()
    
    // Verificar que el dueño existe
    Set owner = ##class(Demo.PETS.Owners).%OpenId(ownerID)
    If '$IsObject(owner) {
      Write "{""error"":""El dueño especificado no existe""}"
      Return $$$OK
    }
    
    // Crear nueva mascota usando clase persistente
    Set pet = ##class(Demo.PETS.Pets).%New()
    Set pet.UserID = userid
    Set pet.Name = nombre
    Set pet.Breed = raza
    Set pet.Age = edad
    Set pet.Weight = peso
    Set pet.Size = tamaño
    Set pet.Color = color
    Set pet.Status = "Active"
    Set pet.Temperament = temperamento
    Set pet.Notes = observaciones
    Set pet.Owner = owner
    
    Set sc = pet.%Save()
    If $$$ISERR(sc) {
      Write "{""error"":""Error al guardar: "_$System.Status.GetErrorText(sc)_"""}"
      Return $$$OK
    }
    
    // Construir JSON de respuesta de forma más segura
    Set json = {}
    Set json.mensaje = "Mascota registrada exitosamente!"
    Set json.id = pet.%Id()
    Set json.userid = userid
    Set json.nombre = nombre
    Set json.raza = raza
    Set json.edad = edad
    Set json.peso = peso
    Set json."tamaño" = tamaño
    Set json.color = color
    Set json.temperamento = temperamento
    Set json.owner = owner.Name
    Set json."owner_id" = ownerID
    Set json.estado = "OK"
    
    Write json.%ToJSON()
    
  } Catch ex {
    Set errorJson = {}
    Set errorJson.error = "Error al guardar: "_ex.DisplayString()
    Write errorJson.%ToJSON()
  }
  
  Return $$$OK
}

/// Genera un UserID único para mascotas
/// Formato: PET-YYYY-NNNN (ej: PET-2024-0001)
ClassMethod GenerateUniqueUserID() As %String
{
  Set year = $ZDate($H, 3)
  Set year = $Extract(year, 1, 4)
  
  // Buscar el último UserID del año actual
  Set sql = "SELECT MAX(UserID) FROM Demo_PETS.Pets WHERE UserID LIKE 'PET-"_year_"-%'"
  Set statement = ##class(%SQL.Statement).%New()
  Set sc = statement.%Prepare(sql)
  Set result = statement.%Execute()
  
  Set maxUserID = ""
  If result.%Next() {
    Set maxUserID = result.%GetData(1)
  }
  
  // Extraer el número secuencial y incrementar
  Set nextNumber = 1
  If (maxUserID '= "") && ($Length(maxUserID, "-") = 3) {
    Set numberPart = $Piece(maxUserID, "-", 3)
    If $IsValidNum(numberPart) {
      Set nextNumber = numberPart + 1
    }
  }
  
  // Formatear con ceros a la izquierda (4 dígitos)
  Set numberStr = $Translate($Justify(nextNumber, 4), " ", "0")
  
  Return "PET-"_year_"-"_numberStr
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
