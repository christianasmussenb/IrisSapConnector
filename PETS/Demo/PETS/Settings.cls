/// Configuraciones globales del sistema de programación de paseos
/// Permite configurar parámetros operativos de manera centralizada
Class Demo.PETS.Settings Extends %Persistent
{

/// Clave única de la configuración
Property SettingKey As %String(MAXLEN = 100) [ Required ];

/// Valor de la configuración
Property SettingValue As %String(MAXLEN = 500) [ Required ];

/// Tipo de dato del valor (TIME, INTEGER, STRING, BOOLEAN, DECIMAL)
Property SettingType As %String(VALUELIST = ",TIME,INTEGER,STRING,BOOLEAN,DECIMAL") [ Required ];

/// Descripción de la configuración
Property Description As %String(MAXLEN = 1000);

/// Categoría de la configuración para organización
Property Category As %String(MAXLEN = 50) [ InitialExpression = "GENERAL" ];

/// Si la configuración es editable por usuarios
Property IsEditable As %Boolean [ InitialExpression = 1 ];

/// Valor por defecto de la configuración
Property DefaultValue As %String(MAXLEN = 500);

/// Fecha de creación
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Fecha de última actualización
Property UpdatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)} ];

/// Índice único en SettingKey
Index SettingKeyIdx On SettingKey [ Unique ];

/// Índice por categoría para consultas rápidas
Index CategoryIdx On Category;

/// Método para obtener el valor de una configuración
ClassMethod GetSetting(key As %String) As %String
{
    Set setting = ..SettingKeyIdxOpen(key)
    If $IsObject(setting) {
        Quit setting.SettingValue
    }
    Quit ""
}

/// Método para establecer el valor de una configuración
ClassMethod SetSetting(key As %String, value As %String, type As %String = "STRING", description As %String = "", category As %String = "GENERAL") As %Status
{
    Set sc = $$$OK
    Try {
        Set setting = ..SettingKeyIdxOpen(key)
        If '$IsObject(setting) {
            Set setting = ..%New()
            Set setting.SettingKey = key
            Set setting.CreatedAt = $ZDATETIME($HOROLOG,3)
        }
        
        Set setting.SettingValue = value
        Set setting.SettingType = type
        Set setting.Description = description
        Set setting.Category = category
        Set setting.UpdatedAt = $ZDATETIME($HOROLOG,3)
        
        Set sc = setting.%Save()
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

/// Método para validar un valor según su tipo
ClassMethod ValidateValue(value As %String, type As %String) As %Boolean
{
    If type = "TIME" {
        // Validar formato HH:MM:SS
        If $MATCH(value, "^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$") {
            Quit 1
        }
    } ElseIf type = "INTEGER" {
        // Validar que sea un número entero
        If +value = value && (value '[ ".") {
            Quit 1
        }
    } ElseIf type = "DECIMAL" {
        // Validar que sea un número decimal
        If +value = value {
            Quit 1
        }
    } ElseIf type = "BOOLEAN" {
        // Validar que sea 0 o 1
        If (value = "0") || (value = "1") {
            Quit 1
        }
    } ElseIf type = "STRING" {
        // STRING siempre es válido
        Quit 1
    }
    Quit 0
}

/// Método para inicializar configuraciones por defecto del sistema
ClassMethod InitializeDefaultSettings() As %Status
{
    Set sc = $$$OK
    Try {
        // Horarios operativos
        Do ..SetSetting("OPERATING_START_TIME", "07:00:00", "TIME", "Hora de inicio de operaciones diarias", "SCHEDULING")
        Do ..SetSetting("OPERATING_END_TIME", "23:00:00", "TIME", "Hora de fin de operaciones diarias", "SCHEDULING")
        Do ..SetSetting("TIME_SLOT_DURATION", "60", "INTEGER", "Duración de cada slot en minutos", "SCHEDULING")
        
        // Límites del sistema
        Do ..SetSetting("MAX_PETS_PER_SLOT", "5", "INTEGER", "Máximo número de mascotas por walker por slot", "LIMITS")
        Do ..SetSetting("MAX_BOOKING_DAYS_AHEAD", "30", "INTEGER", "Máximo días en el futuro para reservar", "LIMITS")
        Do ..SetSetting("MIN_BOOKING_HOURS_AHEAD", "2", "INTEGER", "Mínimo horas de anticipación para reservar", "LIMITS")
        
        // Configuraciones financieras
        Do ..SetSetting("DEFAULT_WALK_PRICE", "15000", "DECIMAL", "Precio base por paseo en pesos chilenos", "PRICING")
        Do ..SetSetting("SYSTEM_COMMISSION_PERCENT", "10", "DECIMAL", "Porcentaje de comisión del sistema", "PRICING")
        
        // Configuraciones de cancelación
        Do ..SetSetting("CANCELLATION_HOURS_LIMIT", "24", "INTEGER", "Horas límite para cancelar sin penalización", "CANCELLATION")
        Do ..SetSetting("CANCELLATION_FEE_PERCENT", "20", "DECIMAL", "Porcentaje de penalización por cancelación tardía", "CANCELLATION")
        
        // Configuraciones de notificaciones
        Do ..SetSetting("SEND_EMAIL_NOTIFICATIONS", "1", "BOOLEAN", "Enviar notificaciones por email", "NOTIFICATIONS")
        Do ..SetSetting("REMINDER_HOURS_BEFORE", "24", "INTEGER", "Horas antes para enviar recordatorio", "NOTIFICATIONS")
        
        Write "✅ Configuraciones por defecto inicializadas correctamente", !
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Write "❌ Error inicializando configuraciones: ", ex.DisplayString(), !
    }
    Quit sc
}

/// Método para obtener todas las configuraciones de una categoría
ClassMethod GetSettingsByCategory(category As %String) As %DynamicObject
{
    Set result = {}
    Set sql = "SELECT SettingKey, SettingValue, SettingType, Description FROM Demo_PETS_Scheduling.AppSettings WHERE Category = ?"
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(sql)
    
    If $$$ISOK(status) {
        Set resultSet = statement.%Execute(category)
        While resultSet.%Next() {
            Do result.%Set(resultSet.%Get("SettingKey"), {
                "value": (resultSet.%Get("SettingValue")),
                "type": (resultSet.%Get("SettingType")),
                "description": (resultSet.%Get("Description"))
            })
        }
    }
    Quit result
}

/// Trigger que se ejecuta antes de guardar para validaciones
Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
    // Validar que el valor sea del tipo correcto
    If '..ValidateValue(..SettingValue, ..SettingType) {
        Quit $$$ERROR(5001, "Valor '" _ ..SettingValue _ "' no es válido para tipo " _ ..SettingType)
    }
    
    // Actualizar timestamp
    Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
    
    Quit $$$OK
}

/// Método para obtener configuraciones de horarios operativos
ClassMethod GetOperatingHours() As %DynamicObject
{
    Set result = {}
    Do result.%Set("startTime", ..GetSetting("OPERATING_START_TIME"))
    Do result.%Set("endTime", ..GetSetting("OPERATING_END_TIME"))
    Do result.%Set("slotDuration", +..GetSetting("TIME_SLOT_DURATION"))
    Quit result
}

/// Método para obtener límites del sistema
ClassMethod GetSystemLimits() As %DynamicObject
{
    Set result = {}
    Do result.%Set("maxPetsPerSlot", +..GetSetting("MAX_PETS_PER_SLOT"))
    Do result.%Set("maxBookingDaysAhead", +..GetSetting("MAX_BOOKING_DAYS_AHEAD"))
    Do result.%Set("minBookingHoursAhead", +..GetSetting("MIN_BOOKING_HOURS_AHEAD"))
    Quit result
}

Storage Default
{
<Data name="AppSettingsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SettingKey</Value>
</Value>
<Value name="3">
<Value>SettingValue</Value>
</Value>
<Value name="4">
<Value>SettingType</Value>
</Value>
<Value name="5">
<Value>Description</Value>
</Value>
<Value name="6">
<Value>Category</Value>
</Value>
<Value name="7">
<Value>IsEditable</Value>
</Value>
<Value name="8">
<Value>DefaultValue</Value>
</Value>
<Value name="9">
<Value>CreatedAt</Value>
</Value>
<Value name="10">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.SettingsD</DataLocation>
<DefaultData>AppSettingsDefaultData</DefaultData>
<IdLocation>^Demo.PETS.SettingsD</IdLocation>
<IndexLocation>^Demo.PETS.SettingsI</IndexLocation>
<StreamLocation>^Demo.PETS.SettingsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
