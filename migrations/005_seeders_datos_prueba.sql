-- ============================================
-- SEEDERS - DATOS DE PRUEBA REALISTAS
-- APP: CONTACTOS
-- Versión: 1.0
-- ============================================
-- EJECUTA ESTE SCRIPT DESPUÉS DE 004_fix_rpc_functions.sql
-- ADVERTENCIA: Este script inserta datos de prueba
-- ============================================

-- ============================================
-- USUARIOS DE PRUEBA
-- Nota: Los usuarios reales se crean desde auth.users
-- Aquí insertamos directamente para testing
-- ============================================

-- Primero limpiamos datos existentes (solo para desarrollo)
-- DELETE FROM public.postulaciones;
-- DELETE FROM public.solicitudes_trabajo;
-- DELETE FROM public.resenas;
-- DELETE FROM public.perfiles_profesionales;
-- DELETE FROM public.foro_respuestas;
-- DELETE FROM public.foro_preguntas;

-- ============================================
-- INSERTAR USUARIOS DE PRUEBA
-- ============================================

-- Usuario Admin
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, zona, rol, tipo_cuenta, creditos, creditos_totales_ganados, verificado, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@contactos.bo', 'Administrador Sistema', '70000001', 'La Paz', 'Centro', 'admin', 'gratuita', 1000, 1000, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Cajero de prueba
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, zona, rol, tipo_cuenta, creditos, creditos_totales_ganados, verificado, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000002', 'cajero@contactos.bo', 'María García Mamani', '70000002', 'La Paz', 'Sopocachi', 'cajero', 'gratuita', 500, 500, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Profesionales de prueba (10 profesionales diversos)
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, zona, rol, tipo_cuenta, creditos, creditos_totales_ganados, verificado, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000010', 'carlos.plomero@gmail.com', 'Carlos Quispe Mamani', '71234567', 'La Paz', 'Villa Fátima', 'profesional', 'basica', 120, 200, true, NOW()),
  ('00000000-0000-0000-0000-000000000011', 'juan.electricista@gmail.com', 'Juan Pérez Condori', '72345678', 'El Alto', 'Ciudad Satélite', 'profesional', 'premium', 250, 500, true, NOW()),
  ('00000000-0000-0000-0000-000000000012', 'maria.limpieza@gmail.com', 'María Elena Choque', '73456789', 'La Paz', 'Miraflores', 'profesional', 'basica', 80, 150, true, NOW()),
  ('00000000-0000-0000-0000-000000000013', 'pedro.carpintero@gmail.com', 'Pedro Huanca Flores', '74567890', 'Santa Cruz', 'Plan 3000', 'profesional', 'gratuita', 50, 50, true, NOW()),
  ('00000000-0000-0000-0000-000000000014', 'ana.pintura@gmail.com', 'Ana Lucía Mamani', '75678901', 'Cochabamba', 'Zona Norte', 'profesional', 'premium', 300, 450, true, NOW()),
  ('00000000-0000-0000-0000-000000000015', 'roberto.tech@gmail.com', 'Roberto Fernández', '76789012', 'La Paz', 'San Miguel', 'profesional', 'premium', 180, 350, true, NOW()),
  ('00000000-0000-0000-0000-000000000016', 'lucia.mecanica@gmail.com', 'Lucía Vargas Ticona', '77890123', 'El Alto', '16 de Julio', 'profesional', 'basica', 90, 140, true, NOW()),
  ('00000000-0000-0000-0000-000000000017', 'miguel.jardinero@gmail.com', 'Miguel Apaza Condori', '78901234', 'La Paz', 'Calacoto', 'profesional', 'gratuita', 60, 80, true, NOW()),
  ('00000000-0000-0000-0000-000000000018', 'carmen.costura@gmail.com', 'Carmen Rosa Quispe', '79012345', 'Sucre', 'Centro', 'profesional', 'basica', 110, 180, true, NOW()),
  ('00000000-0000-0000-0000-000000000019', 'fernando.construccion@gmail.com', 'Fernando Torres Mamani', '70123456', 'Santa Cruz', 'Equipetrol', 'profesional', 'premium', 400, 600, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Buscadores de prueba (5 usuarios regulares)
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, zona, rol, tipo_cuenta, creditos, creditos_totales_ganados, verificado, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000020', 'jose.cliente@gmail.com', 'José Manuel López', '71111111', 'La Paz', 'Obrajes', 'buscador', 'gratuita', 45, 50, true, NOW()),
  ('00000000-0000-0000-0000-000000000021', 'laura.buscadora@gmail.com', 'Laura Patricia Mendoza', '72222222', 'Santa Cruz', 'Centro', 'buscador', 'vip', 100, 150, true, NOW()),
  ('00000000-0000-0000-0000-000000000022', 'diego.usuario@gmail.com', 'Diego Alejandro Rojas', '73333333', 'Cochabamba', 'Cala Cala', 'buscador', 'gratuita', 30, 50, true, NOW()),
  ('00000000-0000-0000-0000-000000000023', 'patricia.cliente@gmail.com', 'Patricia Soledad Guzmán', '74444444', 'La Paz', 'Achumani', 'dual', 'gratuita', 55, 80, true, NOW()),
  ('00000000-0000-0000-0000-000000000024', 'andres.busca@gmail.com', 'Andrés Felipe Morales', '75555555', 'El Alto', 'Villa Adela', 'buscador', 'gratuita', 40, 50, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- PERFILES PROFESIONALES
-- ============================================

INSERT INTO public.perfiles_profesionales (id, user_id, titulo_profesional, descripcion, categoria, subcategorias, ciudad, zona, precio_minimo, precio_maximo, tipo_cobro, experiencia_anios, disponibilidad, calificacion_promedio, total_resenas, total_trabajos, whatsapp, created_at)
VALUES
  -- Carlos - Plomero
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000010',
   'Plomero Profesional con 10 años de experiencia',
   'Ofrezco servicios de plomería integral: instalación, reparación y mantenimiento de tuberías, grifería, tanques de agua, calefones y todo tipo de instalaciones sanitarias. Trabajo garantizado y materiales de calidad. Atención a domicilio en toda La Paz y El Alto.',
   'Hogar', ARRAY['Plomería', 'Instalaciones sanitarias'],
   'La Paz', 'Villa Fátima', 50, 500, 'por_servicio', 10,
   'Lunes a Sábado 8:00 - 18:00', 4.8, 45, 120, '71234567', NOW()),

  -- Juan - Electricista
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000011',
   'Electricista Certificado - Instalaciones Eléctricas',
   'Técnico electricista con certificación. Realizo instalaciones eléctricas domiciliarias e industriales, mantenimiento preventivo, reparación de cortocircuitos, instalación de tableros, iluminación LED y automatización del hogar. Trabajo con garantía.',
   'Hogar', ARRAY['Electricidad', 'Instalaciones eléctricas'],
   'El Alto', 'Ciudad Satélite', 80, 800, 'por_servicio', 12,
   'Disponible 24/7 para emergencias', 4.9, 78, 200, '72345678', NOW()),

  -- María Elena - Limpieza
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000012',
   'Servicio de Limpieza Profesional',
   'Ofrezco servicios de limpieza profunda para hogares, oficinas y locales comerciales. Limpieza de alfombras, vidrios, cocinas y baños. También realizo limpieza post-construcción y mantenimiento periódico. Trabajo puntual y responsable.',
   'Hogar', ARRAY['Limpieza', 'Limpieza profunda'],
   'La Paz', 'Miraflores', 100, 400, 'por_hora', 5,
   'Lunes a Viernes 7:00 - 17:00', 4.7, 32, 85, '73456789', NOW()),

  -- Pedro - Carpintero
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000013',
   'Carpintero - Muebles a Medida',
   'Carpintero con taller propio. Fabricación de muebles a medida: closets, cocinas integrales, muebles de baño, estantes y todo tipo de mobiliario. También realizo reparaciones y restauración de muebles antiguos. Trabajo con madera de calidad.',
   'Hogar', ARRAY['Carpintería', 'Muebles a medida'],
   'Santa Cruz', 'Plan 3000', 200, 3000, 'por_proyecto', 15,
   'Lunes a Sábado 8:00 - 18:00', 4.6, 28, 65, '74567890', NOW()),

  -- Ana - Pintura
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000014',
   'Pintora Profesional - Interiores y Exteriores',
   'Servicios de pintura residencial y comercial. Pintura de interiores, exteriores, techos y fachadas. Trabajamos con pinturas de calidad (Monopol, Glidden). También realizamos empastado, texturizados y acabados decorativos.',
   'Hogar', ARRAY['Pintura', 'Acabados'],
   'Cochabamba', 'Zona Norte', 15, 25, 'por_m2', 8,
   'Disponible toda la semana', 4.9, 56, 140, '75678901', NOW()),

  -- Roberto - Tecnología
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000015',
   'Técnico en Computación - Reparación y Soporte',
   'Técnico certificado en hardware y software. Reparación de computadoras, laptops y celulares. Instalación de Windows, formateo, recuperación de datos, instalación de redes WiFi, cámaras de seguridad y soporte técnico remoto.',
   'Tecnología', ARRAY['Reparación de computadoras', 'Soporte técnico'],
   'La Paz', 'San Miguel', 50, 400, 'por_servicio', 7,
   'Lunes a Sábado 9:00 - 20:00, Domingos medio día', 4.8, 42, 110, '76789012', NOW()),

  -- Lucía - Mecánica
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000016',
   'Mecánica Automotriz - Servicio a Domicilio',
   'Mecánica automotriz con 6 años de experiencia. Realizo cambio de aceite, frenos, suspensión, afinado de motor, diagnóstico computarizado y reparaciones generales. Servicio a domicilio con todas las herramientas necesarias.',
   'Vehículos', ARRAY['Mecánica automotriz', 'Mantenimiento vehicular'],
   'El Alto', '16 de Julio', 100, 1500, 'por_servicio', 6,
   'Lunes a Sábado 7:00 - 19:00', 4.5, 25, 55, '77890123', NOW()),

  -- Miguel - Jardinería
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000017',
   'Jardinero Profesional - Diseño de Jardines',
   'Servicios de jardinería completos: diseño de jardines, mantenimiento de áreas verdes, poda de árboles, instalación de césped y sistemas de riego. Trabajo con plantas ornamentales y frutales. Presupuesto sin compromiso.',
   'Hogar', ARRAY['Jardinería', 'Paisajismo'],
   'La Paz', 'Calacoto', 80, 600, 'por_servicio', 9,
   'Lunes a Sábado 7:00 - 16:00', 4.7, 18, 45, '78901234', NOW()),

  -- Carmen - Costura
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000018',
   'Modista - Confección y Arreglos',
   'Modista con experiencia en confección de vestidos, trajes, uniformes y todo tipo de prendas. También realizo arreglos, ajustes y transformaciones. Trabajo con telas de calidad y entrego a tiempo. Precios accesibles.',
   'Moda', ARRAY['Costura', 'Confección'],
   'Sucre', 'Centro', 30, 500, 'por_prenda', 12,
   'Lunes a Viernes 9:00 - 18:00', 4.8, 35, 90, '79012345', NOW()),

  -- Fernando - Construcción
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000019',
   'Maestro Constructor - Obras Civiles',
   'Maestro constructor con amplia experiencia. Realizamos obras completas: construcción de casas, departamentos, ampliaciones, remodelaciones, muros, pisos y acabados. Trabajo con personal calificado y materiales de primera.',
   'Construcción', ARRAY['Albañilería', 'Construcción'],
   'Santa Cruz', 'Equipetrol', 5000, 100000, 'por_proyecto', 20,
   'Disponible para proyectos', 4.9, 22, 35, '70123456', NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- SOLICITUDES DE TRABAJO DE PRUEBA
-- ============================================

INSERT INTO public.solicitudes_trabajo (id, user_id, titulo, descripcion, categoria, ciudad, zona, presupuesto_minimo, presupuesto_maximo, urgencia, estado, visible, destacada, total_postulaciones, created_at, expires_at)
VALUES
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000020',
   'Necesito plomero para reparar fuga de agua urgente',
   'Tengo una fuga de agua en el baño principal, parece ser en la conexión del inodoro. Necesito que vengan hoy si es posible. La fuga está mojando el piso y necesita atención inmediata.',
   'Plomería', 'La Paz', 'Obrajes', 100, 300, 'urgente', 'activa', true, true, 3, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000021',
   'Instalación de puntos de luz en oficina nueva',
   'Necesito instalar 8 puntos de luz LED en una oficina de 50m2. También necesito 4 tomacorrientes adicionales. La oficina está en obra gris, así que hay que hacer el cableado desde cero.',
   'Electricidad', 'Santa Cruz', 'Centro', 500, 1200, 'normal', 'activa', true, false, 5, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000022',
   'Limpieza profunda de departamento 3 ambientes',
   'Busco servicio de limpieza profunda para departamento de 3 ambientes (80m2). Incluye cocina, 2 baños, 2 dormitorios y sala. Preferiblemente para este fin de semana.',
   'Limpieza', 'Cochabamba', 'Cala Cala', 200, 400, 'normal', 'activa', true, false, 2, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000023',
   'Fabricación de closet empotrado para dormitorio',
   'Necesito un closet empotrado de 2.5m de ancho x 2.4m de alto. Con cajones, barras para colgar ropa y estantes. Preferencia por melamina color nogal. Por favor enviar cotización con foto de trabajos anteriores.',
   'Carpintería', 'La Paz', 'Achumani', 1500, 3000, 'normal', 'activa', true, false, 4, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000024',
   'Pintura de casa completa - 2 pisos',
   'Necesito pintar casa de 2 pisos, aproximadamente 200m2 de paredes. Interior completo (todas las habitaciones) y fachada exterior. Prefiero colores claros. Incluir empastado donde sea necesario.',
   'Pintura', 'El Alto', 'Villa Adela', 2000, 4000, 'normal', 'activa', true, true, 6, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000020',
   'Reparación de laptop que no enciende',
   'Mi laptop HP no enciende, cuando presiono el botón de encendido solo parpadea una luz y se apaga. Tiene 3 años de uso. Necesito diagnóstico y reparación. Es urgente porque la uso para trabajo.',
   'Tecnología', 'La Paz', 'Obrajes', 100, 400, 'urgente', 'activa', true, false, 2, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000021',
   'Mantenimiento completo de vehículo Toyota',
   'Necesito mantenimiento completo para Toyota Corolla 2018: cambio de aceite, filtros, revisión de frenos y suspensión. También revisar por qué hace un ruido al frenar.',
   'Mecánica', 'Santa Cruz', 'Centro', 400, 800, 'normal', 'activa', true, false, 3, NOW(), NOW() + INTERVAL '7 days'),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000022',
   'Diseño y mantenimiento de jardín pequeño',
   'Tengo un jardín de 30m2 que está descuidado. Necesito alguien que lo diseñe bonito con plantas que no requieran mucho mantenimiento, y también necesito servicio de mantenimiento mensual.',
   'Jardinería', 'Cochabamba', 'Cala Cala', 300, 600, 'normal', 'activa', true, false, 1, NOW(), NOW() + INTERVAL '7 days')
ON CONFLICT DO NOTHING;

-- ============================================
-- PREGUNTAS DEL FORO
-- ============================================

INSERT INTO public.foro_preguntas (id, user_id, titulo, contenido, categoria, ciudad, total_respuestas, created_at)
VALUES
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000020',
   '¿Cuánto cobra un plomero por cambiar un grifo?',
   'Necesito cambiar el grifo de la cocina y el del lavamanos del baño. ¿Cuánto es lo normal que cobran? ¿Es mejor comprar yo los grifos o ellos los consiguen más baratos?',
   'Plomería', 'La Paz', 3, NOW()),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000021',
   '¿Alguien conoce electricista de confianza en Santa Cruz?',
   'Hola! Estoy buscando un electricista que sea de confianza para revisar toda la instalación eléctrica de mi casa. Es una casa antigua y quiero asegurarme de que todo esté bien. ¿Alguien tiene recomendaciones?',
   'Electricidad', 'Santa Cruz', 5, NOW()),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000022',
   '¿Qué tipo de pintura es mejor para exteriores?',
   'Quiero pintar la fachada de mi casa pero no sé qué tipo de pintura usar. Me han dicho que hay especiales para exteriores. ¿Cuál recomiendan? ¿Qué marcas son buenas en Bolivia?',
   'Pintura', 'Cochabamba', 4, NOW()),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000023',
   '¿Cuánto tiempo toma hacer un mueble a medida?',
   'Estoy cotizando un closet empotrado y me dicen diferentes tiempos de entrega. ¿Cuánto es lo normal? ¿Una semana? ¿Dos semanas? Quiero saber para planificar.',
   'Carpintería', 'La Paz', 2, NOW()),

  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000024',
   '¿Cómo sé si un técnico de computadoras es confiable?',
   'Mi computadora tiene virus y necesito formatearla, pero me da miedo llevarla a cualquier técnico porque tengo información importante. ¿Qué precauciones debo tomar? ¿Qué les pregunto antes de dejar mi equipo?',
   'Tecnología', 'El Alto', 6, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- CAJEROS/VENDEDORES AUTORIZADOS
-- ============================================

INSERT INTO public.cajeros_vendedores (id, user_id, nombre_completo, telefono, whatsapp, ciudad, zona, metodos_pago, disponible_ahora, calificacion_promedio, total_transacciones, activo, created_at)
VALUES
  (uuid_generate_v4(), '00000000-0000-0000-0000-000000000002',
   'María García Mamani', '70000002', '70000002', 'La Paz', 'Sopocachi',
   ARRAY['Tigo Money', 'Transferencia BNB', 'Efectivo'],
   true, 4.9, 150, true, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- TOKENS DE SOLICITUD GRATUITA
-- (Para que los usuarios nuevos puedan probar)
-- ============================================

INSERT INTO public.tokens_especiales (user_id, tipo, cantidad, usado, created_at)
SELECT id, 'solicitud_gratuita', 1, false, NOW()
FROM public.users
WHERE id NOT IN (SELECT user_id FROM public.tokens_especiales WHERE tipo = 'solicitud_gratuita')
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'Usuarios insertados:' as info, COUNT(*) as total FROM public.users;
SELECT 'Perfiles profesionales:' as info, COUNT(*) as total FROM public.perfiles_profesionales;
SELECT 'Solicitudes de trabajo:' as info, COUNT(*) as total FROM public.solicitudes_trabajo;
SELECT 'Preguntas del foro:' as info, COUNT(*) as total FROM public.foro_preguntas;
SELECT 'Cajeros activos:' as info, COUNT(*) as total FROM public.cajeros_vendedores WHERE activo = true;

SELECT '✅ Seeders ejecutados exitosamente' as mensaje;
