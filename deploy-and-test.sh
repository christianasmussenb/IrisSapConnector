#!/bin/bash

# 🚀 Script de despliegue y prueba del formulario de disponibilidad
# Automatiza el proceso de carga, compilación y prueba

echo "🐕 === PETS - Despliegue y Prueba Formulario Disponibilidad ==="
echo ""

# Verificar que el container IRIS esté corriendo
echo "📋 1. Verificando container IRIS..."
if ! docker ps | grep -q irish; then
    echo "❌ Container 'irish' no está corriendo"
    echo "💡 Ejecute: docker-compose up -d"
    exit 1
fi
echo "✅ Container IRIS corriendo"
echo ""

# Copiar fuentes actualizadas
echo "📋 2. Copiando fuentes actualizadas..."
docker cp ./PETS irish:/tmp/src
if [ $? -eq 0 ]; then
    echo "✅ Fuentes copiadas a /tmp/src"
else
    echo "❌ Error copiando fuentes"
    exit 1
fi
echo ""

# Cargar y compilar clases
echo "📋 3. Cargando y compilando clases..."
docker exec -i irish iris session IRIS -U USER << 'EOF'
Write "Cargando desde /tmp/src...",!
Try {
    Do $System.OBJ.LoadDir("/tmp/src","ck",,1)
    Write "✅ Carga completada",!
} Catch ex {
    Write "❌ Error en carga: " _ ex.DisplayString(),!
    Halt
}

Write !,"Compilando Demo.REST.AvailabilityForm...",!
Try {
    Do $System.OBJ.Compile("Demo.REST.AvailabilityForm","ck")
    Write "✅ Compilación exitosa",!
} Catch ex {
    Write "❌ Error en compilación: " _ ex.DisplayString(),!
    Halt
}

Write !,"Compilando servicios de prueba...",!
Try {
    Do $System.OBJ.Compile("Demo.PETS.Services.AvailabilityFormTestService","ck")
    Do $System.OBJ.Compile("Demo.PETS.Scripts.AvailabilityFormIntegrationTest","ck")
    Write "✅ Servicios de prueba compilados",!
} Catch ex {
    Write "❌ Error compilando pruebas: " _ ex.DisplayString(),!
}

Halt
EOF

if [ $? -eq 0 ]; then
    echo "✅ Compilación completada"
else
    echo "❌ Error en compilación"
    exit 1
fi
echo ""

# Ejecutar pruebas rápidas
echo "📋 4. Ejecutando pruebas rápidas..."
docker exec -i irish iris session IRIS -U USER << 'EOF'
Write "🧪 === EJECUTANDO PRUEBAS RÁPIDAS ===",!,!

Try {
    Do ##class(Demo.PETS.Scripts.AvailabilityFormIntegrationTest).QuickTest()
    Write !,"🎯 Pruebas unitarias completadas",!,!
} Catch ex {
    Write "❌ Error en pruebas: " _ ex.DisplayString(),!
}

Try {
    Write "🔄 Ejecutando prueba integral básica...",!
    Do ##class(Demo.PETS.Scripts.AvailabilityFormIntegrationTest).TestCompletePersistence()
    Write !,"🎯 Prueba integral completada",!
} Catch ex {
    Write "❌ Error en prueba integral: " _ ex.DisplayString(),!
}

Halt
EOF

echo ""
echo "📋 5. URLs de acceso:"
echo "🌐 Página principal: http://localhost:52773/csp/demo2/"
echo "📝 Formulario disponibilidad: http://localhost:52773/csp/demo2/disponibilidad"
echo "🔧 Management Portal: http://localhost:52773/csp/sys/UtilHome.csp"
echo ""

echo "📋 6. Comandos de prueba manual en IRIS:"
echo "   // Pruebas unitarias completas"
echo "   Do ##class(Demo.PETS.Services.AvailabilityFormTestService).RunAllTests()"
echo ""
echo "   // Pruebas integrales completas"  
echo "   Do ##class(Demo.PETS.Scripts.AvailabilityFormIntegrationTest).RunIntegrationTests()"
echo ""

echo "🎉 === DESPLIEGUE COMPLETADO ==="
echo "💡 Ahora puede probar el formulario en el navegador"