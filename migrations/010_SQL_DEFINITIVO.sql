-- ============================================
-- SQL DEFINITIVO v6.0 - BASADO EN BD REAL
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PASO 1: DESACTIVAR RLS
-- ============================================
ALTER TABLE IF EXISTS public.foro_preguntas DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.foro_respuestas DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.perfiles_profesionales DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.solicitudes_trabajo DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.postulaciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.cajeros_vendedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.favoritos DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.resenas DISABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 2: ELIMINAR TODAS LAS POLITICAS
-- ============================================
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname, tablename
        FROM pg_policies
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- ============================================
-- PASO 3: COLUMNAS FALTANTES EN USERS
-- ============================================
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS creditos INT DEFAULT 50;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS creditos_totales_ganados INT DEFAULT 50;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS creditos_totales_gastados INT DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS total_solicitudes_publicadas INT DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS verificado BOOLEAN DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS perfil_completo BOOLEAN DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS rol VARCHAR(20) DEFAULT 'buscador';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS tipo_cuenta VARCHAR(20) DEFAULT 'gratuita';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================
-- PASO 4: COLUMNAS FALTANTES EN FORO_PREGUNTAS
-- ============================================
ALTER TABLE public.foro_preguntas ADD COLUMN IF NOT EXISTS resuelta BOOLEAN DEFAULT false;
ALTER TABLE public.foro_preguntas ADD COLUMN IF NOT EXISTS mejor_respuesta_id UUID;
ALTER TABLE public.foro_preguntas ADD COLUMN IF NOT EXISTS total_vistas INT DEFAULT 0;

-- ============================================
-- PASO 5: TABLA POSTULACIONES (RECREAR)
-- ============================================
DROP TABLE IF EXISTS public.postulaciones CASCADE;

CREATE TABLE public.postulaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  solicitud_id UUID REFERENCES public.solicitudes_trabajo(id) ON DELETE CASCADE NOT NULL,
  profesional_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  mensaje TEXT NOT NULL,
  presupuesto_ofrecido DECIMAL(10,2),
  tiempo_estimado VARCHAR(50),
  estado VARCHAR(20) DEFAULT 'pendiente',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_postulaciones_solicitud ON public.postulaciones(solicitud_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_profesional ON public.postulaciones(profesional_id);

-- ============================================
-- PASO 6: ACTIVAR RLS Y CREAR POLITICAS
-- (Usando nombres de columna REALES de la BD)
-- ============================================

-- PERFILES PROFESIONALES (tiene: user_id, activo, visible_busqueda)
ALTER TABLE public.perfiles_profesionales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pp_select" ON public.perfiles_profesionales FOR SELECT TO authenticated USING (activo = true AND visible_busqueda = true);
CREATE POLICY "pp_all" ON public.perfiles_profesionales FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- SOLICITUDES TRABAJO (tiene: user_id, visible)
ALTER TABLE public.solicitudes_trabajo ENABLE ROW LEVEL SECURITY;
CREATE POLICY "st_select" ON public.solicitudes_trabajo FOR SELECT TO authenticated USING (visible = true);
CREATE POLICY "st_all" ON public.solicitudes_trabajo FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- POSTULACIONES (tiene: profesional_id, solicitud_id)
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "post_insert" ON public.postulaciones FOR INSERT TO authenticated WITH CHECK (auth.uid() = profesional_id);
CREATE POLICY "post_select" ON public.postulaciones FOR SELECT TO authenticated USING (
  auth.uid() = profesional_id OR
  auth.uid() IN (SELECT user_id FROM public.solicitudes_trabajo WHERE id = solicitud_id)
);
CREATE POLICY "post_update" ON public.postulaciones FOR UPDATE TO authenticated USING (auth.uid() = profesional_id);

-- FORO PREGUNTAS (tiene: user_id, visible)
ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fp_select" ON public.foro_preguntas FOR SELECT TO authenticated USING (visible = true);
CREATE POLICY "fp_insert" ON public.foro_preguntas FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "fp_update" ON public.foro_preguntas FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "fp_delete" ON public.foro_preguntas FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- FORO RESPUESTAS (tiene: user_id)
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fr_select" ON public.foro_respuestas FOR SELECT TO authenticated USING (true);
CREATE POLICY "fr_insert" ON public.foro_respuestas FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "fr_update" ON public.foro_respuestas FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- CAJEROS (tiene: user_id, activo)
ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "caj_select" ON public.cajeros_vendedores FOR SELECT TO authenticated USING (activo = true);

-- FAVORITOS (tiene: user_id, profesional_id)
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fav_all" ON public.favoritos FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- RESENAS (tiene: usuario_id NO user_id, visible)
ALTER TABLE public.resenas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "res_select" ON public.resenas FOR SELECT TO authenticated USING (visible = true);
CREATE POLICY "res_insert" ON public.resenas FOR INSERT TO authenticated WITH CHECK (auth.uid() = usuario_id);

-- ============================================
-- PASO 7: FUNCIONES RPC
-- ============================================
DROP FUNCTION IF EXISTS public.descontar_creditos(UUID, INT, TEXT);
DROP FUNCTION IF EXISTS public.incrementar_creditos(UUID, INT, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.puede_publicar_solicitud_gratis(UUID);
DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(UUID);
DROP FUNCTION IF EXISTS public.incrementar_postulaciones_solicitud(UUID);
DROP FUNCTION IF EXISTS public.incrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.decrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.incrementar_vistas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.votar_respuesta(UUID);

CREATE OR REPLACE FUNCTION public.descontar_creditos(p_user_id UUID, p_cantidad INT, p_motivo TEXT DEFAULT 'gasto')
RETURNS BOOLEAN AS $$
DECLARE v_creditos INT;
BEGIN
  SELECT creditos INTO v_creditos FROM public.users WHERE id = p_user_id;
  IF v_creditos IS NULL OR v_creditos < p_cantidad THEN RETURN FALSE; END IF;
  UPDATE public.users SET creditos = creditos - p_cantidad, creditos_totales_gastados = COALESCE(creditos_totales_gastados,0) + p_cantidad WHERE id = p_user_id;
  RETURN TRUE;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_creditos(p_user_id UUID, p_cantidad INT, p_motivo TEXT DEFAULT 'ganancia', p_descripcion TEXT DEFAULT '')
RETURNS VOID AS $$
BEGIN
  UPDATE public.users SET creditos = COALESCE(creditos,0) + p_cantidad, creditos_totales_ganados = COALESCE(creditos_totales_ganados,0) + p_cantidad WHERE id = p_user_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.puede_publicar_solicitud_gratis(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT COALESCE(total_solicitudes_publicadas,0) = 0 FROM public.users WHERE id = p_user_id);
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_solicitudes_publicadas(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.users SET total_solicitudes_publicadas = COALESCE(total_solicitudes_publicadas,0) + 1 WHERE id = p_user_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_postulaciones_solicitud(p_solicitud_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.solicitudes_trabajo SET total_postulaciones = COALESCE(total_postulaciones,0) + 1 WHERE id = p_solicitud_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas SET total_respuestas = COALESCE(total_respuestas,0) + 1 WHERE id = p_pregunta_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.decrementar_respuestas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas SET total_respuestas = GREATEST(COALESCE(total_respuestas,0) - 1, 0) WHERE id = p_pregunta_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_vistas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas SET total_vistas = COALESCE(total_vistas,0) + 1 WHERE id = p_pregunta_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.votar_respuesta(p_respuesta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_respuestas SET total_votos = COALESCE(total_votos,0) + 1 WHERE id = p_respuesta_id;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VERIFICACION
-- ============================================
SELECT 'SQL v6.0 EJECUTADO CORRECTAMENTE' as resultado;
