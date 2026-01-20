@echo off
echo ========================================
echo   CONTACTOS - Servidor Web
echo ========================================
echo.

REM Ir al directorio del proyecto
cd /d "%~dp0"

echo Obteniendo dependencias...
call flutter pub get

echo.
echo Iniciando servidor web (sin navegador)...
echo (La aplicacion estara disponible en http://localhost:8080)
echo.
call flutter run -d web-server --web-port=8080

pause
