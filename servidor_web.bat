@echo off
echo ============================================
echo SERVIDOR WEB LOCAL - CONTACTOS APP
echo ============================================
echo.

cd /d "%~dp0"

REM Verificar si existe el build
if not exist "build\web\index.html" (
    echo No se encontro la aplicacion compilada.
    echo.
    echo Compilando ahora...
    call flutter build web --release
    echo.
)

if exist "build\web\index.html" (
    echo Iniciando servidor web local...
    echo.
    echo ============================================
    echo SERVIDOR ACTIVO
    echo ============================================
    echo.
    echo Abre tu navegador en:
    echo   http://localhost:8000
    echo.
    echo Presiona CTRL+C para detener el servidor
    echo ============================================
    echo.

    cd build\web

    REM Intentar con Python
    python -m http.server 8000 2>nul
    if errorlevel 1 (
        REM Si Python falla, intentar con PHP
        php -S localhost:8000 2>nul
        if errorlevel 1 (
            echo.
            echo [ERROR] No se encontro Python ni PHP
            echo.
            echo Instala Python desde: https://www.python.org/downloads/
            echo O simplemente abre: build\web\index.html
            echo.
            pause
            start "" "%~dp0build\web\index.html"
        )
    )
) else (
    echo [ERROR] No se pudo compilar la aplicacion
    echo.
    echo Ejecuta manualmente:
    echo   flutter build web
    echo.
    pause
)
