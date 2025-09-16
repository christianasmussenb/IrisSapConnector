#!/bin/bash

# Script para ejecutar pruebas específicas del sistema PETS
echo "=========================================="
echo "INICIANDO PRUEBAS ESPECÍFICAS - PETS"
echo "Sistema de Reservas Persistente"
echo "=========================================="

# Navegar al directorio correcto
cd /Users/cab/VSCODE/IrisSapConnector

echo ""
echo "1. Verificando archivos del sistema..."
echo "   - Modelo de datos: Bookings.cls"
if [ -f "PETS/Demo/PETS/Scheduling/Bookings.cls" ]; then
    echo "   ✅ Bookings.cls encontrado"
else
    echo "   ❌ Bookings.cls no encontrado"
fi

echo "   - Servicio de negocio: BookingService.cls"
if [ -f "PETS/Demo/PETS/Services/BookingService.cls" ]; then
    echo "   ✅ BookingService.cls encontrado"
else
    echo "   ❌ BookingService.cls no encontrado"
fi

echo "   - Interfaz Owner: OwnerBookingManager.cls"
if [ -f "PETS/Demo/REST/OwnerBookingManager.cls" ]; then
    echo "   ✅ OwnerBookingManager.cls encontrado"
else
    echo "   ❌ OwnerBookingManager.cls no encontrado"
fi

echo "   - Interfaz Walker: WalkerBookingManager.cls"
if [ -f "PETS/Demo/REST/WalkerBookingManager.cls" ]; then
    echo "   ✅ WalkerBookingManager.cls encontrado"
else
    echo "   ❌ WalkerBookingManager.cls no encontrado"
fi

echo "   - Pruebas unitarias: BookingServiceTest.cls"
if [ -f "PETS/Demo/PETS/Tests/BookingServiceTest.cls" ]; then
    echo "   ✅ BookingServiceTest.cls encontrado"
else
    echo "   ❌ BookingServiceTest.cls no encontrado"
fi

echo "   - Pruebas funcionales: FunctionalityTests.cls"
if [ -f "PETS/Demo/PETS/Tests/FunctionalityTests.cls" ]; then
    echo "   ✅ FunctionalityTests.cls encontrado"
else
    echo "   ❌ FunctionalityTests.cls no encontrado"
fi

echo ""
echo "2. Verificando estructura de archivos..."
echo "   Archivos .cls encontrados:"
find PETS -name "*.cls" -type f | grep -E "(Booking|Test)" | sort

echo ""
echo "3. Verificando líneas de código implementadas..."
echo "   - Bookings.cls:"
if [ -f "PETS/Demo/PETS/Scheduling/Bookings.cls" ]; then
    wc -l PETS/Demo/PETS/Scheduling/Bookings.cls
fi

echo "   - BookingService.cls:"
if [ -f "PETS/Demo/PETS/Services/BookingService.cls" ]; then
    wc -l PETS/Demo/PETS/Services/BookingService.cls
fi

echo "   - OwnerBookingManager.cls:"
if [ -f "PETS/Demo/REST/OwnerBookingManager.cls" ]; then
    wc -l PETS/Demo/REST/OwnerBookingManager.cls
fi

echo "   - WalkerBookingManager.cls:"
if [ -f "PETS/Demo/REST/WalkerBookingManager.cls" ]; then
    wc -l PETS/Demo/REST/WalkerBookingManager.cls
fi

echo ""
echo "4. Verificando métodos implementados..."
echo "   Métodos en BookingService.cls:"
if [ -f "PETS/Demo/PETS/Services/BookingService.cls" ]; then
    grep -n "ClassMethod" PETS/Demo/PETS/Services/BookingService.cls | head -10
fi

echo ""
echo "5. Verificando propiedades del modelo..."
echo "   Propiedades en Bookings.cls:"
if [ -f "PETS/Demo/PETS/Scheduling/Bookings.cls" ]; then
    grep -n "Property" PETS/Demo/PETS/Scheduling/Bookings.cls | head -10
fi

echo ""
echo "=========================================="
echo "VERIFICACIÓN COMPLETADA"
echo "Revisa los resultados arriba para validar"
echo "que todos los componentes están presentes"
echo "=========================================="