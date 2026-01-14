@echo off
echo ============================================
echo EJECUTAR CONTACTOS APP SIN MODO DESARROLLADOR
echo ============================================
echo.

cd /d "%~dp0"

echo Opcion 1: Intentando ejecutar como administrador...
echo.

REM Verificar si ya somos admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Ejecutando con permisos de administrador
    echo.
    echo Limpiando proyecto...
    call flutter clean

    echo.
    echo Obteniendo dependencias...
    call flutter pub get

    echo.
    echo Iniciando aplicacion en Chrome...
    call flutter run -d chrome
) else (
    echo [!] Este script necesita permisos de administrador
    echo.
    echo Soluciones alternativas:
    echo.
    echo 1. Ejecuta este archivo como ADMINISTRADOR
    echo    Click derecho -^> Ejecutar como administrador
    echo.
    echo 2. O usa: ejecutar_web_alternativo.bat
    echo.
)

pause
