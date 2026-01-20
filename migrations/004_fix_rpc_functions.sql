-- ============================================
-- SCRIPT DE CORRECCIÓN DE FUNCIONES RPC
-- APP: CONTACTOS
-- Versión: 1.0
-- Fecha: Enero 2026
-- ============================================
-- EJECUTA ESTE SCRIPT EN SUPABASE SQL EDITOR
-- ============================================

-- ============================================
-- TABLA: tokens_especiales (si no existe)
-- ============================================

CREATE TABLE IF NOT EXISTS public.tokens_especiales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL, -- solicitud_gratuita, etc
  cantidad INT DEFAULT 1,
  usado BOOLEAN DEFAULT false,
  fecha_uso TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tokens_user ON public.tokens_especiales(user_id);
CREATE INDEX IF NOT EXISTS idx_tokens_tipo ON public.tokens_especiales(tipo);
CREATE INDEX IF NOT EXISTS idx_tokens_usado ON public.tokens_especiales(usado);

-- RLS para tokens_especiales
ALTER TABLE public.tokens_especiales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own tokens" ON public.tokens_especiales;
CREATE POLICY "Users can view own tokens"
ON public.tokens_especiales
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own tokens" ON public.tokens_especiales;
CREATE POLICY "Users can insert own tokens"
ON public.tokens_especiales
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own tokens" ON public.tokens_especiales;
CREATE POLICY "Users can update own tokens"
ON public.tokens_especiales
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- FUNCIÓN: puede_publicar_solicitud_gratis
-- Verifica si el usuario tiene un token gratuito disponible
-- ============================================

CREATE OR REPLACE FUNCTION public.puede_publicar_solicitud_gratis(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  tiene_token BOOLEAN;
BEGIN
  -- Verificar si existe un token de solicitud gratuita sin usar
  SELECT EXISTS (
    SELECT 1
    FROM public.tokens_especiales
    WHERE user_id = p_user_id
      AND tipo = 'solicitud_gratuita'
      AND usado = false
      AND cantidad > 0
  ) INTO tiene_token;

  RETURN tiene_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.puede_publicar_solicitud_gratis(UUID) IS 'Verifica si el usuario puede publicar una solicitud gratis (tiene token disponible)';

-- ============================================
-- FUNCIÓN: usar_token_especial
-- Marca un token como usado
-- ============================================

CREATE OR REPLACE FUNCTION public.usar_token_especial(p_user_id UUID, p_tipo VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
  token_id UUID;
BEGIN
  -- Buscar un token disponible
  SELECT id INTO token_id
  FROM public.tokens_especiales
  WHERE user_id = p_user_id
    AND tipo = p_tipo
    AND usado = false
    AND cantidad > 0
  ORDER BY created_at ASC
  LIMIT 1;

  IF token_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Marcar como usado
  UPDATE public.tokens_especiales
  SET usado = true,
      fecha_uso = NOW(),
      cantidad = cantidad - 1
  WHERE id = token_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.usar_token_especial(UUID, VARCHAR) IS 'Usa un token especial del usuario';

-- ============================================
-- FUNCIÓN: descontar_creditos
-- Descuenta créditos y registra el movimiento
-- ============================================

CREATE OR REPLACE FUNCTION public.descontar_creditos(
  p_user_id UUID,
  p_cantidad INT,
  p_motivo VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
  creditos_actuales INT;
  nuevo_saldo INT;
BEGIN
  -- Obtener créditos actuales
  SELECT creditos INTO creditos_actuales
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE; -- Lock para evitar condiciones de carrera

  -- Verificar si tiene suficientes créditos
  IF creditos_actuales < p_cantidad THEN
    RETURN FALSE;
  END IF;

  -- Calcular nuevo saldo
  nuevo_saldo := creditos_actuales - p_cantidad;

  -- Actualizar créditos del usuario
  UPDATE public.users
  SET creditos = nuevo_saldo,
      creditos_totales_gastados = creditos_totales_gastados + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Registrar movimiento de créditos
  INSERT INTO public.movimientos_creditos (
    user_id,
    tipo_movimiento,
    cantidad,
    saldo_anterior,
    saldo_nuevo,
    origen,
    descripcion,
    created_at
  ) VALUES (
    p_user_id,
    'gasto',
    p_cantidad,
    creditos_actuales,
    nuevo_saldo,
    p_motivo,
    'Descuento de créditos: ' || p_motivo,
    NOW()
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.descontar_creditos(UUID, INT, VARCHAR) IS 'Descuenta créditos del usuario y registra el movimiento';

-- ============================================
-- FUNCIÓN: incrementar_creditos (mejorada)
-- Incrementa créditos y registra el movimiento
-- ============================================

CREATE OR REPLACE FUNCTION public.incrementar_creditos(
  p_user_id UUID,
  p_cantidad INT,
  p_motivo VARCHAR DEFAULT 'recarga',
  p_descripcion TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  creditos_actuales INT;
  nuevo_saldo INT;
BEGIN
  -- Obtener créditos actuales
  SELECT creditos INTO creditos_actuales
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE;

  IF creditos_actuales IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Calcular nuevo saldo
  nuevo_saldo := creditos_actuales + p_cantidad;

  -- Actualizar créditos del usuario
  UPDATE public.users
  SET creditos = nuevo_saldo,
      creditos_totales_ganados = creditos_totales_ganados + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Registrar movimiento de créditos
  INSERT INTO public.movimientos_creditos (
    user_id,
    tipo_movimiento,
    cantidad,
    saldo_anterior,
    saldo_nuevo,
    origen,
    descripcion,
    created_at
  ) VALUES (
    p_user_id,
    'ganancia',
    p_cantidad,
    creditos_actuales,
    nuevo_saldo,
    p_motivo,
    COALESCE(p_descripcion, 'Incremento de créditos: ' || p_motivo),
    NOW()
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.incrementar_creditos(UUID, INT, VARCHAR, TEXT) IS 'Incrementa créditos del usuario y registra el movimiento';

-- ============================================
-- CORREGIR TRIGGER handle_new_user
-- Para guardar el nombre correctamente
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  nombre_usuario TEXT;
BEGIN
  -- Intentar obtener el nombre de los metadatos de Google o del formulario
  nombre_usuario := COALESCE(
    NEW.raw_user_meta_data->>'full_name',        -- Google Sign-In
    NEW.raw_user_meta_data->>'name',              -- Alternativa Google
    NEW.raw_user_meta_data->>'nombre_completo',   -- Formulario de registro
    split_part(NEW.email, '@', 1)                 -- Fallback: primera parte del email
  );

  INSERT INTO public.users (
    id,
    email,
    nombre_completo,
    foto_perfil,
    creditos,
    creditos_totales_ganados,
    codigo_referido,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    nombre_usuario,
    NEW.raw_user_meta_data->>'avatar_url',  -- Foto de Google si existe
    50,
    50,
    UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8)),
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recrear el trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- CORREGIR POLÍTICAS RLS DE solicitudes_trabajo
-- Permitir inserción correctamente
-- ============================================

-- Eliminar política existente que puede estar causando problemas
DROP POLICY IF EXISTS "Users can insert their own solicitudes" ON public.solicitudes_trabajo;

-- Crear política corregida para insertar solicitudes
CREATE POLICY "Users can insert their own solicitudes"
ON public.solicitudes_trabajo
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id
  OR user_id = auth.uid()
);

-- Política para que los usuarios puedan ver TODAS las solicitudes activas (para profesionales)
DROP POLICY IF EXISTS "Authenticated users can view active solicitudes" ON public.solicitudes_trabajo;
CREATE POLICY "Authenticated users can view active solicitudes"
ON public.solicitudes_trabajo
FOR SELECT
TO authenticated
USING (
  estado = 'activa' AND visible = true
  OR user_id = auth.uid()
);

-- ============================================
-- CORREGIR POLÍTICAS RLS DE foro_preguntas
-- ============================================

DROP POLICY IF EXISTS "Users can insert preguntas" ON public.foro_preguntas;
CREATE POLICY "Users can insert preguntas"
ON public.foro_preguntas
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- CORREGIR POLÍTICAS RLS DE foro_respuestas
-- ============================================

DROP POLICY IF EXISTS "Users can insert respuestas" ON public.foro_respuestas;
CREATE POLICY "Users can insert respuestas"
ON public.foro_respuestas
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Verificar que las funciones existen
SELECT
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'puede_publicar_solicitud_gratis',
    'descontar_creditos',
    'incrementar_creditos',
    'usar_token_especial',
    'handle_new_user'
  )
ORDER BY routine_name;

-- Verificar políticas de solicitudes_trabajo
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'solicitudes_trabajo';

SELECT '✅ Script de corrección ejecutado exitosamente' as mensaje;
