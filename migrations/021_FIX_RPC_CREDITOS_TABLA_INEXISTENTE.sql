-- ============================================================
-- MIGRACIÓN 021: FIX CRÍTICO - descontar_creditos / incrementar_creditos
-- Fecha: 2026-08-18
--
-- PROBLEMA DETECTADO EN PRODUCCIÓN:
-- Las funciones descontar_creditos() e incrementar_creditos()
-- (definidas en 020_FIXES_CRITICOS.sql) intentan hacer INSERT en la
-- tabla public.transacciones_creditos, la cual NUNCA fue creada en
-- la base de datos real (la tabla que sí existe es movimientos_creditos,
-- creada en 012_CORRECCIONES_COMPLETAS.sql).
--
-- Como ambas funciones tienen "EXCEPTION WHEN OTHERS THEN RETURN false",
-- el INSERT fallido revierte TODA la transacción (incluyendo el UPDATE
-- de creditos) y la función retorna false silenciosamente.
--
-- Efecto real verificado: al "Ver contacto" (2 créditos), el saldo del
-- usuario NUNCA se descuenta, aunque la función se ejecuta sin error de
-- red. Lo mismo aplica a TODAS las formas de ganar créditos que usan
-- incrementar_creditos (video AdMob, referidos, reseñas, perfil completo).
-- ============================================================

CREATE OR REPLACE FUNCTION public.descontar_creditos(
  p_user_id uuid,
  p_cantidad integer,
  p_motivo text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_creditos_actuales integer;
BEGIN
  SELECT creditos INTO v_creditos_actuales
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE;

  IF v_creditos_actuales IS NULL OR v_creditos_actuales < p_cantidad THEN
    RETURN false;
  END IF;

  UPDATE public.users
  SET creditos = creditos - p_cantidad,
      creditos_totales_gastados = COALESCE(creditos_totales_gastados, 0) + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO public.movimientos_creditos (
    user_id, tipo_movimiento, cantidad, saldo_anterior, saldo_nuevo, origen, descripcion
  ) VALUES (
    p_user_id, 'gasto', p_cantidad, v_creditos_actuales, v_creditos_actuales - p_cantidad,
    p_motivo, p_motivo
  );

  RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION public.incrementar_creditos(
  p_user_id uuid,
  p_cantidad integer,
  p_motivo text,
  p_descripcion text DEFAULT ''
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_creditos_actuales integer;
BEGIN
  SELECT creditos INTO v_creditos_actuales
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE;

  IF v_creditos_actuales IS NULL THEN
    RETURN false;
  END IF;

  UPDATE public.users
  SET creditos = creditos + p_cantidad,
      creditos_totales_ganados = COALESCE(creditos_totales_ganados, 0) + p_cantidad,
      updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO public.movimientos_creditos (
    user_id, tipo_movimiento, cantidad, saldo_anterior, saldo_nuevo, origen, descripcion
  ) VALUES (
    p_user_id, 'ganancia', p_cantidad, v_creditos_actuales, v_creditos_actuales + p_cantidad,
    p_motivo, COALESCE(NULLIF(p_descripcion, ''), p_motivo)
  );

  RETURN true;
END;
$$;

GRANT EXECUTE ON FUNCTION public.descontar_creditos(uuid, integer, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.incrementar_creditos(uuid, integer, text, text) TO authenticated;

-- Verificación rápida (ejecutar aparte para confirmar):
-- SELECT public.descontar_creditos('<uuid-de-prueba>', 1, 'test_migracion_021');
-- SELECT creditos FROM public.users WHERE id = '<uuid-de-prueba>';
