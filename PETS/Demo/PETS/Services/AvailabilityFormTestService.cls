/// Servicio de pruebas unitarias para AvailabilityForm
/// Prueba parsing de fecha/hora y validaciones
Class Demo.PETS.Services.AvailabilityFormTestService Extends Demo.PETS.Services.Base
{

/// Pruebas unitarias para parsing de fecha
ClassMethod TestDateParsing() As %DynamicObject
{
    Set results = {}
    Set results.testName = "Date Parsing Tests"
    Set results.tests = []
    
    // Test 1: Fecha futura YYYY-MM-DD
    Set test1 = {}
    Set test1.name = "Future date YYYY-MM-DD format"
    Set futureDate = $ZDATE($HOROLOG + 7, 3)  // 7 días adelante
    Set test1.input = futureDate
    Set test1.expected = $ZDATEH(futureDate, 3)  // YYYY-MM-DD format
    Set test1.result = ..ParseDateString(futureDate)
    Set test1.passed = (test1.result = test1.expected)
    Do results.tests.%Push(test1)
    
    // Test 2: Fecha futura DD/MM/YYYY
    Set test2 = {}
    Set test2.name = "Future date DD/MM/YYYY format"
    Set futureStr = "25/09/2025"  // 10 días adelante aprox
    Set test2.input = futureStr
    // Convertir manualmente para comparar
    Set y = 2025, m = 9, d = 25
    Set us = m_"/"_d_"/"_y
    Set test2.expected = $ZDATEH(us, 1)
    Set test2.result = ..ParseDateString(futureStr)
    Set test2.passed = (test2.result = test2.expected)
    Do results.tests.%Push(test2)
    
    // Test 3: Fecha inválida
    Set test3 = {}
    Set test3.name = "Invalid date"
    Set test3.input = "invalid-date"
    Set test3.expected = ""
    Set test3.result = ..ParseDateString("invalid-date")
    Set test3.passed = (test3.result = test3.expected)
    Do results.tests.%Push(test3)
    
    Return results
}

/// Pruebas unitarias para parsing de hora
ClassMethod TestTimeParsing() As %DynamicObject
{
    Set results = {}
    Set results.testName = "Time Parsing Tests"
    Set results.tests = []
    
    // Test 1: Hora válida HH:MM
    Set test1 = {}
    Set test1.name = "Valid time HH:MM"
    Set test1.input = "09:00"
    Set test1.expected = (9*3600) + (0*60) + 0  // 32400 segundos
    Set test1.result = ..ParseTimeString("09:00")
    Set test1.passed = (test1.result = test1.expected)
    Do results.tests.%Push(test1)
    
    // Test 2: Hora con segundos HH:MM:SS
    Set test2 = {}
    Set test2.name = "Valid time HH:MM:SS"
    Set test2.input = "14:30:15"
    Set test2.expected = (14*3600) + (30*60) + 15  // 52215 segundos
    Set test2.result = ..ParseTimeString("14:30:15")
    Set test2.passed = (test2.result = test2.expected)
    Do results.tests.%Push(test2)
    
    // Test 3: Comparación inicio < fin
    Set test3 = {}
    Set test3.name = "Start time before end time"
    Set start = ..ParseTimeString("09:00")  // 32400
    Set end = ..ParseTimeString("12:00")    // 43200
    Set test3.input = "start: 09:00, end: 12:00"
    Set test3.expected = 1  // true
    Set test3.result = (start < end)
    Set test3.passed = (test3.result = test3.expected)
    Do results.tests.%Push(test3)
    
    // Test 4: Comparación inicio >= fin (error)
    Set test4 = {}
    Set test4.name = "Start time after end time (should fail)"
    Set start = ..ParseTimeString("15:00")  // 54000
    Set end = ..ParseTimeString("12:00")    // 43200
    Set test4.input = "start: 15:00, end: 12:00"
    Set test4.expected = 0  // false (error case)
    Set test4.result = (start < end)
    Set test4.passed = (test4.result = test4.expected)
    Do results.tests.%Push(test4)
    
    Return results
}

/// Simula el parsing de fecha como en AvailabilityForm
ClassMethod ParseDateString(dateStr As %String) As %String
{
    Set date = ""
    If dateStr'="" {
        Set y="",m="",d="",us=""
        If dateStr["-" {
            Set y=$PIECE(dateStr,"-",1), m=$PIECE(dateStr,"-",2), d=$PIECE(dateStr,"-",3)
        } ElseIf dateStr["/" {
            Set d=$PIECE(dateStr,"/",1), m=$PIECE(dateStr,"/",2), y=$PIECE(dateStr,"/",3)
        }
        If (y'="")&(m'="")&(d'="") {
            Set us=m_"/"_d_"/"_y
            Set date=$ZDATEH(us,1)
        }
    }
    Return date
}

/// Simula el parsing de hora como en AvailabilityForm
ClassMethod ParseTimeString(timeStr As %String) As %Integer
{
    Set timeSeconds = ""
    If timeStr'="" {
        Set h=+$PIECE(timeStr,":",1), m=+$PIECE(timeStr,":",2), s=+$PIECE(timeStr,":",3)
        If s="" Set s=0
        Set timeSeconds = (h*3600)+(m*60)+s
    }
    Return timeSeconds
}

/// Prueba integral del flujo completo
ClassMethod TestCompleteAvailabilityFlow() As %DynamicObject
{
    Set results = {}
    Set results.testName = "Complete Availability Flow Test"
    Set results.tests = []
    
    // Preparar datos de prueba
    Set walkerId = 1
    Set testDate = $ZDATEH("10/01/2025", 1)  // Fecha futura
    Set startTime = (9*3600)  // 09:00
    Set endTime = (12*3600)   // 12:00
    Set maxPets = 3
    
    // Test 1: Validar disponibilidad de slot
    Set test1 = {}
    Set test1.name = "SchedulingService validation"
    Try {
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, testDate, startTime, endTime, maxPets)
        Set test1.result = validation.%Get("isValid", 0)  // Usar %Get en lugar de $GET
        Set test1.passed = test1.result
        Set test1.details = "Validation passed: " _ test1.result
        If 'test1.result {
            Do test1.%Set("errors", validation.%Get("errors", ""))  // Usar %Get y %Set
        }
    } Catch ex {
        Set test1.result = 0
        Set test1.passed = 0
        Set test1.details = "Exception: " _ ex.DisplayString()
    }
    Do results.tests.%Push(test1)
    
    // Test 2: Crear y guardar availability
    Set test2 = {}
    Set test2.name = "Create and save availability"
    Try {
        Set avail = ##class(Demo.PETS.Availability).%New()
        Set avail.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
        Set avail.AvailableDate = testDate
        Set avail.StartTime = startTime
        Set avail.EndTime = endTime
        Set avail.MaxPets = maxPets
        Set avail.CurrentBookings = 0
        Set avail.IsActive = 1
        
        Set status = avail.%Save()
        Set test2.result = $$$ISOK(status)
        Set test2.passed = test2.result
        If test2.result {
            Set test2.details = "Availability saved with ID: " _ avail.%Id()
            Do test2.%Set("savedId", avail.%Id())
        } Else {
            Set test2.details = "Save failed: " _ $SYSTEM.Status.GetOneErrorText(status)
        }
    } Catch ex {
        Set test2.result = 0
        Set test2.passed = 0
        Set test2.details = "Exception: " _ ex.DisplayString()
    }
    Do results.tests.%Push(test2)
    
    // Test 3: Verificar que se guardó correctamente
    Set savedId = test2.%Get("savedId", "")
    If savedId '= "" {
        Set test3 = {}
        Set test3.name = "Verify saved availability"
        Try {
            Set saved = ##class(Demo.PETS.Availability).%OpenId(savedId)
            Set test3.result = $IsObject(saved)
            Set test3.passed = test3.result
            If test3.result {
                Set test3.details = "Found saved availability - Date: " _ $ZDATE(saved.AvailableDate, 3) _ 
                                   ", Start: " _ $ZTIME(saved.StartTime) _ ", End: " _ $ZTIME(saved.EndTime)
            } Else {
                Set test3.details = "Saved availability not found"
            }
            
            // Limpiar datos de prueba
            If $IsObject(saved) Do saved.%DeleteId(savedId)
            
        } Catch ex {
            Set test3.result = 0
            Set test3.passed = 0
            Set test3.details = "Exception: " _ ex.DisplayString()
        }
        Do results.tests.%Push(test3)
    }
    
    Return results
}

/// Ejecuta todas las pruebas
ClassMethod RunAllTests() As %DynamicObject
{
    Set allResults = {}
    Set allResults.timestamp = $ZDATETIME($HOROLOG, 3)
    Set allResults.testSuites = []
    
    // Ejecutar suites de pruebas
    Do allResults.testSuites.%Push(..TestDateParsing())
    Do allResults.testSuites.%Push(..TestTimeParsing())
    Do allResults.testSuites.%Push(..TestCompleteAvailabilityFlow())
    
    // Calcular estadísticas
    Set totalTests = 0
    Set passedTests = 0
    
    For i=0:1:allResults.testSuites.%Size()-1 {
        Set suite = allResults.testSuites.%Get(i)
        For j=0:1:suite.tests.%Size()-1 {
            Set test = suite.tests.%Get(j)
            Set totalTests = totalTests + 1
            If test.passed Set passedTests = passedTests + 1
        }
    }
    
    Set allResults.summary = {}
    Set allResults.summary.total = totalTests
    Set allResults.summary.passed = passedTests
    Set allResults.summary.failed = totalTests - passedTests
    Set allResults.summary.successRate = $FNUMBER((passedTests/totalTests)*100, "", 2) _ "%"
    
    Return allResults
}

}