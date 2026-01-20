-- ============================================
-- FIXES URGENTES - CORRECCION DE ERRORES
-- APP: CONTACTOS
-- Fecha: Enero 2026
-- ============================================
-- EJECUTAR EN SUPABASE SQL EDITOR
-- ============================================

-- ============================================
-- 1. AGREGAR COLUMNA fecha_uso SI NO EXISTE
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'tokens_especiales' AND column_name = 'fecha_uso'
  ) THEN
    ALTER TABLE public.tokens_especiales ADD COLUMN fecha_uso TIMESTAMPTZ;
    RAISE NOTICE '✅ Columna fecha_uso agregada a tokens_especiales';
  ELSE
    RAISE NOTICE '⚠️ Columna fecha_uso ya existe';
  END IF;
END $$;

-- ============================================
-- 2. CORREGIR FUNCION usar_token_especial
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

  -- Marcar como usado (manejar si fecha_uso no existe)
  BEGIN
    UPDATE public.tokens_especiales
    SET usado = true,
        fecha_uso = NOW(),
        cantidad = cantidad - 1
    WHERE id = token_id;
  EXCEPTION WHEN undefined_column THEN
    -- Si fecha_uso no existe, actualizar sin ella
    UPDATE public.tokens_especiales
    SET usado = true,
        cantidad = cantidad - 1
    WHERE id = token_id;
  END;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 3. CREAR FUNCION incrementar_solicitudes_publicadas
-- ============================================

-- Eliminar TODAS las versiones de la función primero
DO $$
BEGIN
  -- Eliminar todas las funciones con este nombre
  DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(UUID);
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- Crear la función con el nombre de parámetro correcto
CREATE OR REPLACE FUNCTION public.incrementar_solicitudes_publicadas(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users
  SET total_solicitudes_publicadas = COALESCE(total_solicitudes_publicadas, 0) + 1,
      updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. CREAR FUNCIONES FALTANTES DEL FORO
-- ============================================

CREATE OR REPLACE FUNCTION public.incrementar_vistas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_vistas = COALESCE(total_vistas, 0) + 1
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = COALESCE(total_respuestas, 0) + 1,
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.decrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_respuestas = GREATEST(COALESCE(total_respuestas, 0) - 1, 0),
      updated_at = NOW()
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_respuestas
  SET total_votos = COALESCE(total_votos, 0) + 1
  WHERE id = p_respuesta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. CORREGIR ESTRUCTURA DE foro_preguntas
-- Quitar columna imagenes si existe y causar problemas
-- O agregarla si no existe
-- ============================================

DO $$
BEGIN
  -- Verificar si la columna imagenes existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'foro_preguntas' AND column_name = 'imagenes'
  ) THEN
    -- Agregar la columna si no existe
    ALTER TABLE public.foro_preguntas ADD COLUMN imagenes TEXT[] DEFAULT '{}';
    RAISE NOTICE '✅ Columna imagenes agregada a foro_preguntas';
  END IF;

  -- Verificar columnas de foro_respuestas
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'foro_respuestas' AND column_name = 'imagenes'
  ) THEN
    ALTER TABLE public.foro_respuestas ADD COLUMN imagenes TEXT[] DEFAULT '{}';
    RAISE NOTICE '✅ Columna imagenes agregada a foro_respuestas';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'foro_respuestas' AND column_name = 'es_mejor_respuesta'
  ) THEN
    ALTER TABLE public.foro_respuestas ADD COLUMN es_mejor_respuesta BOOLEAN DEFAULT false;
    RAISE NOTICE '✅ Columna es_mejor_respuesta agregada a foro_respuestas';
  END IF;
END $$;

-- ============================================
-- 6. AGREGAR COLUMNAS FALTANTES EN USERS
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'total_solicitudes_publicadas'
  ) THEN
    ALTER TABLE public.users ADD COLUMN total_solicitudes_publicadas INT DEFAULT 0;
    RAISE NOTICE '✅ Columna total_solicitudes_publicadas agregada';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'creditos_totales_gastados'
  ) THEN
    ALTER TABLE public.users ADD COLUMN creditos_totales_gastados INT DEFAULT 0;
    RAISE NOTICE '✅ Columna creditos_totales_gastados agregada';
  END IF;
END $$;

-- ============================================
-- 7. CREAR TABLA cajeros_vendedores SI NO EXISTE
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
  horario TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para cajeros_vendedores
ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active cajeros" ON public.cajeros_vendedores;
CREATE POLICY "Anyone can view active cajeros"
ON public.cajeros_vendedores
FOR SELECT
TO authenticated
USING (activo = true);

-- ============================================
-- 7.1 CREAR TABLA solicitudes_recarga SI NO EXISTE
-- ============================================

CREATE TABLE IF NOT EXISTS public.solicitudes_recarga (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  cajero_id UUID REFERENCES public.cajeros_vendedores(id),
  tipo_producto VARCHAR(50) NOT NULL,
  cantidad_creditos INT,
  tipo_membresia VARCHAR(50),
  duracion VARCHAR(20),
  monto_total DECIMAL(10,2) NOT NULL,
  comision_cajero DECIMAL(10,2) DEFAULT 0,
  metodo_pago VARCHAR(50),
  estado VARCHAR(50) DEFAULT 'pendiente_pago',
  comprobante_pago TEXT,
  notas TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para solicitudes_recarga
ALTER TABLE public.solicitudes_recarga ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own solicitudes" ON public.solicitudes_recarga;
CREATE POLICY "Users can view own solicitudes"
ON public.solicitudes_recarga
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own solicitudes" ON public.solicitudes_recarga;
CREATE POLICY "Users can insert own solicitudes"
ON public.solicitudes_recarga
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 8. POLITICAS RLS PARA DELETE Y UPDATE EN SOLICITUDES
-- ============================================

DROP POLICY IF EXISTS "Users can update their own solicitudes" ON public.solicitudes_trabajo;
CREATE POLICY "Users can update their own solicitudes"
ON public.solicitudes_trabajo
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own solicitudes" ON public.solicitudes_trabajo;
CREATE POLICY "Users can delete their own solicitudes"
ON public.solicitudes_trabajo
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- 9. INSERTAR CAJEROS DE PRUEBA
-- ============================================

-- Primero agregar columna horario si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cajeros_vendedores' AND column_name = 'horario'
  ) THEN
    ALTER TABLE public.cajeros_vendedores ADD COLUMN horario TEXT;
  END IF;
END $$;

-- Limpiar cajeros anteriores de prueba
DELETE FROM public.cajeros_vendedores WHERE nombre_completo LIKE '%Cajero%' OR nombre_completo LIKE 'Maria Garcia%';

INSERT INTO public.cajeros_vendedores (
  nombre_completo, telefono, whatsapp, ciudad, zona,
  metodos_pago, disponible_ahora, activo, calificacion_promedio, total_transacciones
)
VALUES
  ('Maria Garcia - Cajero Central', '71234567', '59171234567', 'La Paz', 'Centro',
   '{"Efectivo", "QR BNB", "QR BCP", "Transferencia"}', true, true, 4.9, 156),
  ('Carlos Rodriguez - Miraflores', '71234568', '59171234568', 'La Paz', 'Miraflores',
   '{"Efectivo", "QR", "Tigo Money"}', true, true, 4.7, 89),
  ('Ana Martinez - Santa Cruz', '77654321', '59177654321', 'Santa Cruz', 'Centro',
   '{"Efectivo", "QR BNB", "Transferencia", "Tigo Money"}', true, true, 4.8, 234),
  ('Jose Mendoza - Cochabamba', '76543210', '59176543210', 'Cochabamba', 'Centro',
   '{"Efectivo", "QR", "Transferencia"}', false, true, 4.6, 67),
  ('Laura Fernandez - Sucre', '75455489', '59175455489', 'Sucre', 'Centro',
   '{"Efectivo", "QR BNB", "Transferencia"}', true, true, 4.9, 45);

-- ============================================
-- 10. VERIFICACION FINAL
-- ============================================

SELECT 'Funciones RPC creadas:' as info;
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
  AND routine_name IN (
    'usar_token_especial',
    'incrementar_solicitudes_publicadas',
    'incrementar_vistas_pregunta',
    'incrementar_respuestas_pregunta',
    'decrementar_respuestas_pregunta',
    'votar_respuesta',
    'descontar_creditos',
    'incrementar_creditos',
    'puede_publicar_solicitud_gratis'
  );

SELECT 'Cajeros insertados:' as info, COUNT(*) as total FROM public.cajeros_vendedores WHERE activo = true;

SELECT '✅ FIXES URGENTES APLICADOS CORRECTAMENTE' as resultado;
