@echo off
echo ========================================
echo   CONTACTOS - Ejecutar en Web
echo ========================================
echo.

REM Ir al directorio del proyecto
cd /d "%~dp0"

echo Limpiando cache de Flutter...
call flutter clean

echo.
echo Obteniendo dependencias...
call flutter pub get

echo.
echo Iniciando servidor web...
echo (La aplicacion estara disponible en http://localhost:8080)
echo.
call flutter run -d chrome --web-port=8080

pause
