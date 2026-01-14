-- ============================================
-- SCRIPT COMPLETO DE BASE DE DATOS SUPABASE
-- APP: CONTACTOS
-- Versión: 2.0 - CORREGIDO
-- Fecha: Enero 2026
-- ============================================
-- EJECUTA ESTE SCRIPT EN SUPABASE SQL EDITOR
-- https://supabase.com/dashboard/project/TU_PROJECT/sql/new
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsquedas full-text

-- ============================================
-- TABLA: users
-- Extendiendo la tabla de autenticación de Supabase
-- ============================================

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE,
  nombre_completo VARCHAR(100),
  telefono VARCHAR(20),
  whatsapp VARCHAR(20),
  foto_perfil TEXT,
  ciudad VARCHAR(50),
  zona VARCHAR(50),

  -- Roles y tipo de cuenta
  rol VARCHAR(20) DEFAULT 'buscador', -- buscador, profesional, dual, cajero, admin
  tipo_cuenta VARCHAR(20) DEFAULT 'gratuita', -- gratuita, vip_buscador, basico, premium

  -- Créditos
  creditos INT DEFAULT 50, -- inicia con 50
  creditos_totales_ganados INT DEFAULT 50,
  creditos_totales_gastados INT DEFAULT 0,

  -- Membresías
  fecha_inicio_membresia TIMESTAMPTZ,
  fecha_fin_membresia TIMESTAMPTZ,
  membresia_activa BOOLEAN DEFAULT false,

  -- Periodo de prueba
  periodo_prueba_usado BOOLEAN DEFAULT false,
  fecha_inicio_prueba TIMESTAMPTZ,
  fecha_fin_prueba TIMESTAMPTZ,

  -- Estadísticas
  total_busquedas INT DEFAULT 0,
  total_contactos_vistos INT DEFAULT 0,
  total_solicitudes_publicadas INT DEFAULT 0,

  -- Preferencias
  notificaciones_push BOOLEAN DEFAULT true,
  modo_oscuro BOOLEAN DEFAULT false,
  perfil_completo BOOLEAN DEFAULT false,

  -- Control
  verificado BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT true,
  suspendido BOOLEAN DEFAULT false,
  razon_suspension TEXT,

  -- Referidos
  codigo_referido VARCHAR(10) UNIQUE,
  referido_por UUID REFERENCES public.users(id),
  total_referidos INT DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  ultimo_acceso TIMESTAMPTZ
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_users_ciudad ON public.users(ciudad);
CREATE INDEX IF NOT EXISTS idx_users_rol ON public.users(rol);
CREATE INDEX IF NOT EXISTS idx_users_codigo_referido ON public.users(codigo_referido);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ============================================
-- TABLA: perfiles_profesionales
-- ============================================

CREATE TABLE IF NOT EXISTS public.perfiles_profesionales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,

  -- Información básica
  nombre_comercial VARCHAR(100),
  descripcion TEXT,
  eslogan VARCHAR(200),

  -- Categorización
  categoria_principal VARCHAR(50),
  subcategorias TEXT[], -- array de subcategorías
  servicios_ofrecidos TEXT[],

  -- Ubicación y cobertura
  ciudad VARCHAR(50),
  zonas_cobertura TEXT[],

  -- Contacto
  telefono VARCHAR(20),
  whatsapp VARCHAR(20),
  email VARCHAR(100),
  sitio_web VARCHAR(200),
  redes_sociales JSONB, -- {facebook, instagram, linkedin}

  -- Detalles profesionales
  años_experiencia INT,
  rango_precio_desde DECIMAL(10,2),
  rango_precio_hasta DECIMAL(10,2),
  emite_factura BOOLEAN DEFAULT false,
  ofrece_garantia BOOLEAN DEFAULT false,
  metodos_pago TEXT[], -- array: efectivo, transferencia, etc

  -- Horario
  horario_atencion JSONB, -- estructura con días y horas
  disponible_ahora BOOLEAN DEFAULT false,

  -- Multimedia
  foto_perfil TEXT,
  galeria_fotos TEXT[], -- array de URLs (máx 5 para básico, 15 para premium)
  video_presentacion TEXT,

  -- Verificación
  verificado BOOLEAN DEFAULT false,
  verificado_identidad BOOLEAN DEFAULT false,
  verificado_comercial BOOLEAN DEFAULT false,
  documentos_verificacion TEXT[], -- URLs documentos

  -- Estadísticas
  total_vistas INT DEFAULT 0,
  total_contactos INT DEFAULT 0,
  total_postulaciones INT DEFAULT 0,
  total_trabajos_realizados INT DEFAULT 0,
  calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
  total_resenas INT DEFAULT 0,

  -- Configuración Premium
  mensaje_automatico TEXT,
  respuesta_rapida_activa BOOLEAN DEFAULT false,

  -- Estado
  activo BOOLEAN DEFAULT true,
  visible_busqueda BOOLEAN DEFAULT true,
  destacado BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_perfiles_categoria ON public.perfiles_profesionales(categoria_principal);
CREATE INDEX IF NOT EXISTS idx_perfiles_ciudad ON public.perfiles_profesionales(ciudad);
CREATE INDEX IF NOT EXISTS idx_perfiles_calificacion ON public.perfiles_profesionales(calificacion_promedio DESC);
CREATE INDEX IF NOT EXISTS idx_perfiles_user_id ON public.perfiles_profesionales(user_id);
CREATE INDEX IF NOT EXISTS idx_perfiles_activo_visible ON public.perfiles_profesionales(activo, visible_busqueda);

-- ============================================
-- TABLA: solicitudes_trabajo
-- ============================================

CREATE TABLE IF NOT EXISTS public.solicitudes_trabajo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Información de la solicitud
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT NOT NULL,
  categoria VARCHAR(50),
  subcategoria VARCHAR(50),

  -- Ubicación
  ciudad VARCHAR(50),
  zona VARCHAR(50),
  direccion_exacta TEXT,

  -- Detalles
  presupuesto_minimo DECIMAL(10,2),
  presupuesto_maximo DECIMAL(10,2),
  urgencia VARCHAR(20), -- normal, urgente, muy_urgente
  fecha_limite TIMESTAMPTZ,

  -- Multimedia
  fotos TEXT[], -- array de URLs

  -- Estado
  estado VARCHAR(20) DEFAULT 'activa', -- activa, en_proceso, completada, cancelada, expirada
  total_postulaciones INT DEFAULT 0,
  profesional_seleccionado UUID REFERENCES public.users(id),
  fecha_seleccion TIMESTAMPTZ,

  -- Calificación posterior
  calificacion INT, -- 1-5 estrellas
  resena TEXT,
  fecha_calificacion TIMESTAMPTZ,

  -- Control
  creditos_usados INT DEFAULT 20,
  visible BOOLEAN DEFAULT true,
  destacada BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days')
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_solicitudes_categoria ON public.solicitudes_trabajo(categoria);
CREATE INDEX IF NOT EXISTS idx_solicitudes_ciudad ON public.solicitudes_trabajo(ciudad);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado ON public.solicitudes_trabajo(estado);
CREATE INDEX IF NOT EXISTS idx_solicitudes_user_id ON public.solicitudes_trabajo(user_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_created_at ON public.solicitudes_trabajo(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_solicitudes_destacada ON public.solicitudes_trabajo(destacada) WHERE destacada = true;

-- ============================================
-- TABLA: postulaciones
-- ============================================

CREATE TABLE IF NOT EXISTS public.postulaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  solicitud_id UUID REFERENCES public.solicitudes_trabajo(id) ON DELETE CASCADE,
  profesional_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Propuesta
  mensaje_propuesta TEXT,
  precio_propuesto DECIMAL(10,2),
  tiempo_estimado VARCHAR(50),

  -- Estado
  estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, seleccionado, rechazado
  visto_por_cliente BOOLEAN DEFAULT false,
  fecha_visto TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_postulaciones_solicitud ON public.postulaciones(solicitud_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_profesional ON public.postulaciones(profesional_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_estado ON public.postulaciones(estado);

-- ============================================
-- TABLA: resenas
-- ============================================

CREATE TABLE IF NOT EXISTS public.resenas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profesional_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  solicitud_id UUID REFERENCES public.solicitudes_trabajo(id),

  -- Calificación
  calificacion INT CHECK (calificacion >= 1 AND calificacion <= 5) NOT NULL,
  comentario TEXT,
  fotos_trabajo TEXT[], -- fotos del trabajo realizado

  -- Verificación
  verificada BOOLEAN DEFAULT true, -- solo pueden calificar quienes contactaron

  -- Respuesta del profesional
  respuesta_profesional TEXT,
  fecha_respuesta TIMESTAMPTZ,

  -- Moderación
  reportada BOOLEAN DEFAULT false,
  razon_reporte TEXT,
  oculta BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_resenas_profesional ON public.resenas(profesional_id);
CREATE INDEX IF NOT EXISTS idx_resenas_usuario ON public.resenas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_resenas_created_at ON public.resenas(created_at DESC);

-- ============================================
-- TABLA: transacciones (Historial financiero)
-- ============================================

CREATE TABLE IF NOT EXISTS public.transacciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Tipo de transacción
  tipo VARCHAR(50), -- recarga_creditos, pago_membresia, uso_credito, ganancia_credito
  concepto TEXT,

  -- Montos
  cantidad_creditos INT, -- si aplica
  monto_bolivianos DECIMAL(10,2), -- si aplica

  -- Método de pago
  metodo_pago VARCHAR(50), -- tigo_money, transferencia, efectivo, stripe, qr_bancario

  -- Intermediarios
  cajero_id UUID REFERENCES public.users(id),
  admin_id UUID REFERENCES public.users(id),

  -- Detalles de membresía (si aplica)
  tipo_membresia VARCHAR(50),
  duracion_membresia VARCHAR(20), -- mensual, anual

  -- Estado
  estado VARCHAR(20) DEFAULT 'completada', -- pendiente, completada, cancelada, reembolsada

  -- Referencias
  referencia_externa VARCHAR(100), -- ID de Stripe, número de transacción bancaria, etc

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_transacciones_user ON public.transacciones(user_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_tipo ON public.transacciones(tipo);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha ON public.transacciones(created_at DESC);

-- ============================================
-- TABLA: solicitudes_recarga (Para sistema de cajeros)
-- ============================================

CREATE TABLE IF NOT EXISTS public.solicitudes_recarga (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  cajero_id UUID REFERENCES public.users(id),

  -- Producto solicitado
  tipo_producto VARCHAR(50), -- creditos, membresia_basica, membresia_premium, vip_buscador
  cantidad_creditos INT, -- si aplica
  tipo_membresia VARCHAR(50), -- si aplica
  duracion VARCHAR(20), -- mensual, anual

  -- Montos
  monto_total DECIMAL(10,2),
  comision_cajero DECIMAL(10,2),

  -- Método de pago elegido
  metodo_pago VARCHAR(50),

  -- Estado del flujo
  estado VARCHAR(30) DEFAULT 'pendiente_pago',
  -- Estados posibles:
  -- pendiente_pago: usuario contactó cajero
  -- validado_cajero: cajero confirmó pago
  -- pendiente_aprobacion_admin: esperando que admin active
  -- completada: admin activó créditos/membresía
  -- rechazada: pago inválido
  -- cancelada: usuario canceló

  -- Validación cajero
  fecha_validacion_cajero TIMESTAMPTZ,
  notas_cajero TEXT,

  -- Activación admin
  admin_activador UUID REFERENCES public.users(id),
  fecha_activacion_admin TIMESTAMPTZ,
  notas_admin TEXT,

  -- Control
  comprobante_pago TEXT, -- URL de imagen del comprobante

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_user ON public.solicitudes_recarga(user_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_cajero ON public.solicitudes_recarga(cajero_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_estado ON public.solicitudes_recarga(estado);

-- ============================================
-- TABLA: cajeros_vendedores
-- ============================================

CREATE TABLE IF NOT EXISTS public.cajeros_vendedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,

  -- Información
  nombre_completo VARCHAR(100),
  telefono VARCHAR(20),
  whatsapp VARCHAR(20),

  -- Cobertura
  ciudad VARCHAR(50),
  zona VARCHAR(50),

  -- Métodos de pago que acepta
  metodos_pago TEXT[], -- array: tigo_money, efectivo, transferencia, qr_simple

  -- Horario
  horario_atencion JSONB,
  disponible_ahora BOOLEAN DEFAULT true,

  -- Configuración de comisión
  porcentaje_comision DECIMAL(5,2) DEFAULT 5.00, -- 5%
  comision_acumulada DECIMAL(10,2) DEFAULT 0.00,
  comision_pagada DECIMAL(10,2) DEFAULT 0.00,
  comision_pendiente DECIMAL(10,2) DEFAULT 0.00,

  -- Estadísticas
  total_transacciones INT DEFAULT 0,
  total_monto_procesado DECIMAL(10,2) DEFAULT 0.00,
  calificacion_promedio DECIMAL(3,2) DEFAULT 5.00,
  total_calificaciones INT DEFAULT 0,

  -- Estado
  activo BOOLEAN DEFAULT true,
  verificado BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_cajeros_ciudad ON public.cajeros_vendedores(ciudad);
CREATE INDEX IF NOT EXISTS idx_cajeros_activo ON public.cajeros_vendedores(activo);

-- ============================================
-- TABLA: comisiones_cajeros
-- ============================================

CREATE TABLE IF NOT EXISTS public.comisiones_cajeros (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cajero_id UUID REFERENCES public.cajeros_vendedores(id) ON DELETE CASCADE,
  solicitud_recarga_id UUID REFERENCES public.solicitudes_recarga(id),

  -- Montos
  monto_comision DECIMAL(10,2),
  monto_transaccion DECIMAL(10,2),
  porcentaje DECIMAL(5,2),

  -- Estado
  estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, pagada
  fecha_pago TIMESTAMPTZ,
  metodo_pago VARCHAR(50),
  referencia_pago VARCHAR(100),

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_comisiones_cajero ON public.comisiones_cajeros(cajero_id);
CREATE INDEX IF NOT EXISTS idx_comisiones_estado ON public.comisiones_cajeros(estado);

-- ============================================
-- TABLA: movimientos_creditos (Detalle de créditos)
-- ============================================

CREATE TABLE IF NOT EXISTS public.movimientos_creditos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Movimiento
  tipo_movimiento VARCHAR(30), -- ganancia, gasto
  cantidad INT,
  saldo_anterior INT,
  saldo_nuevo INT,

  -- Origen/Destino
  origen VARCHAR(50),
  -- Ganancias: video_admob, referido, resena, racha_diaria, perfil_completo, recarga, bonificacion
  -- Gastos: ver_contacto, publicar_solicitud

  descripcion TEXT,

  -- Referencia
  referencia_id UUID, -- ID de la solicitud, reseña, referido, etc

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_movimientos_creditos_user ON public.movimientos_creditos(user_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_creditos_fecha ON public.movimientos_creditos(created_at DESC);

-- ============================================
-- TABLA: notificaciones
-- ============================================

CREATE TABLE IF NOT EXISTS public.notificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Contenido
  titulo VARCHAR(200),
  mensaje TEXT,
  tipo VARCHAR(50), -- nueva_postulacion, pago_validado, membresia_proxima_vencer, etc

  -- Navegación
  accion_url VARCHAR(200), -- deeplink dentro de la app
  datos_extra JSONB,

  -- Estado
  leida BOOLEAN DEFAULT false,
  fecha_leida TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_notificaciones_user ON public.notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON public.notificaciones(leida);

-- ============================================
-- TABLA: favoritos
-- ============================================

CREATE TABLE IF NOT EXISTS public.favoritos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  profesional_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraint para evitar duplicados
  UNIQUE(user_id, profesional_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_favoritos_user ON public.favoritos(user_id);
CREATE INDEX IF NOT EXISTS idx_favoritos_profesional ON public.favoritos(profesional_id);

-- ============================================
-- TABLA: foro_preguntas (Feature "Alguien Sabe?")
-- ============================================

CREATE TABLE IF NOT EXISTS public.foro_preguntas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Contenido
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT NOT NULL,
  categoria VARCHAR(50),

  -- Estadísticas
  total_respuestas INT DEFAULT 0,
  total_votos INT DEFAULT 0,

  -- Estado
  respondida BOOLEAN DEFAULT false,
  respuesta_aceptada UUID, -- ID de la respuesta marcada como correcta
  visible BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_user ON public.foro_preguntas(user_id);
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_categoria ON public.foro_preguntas(categoria);
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_created_at ON public.foro_preguntas(created_at DESC);

-- ============================================
-- TABLA: foro_respuestas
-- ============================================

CREATE TABLE IF NOT EXISTS public.foro_respuestas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pregunta_id UUID REFERENCES public.foro_preguntas(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Contenido
  contenido TEXT NOT NULL,

  -- Estadísticas
  total_votos INT DEFAULT 0,
  es_respuesta_aceptada BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_foro_respuestas_pregunta ON public.foro_respuestas(pregunta_id);
CREATE INDEX IF NOT EXISTS idx_foro_respuestas_user ON public.foro_respuestas(user_id);

-- ============================================
-- FUNCIONES RPC (Remote Procedure Calls)
-- ============================================

-- Función para incrementar créditos
CREATE OR REPLACE FUNCTION incrementar_creditos(p_user_id UUID, p_cantidad INT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users
  SET
    creditos = creditos + p_cantidad,
    creditos_totales_ganados = creditos_totales_ganados + p_cantidad,
    updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para decrementar créditos
CREATE OR REPLACE FUNCTION decrementar_creditos(p_user_id UUID, p_cantidad INT)
RETURNS BOOLEAN AS $$
DECLARE
  current_credits INT;
BEGIN
  SELECT creditos INTO current_credits FROM public.users WHERE id = p_user_id;

  IF current_credits >= p_cantidad THEN
    UPDATE public.users
    SET
      creditos = creditos - p_cantidad,
      creditos_totales_gastados = creditos_totales_gastados + p_cantidad,
      updated_at = NOW()
    WHERE id = p_user_id;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para actualizar calificación promedio de profesional
CREATE OR REPLACE FUNCTION actualizar_calificacion_profesional()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.perfiles_profesionales
  SET
    calificacion_promedio = (
      SELECT AVG(calificacion)::DECIMAL(3,2)
      FROM public.resenas
      WHERE profesional_id = NEW.profesional_id
        AND oculta = false
    ),
    total_resenas = (
      SELECT COUNT(*)
      FROM public.resenas
      WHERE profesional_id = NEW.profesional_id
        AND oculta = false
    ),
    updated_at = NOW()
  WHERE user_id = NEW.profesional_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar calificación
DROP TRIGGER IF EXISTS trigger_actualizar_calificacion ON public.resenas;
CREATE TRIGGER trigger_actualizar_calificacion
  AFTER INSERT OR UPDATE ON public.resenas
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_calificacion_profesional();

-- Función para actualizar contador de postulaciones
CREATE OR REPLACE FUNCTION actualizar_contador_postulaciones()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.solicitudes_trabajo
  SET total_postulaciones = (
    SELECT COUNT(*)
    FROM public.postulaciones
    WHERE solicitud_id = NEW.solicitud_id
  )
  WHERE id = NEW.solicitud_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para contador de postulaciones
DROP TRIGGER IF EXISTS trigger_contar_postulaciones ON public.postulaciones;
CREATE TRIGGER trigger_contar_postulaciones
  AFTER INSERT ON public.postulaciones
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_contador_postulaciones();

-- Función para actualizar timestamp updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de updated_at a las tablas que lo necesitan
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_perfiles_updated_at ON public.perfiles_profesionales;
CREATE TRIGGER update_perfiles_updated_at
  BEFORE UPDATE ON public.perfiles_profesionales
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_solicitudes_updated_at ON public.solicitudes_trabajo;
CREATE TRIGGER update_solicitudes_updated_at
  BEFORE UPDATE ON public.solicitudes_trabajo
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_solicitudes_recarga_updated_at ON public.solicitudes_recarga;
CREATE TRIGGER update_solicitudes_recarga_updated_at
  BEFORE UPDATE ON public.solicitudes_recarga
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cajeros_updated_at ON public.cajeros_vendedores;
CREATE TRIGGER update_cajeros_updated_at
  BEFORE UPDATE ON public.cajeros_vendedores
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_foro_preguntas_updated_at ON public.foro_preguntas;
CREATE TRIGGER update_foro_preguntas_updated_at
  BEFORE UPDATE ON public.foro_preguntas
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_foro_respuestas_updated_at ON public.foro_respuestas;
CREATE TRIGGER update_foro_respuestas_updated_at
  BEFORE UPDATE ON public.foro_respuestas
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCIÓN Y TRIGGER: Auto-crear usuario
-- ============================================

-- Función para crear usuario automáticamente cuando se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    nombre_completo,
    creditos,
    creditos_totales_ganados,
    codigo_referido,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre_completo', split_part(NEW.email, '@', 1)),
    50, -- créditos iniciales
    50,
    UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8)),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Eliminar trigger si existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Crear trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- ROW LEVEL SECURITY (RLS) - POLÍTICAS DE SEGURIDAD
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfiles_profesionales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_trabajo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resenas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transacciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_recarga ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comisiones_cajeros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS PARA TABLA: users
-- ============================================

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.users;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.users;
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Users can update own data" ON public.users;
DROP POLICY IF EXISTS "Admin can view all users" ON public.users;
DROP POLICY IF EXISTS "Enable read access for public profiles" ON public.users;

-- Permitir que usuarios autenticados se inserten a sí mismos
CREATE POLICY "Enable insert for authenticated users"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Permitir que usuarios lean su propia información
CREATE POLICY "Users can view their own data"
ON public.users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Permitir que usuarios actualicen su propia información
CREATE POLICY "Users can update their own data"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Permitir lectura pública de información básica (para perfiles profesionales)
CREATE POLICY "Enable read access for public profiles"
ON public.users
FOR SELECT
TO public
USING (true);

-- Admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users"
ON public.users
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND rol = 'admin'
  )
);

-- ============================================
-- POLÍTICAS PARA TABLA: perfiles_profesionales
-- ============================================

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can update own profile" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Public can view active profiles" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.perfiles_profesionales;

-- Ver perfiles profesionales públicos
CREATE POLICY "Public profiles are viewable by everyone"
ON public.perfiles_profesionales
FOR SELECT
TO public
USING (activo = true AND visible_busqueda = true);

-- Crear perfil profesional
CREATE POLICY "Users can insert their own profile"
ON public.perfiles_profesionales
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Actualizar perfil profesional
CREATE POLICY "Users can update own profile"
ON public.perfiles_profesionales
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Eliminar perfil profesional
CREATE POLICY "Users can delete own profile"
ON public.perfiles_profesionales
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: solicitudes_trabajo
-- ============================================

DROP POLICY IF EXISTS "Public can view active solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can insert their own solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can update own solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can view own solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Public can view active requests" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can view own requests" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can create requests" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can update own requests" ON public.solicitudes_trabajo;

-- Ver solicitudes activas
CREATE POLICY "Public can view active solicitudes"
ON public.solicitudes_trabajo
FOR SELECT
TO public
USING (estado = 'activa' AND visible = true);

-- Ver propias solicitudes
CREATE POLICY "Users can view own solicitudes"
ON public.solicitudes_trabajo
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Crear solicitudes
CREATE POLICY "Users can insert their own solicitudes"
ON public.solicitudes_trabajo
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Actualizar solicitudes
CREATE POLICY "Users can update own solicitudes"
ON public.solicitudes_trabajo
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: postulaciones
-- ============================================

DROP POLICY IF EXISTS "Users can view postulaciones to their solicitudes" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can view their own postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can insert postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can update own postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Professionals can create applications" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can view applications to own requests" ON public.postulaciones;
DROP POLICY IF EXISTS "Professionals can view own applications" ON public.postulaciones;

-- Ver postulaciones a mis solicitudes
CREATE POLICY "Users can view postulaciones to their solicitudes"
ON public.postulaciones
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.solicitudes_trabajo
    WHERE id = postulaciones.solicitud_id
    AND user_id = auth.uid()
  )
);

-- Ver mis propias postulaciones
CREATE POLICY "Users can view their own postulaciones"
ON public.postulaciones
FOR SELECT
TO authenticated
USING (auth.uid() = profesional_id);

-- Crear postulaciones
CREATE POLICY "Users can insert postulaciones"
ON public.postulaciones
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = profesional_id);

-- Actualizar postulaciones
CREATE POLICY "Users can update own postulaciones"
ON public.postulaciones
FOR UPDATE
TO authenticated
USING (auth.uid() = profesional_id)
WITH CHECK (auth.uid() = profesional_id);

-- ============================================
-- POLÍTICAS PARA TABLA: resenas
-- ============================================

DROP POLICY IF EXISTS "Public can view resenas" ON public.resenas;
DROP POLICY IF EXISTS "Users can insert resenas" ON public.resenas;
DROP POLICY IF EXISTS "Users can update own resenas" ON public.resenas;
DROP POLICY IF EXISTS "Public can view visible reviews" ON public.resenas;
DROP POLICY IF EXISTS "Clients can create reviews" ON public.resenas;

-- Ver reseñas públicas
CREATE POLICY "Public can view resenas"
ON public.resenas
FOR SELECT
TO public
USING (oculta = false);

-- Crear reseñas
CREATE POLICY "Users can insert resenas"
ON public.resenas
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = usuario_id);

-- Actualizar propias reseñas
CREATE POLICY "Users can update own resenas"
ON public.resenas
FOR UPDATE
TO authenticated
USING (auth.uid() = usuario_id)
WITH CHECK (auth.uid() = usuario_id);

-- ============================================
-- POLÍTICAS PARA TABLA: transacciones
-- ============================================

DROP POLICY IF EXISTS "Users can view own transactions" ON public.transacciones;
DROP POLICY IF EXISTS "Admin can view all transactions" ON public.transacciones;

-- Usuario puede ver sus propias transacciones
CREATE POLICY "Users can view own transactions"
ON public.transacciones
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Admin puede ver todas las transacciones
CREATE POLICY "Admin can view all transactions"
ON public.transacciones
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND rol = 'admin'
  )
);

-- ============================================
-- POLÍTICAS PARA TABLA: solicitudes_recarga
-- ============================================

DROP POLICY IF EXISTS "Users can view own recharge requests" ON public.solicitudes_recarga;
DROP POLICY IF EXISTS "Cashiers can view assigned requests" ON public.solicitudes_recarga;
DROP POLICY IF EXISTS "Admin can view all recharge requests" ON public.solicitudes_recarga;
DROP POLICY IF EXISTS "Users can create recharge requests" ON public.solicitudes_recarga;
DROP POLICY IF EXISTS "Cashiers can update assigned requests" ON public.solicitudes_recarga;
DROP POLICY IF EXISTS "Admin can update all recharge requests" ON public.solicitudes_recarga;

-- Usuario puede ver sus propias solicitudes
CREATE POLICY "Users can view own recharge requests"
ON public.solicitudes_recarga
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Cajero puede ver solicitudes asignadas a él
CREATE POLICY "Cashiers can view assigned requests"
ON public.solicitudes_recarga
FOR SELECT
TO authenticated
USING (auth.uid() = cajero_id);

-- Admin puede ver todas las solicitudes
CREATE POLICY "Admin can view all recharge requests"
ON public.solicitudes_recarga
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND rol = 'admin'
  )
);

-- Usuario puede crear solicitudes
CREATE POLICY "Users can create recharge requests"
ON public.solicitudes_recarga
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Cajero puede actualizar solicitudes asignadas
CREATE POLICY "Cashiers can update assigned requests"
ON public.solicitudes_recarga
FOR UPDATE
TO authenticated
USING (auth.uid() = cajero_id);

-- Admin puede actualizar cualquier solicitud
CREATE POLICY "Admin can update all recharge requests"
ON public.solicitudes_recarga
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND rol = 'admin'
  )
);

-- ============================================
-- POLÍTICAS PARA TABLA: movimientos_creditos
-- ============================================

DROP POLICY IF EXISTS "Users can view own movimientos" ON public.movimientos_creditos;
DROP POLICY IF EXISTS "System can insert movimientos" ON public.movimientos_creditos;
DROP POLICY IF EXISTS "Users can view own credit movements" ON public.movimientos_creditos;

-- Ver propios movimientos
CREATE POLICY "Users can view own movimientos"
ON public.movimientos_creditos
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Permitir inserción (se hará desde funciones del servidor)
CREATE POLICY "System can insert movimientos"
ON public.movimientos_creditos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: notificaciones
-- ============================================

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notificaciones;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notificaciones;

-- Usuario puede ver sus propias notificaciones
CREATE POLICY "Users can view own notifications"
ON public.notificaciones
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Usuario puede actualizar sus propias notificaciones (marcar como leída)
CREATE POLICY "Users can update own notifications"
ON public.notificaciones
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: favoritos
-- ============================================

DROP POLICY IF EXISTS "Users can view own favoritos" ON public.favoritos;
DROP POLICY IF EXISTS "Users can insert favoritos" ON public.favoritos;
DROP POLICY IF EXISTS "Users can delete favoritos" ON public.favoritos;
DROP POLICY IF EXISTS "Users can view own favorites" ON public.favoritos;
DROP POLICY IF EXISTS "Users can create favorites" ON public.favoritos;
DROP POLICY IF EXISTS "Users can delete own favorites" ON public.favoritos;

-- Ver propios favoritos
CREATE POLICY "Users can view own favoritos"
ON public.favoritos
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Agregar favoritos
CREATE POLICY "Users can insert favoritos"
ON public.favoritos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Eliminar favoritos
CREATE POLICY "Users can delete favoritos"
ON public.favoritos
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: foro_preguntas
-- ============================================

DROP POLICY IF EXISTS "Public can view preguntas" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can insert preguntas" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can update own preguntas" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Public can view visible questions" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can create questions" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can update own questions" ON public.foro_preguntas;

-- Ver preguntas
CREATE POLICY "Public can view preguntas"
ON public.foro_preguntas
FOR SELECT
TO public
USING (visible = true);

-- Crear preguntas
CREATE POLICY "Users can insert preguntas"
ON public.foro_preguntas
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Actualizar propias preguntas
CREATE POLICY "Users can update own preguntas"
ON public.foro_preguntas
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS PARA TABLA: foro_respuestas
-- ============================================

DROP POLICY IF EXISTS "Public can view respuestas" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can insert respuestas" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can update own respuestas" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Public can view answers" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can create answers" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can update own answers" ON public.foro_respuestas;

-- Ver respuestas
CREATE POLICY "Public can view respuestas"
ON public.foro_respuestas
FOR SELECT
TO public
USING (true);

-- Crear respuestas
CREATE POLICY "Users can insert respuestas"
ON public.foro_respuestas
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Actualizar propias respuestas
CREATE POLICY "Users can update own respuestas"
ON public.foro_respuestas
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- FUNCIONES RPC (Remote Procedure Calls)
-- ============================================

-- Función para incrementar contador de solicitudes publicadas
CREATE OR REPLACE FUNCTION incrementar_solicitudes_publicadas(user_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.users
  SET total_solicitudes_publicadas = total_solicitudes_publicadas + 1,
      updated_at = NOW()
  WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION incrementar_solicitudes_publicadas(UUID) IS 'Incrementa el contador de solicitudes publicadas para un usuario';

-- Función para procesar código de referido
CREATE OR REPLACE FUNCTION procesar_referido(
  nuevo_user_id UUID,
  codigo_ref VARCHAR
)
RETURNS void AS $$
DECLARE
  referidor_id UUID;
  creditos_actuales INT;
BEGIN
  -- Buscar el usuario que refirió (case-insensitive)
  SELECT id INTO referidor_id
  FROM public.users
  WHERE UPPER(codigo_referido) = UPPER(codigo_ref)
  AND id != nuevo_user_id; -- No puede referirse a sí mismo

  -- Si existe el referidor, procesar referido
  IF referidor_id IS NOT NULL THEN
    -- 1. Actualizar usuario nuevo con referido_por
    UPDATE public.users
    SET referido_por = referidor_id,
        updated_at = NOW()
    WHERE id = nuevo_user_id;

    -- 2. Obtener créditos actuales del referidor
    SELECT creditos INTO creditos_actuales
    FROM public.users
    WHERE id = referidor_id;

    -- 3. Actualizar contador, créditos del referidor
    UPDATE public.users
    SET
      total_referidos = total_referidos + 1,
      creditos = creditos + 30,
      creditos_totales_ganados = creditos_totales_ganados + 30,
      updated_at = NOW()
    WHERE id = referidor_id;

    -- 4. Registrar movimiento de créditos del referidor
    INSERT INTO public.movimientos_creditos (
      user_id,
      tipo,
      cantidad,
      saldo_anterior,
      saldo_nuevo,
      origen,
      descripcion,
      created_at
    ) VALUES (
      referidor_id,
      'ganancia',
      30,
      creditos_actuales,
      creditos_actuales + 30,
      'referido',
      'Créditos por referir a nuevo usuario',
      NOW()
    );

    -- Logging para debug
    RAISE NOTICE 'Referido procesado: usuario % referido por %', nuevo_user_id, referidor_id;
  ELSE
    -- Código inválido o usuario no encontrado - no hacer nada
    RAISE NOTICE 'Código de referido inválido o no encontrado: %', codigo_ref;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Capturar cualquier error pero no fallar la transacción
    RAISE WARNING 'Error procesando referido: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION procesar_referido(UUID, VARCHAR) IS 'Procesa un código de referido al registrarse un nuevo usuario. Otorga créditos al referidor.';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Verificar políticas creadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
