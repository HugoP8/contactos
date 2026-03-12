-- ============================================
-- FIXES FINALES 22 ENERO 2026
-- ============================================
-- IMPORTANTE: Ejecutar este archivo COMPLETO en Supabase
-- Este archivo soluciona DEFINITIVAMENTE:
-- 1. Error 300 Multiple Choices en descontar_creditos
-- 2. Error 403 Forbidden en postulaciones
-- 3. Problemas con el foro
-- ============================================

-- ============================================
-- PASO 1: ELIMINAR TODAS LAS FUNCIONES DUPLICADAS
-- ============================================

-- Eliminar TODAS las posibles versiones de descontar_creditos
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT p.proname, pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' AND p.proname = 'descontar_creditos'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.descontar_creditos(' || r.args || ') CASCADE';
        RAISE NOTICE 'Eliminada función: descontar_creditos(%)', r.args;
    END LOOP;
END $$;

-- Por si acaso, eliminar explícitamente todas las variantes conocidas
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, integer, text) CASCADE;
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, integer, character varying) CASCADE;
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, int, text) CASCADE;
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, int, varchar) CASCADE;
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, int4, text) CASCADE;
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, int4, varchar) CASCADE;

-- ============================================
-- PASO 2: CREAR FUNCIÓN ÚNICA descontar_creditos
-- ============================================

CREATE OR REPLACE FUNCTION public.descontar_creditos(
    p_user_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT DEFAULT 'gasto'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_creditos INTEGER;
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

    -- Registrar movimiento
    INSERT INTO public.movimientos_creditos (user_id, tipo, cantidad, motivo, created_at)
    VALUES (p_user_id, 'gasto', p_cantidad, p_motivo, NOW())
    ON CONFLICT DO NOTHING;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- Dar permisos
GRANT EXECUTE ON FUNCTION public.descontar_creditos(UUID, INTEGER, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.descontar_creditos(UUID, INTEGER, TEXT) TO anon;

-- ============================================
-- PASO 3: ARREGLAR RLS DE POSTULACIONES
-- ============================================

-- Deshabilitar RLS temporalmente
ALTER TABLE IF EXISTS public.postulaciones DISABLE ROW LEVEL SECURITY;

-- Eliminar TODAS las políticas existentes
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'postulaciones' AND schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON public.postulaciones';
        RAISE NOTICE 'Eliminada política: %', r.policyname;
    END LOOP;
END $$;

-- Habilitar RLS
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;

-- Crear políticas nuevas y permisivas
CREATE POLICY "postulaciones_all_select" ON public.postulaciones
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "postulaciones_all_insert" ON public.postulaciones
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = profesional_id);

CREATE POLICY "postulaciones_all_update" ON public.postulaciones
    FOR UPDATE TO authenticated
    USING (
        auth.uid() = profesional_id
        OR EXISTS (
            SELECT 1 FROM public.solicitudes_trabajo
            WHERE id = postulaciones.solicitud_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "postulaciones_all_delete" ON public.postulaciones
    FOR DELETE TO authenticated
    USING (auth.uid() = profesional_id);

-- ============================================
-- PASO 4: ARREGLAR FORO
-- ============================================

-- Asegurar columnas en foro_respuestas
ALTER TABLE public.foro_respuestas
    ADD COLUMN IF NOT EXISTS es_mejor_respuesta BOOLEAN DEFAULT false;
ALTER TABLE public.foro_respuestas
    ADD COLUMN IF NOT EXISTS total_votos INTEGER DEFAULT 0;

-- Asegurar columnas en foro_preguntas
ALTER TABLE public.foro_preguntas
    ADD COLUMN IF NOT EXISTS resuelta BOOLEAN DEFAULT false;
ALTER TABLE public.foro_preguntas
    ADD COLUMN IF NOT EXISTS mejor_respuesta_id UUID;
ALTER TABLE public.foro_preguntas
    ADD COLUMN IF NOT EXISTS total_respuestas INTEGER DEFAULT 0;

-- Actualizar contador de respuestas
UPDATE public.foro_preguntas fp
SET total_respuestas = (
    SELECT COUNT(*) FROM public.foro_respuestas fr WHERE fr.pregunta_id = fp.id
);

-- Deshabilitar RLS temporalmente para foro_respuestas
ALTER TABLE IF EXISTS public.foro_respuestas DISABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'foro_respuestas' AND schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON public.foro_respuestas';
    END LOOP;
END $$;

-- Habilitar RLS
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- Crear políticas para foro_respuestas
CREATE POLICY "foro_resp_select" ON public.foro_respuestas
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "foro_resp_insert" ON public.foro_respuestas
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "foro_resp_update" ON public.foro_respuestas
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id OR auth.uid() IN (
        SELECT user_id FROM public.foro_preguntas WHERE id = pregunta_id
    ));

CREATE POLICY "foro_resp_delete" ON public.foro_respuestas
    FOR DELETE TO authenticated
    USING (auth.uid() = user_id);

-- ============================================
-- PASO 5: FUNCIÓN PARA MARCAR MEJOR RESPUESTA
-- ============================================

-- Eliminar versiones anteriores
DROP FUNCTION IF EXISTS public.seleccionar_mejor_respuesta(UUID, UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.marcar_mejor_respuesta(UUID, UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.marcar_mejor_respuesta(
    p_pregunta_id UUID,
    p_respuesta_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_pregunta_owner UUID;
    v_respuesta_autor UUID;
BEGIN
    -- Verificar que el usuario actual es el dueño de la pregunta
    SELECT user_id INTO v_pregunta_owner
    FROM public.foro_preguntas
    WHERE id = p_pregunta_id;

    IF v_pregunta_owner != auth.uid() THEN
        RETURN FALSE;
    END IF;

    -- Obtener el autor de la respuesta
    SELECT user_id INTO v_respuesta_autor
    FROM public.foro_respuestas
    WHERE id = p_respuesta_id AND pregunta_id = p_pregunta_id;

    IF v_respuesta_autor IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Quitar mejor respuesta anterior
    UPDATE public.foro_respuestas
    SET es_mejor_respuesta = false
    WHERE pregunta_id = p_pregunta_id;

    -- Marcar nueva mejor respuesta
    UPDATE public.foro_respuestas
    SET es_mejor_respuesta = true
    WHERE id = p_respuesta_id;

    -- Marcar pregunta como resuelta
    UPDATE public.foro_preguntas
    SET
        resuelta = true,
        mejor_respuesta_id = p_respuesta_id,
        updated_at = NOW()
    WHERE id = p_pregunta_id;

    -- Dar 5 créditos al autor de la mejor respuesta
    UPDATE public.users
    SET
        creditos = COALESCE(creditos, 0) + 5,
        creditos_totales_ganados = COALESCE(creditos_totales_ganados, 0) + 5
    WHERE id = v_respuesta_autor;

    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.marcar_mejor_respuesta(UUID, UUID) TO authenticated;

-- ============================================
-- PASO 6: FUNCIÓN PARA VOTAR RESPUESTA
-- ============================================

DROP FUNCTION IF EXISTS public.votar_respuesta(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.foro_respuestas
    SET total_votos = COALESCE(total_votos, 0) + 1
    WHERE id = p_respuesta_id;

    RETURN FOUND;
END;
$$;

GRANT EXECUTE ON FUNCTION public.votar_respuesta(UUID) TO authenticated;

-- ============================================
-- PASO 7: TRIGGER PARA ACTUALIZAR CONTADOR DE RESPUESTAS
-- ============================================

-- Eliminar trigger anterior si existe
DROP TRIGGER IF EXISTS trigger_actualizar_total_respuestas ON public.foro_respuestas;
DROP FUNCTION IF EXISTS public.actualizar_total_respuestas() CASCADE;

CREATE OR REPLACE FUNCTION public.actualizar_total_respuestas()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.foro_preguntas
        SET total_respuestas = COALESCE(total_respuestas, 0) + 1
        WHERE id = NEW.pregunta_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.foro_preguntas
        SET total_respuestas = GREATEST(COALESCE(total_respuestas, 0) - 1, 0)
        WHERE id = OLD.pregunta_id;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trigger_actualizar_total_respuestas
AFTER INSERT OR DELETE ON public.foro_respuestas
FOR EACH ROW EXECUTE FUNCTION public.actualizar_total_respuestas();

-- ============================================
-- PASO 8: PERMISOS ADICIONALES EN TABLAS
-- ============================================

-- Asegurar que authenticated puede acceder a las tablas necesarias
GRANT SELECT, INSERT, UPDATE, DELETE ON public.postulaciones TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.foro_preguntas TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.foro_respuestas TO authenticated;
GRANT SELECT, UPDATE ON public.users TO authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Verificar que solo hay UNA función descontar_creditos
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'descontar_creditos';

    IF v_count = 1 THEN
        RAISE NOTICE '✅ CORRECTO: Solo existe 1 función descontar_creditos';
    ELSE
        RAISE WARNING '⚠️ ADVERTENCIA: Existen % funciones descontar_creditos', v_count;
    END IF;
END $$;

-- ============================================
-- PASO 9: FUNCIONES RPC ADICIONALES PARA EL FORO
-- ============================================

-- Función para incrementar vistas de pregunta
DROP FUNCTION IF EXISTS public.incrementar_vistas_pregunta(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.incrementar_vistas_pregunta(p_pregunta_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.foro_preguntas
    SET total_vistas = COALESCE(total_vistas, 0) + 1
    WHERE id = p_pregunta_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.incrementar_vistas_pregunta(UUID) TO authenticated;

-- Función para incrementar respuestas de pregunta
DROP FUNCTION IF EXISTS public.incrementar_respuestas_pregunta(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.incrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.foro_preguntas
    SET total_respuestas = COALESCE(total_respuestas, 0) + 1
    WHERE id = p_pregunta_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.incrementar_respuestas_pregunta(UUID) TO authenticated;

-- Función para decrementar respuestas de pregunta
DROP FUNCTION IF EXISTS public.decrementar_respuestas_pregunta(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.decrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.foro_preguntas
    SET total_respuestas = GREATEST(COALESCE(total_respuestas, 0) - 1, 0)
    WHERE id = p_pregunta_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.decrementar_respuestas_pregunta(UUID) TO authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FIXES FINALES 22 ENERO - EJECUTADO CORRECTAMENTE' as resultado;
