-- ============================================================
-- MIGRACIÓN 022: FIX CRÍTICO - Admin no puede ver ni gestionar usuarios
-- Fecha: 2026-08-19
--
-- PROBLEMA DETECTADO EN PRODUCCIÓN:
-- El panel de Admin > "Gestionar Usuarios" solo muestra al propio
-- administrador (1 usuario), no a los demás usuarios de la plataforma.
-- El dashboard también reporta "Usuarios: 1" en vez del total real.
--
-- CAUSA: la tabla public.users solo tiene una política RLS de SELECT
-- que permite a cada usuario ver únicamente su propia fila
-- (auth.uid() = id). No hay ninguna política vigente que permita al
-- rol 'admin' ver o actualizar el resto de usuarios (suspender,
-- activar, etc.), aunque el script original de base de datos sí la
-- definía — se perdió en alguna migración posterior.
--
-- Se usa una función SECURITY DEFINER (public.is_admin) para evitar
-- el riesgo de recursión infinita al referenciar la propia tabla
-- users dentro de su política RLS.
-- ============================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND rol = 'admin'
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

DROP POLICY IF EXISTS "Admin can view all users" ON public.users;
CREATE POLICY "Admin can view all users"
ON public.users
FOR SELECT
TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admin can update all users" ON public.users;
CREATE POLICY "Admin can update all users"
ON public.users
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- ============================================================
-- FIX 2: Admin no puede crear/editar/desactivar/eliminar cajeros
--
-- El código apuntaba a una tabla "cajeros" inexistente (ya corregido
-- en el código a "cajeros_vendedores"). Esa tabla real es legible,
-- pero probablemente le falten políticas de escritura para el admin
-- (mismo patrón que public.users). Se agregan de forma idempotente.
-- ============================================================

ALTER TABLE public.cajeros_vendedores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Cajeros vendedores publicos" ON public.cajeros_vendedores;
CREATE POLICY "Cajeros vendedores publicos"
ON public.cajeros_vendedores
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Admin can manage cajeros" ON public.cajeros_vendedores;
CREATE POLICY "Admin can manage cajeros"
ON public.cajeros_vendedores
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Verificación rápida (ejecutar aparte, logueado como el admin de prueba):
-- SELECT count(*) FROM public.users;  -- debe mostrar el total real, no 1
-- UPDATE public.cajeros_vendedores SET activo = activo WHERE id = (SELECT id FROM public.cajeros_vendedores LIMIT 1); -- no debe dar error de permisos
