-- ============================================
-- ESTRUCTURA COMPLETA DE BASE DE DATOS
-- APP: CONTACTOS
-- VERSION: 1.0
-- ============================================
-- EJECUTAR EN SUPABASE SQL EDITOR
-- Este script unifica toda la estructura necesaria
-- ============================================

-- ============================================
-- PARTE 1: EXTENSION UUID
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PARTE 2: TABLA USERS - AGREGAR COLUMNAS FALTANTES
-- ============================================

DO $$
BEGIN
  -- Columna creditos
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'creditos'
  ) THEN
    ALTER TABLE public.users ADD COLUMN creditos INT DEFAULT 50;
  END IF;

  -- Columna creditos_totales_ganados
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'creditos_totales_ganados'
  ) THEN
    ALTER TABLE public.users ADD COLUMN creditos_totales_ganados INT DEFAULT 50;
  END IF;

  -- Columna creditos_totales_gastados
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'creditos_totales_gastados'
  ) THEN
    ALTER TABLE public.users ADD COLUMN creditos_totales_gastados INT DEFAULT 0;
  END IF;

  -- Columna total_solicitudes_publicadas
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'total_solicitudes_publicadas'
  ) THEN
    ALTER TABLE public.users ADD COLUMN total_solicitudes_publicadas INT DEFAULT 0;
  END IF;

  -- Columna verificado
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'verificado'
  ) THEN
    ALTER TABLE public.users ADD COLUMN verificado BOOLEAN DEFAULT false;
  END IF;

  -- Columna perfil_completo
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'perfil_completo'
  ) THEN
    ALTER TABLE public.users ADD COLUMN perfil_completo BOOLEAN DEFAULT false;
  END IF;

  -- Columna rol
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'rol'
  ) THEN
    ALTER TABLE public.users ADD COLUMN rol VARCHAR(20) DEFAULT 'buscador';
  END IF;

  -- Columna tipo_cuenta
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'tipo_cuenta'
  ) THEN
    ALTER TABLE public.users ADD COLUMN tipo_cuenta VARCHAR(20) DEFAULT 'gratuita';
  END IF;

  RAISE NOTICE 'Columnas de users verificadas/agregadas';
END $$;

-- ============================================
-- PARTE 3: TABLA PERFILES_PROFESIONALES
-- ============================================

CREATE TABLE IF NOT EXISTS public.perfiles_profesionales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  nombre_comercial VARCHAR(100),
  descripcion TEXT,
  categoria_principal VARCHAR(50),
  ciudad VARCHAR(50),
  telefono VARCHAR(20),
  whatsapp VARCHAR(20),
  anos_experiencia INT DEFAULT 0,
  rango_precio_desde DECIMAL(10,2),
  rango_precio_hasta DECIMAL(10,2),
  calificacion_promedio DECIMAL(3,2) DEFAULT 5.0,
  total_resenas INT DEFAULT 0,
  total_trabajos_realizados INT DEFAULT 0,
  activo BOOLEAN DEFAULT true,
  visible_busqueda BOOLEAN DEFAULT true,
  verificado BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices para perfiles
CREATE INDEX IF NOT EXISTS idx_perfiles_categoria ON public.perfiles_profesionales(categoria_principal);
CREATE INDEX IF NOT EXISTS idx_perfiles_ciudad ON public.perfiles_profesionales(ciudad);
CREATE INDEX IF NOT EXISTS idx_perfiles_activo ON public.perfiles_profesionales(activo);

-- RLS para perfiles
ALTER TABLE public.perfiles_profesionales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active profiles" ON public.perfiles_profesionales;
CREATE POLICY "Anyone can view active profiles"
ON public.perfiles_profesionales FOR SELECT
TO authenticated
USING (activo = true AND visible_busqueda = true);

DROP POLICY IF EXISTS "Users can manage own profile" ON public.perfiles_profesionales;
CREATE POLICY "Users can manage own profile"
ON public.perfiles_profesionales FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- PARTE 4: TABLA SOLICITUDES_TRABAJO - VERIFICAR COLUMNAS
-- ============================================

DO $$
BEGIN
  -- Columna destacada
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'destacada'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN destacada BOOLEAN DEFAULT false;
  END IF;

  -- Columna total_postulaciones
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'total_postulaciones'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN total_postulaciones INT DEFAULT 0;
  END IF;

  -- Columna profesional_seleccionado
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'profesional_seleccionado'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN profesional_seleccionado UUID;
  END IF;

  RAISE NOTICE 'Columnas de solicitudes_trabajo verificadas/agregadas';
END $$;

-- ============================================
-- PARTE 5: TABLA POSTULACIONES
-- ============================================

CREATE TABLE IF NOT EXISTS public.postulaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  solicitud_id UUID REFERENCES public.solicitudes_trabajo(id) ON DELETE CASCADE,
  profesional_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  mensaje TEXT,
  precio_propuesto DECIMAL(10,2),
  tiempo_estimado VARCHAR(50),
  estado VARCHAR(20) DEFAULT 'pendiente',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_postulaciones_solicitud ON public.postulaciones(solicitud_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_profesional ON public.postulaciones(profesional_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_estado ON public.postulaciones(estado);

-- RLS
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Professionals can create postulaciones" ON public.postulaciones;
CREATE POLICY "Professionals can create postulaciones"
ON public.postulaciones FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = profesional_id);

DROP POLICY IF EXISTS "Users can view relevant postulaciones" ON public.postulaciones;
CREATE POLICY "Users can view relevant postulaciones"
ON public.postulaciones FOR SELECT
TO authenticated
USING (
  auth.uid() = profesional_id OR
  auth.uid() IN (SELECT user_id FROM public.solicitudes_trabajo WHERE id = solicitud_id)
);

DROP POLICY IF EXISTS "Professionals can update own postulaciones" ON public.postulaciones;
CREATE POLICY "Professionals can update own postulaciones"
ON public.postulaciones FOR UPDATE
TO authenticated
USING (auth.uid() = profesional_id)
WITH CHECK (auth.uid() = profesional_id);

-- ============================================
-- PARTE 6: TABLA FORO_PREGUNTAS - CORREGIR ESTRUCTURA
-- ============================================

-- Primero verificamos si existe la tabla
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'foro_preguntas'
  ) THEN
    -- Crear tabla completa
    CREATE TABLE public.foro_preguntas (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
      titulo VARCHAR(200) NOT NULL,
      descripcion TEXT NOT NULL,
      categoria VARCHAR(50) NOT NULL,
      respondida BOOLEAN DEFAULT false,
      total_respuestas INT DEFAULT 0,
      total_votos INT DEFAULT 0,
      visible BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Tabla foro_preguntas creada';
  ELSE
    -- Agregar columnas faltantes

    -- Columna respondida (en lugar de resuelta)
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'respondida'
    ) THEN
      ALTER TABLE public.foro_preguntas ADD COLUMN respondida BOOLEAN DEFAULT false;
      RAISE NOTICE 'Columna respondida agregada';
    END IF;

    -- Columna total_respuestas
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'total_respuestas'
    ) THEN
      ALTER TABLE public.foro_preguntas ADD COLUMN total_respuestas INT DEFAULT 0;
    END IF;

    -- Columna total_votos
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'total_votos'
    ) THEN
      ALTER TABLE public.foro_preguntas ADD COLUMN total_votos INT DEFAULT 0;
    END IF;

    -- Columna visible
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'visible'
    ) THEN
      ALTER TABLE public.foro_preguntas ADD COLUMN visible BOOLEAN DEFAULT true;
    END IF;

    -- Columna updated_at
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'updated_at'
    ) THEN
      ALTER TABLE public.foro_preguntas ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;

    RAISE NOTICE 'Columnas de foro_preguntas verificadas';
  END IF;
END $$;

-- RLS para foro_preguntas
ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view visible questions" ON public.foro_preguntas;
CREATE POLICY "Anyone can view visible questions"
ON public.foro_preguntas FOR SELECT
TO authenticated
USING (visible = true);

DROP POLICY IF EXISTS "Users can create questions" ON public.foro_preguntas;
CREATE POLICY "Users can create questions"
ON public.foro_preguntas FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own questions" ON public.foro_preguntas;
CREATE POLICY "Users can update own questions"
ON public.foro_preguntas FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own questions" ON public.foro_preguntas;
CREATE POLICY "Users can delete own questions"
ON public.foro_preguntas FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PARTE 7: TABLA FORO_RESPUESTAS
-- ============================================

CREATE TABLE IF NOT EXISTS public.foro_respuestas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pregunta_id UUID REFERENCES public.foro_preguntas(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  contenido TEXT NOT NULL,
  es_respuesta_aceptada BOOLEAN DEFAULT false,
  es_mejor_respuesta BOOLEAN DEFAULT false,
  total_votos INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para foro_respuestas
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view respuestas" ON public.foro_respuestas;
CREATE POLICY "Anyone can view respuestas"
ON public.foro_respuestas FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can create respuestas" ON public.foro_respuestas;
CREATE POLICY "Users can create respuestas"
ON public.foro_respuestas FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own respuestas" ON public.foro_respuestas;
CREATE POLICY "Users can update own respuestas"
ON public.foro_respuestas FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PARTE 8: TABLA CAJEROS_VENDEDORES
-- ============================================

CREATE TABLE IF NOT EXISTS public.cajeros_vendedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  nombre_completo VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  whatsapp VARCHAR(20) NOT NULL,
  ciudad VARCHAR(50) NOT NULL,
  zona VARCHAR(100),
  metodos_pago TEXT[] DEFAULT '{"Efectivo", "QR", "Transferencia"}',
  disponible_ahora BOOLEAN DEFAULT true,
  activo BOOLEAN DEFAULT true,
  calificacion_promedio DECIMAL(3,2) DEFAULT 5.0,
  total_transacciones INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active cajeros" ON public.cajeros_vendedores;
CREATE POLICY "Anyone can view active cajeros"
ON public.cajeros_vendedores FOR SELECT
TO authenticated
USING (activo = true);

-- ============================================
-- PARTE 9: FUNCIONES RPC
-- ============================================

-- Limpiar funciones existentes
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INT, TEXT);
DROP FUNCTION IF EXISTS public.incrementar_creditos(UUID, INT, TEXT);
DROP FUNCTION IF EXISTS public.puede_publicar_solicitud_gratis(UUID);
DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(UUID);
DROP FUNCTION IF EXISTS public.incrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.decrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.votar_respuesta(UUID);
DROP FUNCTION IF EXISTS public.incrementar_postulaciones(UUID);

-- Funcion: Descontar creditos
CREATE OR REPLACE FUNCTION public.descontar_creditos(
  p_user_id UUID,
  p_cantidad INT,
  p_concepto TEXT DEFAULT 'gasto'
)
RETURNS BOOLEAN AS $$
DECLARE
  creditos_actuales INT;
BEGIN
  SELECT creditos INTO creditos_actuales
  FROM public.users
  WHERE id = p_user_id;

  IF creditos_actuales IS NULL OR creditos_actuales < p_cantidad THEN
    RETURN FALSE;
  END IF;

  UPDATE public.users
  SET creditos = creditos - p_cantidad,
      creditos_totales_gastados = COALESCE(creditos_totales_gastados, 0) + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Incrementar creditos
CREATE OR REPLACE FUNCTION public.incrementar_creditos(
  p_user_id UUID,
  p_cantidad INT,
  p_concepto TEXT DEFAULT 'ganancia'
)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users
  SET creditos = COALESCE(creditos, 0) + p_cantidad,
      creditos_totales_ganados = COALESCE(creditos_totales_ganados, 0) + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Verificar si puede publicar gratis
CREATE OR REPLACE FUNCTION public.puede_publicar_solicitud_gratis(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  total_publicadas INT;
BEGIN
  SELECT COALESCE(total_solicitudes_publicadas, 0) INTO total_publicadas
  FROM public.users
  WHERE id = p_user_id;

  -- Primera solicitud es gratis
  RETURN total_publicadas = 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Incrementar solicitudes publicadas
CREATE OR REPLACE FUNCTION public.incrementar_solicitudes_publicadas(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users
  SET total_solicitudes_publicadas = COALESCE(total_solicitudes_publicadas, 0) + 1,
      updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Incrementar respuestas de pregunta
CREATE OR REPLACE FUNCTION public.incrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = COALESCE(total_respuestas, 0) + 1,
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Decrementar respuestas de pregunta
CREATE OR REPLACE FUNCTION public.decrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = GREATEST(COALESCE(total_respuestas, 0) - 1, 0),
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Votar respuesta
CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_respuestas
  SET total_votos = COALESCE(total_votos, 0) + 1
  WHERE id = p_respuesta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funcion: Incrementar postulaciones de solicitud
CREATE OR REPLACE FUNCTION public.incrementar_postulaciones(p_solicitud_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.solicitudes_trabajo
  SET total_postulaciones = COALESCE(total_postulaciones, 0) + 1,
      updated_at = NOW()
  WHERE id = p_solicitud_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PARTE 10: VERIFICACION
-- ============================================

SELECT 'Verificando estructura...' as info;

SELECT 'Tabla users:' as tabla, COUNT(*) as registros FROM public.users;
SELECT 'Tabla perfiles_profesionales:' as tabla, COUNT(*) as registros FROM public.perfiles_profesionales;
SELECT 'Tabla solicitudes_trabajo:' as tabla, COUNT(*) as registros FROM public.solicitudes_trabajo;
SELECT 'Tabla postulaciones:' as tabla, COUNT(*) as registros FROM public.postulaciones;
SELECT 'Tabla foro_preguntas:' as tabla, COUNT(*) as registros FROM public.foro_preguntas;
SELECT 'Tabla foro_respuestas:' as tabla, COUNT(*) as registros FROM public.foro_respuestas;
SELECT 'Tabla cajeros_vendedores:' as tabla, COUNT(*) as registros FROM public.cajeros_vendedores;

SELECT '008_ESTRUCTURA_COMPLETA ejecutado correctamente' as resultado;
