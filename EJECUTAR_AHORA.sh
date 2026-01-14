#!/bin/bash
# Script para ejecutar desde Git Bash

echo "============================================"
echo "CONTACTOS APP - EJECUCION RAPIDA"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "Selecciona una opción:"
echo ""
echo "1) Habilitar Modo Desarrollador (requiere admin)"
echo "2) Compilar y abrir Web (sin permisos)"
echo "3) Ejecutar servidor local"
echo "4) Salir"
echo ""
read -p "Opción [1-4]: " opcion

case $opcion in
    1)
        echo ""
        echo "Habilitando Modo Desarrollador..."
        powershell.exe -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"$PWD/habilitar_modo_dev.ps1\"' -Verb RunAs"
        echo ""
        echo "Si se abrió PowerShell, sigue las instrucciones"
        echo "Luego ejecuta: flutter run -d chrome"
        ;;
    2)
        echo ""
        echo "Compilando para Web..."
        flutter clean
        flutter build web --release
        if [ -f "build/web/index.html" ]; then
            echo ""
            echo "¡Compilación exitosa!"
            echo "Abriendo en navegador..."
            start build/web/index.html
        else
            echo ""
            echo "Error en la compilación"
        fi
        ;;
    3)
        echo ""
        echo "Compilando si es necesario..."
        if [ ! -f "build/web/index.html" ]; then
            flutter build web --release
        fi
        
        echo ""
        echo "Iniciando servidor en http://localhost:8000"
        echo "Presiona Ctrl+C para detener"
        echo ""
        cd build/web
        python -m http.server 8000
        ;;
    4)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac
