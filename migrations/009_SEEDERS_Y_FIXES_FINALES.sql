-- ============================================
-- SEEDERS Y FIXES FINALES
-- APP: CONTACTOS
-- VERSION: 1.0
-- ============================================
-- EJECUTAR DESPUES DE 008_ESTRUCTURA_COMPLETA.sql
-- ============================================

-- ============================================
-- PARTE 0: COLUMNAS FALTANTES EN PERFILES_PROFESIONALES
-- ============================================

DO $$
BEGIN
  -- Columna destacado en perfiles_profesionales
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'perfiles_profesionales' AND column_name = 'destacado'
  ) THEN
    ALTER TABLE public.perfiles_profesionales ADD COLUMN destacado BOOLEAN DEFAULT false;
    RAISE NOTICE 'Columna destacado agregada a perfiles_profesionales';
  END IF;
END $$;

-- ============================================
-- PARTE 0.1: COLUMNAS FALTANTES EN SOLICITUDES_TRABAJO
-- ============================================

DO $$
BEGIN
  -- Columna fotos (array de URLs)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'fotos'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN fotos TEXT[] DEFAULT '{}';
    RAISE NOTICE 'Columna fotos agregada a solicitudes_trabajo';
  END IF;

  -- Columna creditos_usados
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'creditos_usados'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN creditos_usados INT DEFAULT 0;
    RAISE NOTICE 'Columna creditos_usados agregada a solicitudes_trabajo';
  END IF;

  -- Columna updated_at
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'solicitudes_trabajo' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.solicitudes_trabajo ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    RAISE NOTICE 'Columna updated_at agregada a solicitudes_trabajo';
  END IF;
END $$;

-- ============================================
-- PARTE 1: AGREGAR COLUMNA 'resuelta' A foro_preguntas
-- (El modelo Flutter usa 'resuelta', no 'respondida')
-- ============================================

DO $$
BEGIN
  -- Agregar columna resuelta si no existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'resuelta'
  ) THEN
    ALTER TABLE public.foro_preguntas ADD COLUMN resuelta BOOLEAN DEFAULT false;
    RAISE NOTICE 'Columna resuelta agregada a foro_preguntas';
  END IF;

  -- Agregar columna mejor_respuesta_id si no existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'mejor_respuesta_id'
  ) THEN
    ALTER TABLE public.foro_preguntas ADD COLUMN mejor_respuesta_id UUID;
    RAISE NOTICE 'Columna mejor_respuesta_id agregada a foro_preguntas';
  END IF;

  -- Agregar columna total_vistas si no existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'total_vistas'
  ) THEN
    ALTER TABLE public.foro_preguntas ADD COLUMN total_vistas INT DEFAULT 0;
    RAISE NOTICE 'Columna total_vistas agregada a foro_preguntas';
  END IF;

  -- Agregar columna imagenes si no existe (array de URLs)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'foro_preguntas' AND column_name = 'imagenes'
  ) THEN
    ALTER TABLE public.foro_preguntas ADD COLUMN imagenes TEXT[] DEFAULT '{}';
    RAISE NOTICE 'Columna imagenes agregada a foro_preguntas';
  END IF;
END $$;

-- Funcion para incrementar vistas
CREATE OR REPLACE FUNCTION public.incrementar_vistas_pregunta(p_pregunta_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.foro_preguntas
  SET total_vistas = COALESCE(total_vistas, 0) + 1
  WHERE id = p_pregunta_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PARTE 2: LIMPIAR DATOS DE PRUEBA ANTERIORES
-- ============================================

-- Limpiar seeders anteriores (por si se ejecuto antes)
DELETE FROM public.foro_respuestas WHERE contenido LIKE '%[SEED]%';
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';
DELETE FROM public.postulaciones WHERE mensaje LIKE '%[SEED]%';
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%[SEED]%';
DELETE FROM public.cajeros_vendedores WHERE nombre_completo LIKE '%Cajero%' OR nombre_completo LIKE '%Test%';

-- ============================================
-- PARTE 3: OBTENER IDs DE USUARIOS EXISTENTES
-- ============================================

-- NOTA: Reemplaza estos UUIDs con los IDs reales de tus usuarios
-- Puedes obtenerlos ejecutando: SELECT id, email, nombre_completo FROM public.users;

-- Usuario 1: Hugo Porcel
-- Usuario 2: Hugo Stark

-- ============================================
-- PARTE 4: SEEDERS DE PERFILES PROFESIONALES
-- ============================================

-- Eliminar perfiles existentes de usuarios de prueba
DELETE FROM public.perfiles_profesionales
WHERE user_id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- Perfil profesional 1: Hugo Porcel - Tecnico de Tecnologia
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  'TechSoluciones HP',
  'Tecnico certificado con 5 anos de experiencia. Reparacion de computadoras, laptops, celulares. Instalacion de Windows, recuperacion de datos, redes WiFi y camaras de seguridad. Trabajo garantizado.',
  'Tecnologia',
  'La Paz',
  '70000001',
  '59170000001',
  5,
  50, 500,
  4.8, 12, 45,
  true, true, true
);

-- Perfil profesional 2: Hugo Stark - Electricista
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
  'Electricidad Stark Pro',
  'Electricista certificado con 8 anos de experiencia. Instalaciones electricas domiciliarias e industriales, mantenimiento preventivo, reparacion de cortocircuitos, tableros, iluminacion LED. Disponible para emergencias.',
  'Electricidad',
  'Santa Cruz',
  '75455488',
  '59175455488',
  8,
  80, 800,
  4.9, 28, 85,
  true, true, true
);

-- Actualizar rol de usuarios a "dual"
UPDATE public.users SET rol = 'dual' WHERE id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- ============================================
-- PARTE 5: SEEDERS DE MAS PROFESIONALES (FICTICIOS)
-- Estos usan UUIDs generados porque no tienen usuario real
-- ============================================

-- Profesional: Maria Lopez - Plomera
INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  uuid_generate_v4(),
  NULL, -- Sin usuario asociado (perfil demo)
  'Plomeria Express Maria',
  'Plomera profesional con experiencia en instalaciones sanitarias, reparacion de fugas, destape de canerias, instalacion de termas y griferia. Atencion rapida y precios justos.',
  'Plomeria',
  'La Paz',
  '71234567',
  '59171234567',
  6,
  100, 600,
  4.7, 23, 67,
  true, true, true
)
ON CONFLICT DO NOTHING;

-- Profesional: Carlos Mamani - Pintor
INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  uuid_generate_v4(),
  NULL,
  'Pinturas Mamani',
  'Pintor con 10 anos de experiencia. Pintura interior y exterior, empastado, texturado, decoracion. Trabajo limpio y puntual. Materiales de primera calidad.',
  'Pintura',
  'La Paz',
  '72345678',
  '59172345678',
  10,
  150, 1500,
  4.9, 45, 120,
  true, true, true
)
ON CONFLICT DO NOTHING;

-- Profesional: Ana Rodriguez - Limpieza
INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  uuid_generate_v4(),
  NULL,
  'Limpieza Total Ana',
  'Servicio de limpieza profesional. Limpieza de casas, departamentos, oficinas. Limpieza profunda, post-construccion, lavado de alfombras. Personal capacitado y de confianza.',
  'Limpieza',
  'Cochabamba',
  '73456789',
  '59173456789',
  4,
  80, 400,
  4.6, 18, 55,
  true, true, true
)
ON CONFLICT DO NOTHING;

-- Profesional: Pedro Quispe - Carpintero
INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  uuid_generate_v4(),
  NULL,
  'Carpinteria Artesanal Quispe',
  'Maestro carpintero con 15 anos de experiencia. Muebles a medida, closets, cocinas empotradas, puertas, restauracion de muebles antiguos. Trabajos en madera y melamina.',
  'Carpinteria',
  'Santa Cruz',
  '74567890',
  '59174567890',
  15,
  500, 5000,
  4.95, 67, 180,
  true, true, true
)
ON CONFLICT DO NOTHING;

-- Profesional: Luis Fernandez - Mecanico
INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, anos_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado
) VALUES (
  uuid_generate_v4(),
  NULL,
  'Mecanica Fernandez',
  'Mecanico automotriz especializado. Diagnostico computarizado, cambio de aceite, frenos, suspension, electricidad automotriz. Todas las marcas. Servicio a domicilio disponible.',
  'Mecanica',
  'La Paz',
  '75678901',
  '59175678901',
  12,
  100, 2000,
  4.8, 89, 230,
  true, true, true
)
ON CONFLICT DO NOTHING;

-- ============================================
-- PARTE 6: SEEDERS DE SOLICITUDES DE TRABAJO
-- ============================================

-- Solicitudes de Hugo Porcel
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, estado,
  visible, destacada, total_postulaciones, created_at, expires_at
) VALUES
  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Necesito plomero urgente para reparar fuga',
   'Tengo una fuga de agua en el bano principal. La fuga esta en la conexion del inodoro y esta mojando el piso constantemente. Necesito que vengan lo antes posible. Tengo todos los materiales.',
   'Plomeria', 'La Paz', 'Centro',
   100, 300, 'urgente', 'activa',
   true, true, 0, NOW(), NOW() + INTERVAL '7 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Instalacion de 8 puntos de luz LED',
   'Necesito instalar 8 puntos de luz LED en una oficina de 50m2. Tambien necesito 4 tomacorrientes adicionales. La instalacion debe ser empotrada. Prefiero trabajar los fines de semana.',
   'Electricidad', 'La Paz', 'Miraflores',
   500, 1200, 'normal', 'activa',
   true, false, 2, NOW() - INTERVAL '1 day', NOW() + INTERVAL '6 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Fabricacion de closet empotrado 2.5m',
   'Necesito un closet empotrado de 2.5 metros de ancho por 2.4 metros de alto. Debe tener cajones, barras para colgar ropa y estantes. Melamina color nogal. Con luz interior LED.',
   'Carpinteria', 'La Paz', 'Achumani',
   1500, 3000, 'normal', 'activa',
   true, false, 5, NOW() - INTERVAL '2 days', NOW() + INTERVAL '5 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Mantenimiento de jardin mensual',
   'Busco jardinero para mantenimiento mensual de jardin de 50m2. Incluye poda de cesped, cuidado de plantas, limpieza de hojas, riego. Una vez por semana o cada 15 dias.',
   'Jardineria', 'La Paz', 'Calacoto',
   150, 300, 'normal', 'activa',
   true, false, 4, NOW() - INTERVAL '12 hours', NOW() + INTERVAL '7 days');

-- Solicitudes de Hugo Stark
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, estado,
  visible, destacada, total_postulaciones, created_at, expires_at
) VALUES
  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Limpieza profunda de departamento 80m2',
   'Busco servicio de limpieza profunda para departamento de 3 ambientes (80m2). Incluye cocina completa, 2 banos, 2 dormitorios y sala. Preferencia por servicio con productos incluidos.',
   'Limpieza', 'Santa Cruz', 'Centro',
   200, 400, 'normal', 'activa',
   true, false, 1, NOW() - INTERVAL '3 hours', NOW() + INTERVAL '7 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Reparacion de laptop HP que no enciende',
   'Mi laptop HP Pavilion no enciende. Cuando presiono el boton de encendido solo parpadea una luz azul y se apaga. Tiene 2 anos de uso. Necesito diagnostico y presupuesto antes de reparar.',
   'Tecnologia', 'Cochabamba', 'Centro',
   100, 400, 'urgente', 'activa',
   true, true, 3, NOW() - INTERVAL '5 hours', NOW() + INTERVAL '7 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Pintura interior casa 2 pisos (200m2)',
   'Necesito pintar el interior de casa de 2 pisos, aproximadamente 200m2 de paredes. Colores claros (blanco y beige). Incluir empastado donde sea necesario. Material por mi cuenta.',
   'Pintura', 'Sucre', 'Zona Norte',
   2000, 4000, 'normal', 'activa',
   true, false, 0, NOW() - INTERVAL '1 day', NOW() + INTERVAL '6 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Cambio de aceite y revision de frenos Toyota',
   'Necesito cambio de aceite completo (filtro incluido) y revision de frenos para Toyota Corolla 2019. El auto hace un ruido leve al frenar. Servicio a domicilio preferido.',
   'Mecanica', 'Santa Cruz', 'Equipetrol',
   200, 500, 'normal', 'activa',
   true, false, 2, NOW() - INTERVAL '6 hours', NOW() + INTERVAL '7 days');

-- ============================================
-- PARTE 7: SEEDERS DE PREGUNTAS DEL FORO
-- ============================================

-- Limpiar preguntas anteriores
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';

-- Preguntas de Hugo Porcel
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria,
  total_respuestas, total_votos, total_vistas, resuelta, visible, created_at, updated_at
) VALUES
  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Cuanto cobra un plomero por cambiar un grifo?',
   'Necesito cambiar el grifo de la cocina y el del lavamanos del bano. Cuanto es lo normal que cobran? Es mejor comprar yo los grifos o ellos los consiguen mas baratos?',
   'Servicios', 2, 5, 45, false, true, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Que tipo de pintura es mejor para exteriores?',
   'Quiero pintar la fachada de mi casa pero no se que tipo de pintura usar. Me han dicho que hay especiales para exteriores. Cual recomiendan? Que marcas son buenas en Bolivia?',
   'Recomendaciones', 3, 8, 67, true, true, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Como se si un tecnico de computadoras es confiable?',
   'Mi computadora tiene virus y necesito formatearla, pero me da miedo llevarla a cualquier tecnico porque tengo informacion importante. Que precauciones debo tomar? Como verifico que sea de confianza?',
   'Tecnologia', 4, 12, 89, false, true, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours');

-- Preguntas de Hugo Stark
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria,
  total_respuestas, total_votos, total_vistas, resuelta, visible, created_at, updated_at
) VALUES
  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Alguien conoce electricista de confianza en SCZ?',
   'Hola! Estoy buscando un electricista que sea de confianza para revisar toda la instalacion electrica de mi casa. Es una casa antigua y quiero asegurarme de que todo este bien. Zona Equipetrol.',
   'Servicios', 1, 3, 34, false, true, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Cuanto tiempo toma hacer un mueble a medida?',
   'Estoy cotizando un closet empotrado de 3 metros y me dicen diferentes tiempos de entrega. Cuanto es lo normal? Una semana? Dos semanas? Un mes? Quiero saber para planificar mi mudanza.',
   'Recomendaciones', 0, 2, 23, false, true, NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Recomiendan algun servicio de limpieza semanal?',
   'Necesito contratar servicio de limpieza para mi departamento una vez por semana. Alguien tiene experiencia con algun servicio de limpieza profesional en Santa Cruz? Que precios manejan?',
   'Servicios', 2, 4, 56, false, true, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours');

-- ============================================
-- PARTE 8: SEEDERS DE CAJEROS
-- ============================================

INSERT INTO public.cajeros_vendedores (
  nombre_completo, telefono, whatsapp, ciudad, zona,
  metodos_pago, disponible_ahora, activo, calificacion_promedio, total_transacciones
) VALUES
  ('Maria Garcia - Cajero La Paz Centro', '71234567', '59171234567', 'La Paz', 'Centro',
   '{"Efectivo", "QR BNB", "QR BCP", "Transferencia", "Tigo Money"}', true, true, 4.9, 156),
  ('Carlos Rodriguez - Cajero Miraflores', '71234568', '59171234568', 'La Paz', 'Miraflores',
   '{"Efectivo", "QR", "Tigo Money"}', true, true, 4.7, 89),
  ('Ana Martinez - Cajero Santa Cruz', '77654321', '59177654321', 'Santa Cruz', 'Centro',
   '{"Efectivo", "QR BNB", "Transferencia", "Tigo Money"}', true, true, 4.8, 234),
  ('Jose Mendoza - Cajero Cochabamba', '76543210', '59176543210', 'Cochabamba', 'Centro',
   '{"Efectivo", "QR", "Transferencia"}', false, true, 4.6, 67),
  ('Laura Fernandez - Cajero Sucre', '75455489', '59175455489', 'Sucre', 'Centro',
   '{"Efectivo", "QR BNB", "Transferencia"}', true, true, 4.9, 45);

-- ============================================
-- PARTE 9: ACTUALIZAR CREDITOS DE USUARIOS
-- ============================================

UPDATE public.users SET
  creditos = 500,
  creditos_totales_ganados = 500,
  verificado = true,
  perfil_completo = true,
  updated_at = NOW()
WHERE id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- ============================================
-- PARTE 10: VERIFICACION FINAL
-- ============================================

SELECT '--- RESUMEN DE DATOS INSERTADOS ---' as info;

SELECT 'Usuarios con creditos:' as tabla, COUNT(*)::text as total
FROM public.users WHERE creditos >= 100;

SELECT 'Perfiles profesionales activos:' as tabla, COUNT(*)::text as total
FROM public.perfiles_profesionales WHERE activo = true;

SELECT 'Solicitudes de trabajo activas:' as tabla, COUNT(*)::text as total
FROM public.solicitudes_trabajo WHERE estado = 'activa';

SELECT 'Preguntas del foro:' as tabla, COUNT(*)::text as total
FROM public.foro_preguntas WHERE visible = true;

SELECT 'Cajeros activos:' as tabla, COUNT(*)::text as total
FROM public.cajeros_vendedores WHERE activo = true;

-- Mostrar columnas de foro_preguntas para verificar
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'foro_preguntas'
ORDER BY ordinal_position;

SELECT '009_SEEDERS_Y_FIXES_FINALES ejecutado correctamente!' as resultado;
