-- ============================================================
-- MIGRACIÓN 020: FIXES CRÍTICOS DE PRODUCCIÓN
-- Fecha: 2026-02-25
-- Descripción: Corrige errores críticos que impiden el funcionamiento
-- ============================================================

-- ============================================================
-- FIX 1: ELIMINAR FUNCIÓN DUPLICADA descontar_creditos
-- Error: "Could not choose the best candidate function"
-- PGRST203 - ambiguedad por función sobrecargada
-- ============================================================

-- Eliminar la versión con character varying (dejar solo la de text)
DROP FUNCTION IF EXISTS public.descontar_creditos(uuid, integer, character varying);

-- Si la función text no existe, crearla:
CREATE OR REPLACE FUNCTION public.descontar_creditos(
  p_user_id uuid,
  p_cantidad integer,
  p_motivo text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_creditos_actuales integer;
BEGIN
  -- Obtener créditos actuales
  SELECT creditos INTO v_creditos_actuales
  FROM public.users
  WHERE id = p_user_id;

  -- Verificar si tiene suficientes créditos
  IF v_creditos_actuales IS NULL OR v_creditos_actuales < p_cantidad THEN
    RETURN false;
  END IF;

  -- Descontar créditos
  UPDATE public.users
  SET creditos = creditos - p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Registrar transacción
  INSERT INTO public.transacciones_creditos (
    user_id, tipo, cantidad, motivo, created_at
  ) VALUES (
    p_user_id, 'gasto', p_cantidad, p_motivo, NOW()
  ) ON CONFLICT DO NOTHING;

  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- ============================================================
-- FIX 2: RLS POLICIES PARA TABLA postulaciones
-- Error: "permission denied for table postulaciones" (403)
-- ============================================================

-- Activar RLS en postulaciones (si no está activado)
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas antiguas si existen
DROP POLICY IF EXISTS "Profesionales pueden ver sus propias postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Dueños de solicitud pueden ver postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Profesionales pueden crear postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Dueños pueden actualizar estado postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_select_policy" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_insert_policy" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_update_policy" ON public.postulaciones;
DROP POLICY IF EXISTS "postulaciones_delete_policy" ON public.postulaciones;

-- Política SELECT: El profesional ve sus propias postulaciones + el dueño de la solicitud ve las de su solicitud
CREATE POLICY "postulaciones_select_policy"
ON public.postulaciones
FOR SELECT
USING (
  auth.uid() = profesional_id
  OR
  auth.uid() = (
    SELECT user_id FROM public.solicitudes_trabajo
    WHERE id = solicitud_id
    LIMIT 1
  )
);

-- Política INSERT: Solo profesionales pueden postularse (1 vez por solicitud)
CREATE POLICY "postulaciones_insert_policy"
ON public.postulaciones
FOR INSERT
WITH CHECK (
  auth.uid() = profesional_id
  AND
  NOT EXISTS (
    SELECT 1 FROM public.postulaciones p2
    WHERE p2.profesional_id = auth.uid()
    AND p2.solicitud_id = solicitud_id
  )
);

-- Política UPDATE: Solo el dueño de la solicitud puede aceptar/rechazar
CREATE POLICY "postulaciones_update_policy"
ON public.postulaciones
FOR UPDATE
USING (
  auth.uid() = (
    SELECT user_id FROM public.solicitudes_trabajo
    WHERE id = solicitud_id
    LIMIT 1
  )
);

-- Política DELETE: Solo el profesional puede retirar su postulación
CREATE POLICY "postulaciones_delete_policy"
ON public.postulaciones
FOR DELETE
USING (auth.uid() = profesional_id);

-- ============================================================
-- FIX 3: CREAR TABLA postulaciones SI NO EXISTE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.postulaciones (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  solicitud_id uuid REFERENCES public.solicitudes_trabajo(id) ON DELETE CASCADE NOT NULL,
  profesional_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  mensaje_propuesta text NOT NULL,
  precio_propuesto numeric(10,2),
  tiempo_estimado text,
  estado text DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'seleccionado', 'rechazado')),
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),
  UNIQUE(solicitud_id, profesional_id)
);

-- Re-aplicar RLS después de crear
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FIX 4: RLS PARA SOLICITUDES_TRABAJO (si falta)
-- ============================================================

ALTER TABLE public.solicitudes_trabajo ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "solicitudes_select_all" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "solicitudes_insert_own" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "solicitudes_update_own" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "solicitudes_delete_own" ON public.solicitudes_trabajo;

-- Cualquier usuario autenticado puede ver solicitudes activas
CREATE POLICY "solicitudes_select_all"
ON public.solicitudes_trabajo
FOR SELECT
USING (
  auth.uid() IS NOT NULL
  AND (
    (estado = 'activa' AND visible = true)
    OR user_id = auth.uid()
  )
);

-- Solo el dueño puede crear solicitudes
CREATE POLICY "solicitudes_insert_own"
ON public.solicitudes_trabajo
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Solo el dueño puede actualizar
CREATE POLICY "solicitudes_update_own"
ON public.solicitudes_trabajo
FOR UPDATE
USING (auth.uid() = user_id);

-- Solo el dueño puede eliminar
CREATE POLICY "solicitudes_delete_own"
ON public.solicitudes_trabajo
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================
-- FIX 5: FUNCIÓN RPC PARA ENVIAR POSTULACIÓN
-- Permite al profesional postularse y actualiza contador
-- ============================================================

CREATE OR REPLACE FUNCTION public.enviar_postulacion(
  p_solicitud_id uuid,
  p_profesional_id uuid,
  p_mensaje text,
  p_precio numeric DEFAULT NULL,
  p_tiempo_estimado text DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result json;
  v_postulacion_id uuid;
BEGIN
  -- Verificar que no haya postulado antes
  IF EXISTS (
    SELECT 1 FROM public.postulaciones
    WHERE solicitud_id = p_solicitud_id
    AND profesional_id = p_profesional_id
  ) THEN
    RETURN json_build_object('success', false, 'error', 'Ya te has postulado a esta solicitud');
  END IF;

  -- Verificar que la solicitud esté activa
  IF NOT EXISTS (
    SELECT 1 FROM public.solicitudes_trabajo
    WHERE id = p_solicitud_id AND estado = 'activa' AND visible = true
  ) THEN
    RETURN json_build_object('success', false, 'error', 'La solicitud no está disponible');
  END IF;

  -- Insertar postulación
  INSERT INTO public.postulaciones (
    solicitud_id, profesional_id, mensaje_propuesta,
    precio_propuesto, tiempo_estimado, estado
  ) VALUES (
    p_solicitud_id, p_profesional_id, p_mensaje,
    p_precio, p_tiempo_estimado, 'pendiente'
  )
  RETURNING id INTO v_postulacion_id;

  -- Incrementar contador de postulaciones en la solicitud
  UPDATE public.solicitudes_trabajo
  SET total_postulaciones = COALESCE(total_postulaciones, 0) + 1,
      updated_at = NOW()
  WHERE id = p_solicitud_id;

  RETURN json_build_object(
    'success', true,
    'postulacion_id', v_postulacion_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- ============================================================
-- FIX 6: FUNCIÓN PARA ACEPTAR/RECHAZAR POSTULACIONES
-- ============================================================

CREATE OR REPLACE FUNCTION public.actualizar_estado_postulacion(
  p_postulacion_id uuid,
  p_nuevo_estado text,
  p_user_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_solicitud_id uuid;
  v_solicitud_owner uuid;
BEGIN
  -- Obtener la solicitud de esta postulación
  SELECT solicitud_id INTO v_solicitud_id
  FROM public.postulaciones
  WHERE id = p_postulacion_id;

  IF v_solicitud_id IS NULL THEN
    RETURN false;
  END IF;

  -- Verificar que el usuario sea el dueño de la solicitud
  SELECT user_id INTO v_solicitud_owner
  FROM public.solicitudes_trabajo
  WHERE id = v_solicitud_id;

  IF v_solicitud_owner != p_user_id THEN
    RETURN false;
  END IF;

  -- Actualizar estado
  UPDATE public.postulaciones
  SET estado = p_nuevo_estado, updated_at = NOW()
  WHERE id = p_postulacion_id;

  -- Si se selecciona, rechazar las demás
  IF p_nuevo_estado = 'seleccionado' THEN
    UPDATE public.postulaciones
    SET estado = 'rechazado', updated_at = NOW()
    WHERE solicitud_id = v_solicitud_id
    AND id != p_postulacion_id
    AND estado = 'pendiente';

    -- Marcar la solicitud como en proceso
    UPDATE public.solicitudes_trabajo
    SET estado = 'en_proceso', updated_at = NOW()
    WHERE id = v_solicitud_id;
  END IF;

  RETURN true;
END;
$$;

-- ============================================================
-- FIX 7: FUNCIÓN PARA PREMIAR MEJOR RESPUESTA (Foro)
-- Si no existe, crearla para evitar errores
-- ============================================================

CREATE OR REPLACE FUNCTION public.premiar_mejor_respuesta(
  p_pregunta_id uuid,
  p_respuesta_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_respondedor_id uuid;
  v_pregunta_owner uuid;
BEGIN
  -- Obtener el autor de la respuesta
  SELECT user_id INTO v_respondedor_id
  FROM public.foro_respuestas
  WHERE id = p_respuesta_id;

  -- Obtener el dueño de la pregunta para verificar
  SELECT user_id INTO v_pregunta_owner
  FROM public.foro_preguntas
  WHERE id = p_pregunta_id;

  IF v_respondedor_id IS NULL THEN
    RETURN false;
  END IF;

  -- Marcar como mejor respuesta
  UPDATE public.foro_respuestas
  SET es_mejor_respuesta = true, updated_at = NOW()
  WHERE id = p_respuesta_id;

  -- Marcar la pregunta como resuelta
  UPDATE public.foro_preguntas
  SET resuelta = true,
      mejor_respuesta_id = p_respuesta_id,
      updated_at = NOW()
  WHERE id = p_pregunta_id;

  -- Premiar al respondedor con créditos
  UPDATE public.users
  SET creditos = creditos + 2,
      updated_at = NOW()
  WHERE id = v_respondedor_id;

  -- Registrar la transacción
  INSERT INTO public.transacciones_creditos (
    user_id, tipo, cantidad, motivo, created_at
  ) VALUES (
    v_respondedor_id, 'ingreso', 2, 'mejor_respuesta_foro', NOW()
  ) ON CONFLICT DO NOTHING;

  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- ============================================================
-- FIX 8: FUNCIONES AUXILIARES DEL FORO (si no existen)
-- ============================================================

-- Incrementar vistas de una pregunta
CREATE OR REPLACE FUNCTION public.incrementar_vistas_pregunta(p_pregunta_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_vistas = COALESCE(total_vistas, 0) + 1
  WHERE id = p_pregunta_id;
END;
$$;

-- Incrementar respuestas de una pregunta
CREATE OR REPLACE FUNCTION public.incrementar_respuestas_pregunta(p_pregunta_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = COALESCE(total_respuestas, 0) + 1,
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$;

-- Decrementar respuestas de una pregunta
CREATE OR REPLACE FUNCTION public.decrementar_respuestas_pregunta(p_pregunta_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = GREATEST(COALESCE(total_respuestas, 0) - 1, 0),
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$;

-- Votar respuesta
CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.foro_respuestas
  SET total_votos = COALESCE(total_votos, 0) + 1
  WHERE id = p_respuesta_id;
END;
$$;

-- ============================================================
-- FIX 9: RLS PARA FORO (si falta)
-- ============================================================

ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- Foro preguntas: todos autenticados pueden leer
DROP POLICY IF EXISTS "foro_preguntas_select" ON public.foro_preguntas;
DROP POLICY IF EXISTS "foro_preguntas_insert" ON public.foro_preguntas;
DROP POLICY IF EXISTS "foro_preguntas_update" ON public.foro_preguntas;
DROP POLICY IF EXISTS "foro_preguntas_delete" ON public.foro_preguntas;

CREATE POLICY "foro_preguntas_select"
ON public.foro_preguntas FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "foro_preguntas_insert"
ON public.foro_preguntas FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "foro_preguntas_update"
ON public.foro_preguntas FOR UPDATE
USING (auth.uid() = user_id OR auth.uid() IN (SELECT id FROM public.users WHERE rol = 'admin'));

CREATE POLICY "foro_preguntas_delete"
ON public.foro_preguntas FOR DELETE
USING (auth.uid() = user_id OR auth.uid() IN (SELECT id FROM public.users WHERE rol = 'admin'));

-- Foro respuestas: todos autenticados pueden leer
DROP POLICY IF EXISTS "foro_respuestas_select" ON public.foro_respuestas;
DROP POLICY IF EXISTS "foro_respuestas_insert" ON public.foro_respuestas;
DROP POLICY IF EXISTS "foro_respuestas_update" ON public.foro_respuestas;
DROP POLICY IF EXISTS "foro_respuestas_delete" ON public.foro_respuestas;

CREATE POLICY "foro_respuestas_select"
ON public.foro_respuestas FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "foro_respuestas_insert"
ON public.foro_respuestas FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "foro_respuestas_update"
ON public.foro_respuestas FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "foro_respuestas_delete"
ON public.foro_respuestas FOR DELETE
USING (auth.uid() = user_id OR auth.uid() IN (SELECT id FROM public.users WHERE rol = 'admin'));

-- ============================================================
-- FIX 10: INCREMENTAR CRÉDITOS (si la función tiene problemas)
-- ============================================================

CREATE OR REPLACE FUNCTION public.incrementar_creditos(
  p_user_id uuid,
  p_cantidad integer,
  p_motivo text,
  p_descripcion text DEFAULT ''
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.users
  SET creditos = creditos + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO public.transacciones_creditos (
    user_id, tipo, cantidad, motivo, created_at
  ) VALUES (
    p_user_id, 'ingreso', p_cantidad, p_motivo, NOW()
  ) ON CONFLICT DO NOTHING;

  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- ============================================================
-- FIX 11: FUNCIÓN PUEDE_PUBLICAR_SOLICITUD_GRATIS
-- ============================================================

CREATE OR REPLACE FUNCTION public.puede_publicar_solicitud_gratis(p_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tiene_token boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM public.tokens_especiales
    WHERE user_id = p_user_id
    AND tipo = 'solicitud_gratuita'
    AND usado = false
    AND (expires_at IS NULL OR expires_at > NOW())
  ) INTO v_tiene_token;

  RETURN v_tiene_token;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- ============================================================
-- GRANT PERMISOS A authenticated
-- ============================================================

GRANT EXECUTE ON FUNCTION public.descontar_creditos(uuid, integer, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.incrementar_creditos(uuid, integer, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.enviar_postulacion(uuid, uuid, text, numeric, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.actualizar_estado_postulacion(uuid, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.premiar_mejor_respuesta(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.incrementar_vistas_pregunta(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.incrementar_respuestas_pregunta(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.decrementar_respuestas_pregunta(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.votar_respuesta(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.puede_publicar_solicitud_gratis(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.premiar_mejor_respuesta(uuid, uuid) TO authenticated;

-- Grants en tablas
GRANT ALL ON public.postulaciones TO authenticated;
GRANT ALL ON public.solicitudes_trabajo TO authenticated;
GRANT ALL ON public.foro_preguntas TO authenticated;
GRANT ALL ON public.foro_respuestas TO authenticated;
