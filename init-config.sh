#!/bin/bash

echo "🔧 Inicializando configuraciones por defecto de PETS..."

docker exec irish iris session IRIS -U DEMO2 << 'IRIS_EOF'

Write "=== Inicializando Configuraciones PETS ===",!

// Crear horarios operativos por defecto
Set hours = ##class(Demo.PETS.Settings).%New()
Set hours.Category = "operating_hours" 
Set hours.SettingKey = "daily_schedule"
Set hours.SettingValue = "{""startTime"":""06:00"",""endTime"":""20:00""}"
Set hours.Description = "Horarios operativos diarios"
Do hours.%Save()
Write "✅ Horarios configurados (06:00-20:00)",!

// Crear límites del sistema por defecto  
Set limits = ##class(Demo.PETS.Settings).%New()
Set limits.Category = "system_limits"
Set limits.SettingKey = "capacity_limits" 
Set limits.SettingValue = "{""maxPetsPerWalk"":5,""maxPetsPerSlot"":5}"
Set limits.Description = "Límites de capacidad"
Do limits.%Save()
Write "✅ Límites configurados (max 5 mascotas)",!

// Crear límites de fechas
Set dateLimit = ##class(Demo.PETS.Settings).%New()
Set dateLimit.Category = "booking_rules"
Set dateLimit.SettingKey = "max_days_ahead"
Set dateLimit.SettingValue = "30"
Set dateLimit.Description = "Días máximos para reservar con anticipación"
Do dateLimit.%Save()
Write "✅ Límite de fechas configurado (30 días adelante)",!

Write "=== Configuración completada ===",!

halt
IRIS_EOF

echo "✅ Configuraciones inicializadas"