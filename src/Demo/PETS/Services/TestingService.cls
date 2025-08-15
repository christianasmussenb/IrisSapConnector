/// TestingService - Handles automated testing functionality
Class Demo.PETS.Services.TestingService Extends Demo.PETS.Services.Base
{

/// Get test data for automated testing
ClassMethod GetTestData() As %DynamicObject
{
    Set testData = {}
    
    // Test owners data
    Set owners = []
    Set owner1 = {}
    Set owner1.rut = "19876543-2"
    Set owner1.nombre = "Laura Martínez"
    Set owner1.telefono = "555-1111"
    Set owner1.email = "laura@test.com"
    Set owner1.direccion = "Calle Test 123"
    Set owner1.mascotas = 1
    Do owners.%Push(owner1)
    
    Set owner2 = {}
    Set owner2.rut = "20123456-7"
    Set owner2.nombre = "Pedro González"
    Set owner2.telefono = "555-2222"
    Set owner2.email = "pedro@test.com"
    Set owner2.direccion = "Av. Prueba 456"
    Set owner2.mascotas = 2
    Do owners.%Push(owner2)
    
    Set testData.owners = owners
    
    // Test walkers data
    Set walkers = []
    Set walker1 = {}
    Set walker1.rut = "18765432-1"
    Set walker1.nombre = "Sofía López"
    Set walker1.telefono = "555-3333"
    Set walker1.email = "sofia@test.com"
    Set walker1.edad = 26
    Set walker1.experiencia = 2
    Set walker1.disponibilidad = "Tiempo completo"
    Set walker1.tarifa = 16.00
    Do walkers.%Push(walker1)
    
    Set walker2 = {}
    Set walker2.rut = "17654321-9"
    Set walker2.nombre = "Diego Morales"
    Set walker2.telefono = "555-4444"
    Set walker2.email = "diego@test.com"
    Set walker2.edad = 32
    Set walker2.experiencia = 4
    Set walker2.disponibilidad = "Mañanas"
    Set walker2.tarifa = 19.00
    Do walkers.%Push(walker2)
    
    Set testData.walkers = walkers
    
    // Test pets data
    Set pets = []
    Set pet1 = {}
    Set pet1.nombre = "Rocky"
    Set pet1.raza = "Pitbull"
    Set pet1.edad = 4
    Set pet1.peso = 30.5
    Set pet1.color = "Café"
    Set pet1."tamaño" = "Grande"
    Set pet1.temperamento = "Protector, Leal"
    Set pet1.observaciones = "Muy activo, necesita ejercicio diario"
    Do pets.%Push(pet1)
    
    Set pet2 = {}
    Set pet2.nombre = "Milo"
    Set pet2.raza = "Beagle"
    Set pet2.edad = 2
    Set pet2.peso = 15.0
    Set pet2.color = "Tricolor"
    Set pet2."tamaño" = "Mediano"
    Set pet2.temperamento = "Juguetón, Curioso"
    Set pet2.observaciones = "Le gusta explorar y seguir rastros"
    Do pets.%Push(pet2)
    
    Set testData.pets = pets
    
    Return testData
}

/// Generate JavaScript for automated testing
ClassMethod GenerateTestingJavaScript() As %String
{
    Set testData = ..GetTestData()
    
    Set js = "const testData = " _ testData.%ToJSON() _ ";" _ $c(13,10)
    Set js = js _ $c(13,10)
    Set js = js _ "let testResults = document.getElementById('test-results');" _ $c(13,10)
    Set js = js _ "let ownersCreated = [];" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Add result function
    Set js = js _ "function addResult(type, status, data, error = null) {" _ $c(13,10)
    Set js = js _ "  const result = document.createElement('div');" _ $c(13,10)
    Set js = js _ "  result.style.margin = '10px 0';" _ $c(13,10)
    Set js = js _ "  result.style.padding = '10px';" _ $c(13,10)
    Set js = js _ "  result.style.borderRadius = '5px';" _ $c(13,10)
    Set js = js _ "  if (status === 'success') {" _ $c(13,10)
    Set js = js _ "    result.style.background = '#d4edda'; result.style.color = '#155724'; result.style.border = '1px solid #c3e6cb';" _ $c(13,10)
    Set js = js _ "    result.innerHTML = `✅ ${type}: ${data.nombre || data.rut || 'Sin nombre'} registrado exitosamente (ID: ${data.id || 'N/A'})`;" _ $c(13,10)
    Set js = js _ "  } else {" _ $c(13,10)
    Set js = js _ "    result.style.background = '#f8d7da'; result.style.color = '#721c24'; result.style.border = '1px solid #f5c6cb';" _ $c(13,10)
    Set js = js _ "    result.innerHTML = `❌ ${type}: Error - ${error}`;" _ $c(13,10)
    Set js = js _ "  }" _ $c(13,10)
    Set js = js _ "  testResults.appendChild(result);" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Test owners function
    Set js = js _ "async function testOwners() {" _ $c(13,10)
    Set js = js _ "  addResult('INICIO', 'success', {nombre: 'Pruebas de Dueños'});" _ $c(13,10)
    Set js = js _ "  for (let owner of testData.owners) {" _ $c(13,10)
    Set js = js _ "    try {" _ $c(13,10)
    Set js = js _ "      const formData = new FormData();" _ $c(13,10)
    Set js = js _ "      Object.keys(owner).forEach(key => formData.append(key, owner[key]));" _ $c(13,10)
    Set js = js _ "      const response = await fetch('/csp/demo2/guardar-dueño', {method: 'POST', body: formData});" _ $c(13,10)
    Set js = js _ "      const result = await response.json();" _ $c(13,10)
    Set js = js _ "      if (result.error) { addResult('DUEÑO', 'error', owner, result.error); }" _ $c(13,10)
    Set js = js _ "      else { addResult('DUEÑO', 'success', result); ownersCreated.push(result.id); }" _ $c(13,10)
    Set js = js _ "    } catch (e) { addResult('DUEÑO', 'error', owner, e.message); }" _ $c(13,10)
    Set js = js _ "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
    Set js = js _ "  }" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Test walkers function
    Set js = js _ "async function testWalkers() {" _ $c(13,10)
    Set js = js _ "  addResult('INICIO', 'success', {nombre: 'Pruebas de Paseadores'});" _ $c(13,10)
    Set js = js _ "  for (let walker of testData.walkers) {" _ $c(13,10)
    Set js = js _ "    try {" _ $c(13,10)
    Set js = js _ "      const formData = new FormData();" _ $c(13,10)
    Set js = js _ "      Object.keys(walker).forEach(key => formData.append(key, walker[key]));" _ $c(13,10)
    Set js = js _ "      const response = await fetch('/csp/demo2/guardar-paseador', {method: 'POST', body: formData});" _ $c(13,10)
    Set js = js _ "      const result = await response.json();" _ $c(13,10)
    Set js = js _ "      if (result.error) { addResult('PASEADOR', 'error', walker, result.error); }" _ $c(13,10)
    Set js = js _ "      else { addResult('PASEADOR', 'success', result); }" _ $c(13,10)
    Set js = js _ "    } catch (e) { addResult('PASEADOR', 'error', walker, e.message); }" _ $c(13,10)
    Set js = js _ "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
    Set js = js _ "  }" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Test pets function
    Set js = js _ "async function testPets() {" _ $c(13,10)
    Set js = js _ "  addResult('INICIO', 'success', {nombre: 'Pruebas de Mascotas'});" _ $c(13,10)
    Set js = js _ "  for (let i = 0; i < testData.pets.length; i++) {" _ $c(13,10)
    Set js = js _ "    try {" _ $c(13,10)
    Set js = js _ "      const pet = testData.pets[i];" _ $c(13,10)
    Set js = js _ "      const ownerId = ownersCreated[i] || 1;" _ $c(13,10)
    Set js = js _ "      const formData = new FormData();" _ $c(13,10)
    Set js = js _ "      Object.keys(pet).forEach(key => formData.append(key, pet[key]));" _ $c(13,10)
    Set js = js _ "      formData.append('owner_id', ownerId);" _ $c(13,10)
    Set js = js _ "      const response = await fetch('/csp/demo2/guardar-mascota', {method: 'POST', body: formData});" _ $c(13,10)
    Set js = js _ "      const result = await response.json();" _ $c(13,10)
    Set js = js _ "      if (result.error) { addResult('MASCOTA', 'error', pet, result.error); }" _ $c(13,10)
    Set js = js _ "      else { addResult('MASCOTA', 'success', result); }" _ $c(13,10)
    Set js = js _ "    } catch (e) { addResult('MASCOTA', 'error', testData.pets[i], e.message); }" _ $c(13,10)
    Set js = js _ "    await new Promise(resolve => setTimeout(resolve, 500));" _ $c(13,10)
    Set js = js _ "  }" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Main test runner function
    Set js = js _ "async function runAllTests() {" _ $c(13,10)
    Set js = js _ "  document.getElementById('runTests').disabled = true;" _ $c(13,10)
    Set js = js _ "  document.getElementById('runTests').textContent = '⏳ Ejecutando pruebas...';" _ $c(13,10)
    Set js = js _ "  testResults.innerHTML = '<h2>📊 Resultados de las Pruebas:</h2>';" _ $c(13,10)
    Set js = js _ "  await testOwners();" _ $c(13,10)
    Set js = js _ "  await testWalkers();" _ $c(13,10)
    Set js = js _ "  await testPets();" _ $c(13,10)
    Set js = js _ "  addResult('FINALIZADO', 'success', {nombre: '¡Todas las pruebas completadas!'});" _ $c(13,10)
    Set js = js _ "  document.getElementById('runTests').disabled = false;" _ $c(13,10)
    Set js = js _ "  document.getElementById('runTests').textContent = '🔄 Ejecutar Pruebas Nuevamente';" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    
    Return js
}

/// Execute automated tests programmatically (server-side)
ClassMethod ExecuteAutomatedTests() As %DynamicObject
{
    Try {
        Set result = {}
        Set result.success = 1
        Set result.tests = []
        Set result.errors = []
        
        Set testData = ..GetTestData()
        
        // Test creating owners
        Set ownerIds = []
        Set ownerIterator = testData.owners.%GetIterator()
        While ownerIterator.%GetNext(,.owner) {
            Set createResult = ..CreateTestOwner(owner)
            If createResult.success {
                Do ownerIds.%Push(createResult.id)
                Set testInfo = {}
                Set testInfo.type = "Owner"
                Set testInfo.name = owner.nombre
                Set testInfo.status = "success"
                Do result.tests.%Push(testInfo)
            } Else {
                Do result.errors.%Push("Error creating owner " _ owner.nombre _ ": " _ createResult.error)
            }
        }
        
        // Test creating walkers
        Set walkerIterator = testData.walkers.%GetIterator()
        While walkerIterator.%GetNext(,.walker) {
            Set createResult = ..CreateTestWalker(walker)
            If createResult.success {
                Set testInfo = {}
                Set testInfo.type = "Walker"
                Set testInfo.name = walker.nombre
                Set testInfo.status = "success"
                Do result.tests.%Push(testInfo)
            } Else {
                Do result.errors.%Push("Error creating walker " _ walker.nombre _ ": " _ createResult.error)
            }
        }
        
        Set result.totalTests = result.tests.%Size()
        Set result.totalErrors = result.errors.%Size()
        
        Return result
        
    } Catch ex {
        Set errorResult = {}
        Set errorResult.success = 0
        Set errorResult.error = "Error durante pruebas automáticas: " _ ex.DisplayString()
        Return errorResult
    }
}

/// Create test owner
ClassMethod CreateTestOwner(ownerData As %DynamicObject) As %DynamicObject
{
    Try {
        Set owner = ##class(Demo.PETS.Owners).%New()
        Set owner.RUT = ownerData.rut
        Set owner.Name = ownerData.nombre
        Set owner.Phone = ownerData.telefono
        Set owner.Email = ownerData.email
        Set owner.Address = ownerData.direccion
        Set owner.NumberOfPets = ownerData.mascotas
        Set owner.Status = "Active"
        
        Set sc = owner.%Save()
        If $$$ISERR(sc) {
            Set result = {}
            Set result.success = 0
            Set result.error = $System.Status.GetErrorText(sc)
            Return result
        }
        
        Set result = {}
        Set result.success = 1
        Set result.id = owner.%Id()
        Return result
        
    } Catch ex {
        Set result = {}
        Set result.success = 0
        Set result.error = ex.DisplayString()
        Return result
    }
}

/// Create test walker
ClassMethod CreateTestWalker(walkerData As %DynamicObject) As %DynamicObject
{
    Try {
        Set walker = ##class(Demo.PETS.Walkers).%New()
        Set walker.RUT = walkerData.rut
        Set walker.Name = walkerData.nombre
        Set walker.Phone = walkerData.telefono
        Set walker.Email = walkerData.email
        Set walker.Age = walkerData.edad
        Set walker.Experience = walkerData.experiencia
        Set walker.Availability = walkerData.disponibilidad
        Set walker.HourlyRate = walkerData.tarifa
        Set walker.Status = "Available"
        
        Set sc = walker.%Save()
        If $$$ISERR(sc) {
            Set result = {}
            Set result.success = 0
            Set result.error = $System.Status.GetErrorText(sc)
            Return result
        }
        
        Set result = {}
        Set result.success = 1
        Set result.id = walker.%Id()
        Return result
        
    } Catch ex {
        Set result = {}
        Set result.success = 0
        Set result.error = ex.DisplayString()
        Return result
    }
}

}
