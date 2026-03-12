-- ============================================
-- FIXES BUGS 21 ENERO 2026
-- ============================================
-- Este archivo corrige:
-- 1. Error 300 Multiple Choices en descontar_creditos (overload)
-- 2. Error 403 Forbidden en postulaciones (RLS)
-- 3. Problemas con el foro (respuestas y selección)
-- ============================================

-- ============================================
-- PASO 1: ELIMINAR TODAS LAS VERSIONES DE descontar_creditos
-- ============================================
-- El error PGRST203 indica que hay múltiples funciones con el mismo nombre
-- pero diferentes tipos de parámetros (TEXT vs VARCHAR)

DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INT, TEXT);
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INT, VARCHAR);
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INTEGER, TEXT);
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INTEGER, CHARACTER VARYING);

-- Crear una sola versión definitiva
CREATE OR REPLACE FUNCTION public.descontar_creditos(
    p_user_id UUID,
    p_cantidad INT,
    p_motivo TEXT DEFAULT 'gasto'
)
RETURNS BOOLEAN AS $$
DECLARE
    v_creditos INT;
BEGIN
    -- Obtener créditos actuales
    SELECT creditos INTO v_creditos
    FROM public.users
    WHERE id = p_user_id;

    -- Verificar si tiene suficientes créditos
    IF v_creditos IS NULL OR v_creditos < p_cantidad THEN
        RETURN FALSE;
    END IF;

    -- Descontar créditos
    UPDATE public.users
    SET
        creditos = creditos - p_cantidad,
        creditos_totales_gastados = COALESCE(creditos_totales_gastados, 0) + p_cantidad,
        updated_at = NOW()
    WHERE id = p_user_id;

    -- Registrar movimiento si existe la tabla
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimientos_creditos') THEN
        INSERT INTO public.movimientos_creditos (user_id, tipo, cantidad, motivo, created_at)
        VALUES (p_user_id, 'gasto', p_cantidad, p_motivo, NOW());
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 2: ARREGLAR RLS DE POSTULACIONES
-- ============================================
-- Error 403: permission denied for table postulaciones

-- Desactivar RLS temporalmente
ALTER TABLE public.postulaciones DISABLE ROW LEVEL SECURITY;

-- Eliminar todas las políticas existentes
DROP POLICY IF EXISTS "post_insert" ON public.postulaciones;
DROP POLICY IF EXISTS "post_select" ON public.postulaciones;
DROP POLICY IF EXISTS "post_update" ON public.postulaciones;
DROP POLICY IF EXISTS "post_delete" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_insert" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_select" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_update" ON public.postulaciones;

-- Reactivar RLS
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;

-- Crear políticas más permisivas pero seguras
-- SELECT: El profesional puede ver sus propias postulaciones
--         El dueño de la solicitud puede ver las postulaciones
CREATE POLICY "postulaciones_select_policy" ON public.postulaciones
FOR SELECT TO authenticated
USING (
    auth.uid() = profesional_id
    OR
    auth.uid() IN (
        SELECT user_id FROM public.solicitudes_trabajo WHERE id = solicitud_id
    )
);

-- INSERT: Cualquier usuario autenticado puede postularse
CREATE POLICY "postulaciones_insert_policy" ON public.postulaciones
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = profesional_id);

-- UPDATE: Solo el profesional puede actualizar su postulación
--         El dueño de la solicitud puede cambiar el estado
CREATE POLICY "postulaciones_update_policy" ON public.postulaciones
FOR UPDATE TO authenticated
USING (
    auth.uid() = profesional_id
    OR
    auth.uid() IN (
        SELECT user_id FROM public.solicitudes_trabajo WHERE id = solicitud_id
    )
);

-- DELETE: Solo el profesional puede eliminar su postulación
CREATE POLICY "postulaciones_delete_policy" ON public.postulaciones
FOR DELETE TO authenticated
USING (auth.uid() = profesional_id);

-- ============================================
-- PASO 3: ARREGLAR FORO (Respuestas y mejor respuesta)
-- ============================================

-- Asegurar que la tabla foro_respuestas existe y tiene las columnas correctas
ALTER TABLE public.foro_respuestas ADD COLUMN IF NOT EXISTS es_mejor_respuesta BOOLEAN DEFAULT false;
ALTER TABLE public.foro_respuestas ADD COLUMN IF NOT EXISTS total_votos INT DEFAULT 0;

-- Función para seleccionar mejor respuesta
CREATE OR REPLACE FUNCTION public.seleccionar_mejor_respuesta(
    p_pregunta_id UUID,
    p_respuesta_id UUID,
    p_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_pregunta_owner UUID;
BEGIN
    -- Verificar que el usuario es el dueño de la pregunta
    SELECT user_id INTO v_pregunta_owner
    FROM public.foro_preguntas
    WHERE id = p_pregunta_id;

    IF v_pregunta_owner != p_user_id THEN
        RETURN FALSE;
    END IF;

    -- Quitar el estado de mejor respuesta a todas las respuestas de esta pregunta
    UPDATE public.foro_respuestas
    SET es_mejor_respuesta = false
    WHERE pregunta_id = p_pregunta_id;

    -- Marcar la nueva mejor respuesta
    UPDATE public.foro_respuestas
    SET es_mejor_respuesta = true
    WHERE id = p_respuesta_id AND pregunta_id = p_pregunta_id;

    -- Marcar la pregunta como resuelta
    UPDATE public.foro_preguntas
    SET
        resuelta = true,
        mejor_respuesta_id = p_respuesta_id,
        updated_at = NOW()
    WHERE id = p_pregunta_id;

    -- Dar créditos al autor de la mejor respuesta
    UPDATE public.users
    SET
        creditos = COALESCE(creditos, 0) + 5,
        creditos_totales_ganados = COALESCE(creditos_totales_ganados, 0) + 5
    WHERE id = (SELECT user_id FROM public.foro_respuestas WHERE id = p_respuesta_id);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para votar una respuesta
CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.foro_respuestas
    SET total_votos = COALESCE(total_votos, 0) + 1
    WHERE id = p_respuesta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 4: VERIFICAR RLS DEL FORO
-- ============================================

-- Desactivar y reactivar RLS para foro_respuestas
ALTER TABLE public.foro_respuestas DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "fr_select" ON public.foro_respuestas;
DROP POLICY IF EXISTS "fr_insert" ON public.foro_respuestas;
DROP POLICY IF EXISTS "fr_update" ON public.foro_respuestas;
DROP POLICY IF EXISTS "fr_delete" ON public.foro_respuestas;

ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- Políticas para foro_respuestas
CREATE POLICY "foro_respuestas_select" ON public.foro_respuestas
FOR SELECT TO authenticated
USING (true);

CREATE POLICY "foro_respuestas_insert" ON public.foro_respuestas
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "foro_respuestas_update" ON public.foro_respuestas
FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "foro_respuestas_delete" ON public.foro_respuestas
FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PASO 5: GRANT PERMISSIONS
-- ============================================
GRANT EXECUTE ON FUNCTION public.descontar_creditos(UUID, INT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.seleccionar_mejor_respuesta(UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.votar_respuesta(UUID) TO authenticated;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT 'FIXES BUGS 21 ENERO - EJECUTADO CORRECTAMENTE' as resultado;
