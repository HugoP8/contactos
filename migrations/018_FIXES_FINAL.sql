-- ============================================
-- MIGRACIÓN 018: FIXES COMPLETOS - VERSIÓN FINAL
-- UUID Admin: 8f07dcb8-2cd4-4157-a8ba-fe7198137810
-- ============================================

-- ============================================
-- 1. FUNCIONES RPC
-- ============================================

-- Función descontar créditos
DROP FUNCTION IF EXISTS descontar_creditos(uuid, integer, text);
CREATE OR REPLACE FUNCTION descontar_creditos(
    p_user_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_creditos_actuales INTEGER;
BEGIN
    SELECT creditos INTO v_creditos_actuales
    FROM public.users WHERE id = p_user_id FOR UPDATE;

    IF v_creditos_actuales IS NULL OR v_creditos_actuales < p_cantidad THEN
        RETURN FALSE;
    END IF;

    UPDATE public.users
    SET creditos = creditos - p_cantidad, updated_at = NOW()
    WHERE id = p_user_id;

    INSERT INTO public.movimientos_creditos (user_id, tipo, cantidad, motivo, saldo_anterior, saldo_nuevo, created_at)
    VALUES (p_user_id, 'gasto', p_cantidad, p_motivo, v_creditos_actuales, v_creditos_actuales - p_cantidad, NOW());

    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN RETURN FALSE;
END;
$$;

-- Función incrementar créditos
DROP FUNCTION IF EXISTS incrementar_creditos(uuid, integer, text, text);
CREATE OR REPLACE FUNCTION incrementar_creditos(
    p_user_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT,
    p_descripcion TEXT DEFAULT ''
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_creditos_actuales INTEGER;
BEGIN
    SELECT creditos INTO v_creditos_actuales
    FROM public.users WHERE id = p_user_id FOR UPDATE;

    IF v_creditos_actuales IS NULL THEN RETURN FALSE; END IF;

    UPDATE public.users
    SET creditos = creditos + p_cantidad, updated_at = NOW()
    WHERE id = p_user_id;

    INSERT INTO public.movimientos_creditos (user_id, tipo, cantidad, motivo, saldo_anterior, saldo_nuevo, created_at)
    VALUES (p_user_id, 'recarga', p_cantidad, p_motivo, v_creditos_actuales, v_creditos_actuales + p_cantidad, NOW());

    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN RETURN FALSE;
END;
$$;

-- Función corregir contador de respuestas
DROP FUNCTION IF EXISTS incrementar_respuestas_pregunta(uuid);
CREATE OR REPLACE FUNCTION incrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.foro_preguntas
    SET total_respuestas = (SELECT COUNT(*) FROM public.foro_respuestas WHERE pregunta_id = p_pregunta_id),
        updated_at = NOW()
    WHERE id = p_pregunta_id;
END;
$$;

-- Función premiar mejor respuesta (2 créditos)
DROP FUNCTION IF EXISTS premiar_mejor_respuesta(uuid, uuid);
CREATE OR REPLACE FUNCTION premiar_mejor_respuesta(
    p_pregunta_id UUID,
    p_respuesta_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_autor_id UUID;
BEGIN
    SELECT user_id INTO v_autor_id FROM public.foro_respuestas WHERE id = p_respuesta_id;
    IF v_autor_id IS NULL THEN RETURN FALSE; END IF;

    UPDATE public.foro_preguntas
    SET resuelta = TRUE, mejor_respuesta_id = p_respuesta_id, updated_at = NOW()
    WHERE id = p_pregunta_id;

    UPDATE public.foro_respuestas
    SET es_mejor_respuesta = TRUE, updated_at = NOW()
    WHERE id = p_respuesta_id;

    PERFORM incrementar_creditos(v_autor_id, 2, 'premio_mejor_respuesta', 'Premio por mejor respuesta en el foro');

    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN RETURN FALSE;
END;
$$;

-- ============================================
-- 2. CREAR TABLAS NUEVAS
-- ============================================

-- Tabla de cajeros
CREATE TABLE IF NOT EXISTS public.cajeros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    zona TEXT,
    telefono TEXT NOT NULL,
    whatsapp TEXT,
    qr_image TEXT,
    activo BOOLEAN DEFAULT TRUE,
    total_recargas INTEGER DEFAULT 0,
    monto_total_recargado DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cajeros_ciudad ON public.cajeros(ciudad);
CREATE INDEX IF NOT EXISTS idx_cajeros_activo ON public.cajeros(activo);

-- Tabla de mis contactos
CREATE TABLE IF NOT EXISTS public.mis_contactos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    profesional_id UUID NOT NULL REFERENCES public.perfiles_profesionales(id) ON DELETE CASCADE,
    notas TEXT,
    favorito BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, profesional_id)
);

CREATE INDEX IF NOT EXISTS idx_mis_contactos_user ON public.mis_contactos(user_id);
CREATE INDEX IF NOT EXISTS idx_mis_contactos_profesional ON public.mis_contactos(profesional_id);

-- ============================================
-- 3. HACER ADMIN AL USUARIO ESPECÍFICO
-- ============================================

UPDATE public.users
SET
    rol = 'admin',
    tipo_cuenta = 'premium',
    creditos = 9999,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    updated_at = NOW()
WHERE id = '8f07dcb8-2cd4-4157-a8ba-fe7198137810';

-- ============================================
-- 4. INSERTAR CAJEROS DE EJEMPLO
-- ============================================

INSERT INTO public.cajeros (id, nombre, ciudad, zona, telefono, whatsapp, activo) VALUES
(gen_random_uuid(), 'Cajero Central La Paz', 'La Paz', 'Centro', '71234567', '59171234567', TRUE),
(gen_random_uuid(), 'Cajero Sopocachi', 'La Paz', 'Sopocachi', '72345678', '59172345678', TRUE),
(gen_random_uuid(), 'Cajero Santa Cruz Centro', 'Santa Cruz', 'Centro', '73456789', '59173456789', TRUE),
(gen_random_uuid(), 'Cajero Equipetrol', 'Santa Cruz', 'Equipetrol', '74567890', '59174567890', TRUE),
(gen_random_uuid(), 'Cajero Cochabamba', 'Cochabamba', 'Centro', '75678901', '59175678901', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. CORREGIR CONTADORES DEL FORO
-- ============================================

UPDATE public.foro_preguntas fp
SET total_respuestas = (
    SELECT COUNT(*) FROM public.foro_respuestas fr WHERE fr.pregunta_id = fp.id
);

-- ============================================
-- 6. ACTUALIZAR CALIFICACIONES DE PROFESIONALES
-- ============================================

UPDATE public.perfiles_profesionales pp
SET
    total_resenas = COALESCE((SELECT COUNT(*) FROM public.resenas r WHERE r.profesional_id = pp.id), 0),
    calificacion_promedio = COALESCE((SELECT AVG(calificacion)::DECIMAL(3,2) FROM public.resenas r WHERE r.profesional_id = pp.id), 0);

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'MIGRACIÓN COMPLETADA' as status;
SELECT 'Admin configurado: ' || email as admin FROM public.users WHERE id = '8f07dcb8-2cd4-4157-a8ba-fe7198137810';
SELECT 'Cajeros creados: ' || COUNT(*) as cajeros FROM public.cajeros;
SELECT 'Tabla mis_contactos creada: OK' as contactos;
