@echo off
echo ============================================
echo HABILITAR MODO DESARROLLADOR - WINDOWS
echo ============================================
echo.
echo Este script habilitara el Modo Desarrollador en Windows
echo Requiere permisos de ADMINISTRADOR
echo.
pause

echo Habilitando Modo Desarrollador...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

if %errorlevel% == 0 (
    echo.
    echo ============================================
    echo EXITO: Modo Desarrollador habilitado!
    echo ============================================
    echo.
    echo Ahora puedes ejecutar:
    echo   flutter run -d chrome
    echo.
) else (
    echo.
    echo ============================================
    echo ERROR: No se pudo habilitar
    echo ============================================
    echo.
    echo Solucion: Ejecuta este archivo como ADMINISTRADOR
    echo Click derecho sobre el archivo -^> Ejecutar como administrador
    echo.
)

pause
