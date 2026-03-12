-- ============================================
-- MIGRACIÓN 018: FIXES COMPLETOS PARA PRODUCCIÓN
-- Fecha: 22 Enero 2026
-- Corrige: Créditos, Foro, Seeders participativos
-- ============================================

-- ============================================
-- 1. CORREGIR FUNCIÓN DE DESCONTAR CRÉDITOS
-- ============================================

-- Eliminar función existente
DROP FUNCTION IF EXISTS descontar_creditos(uuid, integer, text);

-- Crear función corregida que retorna boolean correctamente
CREATE OR REPLACE FUNCTION descontar_creditos(
    p_user_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_creditos_actuales INTEGER;
BEGIN
    -- Obtener créditos actuales
    SELECT creditos INTO v_creditos_actuales
    FROM public.users
    WHERE id = p_user_id
    FOR UPDATE;

    -- Verificar si tiene suficientes créditos
    IF v_creditos_actuales IS NULL THEN
        RETURN FALSE;
    END IF;

    IF v_creditos_actuales < p_cantidad THEN
        RETURN FALSE;
    END IF;

    -- Descontar créditos
    UPDATE public.users
    SET
        creditos = creditos - p_cantidad,
        updated_at = NOW()
    WHERE id = p_user_id;

    -- Registrar movimiento
    INSERT INTO public.movimientos_creditos (
        user_id,
        tipo,
        cantidad,
        motivo,
        saldo_anterior,
        saldo_nuevo,
        created_at
    ) VALUES (
        p_user_id,
        'gasto',
        p_cantidad,
        p_motivo,
        v_creditos_actuales,
        v_creditos_actuales - p_cantidad,
        NOW()
    );

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- ============================================
-- 2. CORREGIR FUNCIÓN DE INCREMENTAR CRÉDITOS
-- ============================================

DROP FUNCTION IF EXISTS incrementar_creditos(uuid, integer, text, text);

CREATE OR REPLACE FUNCTION incrementar_creditos(
    p_user_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT,
    p_descripcion TEXT DEFAULT ''
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_creditos_actuales INTEGER;
BEGIN
    -- Obtener créditos actuales
    SELECT creditos INTO v_creditos_actuales
    FROM public.users
    WHERE id = p_user_id
    FOR UPDATE;

    IF v_creditos_actuales IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Incrementar créditos
    UPDATE public.users
    SET
        creditos = creditos + p_cantidad,
        updated_at = NOW()
    WHERE id = p_user_id;

    -- Registrar movimiento
    INSERT INTO public.movimientos_creditos (
        user_id,
        tipo,
        cantidad,
        motivo,
        descripcion,
        saldo_anterior,
        saldo_nuevo,
        created_at
    ) VALUES (
        p_user_id,
        'ganancia',
        p_cantidad,
        p_motivo,
        COALESCE(p_descripcion, ''),
        v_creditos_actuales,
        v_creditos_actuales + p_cantidad,
        NOW()
    );

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- ============================================
-- 3. CORREGIR FUNCIÓN DE INCREMENTAR RESPUESTAS
-- (Evitar duplicación del contador)
-- ============================================

DROP FUNCTION IF EXISTS incrementar_respuestas_pregunta(uuid);

CREATE OR REPLACE FUNCTION incrementar_respuestas_pregunta(
    p_pregunta_id UUID
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Actualizar contador con el conteo real de respuestas
    UPDATE public.foro_preguntas
    SET
        total_respuestas = (
            SELECT COUNT(*) FROM public.foro_respuestas
            WHERE pregunta_id = p_pregunta_id
        ),
        updated_at = NOW()
    WHERE id = p_pregunta_id;
END;
$$;

-- ============================================
-- 4. CREAR FUNCIÓN PARA PREMIAR MEJOR RESPUESTA
-- ============================================

DROP FUNCTION IF EXISTS premiar_mejor_respuesta(uuid, uuid);

CREATE OR REPLACE FUNCTION premiar_mejor_respuesta(
    p_pregunta_id UUID,
    p_respuesta_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_autor_respuesta_id UUID;
    v_creditos_premio INTEGER := 2; -- Créditos por mejor respuesta
BEGIN
    -- Obtener el autor de la respuesta
    SELECT user_id INTO v_autor_respuesta_id
    FROM public.foro_respuestas
    WHERE id = p_respuesta_id;

    IF v_autor_respuesta_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Marcar la pregunta como resuelta
    UPDATE public.foro_preguntas
    SET
        resuelta = TRUE,
        mejor_respuesta_id = p_respuesta_id,
        updated_at = NOW()
    WHERE id = p_pregunta_id;

    -- Marcar la respuesta como mejor respuesta
    UPDATE public.foro_respuestas
    SET
        es_mejor_respuesta = TRUE,
        updated_at = NOW()
    WHERE id = p_respuesta_id;

    -- Dar créditos al autor de la respuesta
    PERFORM incrementar_creditos(
        v_autor_respuesta_id,
        v_creditos_premio,
        'mejor_respuesta_foro',
        'Premio por mejor respuesta en el foro'
    );

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- ============================================
-- 5. CREAR TABLA DE CAJEROS (si no existe)
-- ============================================

CREATE TABLE IF NOT EXISTS public.cajeros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    zona TEXT,
    telefono TEXT NOT NULL,
    whatsapp TEXT,
    qr_image TEXT,
    activo BOOLEAN DEFAULT TRUE,
    total_recargas INTEGER DEFAULT 0,
    monto_total_recargado DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_cajeros_ciudad ON public.cajeros(ciudad);
CREATE INDEX IF NOT EXISTS idx_cajeros_activo ON public.cajeros(activo);

-- ============================================
-- 6. CREAR TABLA DE CONTACTOS (nueva feature)
-- ============================================

CREATE TABLE IF NOT EXISTS public.mis_contactos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    profesional_id UUID NOT NULL REFERENCES public.perfiles_profesionales(id) ON DELETE CASCADE,
    notas TEXT,
    favorito BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, profesional_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_mis_contactos_user ON public.mis_contactos(user_id);
CREATE INDEX IF NOT EXISTS idx_mis_contactos_profesional ON public.mis_contactos(profesional_id);

-- ============================================
-- 7. ACTUALIZAR USUARIO ADMINISTRADOR
-- ============================================

-- Asegurar que exista un usuario administrador (usando subconsulta para limitar a 1)
UPDATE public.users
SET
    rol = 'admin',
    tipo_cuenta = 'premium',
    creditos = 9999,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE
WHERE id = (
    SELECT id FROM public.users
    WHERE email = 'admin@contactos.bo' OR email LIKE '%admin%'
    LIMIT 1
);

-- Si no existe admin, asignar al primer usuario creado
UPDATE public.users
SET
    rol = 'admin',
    tipo_cuenta = 'premium',
    creditos = 9999,
    verificado = TRUE
WHERE id = (SELECT id FROM public.users ORDER BY created_at ASC LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM public.users WHERE rol = 'admin');

-- ============================================
-- 8. SEEDERS PARTICIPATIVOS - SOLICITUDES
-- ============================================

-- Limpiar solicitudes de prueba existentes
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%SEED%' OR titulo LIKE '%Test%';

-- Insertar solicitudes reales de los usuarios seeders
INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado,
    total_postulaciones, visible, destacada, created_at, expires_at
) VALUES
-- María busca plomero
(
    gen_random_uuid(),
    'b28ab1f6-2414-4d51-9007-f810feec6159',
    'Necesito plomero urgente - Fuga de agua',
    'Tengo una fuga de agua en el baño principal. El problema parece estar en la tubería detrás de la pared. Necesito alguien que pueda venir hoy o mañana temprano.',
    'Plomero',
    'La Paz',
    'Sopocachi',
    100, 300,
    'urgente',
    'activa',
    2, TRUE, FALSE,
    NOW() - INTERVAL '2 days',
    NOW() + INTERVAL '5 days'
),
-- Carlos busca electricista
(
    gen_random_uuid(),
    '31737974-2c50-4a9d-ba08-c99ed0ddca49',
    'Instalación de luces LED en departamento',
    'Quiero cambiar todas las luces de mi departamento a LED. Son aproximadamente 15 puntos de luz. El departamento tiene 3 dormitorios, sala, comedor y cocina.',
    'Electricista',
    'Santa Cruz',
    'Equipetrol',
    500, 1200,
    'normal',
    'activa',
    3, TRUE, TRUE,
    NOW() - INTERVAL '1 day',
    NOW() + INTERVAL '6 days'
),
-- Ana busca pintor
(
    gen_random_uuid(),
    '763363b6-82df-4a23-b12a-26cbfe359f57',
    'Pintar departamento completo - 80m2',
    'Necesito pintar mi departamento completo. Incluye 2 dormitorios, sala, comedor, cocina y 2 baños. Prefiero colores claros y modernos. El trabajo incluye preparación de paredes.',
    'Pintor',
    'Cochabamba',
    'Zona Norte',
    800, 1500,
    'normal',
    'activa',
    1, TRUE, FALSE,
    NOW() - INTERVAL '3 days',
    NOW() + INTERVAL '4 days'
),
-- Roberto busca técnico PC
(
    gen_random_uuid(),
    '70cf58f1-05ca-47b5-9384-386663a9a20b',
    'Reparación de laptop - No enciende',
    'Mi laptop Dell no enciende. Cargaba bien hasta ayer. Cuando conecto el cargador la luz prende pero la laptop no responde. Tiene información importante.',
    'Reparación computadoras',
    'El Alto',
    'Ciudad Satélite',
    50, 200,
    'urgente',
    'activa',
    2, TRUE, FALSE,
    NOW() - INTERVAL '12 hours',
    NOW() + INTERVAL '7 days'
),
-- Patricia busca limpieza
(
    gen_random_uuid(),
    'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768',
    'Limpieza profunda de casa - 150m2',
    'Necesito una limpieza profunda de toda la casa incluyendo ventanas, cortinas y muebles. Casa de 2 pisos con jardín. Preferiblemente este fin de semana.',
    'Limpieza del hogar',
    'Tarija',
    'Centro',
    200, 400,
    'normal',
    'activa',
    0, TRUE, FALSE,
    NOW() - INTERVAL '4 hours',
    NOW() + INTERVAL '7 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. SEEDERS PARTICIPATIVOS - PREGUNTAS FORO
-- ============================================

-- Limpiar preguntas de prueba
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%SEED%' OR titulo LIKE '%Test%';

-- Insertar preguntas reales
INSERT INTO public.foro_preguntas (
    id, user_id, titulo, descripcion, categoria,
    total_respuestas, total_vistas, resuelta, created_at
) VALUES
-- María pregunta sobre rutas
(
    gen_random_uuid(),
    'b28ab1f6-2414-4d51-9007-f810feec6159',
    '¿Está habilitada la ruta La Paz - Oruro?',
    'Necesito viajar mañana temprano a Oruro. ¿Alguien sabe si la carretera está habilitada? Escuché que hubo un bloqueo ayer.',
    'Rutas y Transporte',
    3, 45, FALSE,
    NOW() - INTERVAL '6 hours'
),
-- Carlos pregunta recomendación
(
    gen_random_uuid(),
    '31737974-2c50-4a9d-ba08-c99ed0ddca49',
    '¿Dónde puedo comprar materiales eléctricos al por mayor?',
    'Estoy buscando un proveedor de materiales eléctricos que venda al por mayor en Santa Cruz. Necesito cables, tomacorrientes y llaves térmicas. ¿Alguna recomendación?',
    'Recomendaciones',
    2, 28, FALSE,
    NOW() - INTERVAL '1 day'
),
-- Ana pregunta sobre trámites
(
    gen_random_uuid(),
    '763363b6-82df-4a23-b12a-26cbfe359f57',
    '¿Qué documentos necesito para renovar mi carnet?',
    'Mi carnet de identidad está por vencer. ¿Qué documentos necesito llevar y cuánto cuesta la renovación? ¿Es mejor ir al SEGIP o a otro lugar?',
    'Trámites',
    4, 89, TRUE,
    NOW() - INTERVAL '3 days'
),
-- Roberto pregunta de tecnología
(
    gen_random_uuid(),
    '70cf58f1-05ca-47b5-9384-386663a9a20b',
    '¿Alguien sabe de un buen técnico de celulares en El Alto?',
    'Se me cayó el celular y la pantalla quedó con líneas verdes. ¿Conocen algún técnico confiable que arregle pantallas de Samsung en El Alto?',
    'Tecnología',
    5, 67, FALSE,
    NOW() - INTERVAL '2 days'
),
-- Patricia pregunta general
(
    gen_random_uuid(),
    'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768',
    '¿Conocen una buena academia de inglés en Tarija?',
    'Quiero aprender inglés desde cero. ¿Alguien puede recomendarme una academia buena y no muy cara en Tarija? Preferiblemente con horarios de noche.',
    'Educación',
    3, 34, FALSE,
    NOW() - INTERVAL '5 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 10. SEEDERS PARTICIPATIVOS - RESPUESTAS FORO
-- ============================================

-- Insertar respuestas de los usuarios profesionales a las preguntas
-- Primero obtener los IDs de las preguntas
DO $$
DECLARE
    v_pregunta_rutas UUID;
    v_pregunta_materiales UUID;
    v_pregunta_carnet UUID;
    v_pregunta_tecnico UUID;
    v_pregunta_ingles UUID;
BEGIN
    -- Obtener IDs de preguntas
    SELECT id INTO v_pregunta_rutas FROM public.foro_preguntas WHERE titulo LIKE '%ruta La Paz%' LIMIT 1;
    SELECT id INTO v_pregunta_materiales FROM public.foro_preguntas WHERE titulo LIKE '%materiales eléctricos%' LIMIT 1;
    SELECT id INTO v_pregunta_carnet FROM public.foro_preguntas WHERE titulo LIKE '%renovar mi carnet%' LIMIT 1;
    SELECT id INTO v_pregunta_tecnico FROM public.foro_preguntas WHERE titulo LIKE '%técnico de celulares%' LIMIT 1;
    SELECT id INTO v_pregunta_ingles FROM public.foro_preguntas WHERE titulo LIKE '%academia de inglés%' LIMIT 1;

    -- Respuestas a pregunta de rutas
    IF v_pregunta_rutas IS NOT NULL THEN
        INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, total_votos, es_mejor_respuesta, created_at)
        VALUES
        (v_pregunta_rutas, 'b3939605-d82b-4327-ba24-7fe4d6826b8b', 'Yo pasé ayer por ahí y estaba todo normal. El bloqueo ya lo levantaron.', 5, FALSE, NOW() - INTERVAL '5 hours'),
        (v_pregunta_rutas, '9b9ba512-d6db-412e-bf13-eff79a49e206', 'Confirmo, la ruta está habilitada. Solo ten cuidado en el tramo de Caracollo porque hay obras.', 3, FALSE, NOW() - INTERVAL '4 hours'),
        (v_pregunta_rutas, '227e12df-6896-4cbf-a9a4-068987512bc2', 'Puedes verificar en la página del ABC o llamar al 800-10-0000 para confirmar.', 8, FALSE, NOW() - INTERVAL '3 hours')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Respuestas a pregunta de materiales
    IF v_pregunta_materiales IS NOT NULL THEN
        INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, total_votos, es_mejor_respuesta, created_at)
        VALUES
        (v_pregunta_materiales, 'b3939605-d82b-4327-ba24-7fe4d6826b8b', 'Te recomiendo DIDELCO en la Av. Grigotá, tienen buenos precios al por mayor. También está ELECTRO IMPORT en la feria.', 12, FALSE, NOW() - INTERVAL '20 hours'),
        (v_pregunta_materiales, 'd0e5595f-7880-4294-b7f5-a56313a41470', 'Yo compro en SODIMAC cuando tienen promociones. A veces sale más barato que los de la feria.', 4, FALSE, NOW() - INTERVAL '18 hours')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Respuestas a pregunta de carnet (esta está resuelta)
    IF v_pregunta_carnet IS NOT NULL THEN
        INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, total_votos, es_mejor_respuesta, created_at)
        VALUES
        (v_pregunta_carnet, '1631b7cc-51ca-4d7b-ac56-a219e56d189c', 'Necesitas tu carnet anterior, certificado de nacimiento original y Bs. 54 para la renovación. En el SEGIP del centro es más rápido, pero hay filas desde las 6am.', 25, TRUE, NOW() - INTERVAL '2 days'),
        (v_pregunta_carnet, 'b3939605-d82b-4327-ba24-7fe4d6826b8b', 'También puedes sacar cita por internet en la página del SEGIP. Es más fácil y no haces tanta fila.', 15, FALSE, NOW() - INTERVAL '2 days'),
        (v_pregunta_carnet, '9b9ba512-d6db-412e-bf13-eff79a49e206', 'Yo lo saqué la semana pasada en el Megacenter, no había casi nada de gente.', 8, FALSE, NOW() - INTERVAL '1 day'),
        (v_pregunta_carnet, 'd0e5595f-7880-4294-b7f5-a56313a41470', 'OJO: Si tu carnet está muy dañado te pueden cobrar Bs. 74 en vez de 54.', 6, FALSE, NOW() - INTERVAL '1 day')
        ON CONFLICT DO NOTHING;

        -- Marcar como resuelta
        UPDATE public.foro_preguntas SET resuelta = TRUE WHERE id = v_pregunta_carnet;
    END IF;

    -- Respuestas a pregunta de técnico celulares
    IF v_pregunta_tecnico IS NOT NULL THEN
        INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, total_votos, es_mejor_respuesta, created_at)
        VALUES
        (v_pregunta_tecnico, 'd0e5595f-7880-4294-b7f5-a56313a41470', 'Soy técnico de celulares, te puedo ayudar. Trabajo en Villa Adela. La pantalla de Samsung varía entre 150-400 Bs dependiendo del modelo. Escríbeme al WhatsApp.', 18, FALSE, NOW() - INTERVAL '1 day'),
        (v_pregunta_tecnico, '227e12df-6896-4cbf-a9a4-068987512bc2', 'En la 16 de Julio hay varios técnicos buenos. Busca al "Celulares Ricky", es confiable.', 7, FALSE, NOW() - INTERVAL '1 day'),
        (v_pregunta_tecnico, '9b9ba512-d6db-412e-bf13-eff79a49e206', 'Cuidado con los técnicos de la feria, algunos ponen repuestos genéricos. Mejor ir a uno recomendado.', 9, FALSE, NOW() - INTERVAL '20 hours'),
        (v_pregunta_tecnico, '1631b7cc-51ca-4d7b-ac56-a219e56d189c', 'Yo llevé mi Xiaomi a "TecnoFix" en Río Seco y me fue bien. Precios justos.', 5, FALSE, NOW() - INTERVAL '12 hours'),
        (v_pregunta_tecnico, 'b3939605-d82b-4327-ba24-7fe4d6826b8b', 'Pregunta bien si la pantalla es original o compatible. La original dura más pero cuesta el doble.', 4, FALSE, NOW() - INTERVAL '6 hours')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Respuestas a pregunta de inglés
    IF v_pregunta_ingles IS NOT NULL THEN
        INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, total_votos, es_mejor_respuesta, created_at)
        VALUES
        (v_pregunta_ingles, '227e12df-6896-4cbf-a9a4-068987512bc2', 'El Centro Boliviano Americano es muy bueno, pero un poco caro. Tienen horarios de 7-9pm.', 6, FALSE, NOW() - INTERVAL '4 days'),
        (v_pregunta_ingles, '1631b7cc-51ca-4d7b-ac56-a219e56d189c', 'Yo aprendí en "English First" cerca de la plaza principal. Son más económicos y los profes son buenos.', 10, FALSE, NOW() - INTERVAL '4 days'),
        (v_pregunta_ingles, 'b3939605-d82b-4327-ba24-7fe4d6826b8b', 'También puedes complementar con Duolingo, es gratis y ayuda bastante para empezar.', 4, FALSE, NOW() - INTERVAL '3 days')
        ON CONFLICT DO NOTHING;
    END IF;
END;
$$;

-- ============================================
-- 11. ACTUALIZAR CONTADORES DE RESPUESTAS
-- ============================================

UPDATE public.foro_preguntas fp
SET total_respuestas = (
    SELECT COUNT(*) FROM public.foro_respuestas fr WHERE fr.pregunta_id = fp.id
);

-- ============================================
-- 12. SEEDERS PARTICIPATIVOS - RESEÑAS
-- ============================================

-- Insertar reseñas de usuarios buscadores a profesionales
INSERT INTO public.resenas (
    id, usuario_id, profesional_id, calificacion, contenido, created_at
)
SELECT
    gen_random_uuid(),
    'b28ab1f6-2414-4d51-9007-f810feec6159', -- María
    pp.id,
    5,
    'Excelente trabajo, muy profesional y puntual. Lo recomiendo totalmente.',
    NOW() - INTERVAL '10 days'
FROM public.perfiles_profesionales pp
WHERE pp.user_id = 'b3939605-d82b-4327-ba24-7fe4d6826b8b' -- Juan Carlos Electricista
ON CONFLICT DO NOTHING;

INSERT INTO public.resenas (
    id, usuario_id, profesional_id, calificacion, contenido, created_at
)
SELECT
    gen_random_uuid(),
    '31737974-2c50-4a9d-ba08-c99ed0ddca49', -- Carlos
    pp.id,
    4,
    'Buen servicio, llegó a tiempo y el trabajo quedó bien. Precios razonables.',
    NOW() - INTERVAL '8 days'
FROM public.perfiles_profesionales pp
WHERE pp.user_id = '9b9ba512-d6db-412e-bf13-eff79a49e206' -- Miguel Plomero
ON CONFLICT DO NOTHING;

INSERT INTO public.resenas (
    id, usuario_id, profesional_id, calificacion, contenido, created_at
)
SELECT
    gen_random_uuid(),
    '763363b6-82df-4a23-b12a-26cbfe359f57', -- Ana
    pp.id,
    5,
    'El mueble quedó espectacular! Mejor de lo que esperaba. Muy buen carpintero.',
    NOW() - INTERVAL '5 days'
FROM public.perfiles_profesionales pp
WHERE pp.user_id = '227e12df-6896-4cbf-a9a4-068987512bc2' -- Pedro Carpintero
ON CONFLICT DO NOTHING;

INSERT INTO public.resenas (
    id, usuario_id, profesional_id, calificacion, contenido, created_at
)
SELECT
    gen_random_uuid(),
    '70cf58f1-05ca-47b5-9384-386663a9a20b', -- Roberto
    pp.id,
    5,
    'Me arregló la laptop en el mismo día. Recuperó todos mis archivos. Gracias!',
    NOW() - INTERVAL '3 days'
FROM public.perfiles_profesionales pp
WHERE pp.user_id = 'd0e5595f-7880-4294-b7f5-a56313a41470' -- Luis Técnico
ON CONFLICT DO NOTHING;

INSERT INTO public.resenas (
    id, usuario_id, profesional_id, calificacion, contenido, created_at
)
SELECT
    gen_random_uuid(),
    'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768', -- Patricia
    pp.id,
    5,
    'Pintó toda la casa y quedó hermosa. Muy limpia y cuidadosa con los muebles.',
    NOW() - INTERVAL '1 day'
FROM public.perfiles_profesionales pp
WHERE pp.user_id = '1631b7cc-51ca-4d7b-ac56-a219e56d189c' -- Rosa Pintora
ON CONFLICT DO NOTHING;

-- ============================================
-- 13. ACTUALIZAR CALIFICACIONES DE PROFESIONALES
-- ============================================

UPDATE public.perfiles_profesionales pp
SET
    total_resenas = (
        SELECT COUNT(*) FROM public.resenas r WHERE r.profesional_id = pp.id
    ),
    calificacion_promedio = COALESCE((
        SELECT AVG(calificacion)::DECIMAL(3,2) FROM public.resenas r WHERE r.profesional_id = pp.id
    ), 0)
WHERE EXISTS (SELECT 1 FROM public.resenas r WHERE r.profesional_id = pp.id);

-- ============================================
-- 14. CREAR CAJEROS DE EJEMPLO
-- ============================================

INSERT INTO public.cajeros (
    id, nombre, ciudad, zona, telefono, whatsapp, activo
) VALUES
(gen_random_uuid(), 'Cajero Central La Paz', 'La Paz', 'Centro', '71234567', '59171234567', TRUE),
(gen_random_uuid(), 'Cajero Sopocachi', 'La Paz', 'Sopocachi', '72345678', '59172345678', TRUE),
(gen_random_uuid(), 'Cajero Santa Cruz Centro', 'Santa Cruz', 'Centro', '73456789', '59173456789', TRUE),
(gen_random_uuid(), 'Cajero Equipetrol', 'Santa Cruz', 'Equipetrol', '74567890', '59174567890', TRUE),
(gen_random_uuid(), 'Cajero Cochabamba', 'Cochabamba', 'Centro', '75678901', '59175678901', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ MIGRACIÓN 018 EJECUTADA CORRECTAMENTE' as resultado;
SELECT 'Usuarios con rol admin: ' || COUNT(*) FROM public.users WHERE rol = 'admin';
SELECT 'Solicitudes activas: ' || COUNT(*) FROM public.solicitudes_trabajo WHERE estado = 'activa';
SELECT 'Preguntas del foro: ' || COUNT(*) FROM public.foro_preguntas;
SELECT 'Respuestas del foro: ' || COUNT(*) FROM public.foro_respuestas;
SELECT 'Cajeros activos: ' || COUNT(*) FROM public.cajeros WHERE activo = TRUE;
