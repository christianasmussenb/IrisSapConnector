/// Inicializar configuraciones por defecto del sistema PETS
/// Crea configuraciones básicas necesarias para el funcionamiento
Class Demo.PETS.Scripts.InitSettings
{

/// Inicializar todas las configuraciones por defecto
ClassMethod InitializeAll() As %Status
{
    Try {
        Do ..InitializeOperatingHours()
        Do ..InitializeSystemLimits()
        
        Write "✅ Configuraciones por defecto inicializadas correctamente",!
        Return $$$OK
        
    } Catch ex {
        Write "❌ Error inicializando configuraciones: "_ex.DisplayString(),!
        Return ex.AsStatus()
    }
}

/// Inicializar horarios operativos por defecto (6:00 AM - 8:00 PM)
ClassMethod InitializeOperatingHours() As %Status
{
    Try {
        // Crear configuración de horarios si no existe
        Set setting = ##class(Demo.PETS.Settings).%OpenId("operating_hours")
        If '$IsObject(setting) {
            Set setting = ##class(Demo.PETS.Settings).%New()
            Set setting.Category = "operating_hours"
            Set setting.SettingKey = "daily_schedule"
            Set setting.SettingValue = "{""startTime"":""06:00"",""endTime"":""20:00""}"
            Set setting.Description = "Horarios operativos diarios del servicio"
            Do setting.%Save()
            Write "Horarios operativos configurados: 06:00 - 20:00",!
        }
        
        Return $$$OK
        
    } Catch ex {
        Write "Error configurando horarios: "_ex.DisplayString(),!
        Return ex.AsStatus()
    }
}

/// Inicializar límites del sistema por defecto
ClassMethod InitializeSystemLimits() As %Status
{
    Try {
        // Crear configuración de límites si no existe
        Set setting = ##class(Demo.PETS.Settings).%OpenId("system_limits")
        If '$IsObject(setting) {
            Set setting = ##class(Demo.PETS.Settings).%New()
            Set setting.Category = "system_limits"
            Set setting.SettingKey = "capacity_limits"
            Set setting.SettingValue = "{""maxPetsPerWalk"":5,""maxPetsPerSlot"":5,""maxWalkersPerSlot"":3}"
            Set setting.Description = "Límites de capacidad del sistema"
            Do setting.%Save()
            Write "Límites del sistema configurados: max 5 mascotas por turno",!
        }
        
        Return $$$OK
        
    } Catch ex {
        Write "Error configurando límites: "_ex.DisplayString(),!
        Return ex.AsStatus()
    }
}

}