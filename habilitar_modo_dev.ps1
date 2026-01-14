# PowerShell Script para habilitar Modo Desarrollador
# Ejecutar como: powershell -ExecutionPolicy Bypass -File habilitar_modo_dev.ps1

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "HABILITAR MODO DESARROLLADOR - WINDOWS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si es administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Este script requiere permisos de ADMINISTRADOR" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ejecuta esto en PowerShell como Administrador:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File habilitar_modo_dev.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "O click derecho en el archivo -> Ejecutar como Administrador" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "Habilitando Modo Desarrollador..." -ForegroundColor Yellow

try {
    # Habilitar modo desarrollador
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
                     -Name "AllowDevelopmentWithoutDevLicense" `
                     -Value 1 `
                     -Type DWord `
                     -Force

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "EXITO: Modo Desarrollador habilitado!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ahora puedes ejecutar:" -ForegroundColor White
    Write-Host "  flutter run -d chrome" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Nota: Reinicia tu terminal Git Bash" -ForegroundColor Yellow
    Write-Host ""

    $estadoActual = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    Write-Host "Estado actual: $($estadoActual.AllowDevelopmentWithoutDevLicense)" -ForegroundColor Cyan

} catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "ERROR: No se pudo habilitar" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalles del error:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Read-Host "Presiona Enter para salir"
