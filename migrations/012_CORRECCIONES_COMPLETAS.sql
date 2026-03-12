-- ============================================
-- CORRECCIONES COMPLETAS v1.0
-- APP: CONTACTOS
-- FECHA: 2026-01-21
-- ============================================
-- EJECUTAR DESPUES DE 010_SQL_DEFINITIVO.sql
-- Este script agrega TODAS las tablas y funciones faltantes
-- ============================================

-- ============================================
-- PARTE 1: EXTENSION UUID (si no existe)
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PARTE 2: COLUMNAS ADICIONALES EN USERS
-- ============================================
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS referido_por UUID;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS total_referidos INT DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS codigo_referido VARCHAR(10);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS total_contactos_vistos INT DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS notificaciones_push BOOLEAN DEFAULT true;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS modo_oscuro BOOLEAN DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS membresia_activa BOOLEAN DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS fecha_inicio_membresia TIMESTAMPTZ;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS fecha_fin_membresia TIMESTAMPTZ;

-- Crear indice para codigo_referido
CREATE INDEX IF NOT EXISTS idx_users_codigo_referido ON public.users(codigo_referido);

-- ============================================
-- PARTE 3: TABLA TOKENS_ESPECIALES
-- ============================================
CREATE TABLE IF NOT EXISTS public.tokens_especiales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tipo VARCHAR(50) NOT NULL, -- 'solicitud_gratuita', etc.
  cantidad INT DEFAULT 1,
  usado BOOLEAN DEFAULT false,
  fecha_uso TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indice para busquedas
CREATE INDEX IF NOT EXISTS idx_tokens_user_id ON public.tokens_especiales(user_id);
CREATE INDEX IF NOT EXISTS idx_tokens_tipo ON public.tokens_especiales(tipo);

-- RLS para tokens_especiales
ALTER TABLE public.tokens_especiales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tokens_select_own" ON public.tokens_especiales;
CREATE POLICY "tokens_select_own" ON public.tokens_especiales
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "tokens_insert_own" ON public.tokens_especiales;
CREATE POLICY "tokens_insert_own" ON public.tokens_especiales
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "tokens_update_own" ON public.tokens_especiales;
CREATE POLICY "tokens_update_own" ON public.tokens_especiales
FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PARTE 4: TABLA MOVIMIENTOS_CREDITOS
-- ============================================
CREATE TABLE IF NOT EXISTS public.movimientos_creditos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tipo_movimiento VARCHAR(30) NOT NULL, -- 'ganancia' o 'gasto'
  cantidad INT NOT NULL,
  saldo_anterior INT DEFAULT 0,
  saldo_nuevo INT DEFAULT 0,
  origen VARCHAR(50), -- 'registro_bienvenida', 'video_admob', 'referido', 'compra', etc.
  descripcion TEXT,
  referencia_id UUID, -- ID de la solicitud, reseña, etc. (opcional)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices para movimientos
CREATE INDEX IF NOT EXISTS idx_movimientos_user_id ON public.movimientos_creditos(user_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha ON public.movimientos_creditos(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_origen ON public.movimientos_creditos(origen);

-- RLS para movimientos_creditos
ALTER TABLE public.movimientos_creditos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "movimientos_select_own" ON public.movimientos_creditos;
CREATE POLICY "movimientos_select_own" ON public.movimientos_creditos
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "movimientos_insert_own" ON public.movimientos_creditos;
CREATE POLICY "movimientos_insert_own" ON public.movimientos_creditos
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- PARTE 5: TABLA NOTIFICACIONES
-- ============================================
CREATE TABLE IF NOT EXISTS public.notificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  mensaje TEXT NOT NULL,
  tipo VARCHAR(50), -- 'nueva_postulacion', 'pago_validado', 'membresia_vencer', etc.
  leida BOOLEAN DEFAULT false,
  fecha_leida TIMESTAMPTZ,
  accion_url VARCHAR(200), -- deeplink en la app
  datos_extra JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_notificaciones_user_id ON public.notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON public.notificaciones(leida);

-- RLS
ALTER TABLE public.notificaciones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notificaciones_select_own" ON public.notificaciones;
CREATE POLICY "notificaciones_select_own" ON public.notificaciones
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notificaciones_update_own" ON public.notificaciones;
CREATE POLICY "notificaciones_update_own" ON public.notificaciones
FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PARTE 6: TABLA TRANSACCIONES (Historial de pagos)
-- ============================================
CREATE TABLE IF NOT EXISTS public.transacciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tipo VARCHAR(50) NOT NULL, -- 'recarga_creditos', 'pago_membresia', 'uso_credito'
  concepto TEXT,
  cantidad_creditos INT,
  monto_bolivianos DECIMAL(10,2),
  metodo_pago VARCHAR(50), -- 'efectivo', 'transferencia', 'qr', 'tigo_money'
  cajero_id UUID,
  admin_id UUID,
  tipo_membresia VARCHAR(50),
  duracion_membresia VARCHAR(20),
  estado VARCHAR(20) DEFAULT 'completada', -- 'pendiente', 'completada', 'cancelada'
  referencia_externa VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_transacciones_user_id ON public.transacciones(user_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_tipo ON public.transacciones(tipo);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha ON public.transacciones(created_at DESC);

-- RLS
ALTER TABLE public.transacciones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "transacciones_select_own" ON public.transacciones;
CREATE POLICY "transacciones_select_own" ON public.transacciones
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- PARTE 7: TABLA SOLICITUDES_RECARGA
-- ============================================
CREATE TABLE IF NOT EXISTS public.solicitudes_recarga (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cajero_id UUID,
  tipo_producto VARCHAR(50) NOT NULL, -- 'creditos', 'membresia_basica', 'membresia_premium', 'vip_buscador'
  cantidad_creditos INT,
  tipo_membresia VARCHAR(50),
  duracion VARCHAR(20), -- 'mensual', 'anual'
  monto_total DECIMAL(10,2) NOT NULL,
  comision_cajero DECIMAL(10,2),
  metodo_pago VARCHAR(50),
  estado VARCHAR(30) DEFAULT 'pendiente_pago',
  -- Estados: pendiente_pago, validado_cajero, pendiente_aprobacion_admin, completada, rechazada, cancelada
  fecha_validacion_cajero TIMESTAMPTZ,
  notas_cajero TEXT,
  admin_activador UUID,
  fecha_activacion_admin TIMESTAMPTZ,
  notas_admin TEXT,
  comprobante_pago TEXT, -- URL de imagen
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_user ON public.solicitudes_recarga(user_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_cajero ON public.solicitudes_recarga(cajero_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_estado ON public.solicitudes_recarga(estado);

-- RLS
ALTER TABLE public.solicitudes_recarga ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "recarga_select_own" ON public.solicitudes_recarga;
CREATE POLICY "recarga_select_own" ON public.solicitudes_recarga
FOR SELECT TO authenticated
USING (auth.uid() = user_id OR auth.uid() = cajero_id);

DROP POLICY IF EXISTS "recarga_insert_own" ON public.solicitudes_recarga;
CREATE POLICY "recarga_insert_own" ON public.solicitudes_recarga
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- PARTE 8: TABLA COMISIONES_CAJEROS
-- ============================================
CREATE TABLE IF NOT EXISTS public.comisiones_cajeros (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cajero_id UUID NOT NULL,
  solicitud_recarga_id UUID REFERENCES public.solicitudes_recarga(id),
  monto_comision DECIMAL(10,2) NOT NULL,
  monto_transaccion DECIMAL(10,2),
  porcentaje DECIMAL(5,2) DEFAULT 5.00,
  estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'pagada'
  fecha_pago TIMESTAMPTZ,
  metodo_pago VARCHAR(50),
  referencia_pago VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_comisiones_cajero ON public.comisiones_cajeros(cajero_id);
CREATE INDEX IF NOT EXISTS idx_comisiones_estado ON public.comisiones_cajeros(estado);

-- ============================================
-- PARTE 9: TABLA RESENAS (si no existe)
-- ============================================
CREATE TABLE IF NOT EXISTS public.resenas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profesional_id UUID NOT NULL, -- ID del profesional (perfil o user)
  usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL, -- Quien escribe la reseña
  solicitud_id UUID, -- Solicitud relacionada (opcional)
  calificacion INT NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
  contenido TEXT,
  fotos TEXT[],
  respuesta_profesional TEXT,
  fecha_respuesta TIMESTAMPTZ,
  visible BOOLEAN DEFAULT true,
  reportada BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indices para resenas
CREATE INDEX IF NOT EXISTS idx_resenas_profesional ON public.resenas(profesional_id);
CREATE INDEX IF NOT EXISTS idx_resenas_usuario ON public.resenas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_resenas_visible ON public.resenas(visible);

-- RLS para resenas (si no existe)
ALTER TABLE public.resenas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "res_select" ON public.resenas;
CREATE POLICY "res_select" ON public.resenas
FOR SELECT TO authenticated
USING (visible = true);

DROP POLICY IF EXISTS "res_insert" ON public.resenas;
CREATE POLICY "res_insert" ON public.resenas
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "res_update_own" ON public.resenas;
CREATE POLICY "res_update_own" ON public.resenas
FOR UPDATE TO authenticated
USING (auth.uid() = usuario_id);

-- ============================================
-- PARTE 10: COLUMNAS FALTANTES EN PERFILES_PROFESIONALES
-- ============================================
ALTER TABLE public.perfiles_profesionales ADD COLUMN IF NOT EXISTS subcategorias TEXT[];
ALTER TABLE public.perfiles_profesionales ADD COLUMN IF NOT EXISTS foto_perfil TEXT;
ALTER TABLE public.perfiles_profesionales ADD COLUMN IF NOT EXISTS galeria_fotos TEXT[];
ALTER TABLE public.perfiles_profesionales ADD COLUMN IF NOT EXISTS destacado BOOLEAN DEFAULT false;
ALTER TABLE public.perfiles_profesionales ADD COLUMN IF NOT EXISTS zonas_cobertura TEXT[];

-- ============================================
-- PARTE 11: COLUMNAS FALTANTES EN FORO
-- ============================================
ALTER TABLE public.foro_preguntas ADD COLUMN IF NOT EXISTS imagenes TEXT[];

-- ============================================
-- PARTE 12: FUNCIONES RPC ADICIONALES
-- ============================================

-- Función para usar token especial
DROP FUNCTION IF EXISTS public.usar_token_especial(UUID, TEXT);
CREATE OR REPLACE FUNCTION public.usar_token_especial(p_user_id UUID, p_tipo TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_token_id UUID;
BEGIN
  -- Buscar token no usado
  SELECT id INTO v_token_id
  FROM public.tokens_especiales
  WHERE user_id = p_user_id
    AND tipo = p_tipo
    AND usado = false
  LIMIT 1;

  IF v_token_id IS NOT NULL THEN
    -- Marcar como usado
    UPDATE public.tokens_especiales
    SET usado = true, fecha_uso = NOW()
    WHERE id = v_token_id;
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para procesar referido (RECREAR con tabla correcta)
DROP FUNCTION IF EXISTS public.procesar_referido(UUID, TEXT);
CREATE OR REPLACE FUNCTION public.procesar_referido(nuevo_user_id UUID, codigo_ref TEXT)
RETURNS VOID AS $$
DECLARE
  referidor_id UUID;
  creditos_actuales INT;
BEGIN
  -- Buscar el usuario referidor (case-insensitive)
  SELECT id INTO referidor_id
  FROM public.users
  WHERE UPPER(codigo_referido) = UPPER(codigo_ref)
  AND id != nuevo_user_id;

  IF referidor_id IS NOT NULL THEN
    -- Obtener créditos actuales del referidor
    SELECT creditos INTO creditos_actuales
    FROM public.users
    WHERE id = referidor_id;

    -- Actualizar usuario nuevo
    UPDATE public.users
    SET referido_por = referidor_id,
        updated_at = NOW()
    WHERE id = nuevo_user_id;

    -- Dar créditos al referidor
    UPDATE public.users
    SET
      total_referidos = COALESCE(total_referidos, 0) + 1,
      creditos = COALESCE(creditos, 0) + 30,
      creditos_totales_ganados = COALESCE(creditos_totales_ganados, 0) + 30,
      updated_at = NOW()
    WHERE id = referidor_id;

    -- Registrar movimiento
    INSERT INTO public.movimientos_creditos (
      user_id, tipo_movimiento, cantidad, saldo_anterior, saldo_nuevo, origen, descripcion
    ) VALUES (
      referidor_id,
      'ganancia',
      30,
      COALESCE(creditos_actuales, 0),
      COALESCE(creditos_actuales, 0) + 30,
      'referido',
      'Créditos por referir a nuevo usuario'
    );

    RAISE NOTICE 'Referido procesado correctamente';
  ELSE
    RAISE NOTICE 'Código de referido no encontrado: %', codigo_ref;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error procesando referido: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para generar código de referido único
DROP FUNCTION IF EXISTS public.generar_codigo_referido();
CREATE OR REPLACE FUNCTION public.generar_codigo_referido()
RETURNS TEXT AS $$
DECLARE
  nuevo_codigo TEXT;
  existe BOOLEAN;
BEGIN
  LOOP
    -- Generar código de 8 caracteres alfanuméricos
    nuevo_codigo := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || CLOCK_TIMESTAMP()::TEXT) FOR 8));

    -- Verificar si ya existe
    SELECT EXISTS(SELECT 1 FROM public.users WHERE codigo_referido = nuevo_codigo) INTO existe;

    -- Si no existe, retornar
    IF NOT existe THEN
      RETURN nuevo_codigo;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Función para marcar notificación como leída
DROP FUNCTION IF EXISTS public.marcar_notificacion_leida(UUID);
CREATE OR REPLACE FUNCTION public.marcar_notificacion_leida(p_notificacion_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.notificaciones
  SET leida = true, fecha_leida = NOW()
  WHERE id = p_notificacion_id AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para marcar todas las notificaciones como leídas
DROP FUNCTION IF EXISTS public.marcar_todas_notificaciones_leidas(UUID);
CREATE OR REPLACE FUNCTION public.marcar_todas_notificaciones_leidas(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.notificaciones
  SET leida = true, fecha_leida = NOW()
  WHERE user_id = p_user_id AND leida = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para crear notificación
DROP FUNCTION IF EXISTS public.crear_notificacion(UUID, TEXT, TEXT, TEXT, TEXT, JSONB);
CREATE OR REPLACE FUNCTION public.crear_notificacion(
  p_user_id UUID,
  p_titulo TEXT,
  p_mensaje TEXT,
  p_tipo TEXT DEFAULT 'general',
  p_accion_url TEXT DEFAULT NULL,
  p_datos_extra JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  nueva_id UUID;
BEGIN
  INSERT INTO public.notificaciones (user_id, titulo, mensaje, tipo, accion_url, datos_extra)
  VALUES (p_user_id, p_titulo, p_mensaje, p_tipo, p_accion_url, p_datos_extra)
  RETURNING id INTO nueva_id;

  RETURN nueva_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PARTE 13: TRIGGER PARA NUEVO USUARIO
-- ============================================

-- Función del trigger
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  nuevo_codigo TEXT;
BEGIN
  -- Generar código de referido único
  nuevo_codigo := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.id::TEXT) FOR 8));

  -- Insertar en tabla users
  INSERT INTO public.users (
    id,
    email,
    nombre_completo,
    telefono,
    ciudad,
    rol,
    tipo_cuenta,
    creditos,
    creditos_totales_ganados,
    codigo_referido,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre_completo', NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'telefono', ''),
    COALESCE(NEW.raw_user_meta_data->>'ciudad', ''),
    'buscador',
    'gratuita',
    50,  -- Créditos iniciales
    50,
    nuevo_codigo,
    NOW(),
    NOW()
  );

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Si ya existe el usuario (por algún caso raro), actualizar
    UPDATE public.users SET
      email = NEW.email,
      updated_at = NOW()
    WHERE id = NEW.id;
    RETURN NEW;
  WHEN OTHERS THEN
    RAISE WARNING 'Error en handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger (eliminar si existe)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PARTE 14: VERIFICACION FINAL
-- ============================================

SELECT '=== VERIFICACIÓN DE TABLAS ===' as info;

SELECT 'tokens_especiales' as tabla, COUNT(*) as columnas
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'tokens_especiales';

SELECT 'movimientos_creditos' as tabla, COUNT(*) as columnas
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'movimientos_creditos';

SELECT 'notificaciones' as tabla, COUNT(*) as columnas
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'notificaciones';

SELECT 'transacciones' as tabla, COUNT(*) as columnas
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'transacciones';

SELECT 'solicitudes_recarga' as tabla, COUNT(*) as columnas
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'solicitudes_recarga';

SELECT '=== VERIFICACIÓN DE FUNCIONES ===' as info;

SELECT proname as funcion
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
AND proname IN ('procesar_referido', 'usar_token_especial', 'generar_codigo_referido',
                'marcar_notificacion_leida', 'crear_notificacion', 'handle_new_user');

SELECT '012_CORRECCIONES_COMPLETAS.sql ejecutado correctamente!' as resultado;
