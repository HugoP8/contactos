# INSTRUCCIONES DE EJECUCION - BASE DE DATOS

## ORDEN DE EJECUCION DE SCRIPTS SQL

Ejecutar en Supabase SQL Editor en el siguiente orden:

### PASO 1: SQL Definitivo - Estructura completa corregida
```
migrations/010_SQL_DEFINITIVO.sql
```
Este script:
- Crea/verifica todas las tablas necesarias con columnas correctas
- Corrige inconsistencias entre Flutter y la BD
- Tabla `postulaciones` usa `presupuesto_ofrecido` (no `precio_propuesto`)
- Funciones RPC usan `p_motivo` (no `p_concepto`)
- Agrega todas las columnas faltantes a perfiles_profesionales
- Configura RLS (Row Level Security)
- Crea todas las funciones RPC necesarias para el foro y otras operaciones

### PASO 2: Seeders - Datos de prueba
```
migrations/011_SEEDERS_DEFINITIVOS.sql
```
Este script:
- Inserta 10 perfiles profesionales de prueba (verificados y no verificados)
- Inserta 10 solicitudes de trabajo activas
- Inserta 6 preguntas del foro
- Inserta 5 cajeros/vendedores de creditos
- Datos en diferentes ciudades (La Paz, Cochabamba, Santa Cruz)

---

## VERIFICACION POST-EJECUCION

Despues de ejecutar ambos scripts, verifica con estas consultas:

### Verificar perfiles profesionales:
```sql
SELECT nombre_comercial, categoria_principal, ciudad, calificacion_promedio, verificado
FROM public.perfiles_profesionales
WHERE activo = true AND visible_busqueda = true;
```
**Esperado:** 10 registros con [SEED] en el nombre

### Verificar solicitudes de trabajo:
```sql
SELECT titulo, categoria, ciudad, estado, total_postulaciones
FROM public.solicitudes_trabajo
WHERE estado = 'activa' AND visible = true;
```
**Esperado:** 10 registros con [SEED] en el titulo

### Verificar foro:
```sql
SELECT titulo, categoria, total_respuestas, resuelta
FROM public.foro_preguntas
WHERE visible = true;
```
**Esperado:** 6 registros con [SEED] en el titulo

### Verificar columnas de postulaciones (IMPORTANTE):
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'postulaciones';
```
**Esperado:** Debe incluir columna `presupuesto_ofrecido` (NO `precio_propuesto`)

### Verificar funciones RPC:
```sql
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
ORDER BY routine_name;
```
**Esperado:** Debe incluir:
- descontar_creditos
- incrementar_creditos
- incrementar_postulaciones_solicitud
- incrementar_respuestas_pregunta
- decrementar_respuestas_pregunta
- incrementar_vistas_pregunta
- votar_respuesta

### Verificar cajeros:
```sql
SELECT nombre_completo, ciudad, disponible_ahora
FROM public.cajeros_vendedores
WHERE activo = true;
```
**Esperado:** 5 registros con [SEED] en el nombre

---

## SOLUCION DE PROBLEMAS

### Error: "column resuelta does not exist"
Ejecutar el script 010_SQL_DEFINITIVO.sql completo nuevamente.

### Error: "column presupuesto_ofrecido does not exist"
El script 010 recrea la tabla postulaciones. Ejecutar nuevamente.

### Error: "function incrementar_postulaciones_solicitud does not exist"
Ejecutar el script 010_SQL_DEFINITIVO.sql - crea todas las funciones.

### Error: RPC function parameter mismatch
Las funciones usan:
- `p_motivo` (NO `p_concepto`)
- `p_descripcion` (parametro adicional en incrementar_creditos)

### Error: "relation perfiles_profesionales does not exist"
Ejecutar primero 010_SQL_DEFINITIVO.sql

---

## LIMPIAR DATOS DE PRUEBA

Si necesitas eliminar los seeders:
```sql
-- Limpiar datos de prueba
DELETE FROM public.foro_respuestas WHERE contenido LIKE '%[SEED]%';
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';
DELETE FROM public.postulaciones WHERE mensaje LIKE '%[SEED]%';
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%[SEED]%';
DELETE FROM public.cajeros_vendedores WHERE nombre_completo LIKE '%[SEED]%';
DELETE FROM public.perfiles_profesionales WHERE nombre_comercial LIKE '%[SEED]%';
```

Luego ejecutar de nuevo: `011_SEEDERS_DEFINITIVOS.sql`

---

## FLUJO COMPLETO DE USO

1. **Buscar profesionales:** `/search` - Muestra perfiles activos
2. **Ver solicitudes:** `/solicitudes` - Feed de solicitudes activas
3. **Mis solicitudes:** `/mis-solicitudes` - Solicitudes del usuario
4. **Crear solicitud:** `/solicitud/crear` - Formulario de creacion
5. **Ver detalle:** `/solicitud/:id` - Detalle y postulacion
6. **Foro:** `/foro` - Preguntas y respuestas

---

## RESUMEN DE ARCHIVOS SQL

| Archivo | Descripcion |
|---------|-------------|
| 010_SQL_DEFINITIVO.sql | Estructura de BD corregida y funciones RPC |
| 011_SEEDERS_DEFINITIVOS.sql | Datos de prueba para testing |
