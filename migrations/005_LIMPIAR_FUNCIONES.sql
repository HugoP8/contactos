-- ============================================
-- LIMPIAR FUNCIONES EXISTENTES
-- EJECUTAR ANTES DE 006_FIXES_URGENTES.sql
-- ============================================

-- Eliminar función incrementar_solicitudes_publicadas (todas las versiones)
DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(UUID);
DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(user_uuid UUID);
DROP FUNCTION IF EXISTS public.incrementar_solicitudes_publicadas(p_user_id UUID);

-- Eliminar otras funciones que pueden tener conflictos
DROP FUNCTION IF EXISTS public.usar_token_especial(UUID, VARCHAR);
DROP FUNCTION IF EXISTS public.usar_token_especial(p_user_id UUID, p_tipo VARCHAR);

DROP FUNCTION IF EXISTS public.incrementar_vistas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.incrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.decrementar_respuestas_pregunta(UUID);
DROP FUNCTION IF EXISTS public.votar_respuesta(UUID);

SELECT '✅ Funciones limpiadas correctamente' as resultado;
