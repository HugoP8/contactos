# 🚀 EJECUTAR CONTACTOS APP - SIN MODO DESARROLLADOR

He creado **4 scripts automáticos** para ti. Aquí están las opciones:

---

## ✅ OPCIÓN 1: Habilitar Modo Desarrollador (CON CÓDIGO) ⭐

### Paso 1: Click derecho sobre este archivo:
```
habilitar_modo_dev.bat
```

### Paso 2: Selecciona "Ejecutar como administrador"

### Paso 3: Presiona cualquier tecla cuando te lo pida

**¡LISTO!** El modo desarrollador estará habilitado.

Luego ejecuta en Git Bash:
```bash
flutter run -d chrome
```

---

## ✅ OPCIÓN 2: Ejecutar Como Administrador (DIRECTO) 🔐

### Paso 1: Click derecho sobre:
```
ejecutar_sin_modo_dev.bat
```

### Paso 2: Selecciona "Ejecutar como administrador"

**¡SE ABRIRÁ AUTOMÁTICAMENTE EN CHROME!**

---

## ✅ OPCIÓN 3: Compilar Web (SIN PERMISOS) 🌐

### Simplemente doble click en:
```
ejecutar_web_alternativo.bat
```

Esto:
1. Compila la app para web
2. Abre automáticamente en tu navegador

**NO REQUIERE PERMISOS DE ADMINISTRADOR**

---

## ✅ OPCIÓN 4: Servidor Web Local 🖥️

### Doble click en:
```
servidor_web.bat
```

Abre tu navegador en: **http://localhost:8000**

---

## 🎯 RECOMENDACIÓN

**Para desarrollo rápido:**
- Usa **OPCIÓN 3** (ejecutar_web_alternativo.bat)

**Para desarrollo continuo:**
- Usa **OPCIÓN 1** (habilitar_modo_dev.bat) una sola vez
- Luego siempre usa: `flutter run -d chrome`

---

## 💻 DESDE GIT BASH (ALTERNATIVA)

Si prefieres usar código en Git Bash:

```bash
# Compilar directamente
flutter build web --release

# Ver resultado
cd build/web
python -m http.server 8000

# Abre: http://localhost:8000
```

---

## ⚠️ SI NADA FUNCIONA

Ejecuta esto en **PowerShell como Administrador**:

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
```

Luego reinicia Git Bash y ejecuta:
```bash
flutter run -d chrome
```

---

## 📞 AYUDA RÁPIDA

**¿Cuál script usar?**
- ¿Quieres habilitarlo permanente? → `habilitar_modo_dev.bat`
- ¿Solo quieres probarlo ahora? → `ejecutar_web_alternativo.bat`
- ¿Ya compilaste? → `servidor_web.bat`

**¡Todos los scripts están listos para usar!** 🎉
