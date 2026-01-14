-- ============================================
-- MIGRACIÓN 001: Agregar columna 'destacada'
-- Fecha: 2026-01-14
-- Descripción: Agrega la columna destacada a solicitudes_trabajo
-- ============================================

-- Agregar columna destacada
ALTER TABLE public.solicitudes_trabajo
ADD COLUMN IF NOT EXISTS destacada BOOLEAN DEFAULT false;

-- Crear índice para optimizar consultas de solicitudes destacadas
CREATE INDEX IF NOT EXISTS idx_solicitudes_destacada
ON public.solicitudes_trabajo(destacada)
WHERE destacada = true;

-- Agregar comentario a la columna
COMMENT ON COLUMN public.solicitudes_trabajo.destacada IS 'Indica si la solicitud está destacada (costo adicional de créditos)';
