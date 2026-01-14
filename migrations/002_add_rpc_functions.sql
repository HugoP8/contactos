-- ============================================
-- MIGRACIÓN 002: Funciones RPC
-- Fecha: 2026-01-14
-- Descripción: Agrega funciones RPC necesarias para la aplicación
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

-- Comentario
COMMENT ON FUNCTION incrementar_solicitudes_publicadas(UUID) IS 'Incrementa el contador de solicitudes publicadas para un usuario';
