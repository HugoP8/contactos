-- ============================================
-- SEEDERS - DATOS DE PRUEBA REALISTAS V2
-- APP: CONTACTOS
-- ============================================
-- Este script usa usuarios existentes o crea datos
-- que no dependen de auth.users
-- ============================================

-- ============================================
-- PASO 1: Crear función auxiliar para obtener un user_id válido
-- ============================================

-- Primero verificamos si hay usuarios en el sistema
DO $$
DECLARE
  user_count INT;
BEGIN
  SELECT COUNT(*) INTO user_count FROM public.users;

  IF user_count = 0 THEN
    RAISE NOTICE '⚠️ No hay usuarios en el sistema. Primero registra al menos un usuario desde la app.';
    RAISE NOTICE 'Los seeders de perfiles, solicitudes y foro requieren usuarios existentes.';
  ELSE
    RAISE NOTICE '✅ Se encontraron % usuarios en el sistema.', user_count;
  END IF;
END $$;

-- ============================================
-- PASO 2: Crear tabla de categorías si no existe
-- (No depende de usuarios)
-- ============================================

CREATE TABLE IF NOT EXISTS public.categorias_servicio (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50),
  orden INT DEFAULT 0,
  activa BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar categorías de servicios
INSERT INTO public.categorias_servicio (nombre, descripcion, icono, orden) VALUES
  ('Hogar', 'Servicios para el hogar y mantenimiento', 'home', 1),
  ('Tecnología', 'Reparación y soporte técnico', 'computer', 2),
  ('Vehículos', 'Mecánica y mantenimiento vehicular', 'directions_car', 3),
  ('Construcción', 'Obras civiles y remodelaciones', 'construction', 4),
  ('Salud', 'Servicios de salud y bienestar', 'local_hospital', 5),
  ('Educación', 'Clases particulares y tutorías', 'school', 6),
  ('Moda', 'Costura, confección y moda', 'checkroom', 7),
  ('Eventos', 'Organización de eventos y fiestas', 'celebration', 8),
  ('Belleza', 'Estética y cuidado personal', 'spa', 9),
  ('Legal', 'Servicios legales y trámites', 'gavel', 10),
  ('Transporte', 'Mudanzas y transporte de carga', 'local_shipping', 11),
  ('Mascotas', 'Cuidado y servicios para mascotas', 'pets', 12)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- PASO 3: Crear tabla de subcategorías
-- ============================================

CREATE TABLE IF NOT EXISTS public.subcategorias_servicio (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  categoria_id UUID REFERENCES public.categorias_servicio(id),
  nombre VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(categoria_id, nombre)
);

-- Insertar subcategorías (Hogar)
INSERT INTO public.subcategorias_servicio (categoria_id, nombre)
SELECT c.id, s.nombre
FROM public.categorias_servicio c
CROSS JOIN (VALUES
  ('Plomería'), ('Electricidad'), ('Carpintería'), ('Pintura'),
  ('Limpieza'), ('Jardinería'), ('Cerrajería'), ('Albañilería'),
  ('Vidriería'), ('Herrería'), ('Fumigación'), ('Instalación de gas')
) AS s(nombre)
WHERE c.nombre = 'Hogar'
ON CONFLICT DO NOTHING;

-- Insertar subcategorías (Tecnología)
INSERT INTO public.subcategorias_servicio (categoria_id, nombre)
SELECT c.id, s.nombre
FROM public.categorias_servicio c
CROSS JOIN (VALUES
  ('Reparación de computadoras'), ('Reparación de celulares'),
  ('Instalación de redes'), ('Soporte técnico'), ('Desarrollo web'),
  ('Cámaras de seguridad'), ('Automatización')
) AS s(nombre)
WHERE c.nombre = 'Tecnología'
ON CONFLICT DO NOTHING;

-- Insertar subcategorías (Vehículos)
INSERT INTO public.subcategorias_servicio (categoria_id, nombre)
SELECT c.id, s.nombre
FROM public.categorias_servicio c
CROSS JOIN (VALUES
  ('Mecánica general'), ('Electricidad automotriz'), ('Pintura automotriz'),
  ('Lavado y detailing'), ('Cambio de aceite'), ('Frenos y suspensión'),
  ('Grúas y remolque')
) AS s(nombre)
WHERE c.nombre = 'Vehículos'
ON CONFLICT DO NOTHING;

-- ============================================
-- PASO 4: Insertar preguntas frecuentes del foro
-- (Usando el primer usuario disponible)
-- ============================================

DO $$
DECLARE
  first_user_id UUID;
  pregunta_id UUID;
BEGIN
  -- Obtener el primer usuario disponible
  SELECT id INTO first_user_id FROM public.users LIMIT 1;

  IF first_user_id IS NULL THEN
    RAISE NOTICE 'No hay usuarios para crear preguntas del foro';
    RETURN;
  END IF;

  -- Insertar preguntas del foro
  INSERT INTO public.foro_preguntas (id, user_id, titulo, contenido, categoria, ciudad, total_respuestas, created_at)
  VALUES
    (uuid_generate_v4(), first_user_id,
     '¿Cuánto cobra un plomero por cambiar un grifo?',
     'Necesito cambiar el grifo de la cocina y el del lavamanos del baño. ¿Cuánto es lo normal que cobran? ¿Es mejor comprar yo los grifos o ellos los consiguen más baratos?',
     'Plomería', 'La Paz', 0, NOW() - INTERVAL '2 days'),

    (uuid_generate_v4(), first_user_id,
     '¿Alguien conoce electricista de confianza en Santa Cruz?',
     'Hola! Estoy buscando un electricista que sea de confianza para revisar toda la instalación eléctrica de mi casa. Es una casa antigua y quiero asegurarme de que todo esté bien.',
     'Electricidad', 'Santa Cruz', 0, NOW() - INTERVAL '1 day'),

    (uuid_generate_v4(), first_user_id,
     '¿Qué tipo de pintura es mejor para exteriores?',
     'Quiero pintar la fachada de mi casa pero no sé qué tipo de pintura usar. Me han dicho que hay especiales para exteriores. ¿Cuál recomiendan? ¿Qué marcas son buenas en Bolivia?',
     'Pintura', 'Cochabamba', 0, NOW() - INTERVAL '3 hours'),

    (uuid_generate_v4(), first_user_id,
     '¿Cuánto tiempo toma hacer un mueble a medida?',
     'Estoy cotizando un closet empotrado y me dicen diferentes tiempos de entrega. ¿Cuánto es lo normal? ¿Una semana? ¿Dos semanas? Quiero saber para planificar.',
     'Carpintería', 'La Paz', 0, NOW() - INTERVAL '12 hours'),

    (uuid_generate_v4(), first_user_id,
     '¿Cómo sé si un técnico de computadoras es confiable?',
     'Mi computadora tiene virus y necesito formatearla, pero me da miedo llevarla a cualquier técnico porque tengo información importante. ¿Qué precauciones debo tomar?',
     'Tecnología', 'El Alto', 0, NOW() - INTERVAL '6 hours')
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ Preguntas del foro creadas con user_id: %', first_user_id;
END $$;

-- ============================================
-- PASO 5: Dar token de solicitud gratuita a usuarios existentes
-- ============================================

INSERT INTO public.tokens_especiales (user_id, tipo, cantidad, usado, created_at)
SELECT id, 'solicitud_gratuita', 1, false, NOW()
FROM public.users
WHERE id NOT IN (
  SELECT user_id FROM public.tokens_especiales
  WHERE tipo = 'solicitud_gratuita'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- PASO 6: Actualizar créditos de usuarios existentes (bonus de prueba)
-- ============================================

UPDATE public.users
SET creditos = creditos + 100,
    creditos_totales_ganados = creditos_totales_ganados + 100
WHERE creditos < 100;

-- ============================================
-- PASO 7: Crear solicitudes de prueba
-- (Usando el primer usuario disponible)
-- ============================================

DO $$
DECLARE
  first_user_id UUID;
BEGIN
  SELECT id INTO first_user_id FROM public.users LIMIT 1;

  IF first_user_id IS NULL THEN
    RAISE NOTICE 'No hay usuarios para crear solicitudes';
    RETURN;
  END IF;

  INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado,
    visible, destacada, total_postulaciones, created_at, expires_at
  ) VALUES
    (uuid_generate_v4(), first_user_id,
     'Necesito plomero para reparar fuga de agua urgente',
     'Tengo una fuga de agua en el baño principal, parece ser en la conexión del inodoro. Necesito que vengan hoy si es posible. La fuga está mojando el piso.',
     'Plomería', 'La Paz', 'Obrajes', 100, 300, 'urgente', 'activa',
     true, true, 0, NOW(), NOW() + INTERVAL '7 days'),

    (uuid_generate_v4(), first_user_id,
     'Instalación de puntos de luz en oficina nueva',
     'Necesito instalar 8 puntos de luz LED en una oficina de 50m2. También necesito 4 tomacorrientes adicionales.',
     'Electricidad', 'Santa Cruz', 'Centro', 500, 1200, 'normal', 'activa',
     true, false, 0, NOW(), NOW() + INTERVAL '7 days'),

    (uuid_generate_v4(), first_user_id,
     'Limpieza profunda de departamento 3 ambientes',
     'Busco servicio de limpieza profunda para departamento de 3 ambientes (80m2). Incluye cocina, 2 baños, 2 dormitorios y sala.',
     'Limpieza', 'Cochabamba', 'Cala Cala', 200, 400, 'normal', 'activa',
     true, false, 0, NOW(), NOW() + INTERVAL '7 days'),

    (uuid_generate_v4(), first_user_id,
     'Fabricación de closet empotrado para dormitorio',
     'Necesito un closet empotrado de 2.5m de ancho x 2.4m de alto. Con cajones, barras para colgar ropa y estantes.',
     'Carpintería', 'La Paz', 'Achumani', 1500, 3000, 'normal', 'activa',
     true, false, 0, NOW(), NOW() + INTERVAL '7 days'),

    (uuid_generate_v4(), first_user_id,
     'Reparación de laptop que no enciende',
     'Mi laptop HP no enciende, cuando presiono el botón de encendido solo parpadea una luz y se apaga. Tiene 3 años de uso.',
     'Tecnología', 'La Paz', 'Miraflores', 100, 400, 'urgente', 'activa',
     true, false, 0, NOW(), NOW() + INTERVAL '7 days')
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ Solicitudes de trabajo creadas';
END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '📊 RESUMEN DE DATOS:' as info;
SELECT 'Usuarios en el sistema:' as tabla, COUNT(*)::text as total FROM public.users
UNION ALL
SELECT 'Categorías de servicio:', COUNT(*)::text FROM public.categorias_servicio
UNION ALL
SELECT 'Subcategorías:', COUNT(*)::text FROM public.subcategorias_servicio
UNION ALL
SELECT 'Preguntas del foro:', COUNT(*)::text FROM public.foro_preguntas
UNION ALL
SELECT 'Solicitudes de trabajo:', COUNT(*)::text FROM public.solicitudes_trabajo
UNION ALL
SELECT 'Tokens especiales:', COUNT(*)::text FROM public.tokens_especiales;

SELECT '✅ Seeders V2 ejecutados exitosamente' as mensaje;
SELECT '💡 Tip: Registra más usuarios desde la app para crear perfiles profesionales' as nota;
