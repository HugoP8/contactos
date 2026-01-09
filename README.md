# 📱 CONTACTOS App

Plataforma de servicios profesionales para Bolivia - Páginas amarillas modernas

## 🎯 Descripción

CONTACTOS es una aplicación multiplataforma (móvil y web) que conecta usuarios que buscan servicios con profesionales que los ofrecen. Funciona como un marketplace de servicios profesionales con sistema de créditos, solicitudes de trabajo, postulaciones y membresías.

## ✨ Características Principales

- 🔐 **Autenticación múltiple**: Google Sign-In, Email/Password
- 👥 **Sistema de roles**: Buscador, Profesional, Dual, Cajero, Admin
- 💰 **Sistema de créditos**: 50 créditos iniciales + múltiples formas de ganar más
- 📋 **Solicitudes de trabajo**: Publicación de necesidades con postulaciones
- 👨‍💼 **Perfiles profesionales**: Galería, calificaciones, verificación
- 🔍 **Búsqueda avanzada**: Por categoría, ubicación, precio, calificación
- 💬 **Integración WhatsApp**: Contacto directo con mensajes predefinidos
- 💳 **Sistema de pagos**: Manual (cajeros) y futuro automático
- 🎖️ **Membresías**: Profesionales (Básica/Premium) y Buscadores (VIP)
- 📺 **Monetización**: AdMob (videos recompensados y banners)
- ⭐ **Reseñas y calificaciones**: Sistema completo de valoraciones
- ❤️ **Favoritos**: Guarda tus profesionales preferidos
- 📊 **Panel admin**: Gestión completa de la plataforma

## 🛠️ Stack Tecnológico

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Navegación**: GoRouter
- **Autenticación**: Supabase Auth + Google Sign-In
- **Notificaciones**: Firebase Cloud Messaging
- **Ads**: Google AdMob
- **Mapas**: Google Maps Flutter

## 📁 Estructura del Proyecto

```
lib/
├── core/                    # Configuración central
│   ├── constants/          # Constantes de la app
│   ├── theme/              # Tema y estilos
│   ├── utils/              # Utilidades
│   ├── routes/             # Configuración de rutas
│   └── services/           # Servicios globales
├── features/               # Características por módulos
│   ├── auth/              # Autenticación
│   ├── home/              # Pantalla principal
│   ├── search/            # Búsqueda de profesionales
│   ├── profile/           # Perfil de usuario
│   ├── solicitudes/       # Solicitudes de trabajo
│   ├── postulaciones/     # Sistema de postulaciones
│   ├── creditos/          # Gestión de créditos
│   ├── resenas/           # Reseñas y calificaciones
│   ├── favoritos/         # Favoritos
│   ├── payments/          # Sistema de pagos
│   └── admin/             # Panel administrativo
└── shared/                 # Componentes compartidos
    ├── widgets/           # Widgets reutilizables
    ├── models/            # Modelos compartidos
    └── services/          # Servicios compartidos
```

## 🚀 Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd contactos
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Copia `.env.example` a `.env` y configura las variables:

```bash
cp .env.example .env
```

Edita `.env` con tus credenciales de:
- Supabase (URL y Anon Key)
- AdMob (IDs de Android e iOS)

### 4. Configurar Firebase

- Android: Coloca `google-services.json` en `android/app/`
- iOS: Coloca `GoogleService-Info.plist` en `ios/Runner/`

### 5. Ejecutar la app

```bash
flutter run
```

## 💰 Sistema de Créditos

### Costos:
- Ver contacto de profesional: **2 créditos**
- Publicar solicitud: **15 créditos** (1 gratis al registro)
- Destacar solicitud: **10 créditos**
- Renovar solicitud: **5 créditos**

### Formas de ganar:
- Registro inicial: **50 créditos**
- Ver video AdMob: **5 créditos** (máx 10/día)
- Referir amigo: **30 créditos**
- Perfil completo: **20 créditos**
- Escribir reseña: **4 créditos**

## 📋 Membresías

### Profesionales:
- **Básica** (Bs. 20/mes): Perfil completo, hasta 10 fotos
- **Premium** (Bs. 30/mes): Perfil destacado, badge PREMIUM, galería ilimitada

### Buscadores:
- **VIP** (Bs. 10/mes): Descuentos en créditos, solicitudes destacadas

## 🏗️ Desarrollo

### Arquitectura

El proyecto sigue **Clean Architecture** con principios SOLID:
- **Data Layer**: Modelos y repositorios
- **Domain Layer**: Entidades y casos de uso
- **Presentation Layer**: UI y providers (Riverpod)

### Comandos útiles

```bash
# Generar código (modelos, providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Análisis de código
flutter analyze

# Tests
flutter test

# Build para producción
flutter build apk --release
flutter build ios --release
```

## 🎨 Diseño

- **Material Design 3**
- **Fuente**: Poppins
- **Colores principales**:
  - Primary: #2563EB (azul)
  - Secondary: #10B981 (verde)
  - Accent: #F59E0B (naranja)

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web (próximamente)

## 🌍 Ciudades (Bolivia)

La Paz, El Alto, Santa Cruz, Cochabamba, Sucre, Oruro, Potosí, Tarija

## 📄 Licencia

Este proyecto es privado y confidencial.

## 👨‍💻 Autor

Hugo - 2026
