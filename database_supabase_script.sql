-- ============================================
-- SCRIPT COMPLETO DE BASE DE DATOS SUPABASE
-- APP: CONTACTOS
-- Versión: 1.0
-- Fecha: Enero 2026
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
-- TABLA: resenas_calificaciones
-- ============================================

CREATE TABLE IF NOT EXISTS public.resenas_calificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profesional_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
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
CREATE INDEX IF NOT EXISTS idx_resenas_profesional ON public.resenas_calificaciones(profesional_id);
CREATE INDEX IF NOT EXISTS idx_resenas_cliente ON public.resenas_calificaciones(cliente_id);
CREATE INDEX IF NOT EXISTS idx_resenas_created_at ON public.resenas_calificaciones(created_at DESC);

-- ============================================
-- TABLA: transacciones (Historial financiero)
-- ============================================

CREATE TABLE IF NOT EXISTS public.transacciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

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
CREATE INDEX IF NOT EXISTS idx_transacciones_usuario ON public.transacciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_tipo ON public.transacciones(tipo);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha ON public.transacciones(created_at DESC);

-- ============================================
-- TABLA: solicitudes_recarga (Para sistema de cajeros)
-- ============================================

CREATE TABLE IF NOT EXISTS public.solicitudes_recarga (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
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
CREATE INDEX IF NOT EXISTS idx_solicitudes_recarga_usuario ON public.solicitudes_recarga(usuario_id);
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
-- TABLA: creditos_movimientos (Detalle de créditos)
-- ============================================

CREATE TABLE IF NOT EXISTS public.creditos_movimientos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

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
CREATE INDEX IF NOT EXISTS idx_creditos_usuario ON public.creditos_movimientos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_creditos_fecha ON public.creditos_movimientos(created_at DESC);

-- ============================================
-- TABLA: notificaciones
-- ============================================

CREATE TABLE IF NOT EXISTS public.notificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

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
CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario ON public.notificaciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON public.notificaciones(leida);

-- ============================================
-- TABLA: favoritos
-- ============================================

CREATE TABLE IF NOT EXISTS public.favoritos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  profesional_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraint para evitar duplicados
  UNIQUE(usuario_id, profesional_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_favoritos_usuario ON public.favoritos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_favoritos_profesional ON public.favoritos(profesional_id);

-- ============================================
-- TABLA: foro_preguntas (Feature "Alguien Sabe?")
-- ============================================

CREATE TABLE IF NOT EXISTS public.foro_preguntas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

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
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_usuario ON public.foro_preguntas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_categoria ON public.foro_preguntas(categoria);
CREATE INDEX IF NOT EXISTS idx_foro_preguntas_created_at ON public.foro_preguntas(created_at DESC);

-- ============================================
-- TABLA: foro_respuestas
-- ============================================

CREATE TABLE IF NOT EXISTS public.foro_respuestas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pregunta_id UUID REFERENCES public.foro_preguntas(id) ON DELETE CASCADE,
  usuario_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

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
CREATE INDEX IF NOT EXISTS idx_foro_respuestas_usuario ON public.foro_respuestas(usuario_id);

-- ============================================
-- FUNCIONES RPC (Remote Procedure Calls)
-- ============================================

-- Función para incrementar créditos
CREATE OR REPLACE FUNCTION incrementar_creditos(user_id UUID, cantidad INT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users
  SET
    creditos = creditos + cantidad,
    creditos_totales_ganados = creditos_totales_ganados + cantidad,
    updated_at = NOW()
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para decrementar créditos
CREATE OR REPLACE FUNCTION decrementar_creditos(user_id UUID, cantidad INT)
RETURNS BOOLEAN AS $$
DECLARE
  current_credits INT;
BEGIN
  SELECT creditos INTO current_credits FROM public.users WHERE id = user_id;

  IF current_credits >= cantidad THEN
    UPDATE public.users
    SET
      creditos = creditos - cantidad,
      creditos_totales_gastados = creditos_totales_gastados + cantidad,
      updated_at = NOW()
    WHERE id = user_id;
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
      FROM public.resenas_calificaciones
      WHERE profesional_id = NEW.profesional_id
        AND oculta = false
    ),
    total_resenas = (
      SELECT COUNT(*)
      FROM public.resenas_calificaciones
      WHERE profesional_id = NEW.profesional_id
        AND oculta = false
    ),
    updated_at = NOW()
  WHERE user_id = NEW.profesional_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar calificación
DROP TRIGGER IF EXISTS trigger_actualizar_calificacion ON public.resenas_calificaciones;
CREATE TRIGGER trigger_actualizar_calificacion
  AFTER INSERT OR UPDATE ON public.resenas_calificaciones
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

-- ============================================
-- ROW LEVEL SECURITY (RLS) - POLÍTICAS DE SEGURIDAD
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfiles_profesionales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_trabajo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resenas_calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transacciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_recarga ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comisiones_cajeros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creditos_movimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- Políticas para USERS
-- Los usuarios pueden ver su propia información
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propia información
CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND rol = 'admin'
    )
  );

-- Políticas para PERFILES_PROFESIONALES
-- Todos pueden ver perfiles activos
CREATE POLICY "Public can view active profiles" ON public.perfiles_profesionales
  FOR SELECT USING (activo = true AND visible_busqueda = true);

-- Usuario puede actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON public.perfiles_profesionales
  FOR UPDATE USING (auth.uid() = user_id);

-- Usuario puede insertar su propio perfil
CREATE POLICY "Users can insert own profile" ON public.perfiles_profesionales
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para SOLICITUDES_TRABAJO
-- Todos pueden ver solicitudes activas
CREATE POLICY "Public can view active requests" ON public.solicitudes_trabajo
  FOR SELECT USING (estado = 'activa' AND visible = true);

-- Usuario puede ver sus propias solicitudes
CREATE POLICY "Users can view own requests" ON public.solicitudes_trabajo
  FOR SELECT USING (auth.uid() = user_id);

-- Usuario puede crear solicitudes
CREATE POLICY "Users can create requests" ON public.solicitudes_trabajo
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuario puede actualizar sus solicitudes
CREATE POLICY "Users can update own requests" ON public.solicitudes_trabajo
  FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para POSTULACIONES
-- Profesional puede crear postulaciones
CREATE POLICY "Professionals can create applications" ON public.postulaciones
  FOR INSERT WITH CHECK (auth.uid() = profesional_id);

-- Usuario ve postulaciones de sus solicitudes
CREATE POLICY "Users can view applications to own requests" ON public.postulaciones
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.solicitudes_trabajo
      WHERE id = solicitud_id AND user_id = auth.uid()
    )
  );

-- Profesional ve sus propias postulaciones
CREATE POLICY "Professionals can view own applications" ON public.postulaciones
  FOR SELECT USING (auth.uid() = profesional_id);

-- Políticas para RESEÑAS
-- Todos pueden ver reseñas no ocultas
CREATE POLICY "Public can view visible reviews" ON public.resenas_calificaciones
  FOR SELECT USING (oculta = false);

-- Cliente puede crear reseña
CREATE POLICY "Clients can create reviews" ON public.resenas_calificaciones
  FOR INSERT WITH CHECK (auth.uid() = cliente_id);

-- Políticas para TRANSACCIONES
-- Usuario puede ver sus propias transacciones
CREATE POLICY "Users can view own transactions" ON public.transacciones
  FOR SELECT USING (auth.uid() = usuario_id);

-- Admin puede ver todas las transacciones
CREATE POLICY "Admin can view all transactions" ON public.transacciones
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND rol = 'admin'
    )
  );

-- Políticas para SOLICITUDES_RECARGA
-- Usuario puede ver sus propias solicitudes
CREATE POLICY "Users can view own recharge requests" ON public.solicitudes_recarga
  FOR SELECT USING (auth.uid() = usuario_id);

-- Cajero puede ver solicitudes asignadas a él
CREATE POLICY "Cashiers can view assigned requests" ON public.solicitudes_recarga
  FOR SELECT USING (auth.uid() = cajero_id);

-- Admin puede ver todas las solicitudes
CREATE POLICY "Admin can view all recharge requests" ON public.solicitudes_recarga
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND rol = 'admin'
    )
  );

-- Usuario puede crear solicitudes
CREATE POLICY "Users can create recharge requests" ON public.solicitudes_recarga
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

-- Cajero puede actualizar solicitudes asignadas
CREATE POLICY "Cashiers can update assigned requests" ON public.solicitudes_recarga
  FOR UPDATE USING (auth.uid() = cajero_id);

-- Admin puede actualizar cualquier solicitud
CREATE POLICY "Admin can update all recharge requests" ON public.solicitudes_recarga
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND rol = 'admin'
    )
  );

-- Políticas para CREDITOS_MOVIMIENTOS
-- Usuario puede ver su propio historial
CREATE POLICY "Users can view own credit movements" ON public.creditos_movimientos
  FOR SELECT USING (auth.uid() = usuario_id);

-- Políticas para NOTIFICACIONES
-- Usuario puede ver sus propias notificaciones
CREATE POLICY "Users can view own notifications" ON public.notificaciones
  FOR SELECT USING (auth.uid() = usuario_id);

-- Usuario puede actualizar sus propias notificaciones (marcar como leída)
CREATE POLICY "Users can update own notifications" ON public.notificaciones
  FOR UPDATE USING (auth.uid() = usuario_id);

-- Políticas para FAVORITOS
-- Usuario puede ver sus propios favoritos
CREATE POLICY "Users can view own favorites" ON public.favoritos
  FOR SELECT USING (auth.uid() = usuario_id);

-- Usuario puede crear favoritos
CREATE POLICY "Users can create favorites" ON public.favoritos
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

-- Usuario puede eliminar sus favoritos
CREATE POLICY "Users can delete own favorites" ON public.favoritos
  FOR DELETE USING (auth.uid() = usuario_id);

-- Políticas para FORO
-- Todos pueden ver preguntas visibles
CREATE POLICY "Public can view visible questions" ON public.foro_preguntas
  FOR SELECT USING (visible = true);

-- Usuario puede crear preguntas
CREATE POLICY "Users can create questions" ON public.foro_preguntas
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

-- Usuario puede actualizar sus preguntas
CREATE POLICY "Users can update own questions" ON public.foro_preguntas
  FOR UPDATE USING (auth.uid() = usuario_id);

-- Todos pueden ver respuestas
CREATE POLICY "Public can view answers" ON public.foro_respuestas
  FOR SELECT USING (true);

-- Usuario puede crear respuestas
CREATE POLICY "Users can create answers" ON public.foro_respuestas
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

-- Usuario puede actualizar sus respuestas
CREATE POLICY "Users can update own answers" ON public.foro_respuestas
  FOR UPDATE USING (auth.uid() = usuario_id);

-- ============================================
-- DATOS INICIALES (SEEDS)
-- ============================================

-- Insertar categorías en una tabla de configuración si la creas
-- O puedes usar estos valores directamente en tu app

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Para ejecutar este script:
-- 1. Ir a Supabase Dashboard > SQL Editor
-- 2. Crear una nueva query
-- 3. Copiar y pegar TODO este script
-- 4. Ejecutar (Run)
-- 5. Verificar que no haya errores

-- IMPORTANTE: Después de ejecutar este script:
-- 1. Verifica las tablas en el editor de tablas
-- 2. Prueba las funciones RPC desde tu app
-- 3. Configura las políticas de Storage para las imágenes
-- 4. Configura Authentication en Supabase Dashboard

-- ============================================
-- NOTAS ADICIONALES
-- ============================================

-- Para configurar Storage (imágenes, documentos):
-- 1. Ir a Storage en Supabase Dashboard
-- 2. Crear buckets:
--    - perfiles (públicos)
--    - galeria (públicos)
--    - comprobantes (privados, solo admin)
--    - documentos (privados, solo admin)

-- Para configurar Authentication:
-- 1. Habilitar Google OAuth en Auth > Providers
-- 2. Configurar Email/Password si no está habilitado
-- 3. Configurar templates de emails si es necesario
