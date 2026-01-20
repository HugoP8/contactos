# CONTACTOS - FLUJOS Y CASOS DE USO POR ROL

## DOCUMENTO DE REFERENCIA v1.0

**Fecha:** Enero 2026
**Proyecto:** CONTACTOS - Plataforma de Servicios Profesionales Bolivia

---

## TABLA DE CONTENIDOS

1. [Resumen de Roles](#1-resumen-de-roles)
2. [Flujo: Usuario Buscador](#2-flujo-usuario-buscador)
3. [Flujo: Usuario Profesional](#3-flujo-usuario-profesional)
4. [Flujo: Usuario Dual](#4-flujo-usuario-dual)
5. [Flujo: Cajero/Vendedor](#5-flujo-cajerovendedor)
6. [Flujo: Administrador](#6-flujo-administrador)
7. [Sistema de Solicitudes y Postulaciones](#7-sistema-de-solicitudes-y-postulaciones)
8. [Foro "Alguien Sabe?"](#8-foro-alguien-sabe)
9. [Sistema de Creditos](#9-sistema-de-creditos)
10. [Estructura de Base de Datos Requerida](#10-estructura-de-base-de-datos-requerida)

---

## 1. RESUMEN DE ROLES

| Rol | Descripcion | Puede Buscar | Puede Ofrecer | Membresía |
|-----|-------------|--------------|---------------|-----------|
| **Buscador** | Usuario que busca servicios profesionales | SI | NO | VIP opcional |
| **Profesional** | Usuario que ofrece servicios | NO | SI | Basica/Premium |
| **Dual** | Combinacion de ambos | SI | SI | Ambas disponibles |
| **Cajero** | Gestiona pagos manuales | NO | NO | N/A |
| **Admin** | Control total del sistema | SI | SI | N/A |

---

## 2. FLUJO: USUARIO BUSCADOR

### 2.1 Registro e Inicio

```
[Pantalla Bienvenida]
        |
        v
[Seleccionar: Email / Google / Telefono]
        |
        v
[Completar Perfil Basico]
  - Nombre completo
  - Ciudad
  - Telefono/WhatsApp
        |
        v
[Seleccionar Rol: "Busco servicios"]
        |
        v
[+50 creditos de bienvenida]
        |
        v
[Home - Dashboard Buscador]
```

### 2.2 Casos de Uso - Buscador

#### UC-B01: Buscar Profesionales
```
ACTOR: Usuario Buscador
PRECONDICION: Usuario autenticado con creditos > 0

FLUJO PRINCIPAL:
1. Usuario accede a "Buscar Profesional"
2. Sistema muestra categorias principales
3. Usuario selecciona categoria (ej: "Plomeria")
4. Sistema muestra filtros: ciudad, precio, calificacion
5. Usuario aplica filtros
6. Sistema muestra lista de profesionales
7. Usuario selecciona un profesional
8. Sistema muestra perfil publico (sin contacto)
9. Usuario presiona "Ver Contacto" (costo: 2 creditos)
10. Sistema descuenta creditos
11. Sistema muestra telefono/whatsapp
12. Usuario puede contactar por WhatsApp (mensaje pre-llenado)

FLUJO ALTERNATIVO (sin creditos):
9a. Sistema muestra "Creditos insuficientes"
9b. Sistema ofrece: Ver video / Comprar creditos
```

#### UC-B02: Publicar Solicitud de Trabajo
```
ACTOR: Usuario Buscador
PRECONDICION: Usuario autenticado con creditos >= 15

FLUJO PRINCIPAL:
1. Usuario accede a "Publicar Solicitud"
2. Sistema muestra formulario:
   - Titulo (requerido)
   - Descripcion detallada (requerido)
   - Categoria (requerido)
   - Ciudad y Zona (requerido)
   - Presupuesto min/max (opcional)
   - Urgencia: Normal / Urgente
   - Fotos (hasta 5, opcional)
3. Usuario completa y presiona "Publicar"
4. Sistema verifica creditos (15 creditos)
5. Sistema descuenta creditos
6. Sistema publica solicitud (visible 7 dias)
7. Sistema muestra confirmacion
8. Solicitud aparece en "Solicitudes" (marketplace)

POSTCONDICION:
- Solicitud visible para profesionales
- Profesionales pueden postularse
- Usuario recibe notificaciones de postulaciones
```

#### UC-B03: Gestionar Mis Solicitudes
```
ACTOR: Usuario Buscador
PRECONDICION: Usuario tiene solicitudes publicadas

ACCIONES DISPONIBLES:
1. Ver postulaciones recibidas
2. Ver perfil del profesional postulado
3. Aceptar postulacion (seleccionar profesional)
4. Rechazar postulacion
5. Destacar solicitud (+10 creditos)
6. Renovar solicitud (+5 creditos, si expiro)
7. Eliminar solicitud
8. Marcar como completada
9. Calificar profesional (despues de completar)
```

#### UC-B04: Ver Postulaciones de una Solicitud
```
ACTOR: Usuario Buscador
PRECONDICION: Solicitud con postulaciones

FLUJO:
1. Usuario accede a "Mis Solicitudes"
2. Selecciona una solicitud
3. Ve lista de postulaciones con:
   - Nombre del profesional
   - Calificacion
   - Mensaje de propuesta
   - Precio propuesto
   - Tiempo estimado
4. Usuario puede ver perfil completo del profesional
5. Usuario puede aceptar una postulacion
6. Al aceptar, sistema notifica al profesional
7. Se habilita contacto por WhatsApp
```

---

## 3. FLUJO: USUARIO PROFESIONAL

### 3.1 Registro e Inicio

```
[Pantalla Bienvenida]
        |
        v
[Autenticacion]
        |
        v
[Completar Perfil Basico]
        |
        v
[Seleccionar Rol: "Ofrezco servicios"]
        |
        v
[Crear Perfil Profesional]
  - Nombre comercial
  - Categoria principal
  - Descripcion de servicios
  - Anos experiencia
  - Zonas de cobertura
  - Rango de precios
  - Fotos de trabajos (galeria)
        |
        v
[Activar Prueba Gratuita 3 meses]
        |
        v
[Home - Dashboard Profesional]
```

### 3.2 Casos de Uso - Profesional

#### UC-P01: Explorar Solicitudes de Trabajo
```
ACTOR: Usuario Profesional
PRECONDICION: Perfil profesional activo

FLUJO PRINCIPAL:
1. Profesional accede a "Solicitudes" (marketplace)
2. Sistema muestra solicitudes activas
3. Profesional puede filtrar por:
   - Categoria (su especialidad)
   - Ciudad
   - Urgencia
   - Presupuesto
4. Profesional selecciona una solicitud
5. Sistema muestra detalle completo
6. Profesional decide postularse

NOTA: El profesional ve TODAS las solicitudes activas
      NO solo las de su categoria
```

#### UC-P02: Postularse a una Solicitud
```
ACTOR: Usuario Profesional
PRECONDICION:
  - Perfil profesional activo
  - Membresia vigente (o prueba gratuita)

FLUJO PRINCIPAL:
1. Profesional ve detalle de solicitud
2. Presiona "Postularme"
3. Sistema muestra formulario:
   - Mensaje de propuesta
   - Precio propuesto
   - Tiempo estimado
4. Profesional completa y envia
5. Sistema registra postulacion
6. Sistema notifica al cliente
7. Estado: "Pendiente"

ESTADOS DE POSTULACION:
- Pendiente: Esperando revision del cliente
- Aceptada: Cliente selecciono este profesional
- Rechazada: Cliente rechazo la propuesta
- Cancelada: Profesional retiro su postulacion
```

#### UC-P03: Gestionar Mi Perfil Profesional
```
ACTOR: Usuario Profesional

ACCIONES:
1. Editar informacion basica
2. Actualizar descripcion de servicios
3. Cambiar categoria principal
4. Agregar/quitar subcategorias
5. Actualizar zonas de cobertura
6. Modificar rango de precios
7. Subir fotos a galeria
8. Ver estadisticas:
   - Total vistas perfil
   - Total contactos recibidos
   - Calificacion promedio
   - Total resenas
```

#### UC-P04: Ver Mis Postulaciones
```
ACTOR: Usuario Profesional

FLUJO:
1. Accede a "Mis Postulaciones"
2. Ve lista organizada por estado:
   - Pendientes
   - Aceptadas
   - Rechazadas
3. Puede ver detalle de cada postulacion
4. Si fue aceptado:
   - Ve datos de contacto del cliente
   - Puede contactar por WhatsApp
5. Puede cancelar postulaciones pendientes
```

---

## 4. FLUJO: USUARIO DUAL

### 4.1 Caracteristicas

- Combina capacidades de Buscador + Profesional
- Un solo perfil con dos secciones
- Creditos compartidos
- Puede publicar solicitudes Y postularse

### 4.2 Dashboard Dual

```
[Home Dual]
    |
    +-- [Seccion Buscador]
    |       |-- Buscar profesionales
    |       |-- Mis solicitudes publicadas
    |       |-- Ver postulaciones recibidas
    |
    +-- [Seccion Profesional]
            |-- Mi perfil profesional
            |-- Solicitudes disponibles
            |-- Mis postulaciones enviadas
```

---

## 5. FLUJO: CAJERO/VENDEDOR

### 5.1 Registro de Cajero

```
[Admin registra cajero en panel]
        |
        v
[Cajero recibe credenciales]
        |
        v
[Cajero configura su perfil]
  - WhatsApp
  - Metodos de pago que acepta
  - Ciudad/Zona
  - Horario de atencion
```

### 5.2 Caso de Uso - Procesar Recarga

```
ACTOR: Cajero
PRECONDICION: Cajero activo en el sistema

FLUJO:
1. Usuario solicita recarga via WhatsApp
2. Cajero recibe mensaje con detalles:
   - Producto solicitado
   - Monto
   - ID de usuario
3. Cajero coordina pago (Tigo Money, efectivo, etc)
4. Usuario realiza pago
5. Usuario envia comprobante
6. Cajero ingresa a panel web
7. Cajero busca solicitud por ID
8. Cajero presiona "Validar Pago"
9. Sistema envia a Admin para aprobacion
10. Admin aprueba
11. Sistema acredita al usuario
12. Cajero recibe comision (5%)
```

---

## 6. FLUJO: ADMINISTRADOR

### 6.1 Panel de Control

```
[Dashboard Admin]
    |
    +-- Metricas generales
    |       |-- Total usuarios
    |       |-- Usuarios nuevos (hoy/semana/mes)
    |       |-- Solicitudes activas
    |       |-- Transacciones pendientes
    |
    +-- Gestion de Usuarios
    |       |-- Ver todos los usuarios
    |       |-- Suspender/Activar
    |       |-- Editar datos
    |       |-- Ver historial
    |
    +-- Gestion de Cajeros
    |       |-- Agregar cajero
    |       |-- Editar cajero
    |       |-- Desactivar cajero
    |       |-- Ver comisiones
    |
    +-- Recargas Pendientes
    |       |-- Aprobar recargas validadas
    |       |-- Rechazar recargas
    |       |-- Ver historial
    |
    +-- Moderacion
            |-- Revisar reportes
            |-- Moderar resenas
            |-- Gestionar contenido
```

---

## 7. SISTEMA DE SOLICITUDES Y POSTULACIONES

### 7.1 Ciclo de Vida de una Solicitud

```
[ACTIVA] -----> Recibe postulaciones
    |
    v
[EN_PROCESO] --> Cliente acepto un profesional
    |
    v
[COMPLETADA] --> Trabajo terminado, puede calificar
    |
    OR
    v
[CANCELADA] --> Cliente o profesional cancelo
    |
    OR
    v
[EXPIRADA] --> Pasaron 7 dias sin actividad
```

### 7.2 Flujo Visual del Marketplace

```
PANTALLA: /solicitudes (Marketplace de Solicitudes)

+--------------------------------------------------+
| [Header] Solicitudes de Trabajo                  |
| [Boton] Mis Solicitudes | [Boton] + Nueva        |
+--------------------------------------------------+
| [Filtros]                                        |
| Categoria: [Todas v] Ciudad: [Todas v]           |
| Buscar: [________________] [Buscar]              |
+--------------------------------------------------+
| [Lista de Solicitudes]                           |
|                                                  |
| +----------------------------------------------+ |
| | [URGENTE] Plomero para fuga de agua          | |
| | La Paz - Centro | Bs. 100-300                | |
| | "Tengo una fuga en el bano..."               | |
| | 3 postulaciones | Expira en 5 dias           | |
| +----------------------------------------------+ |
|                                                  |
| +----------------------------------------------+ |
| | Electricista para instalacion LED            | |
| | La Paz - Miraflores | Bs. 500-1200           | |
| | "Necesito instalar 8 puntos..."              | |
| | 5 postulaciones | Expira en 3 dias           | |
| +----------------------------------------------+ |
+--------------------------------------------------+
| [BottomNav: Inicio | Buscar | Solicitudes | Foro | Perfil]
+--------------------------------------------------+
```

### 7.3 Pantalla: Detalle de Solicitud

```
PANTALLA: /solicitud/{id}

+--------------------------------------------------+
| [<] Detalle de Solicitud                         |
+--------------------------------------------------+
| [URGENTE]                          [DESTACADA]   |
| Plomero para fuga de agua                        |
+--------------------------------------------------+
| Publicado por: Juan Perez                        |
| Hace 2 horas                                     |
+--------------------------------------------------+
| Descripcion:                                     |
| Tengo una fuga de agua en el bano principal.     |
| La fuga esta en la conexion del inodoro y esta   |
| mojando el piso constantemente. Necesito que     |
| vengan lo antes posible.                         |
+--------------------------------------------------+
| Ubicacion: La Paz - Centro                       |
| Presupuesto: Bs. 100 - Bs. 300                   |
| Categoria: Plomeria                              |
| Urgencia: URGENTE                                |
| Expira: 15 Enero 2026                            |
+--------------------------------------------------+
| [Fotos adjuntas]                                 |
| [img1] [img2] [img3]                             |
+--------------------------------------------------+
| Postulaciones: 3                                 |
+--------------------------------------------------+

SI ES PROFESIONAL:
| [========= POSTULARME =========]                 |
+--------------------------------------------------+

SI ES EL DUENO:
| [Ver Postulaciones (3)]                          |
| [Editar] [Destacar] [Eliminar]                   |
+--------------------------------------------------+
```

### 7.4 Pantalla: Postularse

```
PANTALLA: /solicitud/{id}/postular

+--------------------------------------------------+
| [<] Enviar Propuesta                             |
+--------------------------------------------------+
| Solicitud: Plomero para fuga de agua             |
| Cliente: Juan Perez                              |
| Presupuesto sugerido: Bs. 100 - 300              |
+--------------------------------------------------+
| Tu propuesta:                                    |
|                                                  |
| Mensaje *                                        |
| +----------------------------------------------+ |
| | Hola! Soy plomero con 5 anos de experiencia. | |
| | Puedo ir hoy mismo a revisar la fuga.        | |
| | El trabajo incluye revision completa y       | |
| | materiales de primera calidad.               | |
| +----------------------------------------------+ |
|                                                  |
| Precio propuesto (Bs.) *                         |
| [200_______]                                     |
|                                                  |
| Tiempo estimado *                                |
| [2 horas___]                                     |
|                                                  |
+--------------------------------------------------+
| [========= ENVIAR PROPUESTA =========]           |
+--------------------------------------------------+
```

---

## 8. FORO "ALGUIEN SABE?"

### 8.1 Descripcion

Espacio donde usuarios pueden hacer preguntas abiertas sobre cualquier tema:
- Recomendaciones de servicios
- Consultas sobre precios
- Estado de rutas/transporte
- Tramites
- Consejos generales

### 8.2 Flujo de Pregunta

```
[Usuario crea pregunta] --> Costo: 5 creditos
        |
        v
[Pregunta visible en foro]
        |
        v
[Otros usuarios responden] --> Gratis
        |
        v
[Autor marca mejor respuesta]
        |
        v
[Autor de mejor respuesta gana 2 creditos]
```

### 8.3 Estructura Requerida

**Tabla: foro_preguntas**
- id, user_id, titulo, descripcion, categoria
- respondida (BOOLEAN) - si tiene al menos una respuesta marcada como aceptada
- total_respuestas, total_votos
- visible, created_at, updated_at

**Tabla: foro_respuestas**
- id, pregunta_id, user_id, contenido
- es_respuesta_aceptada (BOOLEAN)
- es_mejor_respuesta (BOOLEAN)
- total_votos
- created_at, updated_at

---

## 9. SISTEMA DE CREDITOS

### 9.1 Formas de Ganar Creditos

| Accion | Creditos | Limite |
|--------|----------|--------|
| Registro inicial | +50 | Una vez |
| Ver video AdMob | +5 | 10/dia |
| Referir amigo | +30 | Ilimitado |
| Perfil completo 100% | +20 | Una vez |
| Dejar resena con foto | +4 | 3/dia |
| Racha diaria | +3 | 7 dias seguidos |
| Mejor respuesta foro | +2 | Ilimitado |

### 9.2 Costos en Creditos

| Accion | Costo |
|--------|-------|
| Ver contacto profesional | 2 creditos |
| Publicar solicitud | 15 creditos |
| Destacar solicitud | 10 creditos |
| Renovar solicitud | 5 creditos |
| Publicar pregunta foro | 5 creditos |

### 9.3 Paquetes de Compra

| Paquete | Creditos | Precio (Bs.) |
|---------|----------|--------------|
| Basico | 30 | 5 |
| Popular | 75 | 10 |
| Plus | 200 | 25 |
| Pro | 500 | 50 |

---

## 10. ESTRUCTURA DE BASE DE DATOS REQUERIDA

### 10.1 Tablas Principales

```sql
-- USUARIOS
users (
  id, email, nombre_completo, telefono, whatsapp,
  foto_perfil, ciudad, zona,
  rol, tipo_cuenta,
  creditos, creditos_totales_ganados, creditos_totales_gastados,
  verificado, perfil_completo, activo,
  codigo_referido, referido_por,
  created_at, updated_at
)

-- PERFILES PROFESIONALES
perfiles_profesionales (
  id, user_id,
  nombre_comercial, descripcion, categoria_principal,
  ciudad, zonas_cobertura,
  telefono, whatsapp,
  anos_experiencia, rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado,
  created_at, updated_at
)

-- SOLICITUDES DE TRABAJO
solicitudes_trabajo (
  id, user_id,
  titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo,
  urgencia, estado,
  visible, destacada, total_postulaciones,
  profesional_seleccionado,
  created_at, updated_at, expires_at
)

-- POSTULACIONES
postulaciones (
  id, solicitud_id, profesional_id,
  mensaje, precio_propuesto, tiempo_estimado,
  estado,
  created_at, updated_at
)

-- FORO PREGUNTAS
foro_preguntas (
  id, user_id,
  titulo, descripcion, categoria,
  respondida, total_respuestas, total_votos,
  visible, created_at, updated_at
)

-- FORO RESPUESTAS
foro_respuestas (
  id, pregunta_id, user_id,
  contenido,
  es_respuesta_aceptada, es_mejor_respuesta,
  total_votos,
  created_at, updated_at
)

-- CAJEROS
cajeros_vendedores (
  id, user_id,
  nombre_completo, telefono, whatsapp,
  ciudad, zona, metodos_pago,
  disponible_ahora, activo,
  calificacion_promedio, total_transacciones,
  created_at
)
```

### 10.2 Funciones RPC Requeridas

```sql
-- Creditos
descontar_creditos(p_user_id UUID, p_cantidad INT, p_concepto TEXT)
incrementar_creditos(p_user_id UUID, p_cantidad INT, p_concepto TEXT)
puede_publicar_solicitud_gratis(p_user_id UUID) RETURNS BOOLEAN

-- Solicitudes
incrementar_solicitudes_publicadas(p_user_id UUID)
incrementar_postulaciones(p_solicitud_id UUID)

-- Foro
incrementar_respuestas_pregunta(p_pregunta_id UUID)
decrementar_respuestas_pregunta(p_pregunta_id UUID)
votar_respuesta(p_respuesta_id UUID)
```

---

## NOTAS FINALES

### Prioridades de Implementacion

1. **ALTA**: Sistema de solicitudes y postulaciones funcionando
2. **ALTA**: Busqueda de profesionales con seeders de prueba
3. **ALTA**: Foro con estructura correcta
4. **MEDIA**: Sistema de creditos completo
5. **MEDIA**: Sistema de cajeros
6. **BAJA**: Panel de administracion completo

### Errores Conocidos a Corregir

1. Tabla foro_preguntas usa "resuelta" pero deberia ser "respondida"
2. Faltan seeders de perfiles_profesionales para busqueda
3. Flujo de postulaciones incompleto
4. Navegacion entre "Solicitudes" y "Mis Solicitudes" confusa

---

**Documento generado para el proyecto CONTACTOS**
**Ultima actualizacion:** Enero 2026
