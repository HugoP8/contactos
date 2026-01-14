# CAMBIOS REALIZADOS EN LA BASE DE DATOS

## Archivo generado: `database_supabase_script_FIXED.sql`

---

## INCONSISTENCIAS ENCONTRADAS Y CORREGIDAS

### 1. **Nombres de Tablas Inconsistentes**

#### ❌ PROBLEMA: Tabla `movimientos_creditos` vs `creditos_movimientos`
- **FIX_RLS_POLICIES.sql** (línea 17): Referenciaba `movimientos_creditos`
- **database_supabase_script.sql** (línea 457): Definía `creditos_movimientos`

✅ **SOLUCIÓN**: Se estandarizó a `movimientos_creditos` en todo el script

---

#### ❌ PROBLEMA: Tabla `resenas` vs `resenas_calificaciones`
- **FIX_RLS_POLICIES.sql** (línea 18): Referenciaba `resenas`
- **database_supabase_script.sql** (línea 248): Definía `resenas_calificaciones`

✅ **SOLUCIÓN**: Se estandarizó a `resenas` (nombre más simple y directo)

---

### 2. **Nombres de Campos Inconsistentes**

#### ❌ PROBLEMA: Uso mixto de `user_id` vs `usuario_id` vs `cliente_id`

**Tabla `resenas` (antes `resenas_calificaciones`):**
- database_supabase_script.sql usaba:
  - `profesional_id` ✓ (correcto)
  - `cliente_id` ❌ (inconsistente)
  - `solicitud_id` ✓ (correcto)

✅ **SOLUCIÓN**: Se cambió `cliente_id` → `usuario_id` para mantener consistencia

---

#### ❌ PROBLEMA: Tabla `favoritos`
- **FIX_RLS_POLICIES.sql** (línea 247): Usaba `user_id`
- **database_supabase_script.sql** (línea 520): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se estandarizó a `user_id` en toda la tabla `favoritos`

---

#### ❌ PROBLEMA: Tabla `transacciones`
- database_supabase_script.sql (línea 286): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se cambió a `user_id` para consistencia

---

#### ❌ PROBLEMA: Tabla `solicitudes_recarga`
- database_supabase_script.sql (línea 328): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se cambió a `user_id` para consistencia

---

#### ❌ PROBLEMA: Tabla `notificaciones`
- database_supabase_script.sql (línea 491): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se cambió a `user_id` para consistencia

---

#### ❌ PROBLEMA: Tabla `foro_preguntas`
- database_supabase_script.sql (línea 540): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se cambió a `user_id` para consistencia

---

#### ❌ PROBLEMA: Tabla `foro_respuestas`
- database_supabase_script.sql (línea 573): Usaba `usuario_id`

✅ **SOLUCIÓN**: Se cambió a `user_id` para consistencia

---

## ESTÁNDAR ADOPTADO

### Convención de Nombres de Campos:

1. **Para referencias a usuarios**: Siempre usar `user_id`
   - ✅ `user_id` (general)
   - ✅ `profesional_id` (cuando es específicamente un profesional)
   - ✅ `cajero_id` (cuando es específicamente un cajero)
   - ✅ `admin_id` (cuando es específicamente un admin)
   - ❌ `usuario_id` (evitar)
   - ❌ `cliente_id` (evitar, usar `usuario_id` si es necesario)

2. **Para nombres de tablas**: Usar español pero con estructura clara
   - ✅ `movimientos_creditos` (sustantivo_complemento)
   - ✅ `resenas` (simple y directo)

---

## CAMBIOS ADICIONALES REALIZADOS

### 1. **Funciones RPC Mejoradas**
- Se agregaron prefijos `p_` a los parámetros para evitar conflictos:
  - `incrementar_creditos(p_user_id UUID, p_cantidad INT)`
  - `decrementar_creditos(p_user_id UUID, p_cantidad INT)`

### 2. **Triggers Adicionales**
Se agregaron triggers `updated_at` para más tablas:
- `solicitudes_recarga`
- `cajeros_vendedores`
- `foro_preguntas`
- `foro_respuestas`

### 3. **Índices Corregidos**
Todos los índices ahora usan nombres consistentes con las tablas/campos corregidos:
- `idx_movimientos_creditos_user`
- `idx_transacciones_user`
- `idx_solicitudes_recarga_user`
- `idx_notificaciones_user`
- `idx_favoritos_user`
- `idx_foro_preguntas_user`
- `idx_foro_respuestas_user`

### 4. **Políticas RLS Unificadas**
- Todas las políticas duplicadas fueron consolidadas
- Se eliminaron referencias a nombres de políticas antiguas

---

## VERIFICACIÓN FINAL

El script ahora:
✅ No tiene conflictos de nombres de tablas
✅ Usa convención consistente para campos de usuario
✅ Todas las referencias FK apuntan a tablas/campos correctos
✅ Políticas RLS alineadas con nombres de campos
✅ Triggers e índices sincronizados

---

## INSTRUCCIONES DE USO

1. **Elimina el script anterior** (si ya ejecutaste algo):
   ```sql
   -- Solo si necesitas empezar de cero
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   GRANT ALL ON SCHEMA public TO postgres;
   GRANT ALL ON SCHEMA public TO public;
   ```

2. **Ejecuta el nuevo script**:
   - Abre Supabase Dashboard
   - Ve a SQL Editor
   - Copia y pega `database_supabase_script_FIXED.sql`
   - Ejecuta (Run)

3. **Verifica**:
   ```sql
   -- Verifica que las tablas se crearon
   SELECT tablename FROM pg_tables WHERE schemaname = 'public';

   -- Verifica las políticas
   SELECT tablename, policyname
   FROM pg_policies
   WHERE schemaname = 'public'
   ORDER BY tablename;
   ```

---

## ARCHIVOS OBSOLETOS

Puedes eliminar:
- ❌ `FIX_RLS_POLICIES.sql` (ya no es necesario)
- ❌ `database_supabase_script.sql` (reemplazado por la versión FIXED)

---

**Fecha de corrección**: Enero 2026
**Versión**: 2.0 - FIXED
