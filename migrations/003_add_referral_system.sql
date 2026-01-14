-- ============================================
-- MIGRACIÓN 003: Sistema de Referidos
-- Fecha: 2026-01-14
-- Descripción: Implementa el sistema completo de referidos
-- ============================================

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

-- Comentario
COMMENT ON FUNCTION procesar_referido(UUID, VARCHAR) IS 'Procesa un código de referido al registrarse un nuevo usuario. Otorga créditos al referidor.';
