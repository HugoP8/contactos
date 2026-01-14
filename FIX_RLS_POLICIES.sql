-- ============================================
-- FIX: Row Level Security (RLS) Policies
-- CONTACTOS APP - Supabase
-- ============================================
-- EJECUTA ESTE SCRIPT EN SUPABASE SQL EDITOR
-- https://supabase.com/dashboard/project/TU_PROJECT/sql/new
-- ============================================

-- ============================================
-- 1. HABILITAR RLS EN TODAS LAS TABLAS
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfiles_profesionales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_trabajo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.postulaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resenas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_preguntas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foro_respuestas ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. POLÍTICAS PARA TABLA: users
-- ============================================

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.users;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.users;

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

-- ============================================
-- 3. POLÍTICAS PARA TABLA: perfiles_profesionales
-- ============================================

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can update own profile" ON public.perfiles_profesionales;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.perfiles_profesionales;

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
-- 4. POLÍTICAS PARA TABLA: solicitudes_trabajo
-- ============================================

DROP POLICY IF EXISTS "Public can view active solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can insert their own solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can update own solicitudes" ON public.solicitudes_trabajo;
DROP POLICY IF EXISTS "Users can view own solicitudes" ON public.solicitudes_trabajo;

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
-- 5. POLÍTICAS PARA TABLA: postulaciones
-- ============================================

DROP POLICY IF EXISTS "Users can view postulaciones to their solicitudes" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can view their own postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can insert postulaciones" ON public.postulaciones;
DROP POLICY IF EXISTS "Users can update own postulaciones" ON public.postulaciones;

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
-- 6. POLÍTICAS PARA TABLA: movimientos_creditos
-- ============================================

DROP POLICY IF EXISTS "Users can view own movimientos" ON public.movimientos_creditos;
DROP POLICY IF EXISTS "System can insert movimientos" ON public.movimientos_creditos;

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
-- 7. POLÍTICAS PARA TABLA: resenas
-- ============================================

DROP POLICY IF EXISTS "Public can view resenas" ON public.resenas;
DROP POLICY IF EXISTS "Users can insert resenas" ON public.resenas;
DROP POLICY IF EXISTS "Users can update own resenas" ON public.resenas;

-- Ver reseñas públicas
CREATE POLICY "Public can view resenas"
ON public.resenas
FOR SELECT
TO public
USING (true);

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
-- 8. POLÍTICAS PARA TABLA: favoritos
-- ============================================

DROP POLICY IF EXISTS "Users can view own favoritos" ON public.favoritos;
DROP POLICY IF EXISTS "Users can insert favoritos" ON public.favoritos;
DROP POLICY IF EXISTS "Users can delete favoritos" ON public.favoritos;

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
-- 9. POLÍTICAS PARA TABLA: foro_preguntas
-- ============================================

DROP POLICY IF EXISTS "Public can view preguntas" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can insert preguntas" ON public.foro_preguntas;
DROP POLICY IF EXISTS "Users can update own preguntas" ON public.foro_preguntas;

-- Ver preguntas
CREATE POLICY "Public can view preguntas"
ON public.foro_preguntas
FOR SELECT
TO public
USING (true);

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
-- 10. POLÍTICAS PARA TABLA: foro_respuestas
-- ============================================

DROP POLICY IF EXISTS "Public can view respuestas" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can insert respuestas" ON public.foro_respuestas;
DROP POLICY IF EXISTS "Users can update own respuestas" ON public.foro_respuestas;

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
-- 11. FUNCIÓN Y TRIGGER: Auto-crear usuario
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
-- 12. FUNCIÓN: Actualizar timestamp
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a tabla users
DROP TRIGGER IF EXISTS set_updated_at ON public.users;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

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
