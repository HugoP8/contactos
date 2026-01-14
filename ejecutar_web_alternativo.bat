@echo off
echo ============================================
echo CONTACTOS APP - BUILD WEB (SIN MODO DEV)
echo ============================================
echo.

cd /d "%~dp0"

echo [1/3] Limpiando proyecto...
call flutter clean

echo.
echo [2/3] Compilando para Web...
call flutter build web --release

echo.
if exist "build\web\index.html" (
    echo [3/3] Compilacion exitosa!
    echo.
    echo ============================================
    echo APLICACION COMPILADA
    echo ============================================
    echo.
    echo Ubicacion: build\web\index.html
    echo.
    echo Opciones para ejecutar:
    echo.
    echo 1. Doble click en: build\web\index.html
    echo.
    echo 2. O usa Python:
    echo    cd build\web
    echo    python -m http.server 8000
    echo    Abre: http://localhost:8000
    echo.
    echo 3. O usa PHP:
    echo    cd build\web
    echo    php -S localhost:8000
    echo.

    echo Presiona cualquier tecla para abrir la app...
    pause >nul
    start "" "build\web\index.html"
) else (
    echo.
    echo [ERROR] La compilacion fallo
    echo.
    echo Intenta ejecutar manualmente:
    echo   flutter build web
    echo.
)

pause
