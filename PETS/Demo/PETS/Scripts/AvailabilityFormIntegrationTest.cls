/// Script de prueba integral para el formulario de disponibilidad
/// Prueba el flujo completo desde validación hasta persistencia
Class Demo.PETS.Scripts.AvailabilityFormIntegrationTest
{

/// Ejecuta pruebas integrales del formulario de disponibilidad
ClassMethod RunIntegrationTests() As %Status
{
    Write "🧪 === PRUEBAS INTEGRALES FORMULARIO DISPONIBILIDAD ===",!,!
    
    // 1. Verificar servicios dependientes
    Write "📋 1. VERIFICANDO SERVICIOS DEPENDIENTES...",!
    Do ..TestDependencies()
    
    Write !
    
    // 2. Probar parsing de fecha/hora
    Write "📋 2. PROBANDO PARSING FECHA/HORA...",!
    Do ..TestParsing()
    
    Write !
    
    // 3. Probar validación de negocio
    Write "📋 3. PROBANDO VALIDACIÓN DE NEGOCIO...",!  
    Do ..TestBusinessValidation()
    
    Write !
    
    // 4. Probar persistencia completa
    Write "📋 4. PROBANDO PERSISTENCIA COMPLETA...",!
    Do ..TestCompletePersistence()
    
    Write !
    Write "🏁 === PRUEBAS COMPLETADAS ===",!
    
    Return $$$OK
}

/// Verifica que los servicios dependientes están disponibles
ClassMethod TestDependencies() As %Status
{
    // Test ConfigService
    Try {
        Set limits = ##class(Demo.PETS.Services.ConfigService).GetSystemLimits()
        Write "   ✅ ConfigService: Límites obtenidos (maxPets: " _ limits.maxPetsPerWalk _ ")",!
    } Catch ex {
        Write "   ❌ ConfigService: " _ ex.DisplayString(),!
    }
    
    // Test SchedulingService  
    Try {
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(1, $HOROLOG+1, 32400, 43200, 3)
        Write "   ✅ SchedulingService: Validación funcional",!
    } Catch ex {
        Write "   ❌ SchedulingService: " _ ex.DisplayString(),!
    }
    
    // Test Walker existe
    Try {
        Set walker = ##class(Demo.PETS.Walkers).%OpenId(1)
        If $IsObject(walker) {
            Write "   ✅ Walker ID 1: " _ walker.Name,!
        } Else {
            Write "   ⚠️  Walker ID 1: No encontrado, creando...",!
            Set walker = ##class(Demo.PETS.Walkers).%New()
            Set walker.Name = "Tester Walker"
            Set walker.Experience = "Intermedio"  
            Set walker.HourlyRate = 25.00
            Do walker.%Save()
            Write "   ✅ Walker creado: " _ walker.Name,!
        }
    } Catch ex {
        Write "   ❌ Walker test: " _ ex.DisplayString(),!
    }
    
    Return $$$OK
}

/// Prueba el parsing de fecha y hora
ClassMethod TestParsing() As %Status
{
    // Test parsing fecha futura YYYY-MM-DD
    Set futureDate = $ZDATE($HOROLOG + 7, 3)  // 7 días adelante
    Set parsed = ..ParseDateLikeForm(futureDate)
    Write "   📅 Fecha YYYY-MM-DD (" _ futureDate _ "): "
    If parsed'="" {
        Write "✅ " _ $ZDATE(parsed, 1),!
    } Else {
        Write "❌ No parsed",!
    }
    
    // Test parsing fecha DD/MM/YYYY  
    Set ddmmDate = "25/09/2025"
    Set parsed = ..ParseDateLikeForm(ddmmDate)
    Write "   📅 Fecha DD/MM/YYYY (" _ ddmmDate _ "): "
    If parsed'="" {
        Write "✅ " _ $ZDATE(parsed, 1),!
    } Else {
        Write "❌ No parsed",!
    }
    
    // Test parsing hora
    Set timeStr = "09:30"
    Set seconds = ..ParseTimeLikeForm(timeStr)
    Write "   🕘 Hora HH:MM (" _ timeStr _ "): "
    If seconds'="" {
        Write "✅ " _ seconds _ " segundos (" _ $ZTIME(seconds) _ ")",!
    } Else {
        Write "❌ No parsed",!
    }
    
    // Test validación hora inicio < fin
    Set start = ..ParseTimeLikeForm("09:00")
    Set end = ..ParseTimeLikeForm("12:00")
    Write "   ⏰ Validación 09:00 < 12:00: "
    If (start < end) {
        Write "✅ Correcto (" _ start _ " < " _ end _ ")",!
    } Else {
        Write "❌ Incorrecto (" _ start _ " >= " _ end _ ")",!
    }
    
    Return $$$OK
}

/// Prueba validación de reglas de negocio
ClassMethod TestBusinessValidation() As %Status
{
    Set walkerId = 1
    Set testDate = $HOROLOG + 3  // 3 días adelante
    Set startTime = 9*3600       // 09:00
    Set endTime = 12*3600        // 12:00 
    Set maxPets = 3
    
    Write "   🔍 Validando slot walkerId:" _ walkerId _ ", fecha:" _ $ZDATE(testDate,1) _ ", 09:00-12:00, 3 mascotas...",!
    
    Try {
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, testDate, startTime, endTime, maxPets)
        
        If validation.isValid {
            Write "   ✅ Validación exitosa - Slot permitido",!
        } Else {
            Write "   ❌ Validación falló:",!
            For i=0:1:validation.errors.%Size()-1 {
                Write "      - " _ validation.errors.%Get(i),!
            }
        }
    } Catch ex {
        Write "   ❌ Excepción en validación: " _ ex.DisplayString(),!
    }
    
    Return $$$OK
}

/// Prueba el proceso completo de persistencia
ClassMethod TestCompletePersistence() As %Status
{
    Set walkerId = 1
    Set testDate = $HOROLOG + 5  // 5 días adelante para evitar conflictos
    Set startTime = 14*3600      // 14:00 
    Set endTime = 17*3600        // 17:00
    Set maxPets = 2
    Set notes = "Prueba integración - " _ $ZDATETIME($HOROLOG,3)
    
    Write "   💾 Creando availability completa...",!
    Write "      Walker: " _ walkerId _ ", Fecha: " _ $ZDATE(testDate,1) _ ", 14:00-17:00, 2 mascotas",!
    
    Try {
        // Paso 1: Validación previa
        Set validation = ##class(Demo.PETS.Services.SchedulingService).ValidateAvailabilitySlot(walkerId, testDate, startTime, endTime, maxPets)
        
        If 'validation.isValid {
            Write "   ❌ Pre-validación falló:",!
            For i=0:1:validation.errors.%Size()-1 {
                Write "      - " _ validation.errors.%Get(i),!
            }
            Return $$$ERROR($$$GeneralError, "Validation failed")
        }
        
        Write "   ✅ Pre-validación OK",!
        
        // Paso 2: Crear objeto
        Set avail = ##class(Demo.PETS.Availability).%New()
        Set avail.Walker = ##class(Demo.PETS.Walkers).%OpenId(walkerId)
        Set avail.AvailableDate = testDate
        Set avail.StartTime = startTime
        Set avail.EndTime = endTime  
        Set avail.MaxPets = maxPets
        Set avail.CurrentBookings = 0
        Set avail.Notes = notes
        Set avail.IsActive = 1
        
        // Paso 3: Guardar
        Set status = avail.%Save()
        
        If $$$ISOK(status) {
            Set savedId = avail.%Id()
            Write "   ✅ Guardado exitoso - ID: " _ savedId,!
            
            // Paso 4: Verificar persistencia
            Set retrieved = ##class(Demo.PETS.Availability).%OpenId(savedId)
            If $IsObject(retrieved) {
                Write "   ✅ Verificación OK:",!
                Write "      - Fecha: " _ $ZDATE(retrieved.AvailableDate, 1),!
                Write "      - Horario: " _ $ZTIME(retrieved.StartTime) _ " - " _ $ZTIME(retrieved.EndTime),!
                Write "      - Mascotas: " _ retrieved.MaxPets,!
                Write "      - Notas: " _ retrieved.Notes,!
                
                // Paso 5: Limpiar (eliminar prueba)
                Do ##class(Demo.PETS.Availability).%DeleteId(savedId)
                Write "   🧹 Datos de prueba eliminados",!
                
                Write "   🎉 PRUEBA INTEGRAL COMPLETA - TODO OK",!
                
            } Else {
                Write "   ❌ No se pudo recuperar el objeto guardado",!
            }
            
        } Else {
            Write "   ❌ Error al guardar: " _ $SYSTEM.Status.GetOneErrorText(status),!
        }
        
    } Catch ex {
        Write "   ❌ Excepción: " _ ex.DisplayString(),!
    }
    
    Return $$$OK
}

/// Simula parsing de fecha como en AvailabilityForm
ClassMethod ParseDateLikeForm(dateStr As %String) As %String
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

/// Simula parsing de hora como en AvailabilityForm  
ClassMethod ParseTimeLikeForm(timeStr As %String) As %Integer
{
    Set timeSeconds = ""
    If timeStr'="" {
        Set h=+$PIECE(timeStr,":",1), m=+$PIECE(timeStr,":",2), s=+$PIECE(timeStr,":",3)
        If s="" Set s=0
        Set timeSeconds = (h*3600)+(m*60)+s
    }
    Return timeSeconds
}

/// Método rápido para ejecutar solo pruebas básicas
ClassMethod QuickTest() As %Status
{
    Write "⚡ QUICK TEST - Formulario Disponibilidad",!,!
    
    // Solo las pruebas esenciales
    Set results = ##class(Demo.PETS.Services.AvailabilityFormTestService).RunAllTests()
    
    Write "📊 RESULTADOS:",!
    Write "   Total: " _ results.summary.total _ " pruebas",!
    Write "   Exitosas: " _ results.summary.passed,!  
    Write "   Fallidas: " _ results.summary.failed,!
    Write "   Éxito: " _ results.summary.successRate,!
    
    If results.summary.failed > 0 {
        Write !,"❌ FALLOS DETECTADOS:",!
        For i=0:1:results.testSuites.%Size()-1 {
            Set suite = results.testSuites.%Get(i)
            For j=0:1:suite.tests.%Size()-1 {
                Set test = suite.tests.%Get(j)
                If 'test.passed {
                    Write "   - " _ suite.testName _ ": " _ test.name,!
                    Write "     " _ test.%Get("details", "No details"),!
                }
            }
        }
    } Else {
        Write !,"🎉 TODAS LAS PRUEBAS PASARON!",!
    }
    
    Return $$$OK
}

}