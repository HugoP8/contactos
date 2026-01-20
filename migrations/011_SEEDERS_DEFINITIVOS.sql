-- ============================================
-- SEEDERS DEFINITIVOS - DATOS DE PRUEBA
-- APP: CONTACTOS
-- VERSION: 2.0
-- ============================================
-- EJECUTAR DESPUES DE 010_SQL_DEFINITIVO.sql
-- ============================================

-- ============================================
-- PARTE 1: OBTENER IDs DE USUARIOS EXISTENTES
-- ============================================
-- Primero verifica tus usuarios con:
-- SELECT id, email, nombre_completo FROM public.users;
-- Y reemplaza los UUIDs de abajo si es necesario

-- ============================================
-- PARTE 2: PERFILES PROFESIONALES DE PRUEBA
-- ============================================

-- Limpiar datos de prueba anteriores
DELETE FROM public.perfiles_profesionales WHERE nombre_comercial LIKE '%[SEED]%';

-- Insertar perfiles profesionales (sin user_id para evitar conflicto de unicidad)
INSERT INTO public.perfiles_profesionales (
  id, nombre_comercial, descripcion, categoria_principal,
  subcategorias, ciudad, whatsapp, foto_perfil,
  calificacion_promedio, total_resenas,
  activo, visible_busqueda, verificado, destacado
) VALUES
-- Electricista
(
  'a1111111-1111-1111-1111-111111111111',
  'ElectroFix Bolivia [SEED]',
  'Electricista profesional con mas de 10 anos de experiencia. Instalaciones electricas, reparaciones, mantenimiento preventivo y correctivo. Trabajo garantizado.',
  'Electricista',
  ARRAY['Instalaciones', 'Reparaciones', 'Mantenimiento'],
  'La Paz',
  '71234567',
  'https://randomuser.me/api/portraits/men/1.jpg',
  4.8,
  25,
  true,
  true,
  true,
  true
),
-- Plomero
(
  'a2222222-2222-2222-2222-222222222222',
  'Plomeria Express [SEED]',
  'Servicio de plomeria 24/7. Destapes, instalaciones de gas, reparacion de fugas, instalacion de calefones y termas. Atencion rapida y precios justos.',
  'Plomero',
  ARRAY['Destapes', 'Instalaciones', 'Fugas', 'Gas'],
  'La Paz',
  '72345678',
  'https://randomuser.me/api/portraits/men/2.jpg',
  4.9,
  42,
  true,
  true,
  true,
  true
),
-- Carpintero
(
  'a3333333-3333-3333-3333-333333333333',
  'Carpinteria Artesanal [SEED]',
  'Muebles a medida, closets, cocinas empotradas, puertas y ventanas. Trabajamos con madera de primera calidad. Diseno personalizado.',
  'Carpintero',
  ARRAY['Muebles', 'Closets', 'Cocinas', 'Puertas'],
  'Cochabamba',
  '73456789',
  'https://randomuser.me/api/portraits/men/3.jpg',
  4.7,
  18,
  true,
  true,
  false,
  false
),
-- Pintor
(
  'a4444444-4444-4444-4444-444444444444',
  'Pinturas Profesionales [SEED]',
  'Pintura interior y exterior. Acabados de primera, empastado, texturizado, decoracion. Usamos pinturas de marca reconocida.',
  'Pintor',
  ARRAY['Interior', 'Exterior', 'Texturizado', 'Empastado'],
  'Santa Cruz',
  '74567890',
  'https://randomuser.me/api/portraits/men/4.jpg',
  4.5,
  30,
  true,
  true,
  false,
  false
),
-- Mecanico
(
  'a5555555-5555-5555-5555-555555555555',
  'Mecanica Automotriz JR [SEED]',
  'Reparacion de motores, frenos, suspension, electricidad automotriz. Diagnostico computarizado. Atendemos todas las marcas.',
  'Mecanico Automotriz',
  ARRAY['Motores', 'Frenos', 'Suspension', 'Electricidad'],
  'La Paz',
  '75678901',
  'https://randomuser.me/api/portraits/men/5.jpg',
  4.6,
  55,
  true,
  true,
  true,
  false
),
-- Tecnico computadoras
(
  'a6666666-6666-6666-6666-666666666666',
  'TechSupport Bolivia [SEED]',
  'Reparacion de computadoras, laptops, formateo, recuperacion de datos, redes, instalacion de software. Servicio a domicilio.',
  'Tecnico en Computacion',
  ARRAY['Reparacion', 'Formateo', 'Redes', 'Software'],
  'La Paz',
  '76789012',
  'https://randomuser.me/api/portraits/men/6.jpg',
  4.9,
  68,
  true,
  true,
  true,
  true
),
-- Albanil
(
  'a7777777-7777-7777-7777-777777777777',
  'Construcciones Solidas [SEED]',
  'Construccion de casas, muros, pisos, acabados. Trabajamos con materiales de calidad. Presupuesto sin compromiso.',
  'Albanil',
  ARRAY['Construccion', 'Muros', 'Pisos', 'Acabados'],
  'Cochabamba',
  '77890123',
  'https://randomuser.me/api/portraits/men/7.jpg',
  4.4,
  22,
  true,
  true,
  false,
  false
),
-- Cerrajero
(
  'a8888888-8888-8888-8888-888888888888',
  'Cerrajeria 24H [SEED]',
  'Apertura de puertas, cambio de chapas, duplicado de llaves, instalacion de cerraduras de seguridad. Servicio de emergencia 24 horas.',
  'Cerrajero',
  ARRAY['Apertura', 'Chapas', 'Llaves', 'Seguridad'],
  'Santa Cruz',
  '78901234',
  'https://randomuser.me/api/portraits/men/8.jpg',
  4.8,
  90,
  true,
  true,
  true,
  true
),
-- Limpieza
(
  'a9999999-9999-9999-9999-999999999999',
  'Limpieza Total [SEED]',
  'Servicio de limpieza profesional para hogares, oficinas y locales comerciales. Limpieza profunda, desinfeccion, lavado de alfombras.',
  'Limpieza',
  ARRAY['Hogares', 'Oficinas', 'Desinfeccion', 'Alfombras'],
  'La Paz',
  '79012345',
  'https://randomuser.me/api/portraits/women/1.jpg',
  4.7,
  35,
  true,
  true,
  false,
  false
),
-- Jardinero
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'Jardines Verdes [SEED]',
  'Diseno y mantenimiento de jardines. Poda, riego, plantacion, fumigacion. Transformamos tu espacio verde.',
  'Jardinero',
  ARRAY['Diseno', 'Mantenimiento', 'Poda', 'Fumigacion'],
  'Cochabamba',
  '70123456',
  'https://randomuser.me/api/portraits/men/9.jpg',
  4.6,
  28,
  true,
  true,
  false,
  false
)
ON CONFLICT (id) DO UPDATE SET
  nombre_comercial = EXCLUDED.nombre_comercial,
  descripcion = EXCLUDED.descripcion,
  activo = true,
  visible_busqueda = true;

-- ============================================
-- PARTE 3: SOLICITUDES DE TRABAJO DE PRUEBA
-- ============================================

-- Limpiar solicitudes de prueba anteriores
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%[SEED]%';

-- Insertar solicitudes de trabajo
INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, fotos,
  estado, total_postulaciones, creditos_usados, visible, destacada,
  created_at, expires_at
) VALUES
-- Solicitud 1: Electricista urgente
(
  'b1111111-1111-1111-1111-111111111111',
  (SELECT id FROM public.users LIMIT 1),
  'Necesito electricista urgente [SEED]',
  'Se fue la luz en mi casa y no puedo identificar el problema. Necesito un electricista que pueda venir hoy o manana temprano. Tengo ninos pequenos y es urgente.',
  'Electricista',
  'La Paz',
  'Zona Sur',
  100.00,
  300.00,
  'urgente',
  ARRAY[]::TEXT[],
  'activa',
  3,
  5,
  true,
  true,
  NOW() - INTERVAL '2 days',
  NOW() + INTERVAL '5 days'
),
-- Solicitud 2: Plomero fuga
(
  'b2222222-2222-2222-2222-222222222222',
  (SELECT id FROM public.users LIMIT 1),
  'Fuga de agua en el bano [SEED]',
  'Tengo una fuga debajo del lavamanos que esta mojando todo el piso. Necesito que la reparen lo antes posible para evitar danos mayores.',
  'Plomero',
  'La Paz',
  'Miraflores',
  50.00,
  150.00,
  'urgente',
  ARRAY[]::TEXT[],
  'activa',
  5,
  5,
  true,
  false,
  NOW() - INTERVAL '1 day',
  NOW() + INTERVAL '6 days'
),
-- Solicitud 3: Carpintero mueble
(
  'b3333333-3333-3333-3333-333333333333',
  (SELECT id FROM public.users LIMIT 1),
  'Mueble de cocina a medida [SEED]',
  'Busco carpintero para hacer un mueble de cocina empotrado. Medidas: 2m de largo x 90cm de alto. Necesito que tenga cajones y puertas. Material: melamina.',
  'Carpintero',
  'Cochabamba',
  'Centro',
  500.00,
  1200.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  2,
  5,
  true,
  false,
  NOW() - INTERVAL '3 days',
  NOW() + INTERVAL '4 days'
),
-- Solicitud 4: Pintar departamento
(
  'b4444444-4444-4444-4444-444444444444',
  (SELECT id FROM public.users LIMIT 1),
  'Pintar departamento completo [SEED]',
  'Necesito pintar mi departamento de 3 dormitorios, sala, comedor y cocina. Aproximadamente 80m2. Incluye empastado de paredes. Colores claros.',
  'Pintor',
  'Santa Cruz',
  'Equipetrol',
  800.00,
  1500.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  4,
  5,
  true,
  true,
  NOW() - INTERVAL '4 days',
  NOW() + INTERVAL '3 days'
),
-- Solicitud 5: Mecanico auto
(
  'b5555555-5555-5555-5555-555555555555',
  (SELECT id FROM public.users LIMIT 1),
  'Revision completa de vehiculo [SEED]',
  'Mi auto Toyota Corolla 2018 necesita revision completa: frenos, suspension, motor. Hace ruidos extranos al frenar. Necesito diagnostico y presupuesto.',
  'Mecanico Automotriz',
  'La Paz',
  'Sopocachi',
  200.00,
  800.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  1,
  5,
  true,
  false,
  NOW() - INTERVAL '5 days',
  NOW() + INTERVAL '2 days'
),
-- Solicitud 6: Tecnico computadora
(
  'b6666666-6666-6666-6666-666666666666',
  (SELECT id FROM public.users LIMIT 1),
  'Laptop muy lenta necesita revision [SEED]',
  'Mi laptop Lenovo esta muy lenta, tarda mucho en iniciar y los programas se cierran solos. Tiene 4 anos de uso. Necesito que la revisen y reparen.',
  'Tecnico en Computacion',
  'La Paz',
  'San Miguel',
  80.00,
  200.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  6,
  5,
  true,
  false,
  NOW() - INTERVAL '1 day',
  NOW() + INTERVAL '6 days'
),
-- Solicitud 7: Albanil muro
(
  'b7777777-7777-7777-7777-777777777777',
  (SELECT id FROM public.users LIMIT 1),
  'Construccion de muro perimetral [SEED]',
  'Necesito construir un muro perimetral de aproximadamente 15 metros de largo y 2.5 metros de alto. Con base de piedra y ladrillo. Incluir tarrajeo.',
  'Albanil',
  'Cochabamba',
  'Tiquipaya',
  2000.00,
  4000.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  2,
  5,
  true,
  false,
  NOW() - INTERVAL '6 days',
  NOW() + INTERVAL '1 day'
),
-- Solicitud 8: Cerrajero urgente
(
  'b8888888-8888-8888-8888-888888888888',
  (SELECT id FROM public.users LIMIT 1),
  'Cambio de chapa urgente [SEED]',
  'Me robaron y necesito cambiar la chapa de la puerta principal urgente. Es una puerta de metal. Necesito una chapa de seguridad de buena calidad.',
  'Cerrajero',
  'Santa Cruz',
  'Plan 3000',
  100.00,
  250.00,
  'urgente',
  ARRAY[]::TEXT[],
  'activa',
  3,
  5,
  true,
  true,
  NOW() - INTERVAL '12 hours',
  NOW() + INTERVAL '7 days'
),
-- Solicitud 9: Limpieza profunda
(
  'b9999999-9999-9999-9999-999999999999',
  (SELECT id FROM public.users LIMIT 1),
  'Limpieza profunda de oficina [SEED]',
  'Necesito limpieza profunda de oficina de 100m2. Incluye limpieza de ventanas, desinfeccion de banos, aspirado de alfombras. Para este fin de semana.',
  'Limpieza',
  'La Paz',
  'Centro',
  150.00,
  300.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  2,
  5,
  true,
  false,
  NOW() - INTERVAL '2 days',
  NOW() + INTERVAL '5 days'
),
-- Solicitud 10: Jardinero
(
  'baaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  (SELECT id FROM public.users LIMIT 1),
  'Mantenimiento de jardin mensual [SEED]',
  'Busco jardinero para mantenimiento mensual de mi jardin. Incluye poda de cesped, riego, cuidado de plantas y arbustos. Jardin de aproximadamente 50m2.',
  'Jardinero',
  'Cochabamba',
  'Zona Norte',
  100.00,
  200.00,
  'normal',
  ARRAY[]::TEXT[],
  'activa',
  1,
  5,
  true,
  false,
  NOW() - INTERVAL '3 days',
  NOW() + INTERVAL '4 days'
)
ON CONFLICT (id) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descripcion = EXCLUDED.descripcion,
  estado = 'activa',
  visible = true;

-- ============================================
-- PARTE 4: PREGUNTAS DEL FORO DE PRUEBA
-- ============================================

-- Limpiar preguntas de prueba anteriores
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';

-- Insertar preguntas del foro
INSERT INTO public.foro_preguntas (
  id, user_id, titulo, descripcion, categoria, imagenes,
  resuelta, mejor_respuesta_id, total_respuestas, total_vistas, visible
) VALUES
-- Pregunta 1
(
  'c1111111-1111-1111-1111-111111111111',
  (SELECT id FROM public.users LIMIT 1),
  'Como puedo saber si un electricista es confiable? [SEED]',
  'Necesito contratar un electricista pero me da miedo que me estafen o que hagan mal el trabajo. Que recomendaciones me dan para verificar si es confiable? Que papeles debo pedir?',
  'Electricista',
  ARRAY[]::TEXT[],
  false,
  NULL,
  3,
  45,
  true
),
-- Pregunta 2
(
  'c2222222-2222-2222-2222-222222222222',
  (SELECT id FROM public.users LIMIT 1),
  'Cuanto cuesta instalar un calefon? [SEED]',
  'Quiero instalar un calefon en mi bano pero no se cuanto deberia costar la instalacion. Es un calefon de 10 litros. Alguien sabe el precio promedio en La Paz?',
  'Plomero',
  ARRAY[]::TEXT[],
  true,
  NULL,
  5,
  120,
  true
),
-- Pregunta 3
(
  'c3333333-3333-3333-3333-333333333333',
  (SELECT id FROM public.users LIMIT 1),
  'Que tipo de madera es mejor para muebles? [SEED]',
  'Estoy por mandar a hacer un closet y no se que madera elegir. Me ofrecen cedro, pino y melamina. Cual es mas durable? Cual es mejor relacion calidad-precio?',
  'Carpintero',
  ARRAY[]::TEXT[],
  false,
  NULL,
  4,
  89,
  true
),
-- Pregunta 4
(
  'c4444444-4444-4444-4444-444444444444',
  (SELECT id FROM public.users LIMIT 1),
  'Cada cuanto debo cambiar el aceite de mi auto? [SEED]',
  'Tengo un auto Toyota Yaris 2020. El mecanico me dice cada 5000km pero otros dicen cada 10000km. Cual es lo correcto? Uso el auto principalmente en ciudad.',
  'Mecanico Automotriz',
  ARRAY[]::TEXT[],
  true,
  NULL,
  6,
  200,
  true
),
-- Pregunta 5
(
  'c5555555-5555-5555-5555-555555555555',
  (SELECT id FROM public.users LIMIT 1),
  'Mi computadora no enciende, que puede ser? [SEED]',
  'Mi PC de escritorio no enciende. Cuando presiono el boton de encendido no pasa nada, ni siquiera las luces se prenden. Ya verifique que esta bien conectada. Que puede estar fallando?',
  'Tecnico en Computacion',
  ARRAY[]::TEXT[],
  false,
  NULL,
  7,
  156,
  true
),
-- Pregunta 6
(
  'c6666666-6666-6666-6666-666666666666',
  (SELECT id FROM public.users LIMIT 1),
  'Como preparar la pared antes de pintar? [SEED]',
  'Voy a pintar mi cuarto pero las paredes tienen algunas grietas pequenas y la pintura anterior esta un poco descascarada. Como debo preparar la pared antes de pintar?',
  'Pintor',
  ARRAY[]::TEXT[],
  false,
  NULL,
  4,
  78,
  true
)
ON CONFLICT (id) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descripcion = EXCLUDED.descripcion,
  visible = true;

-- ============================================
-- PARTE 5: CAJEROS DE PRUEBA
-- ============================================

-- Limpiar cajeros de prueba anteriores
DELETE FROM public.cajeros_vendedores WHERE nombre_completo LIKE '%[SEED]%';

-- Insertar cajeros
INSERT INTO public.cajeros_vendedores (
  id, user_id, nombre_completo, telefono, whatsapp, ciudad, zona,
  metodos_pago, disponible_ahora, activo, calificacion_promedio, total_transacciones
) VALUES
(
  'd1111111-1111-1111-1111-111111111111',
  NULL,
  'Maria Lopez [SEED]',
  '71111111',
  '71111111',
  'La Paz',
  'Zona Sur',
  ARRAY['Efectivo', 'QR', 'Transferencia'],
  true,
  true,
  4.9,
  250
),
(
  'd2222222-2222-2222-2222-222222222222',
  NULL,
  'Carlos Mamani [SEED]',
  '72222222',
  '72222222',
  'La Paz',
  'Centro',
  ARRAY['Efectivo', 'QR'],
  true,
  true,
  4.7,
  180
),
(
  'd3333333-3333-3333-3333-333333333333',
  NULL,
  'Ana Gutierrez [SEED]',
  '73333333',
  '73333333',
  'Cochabamba',
  'Centro',
  ARRAY['Efectivo', 'Transferencia'],
  true,
  true,
  4.8,
  150
),
(
  'd4444444-4444-4444-4444-444444444444',
  NULL,
  'Pedro Quispe [SEED]',
  '74444444',
  '74444444',
  'Santa Cruz',
  'Centro',
  ARRAY['Efectivo', 'QR', 'Transferencia'],
  false,
  true,
  4.6,
  200
),
(
  'd5555555-5555-5555-5555-555555555555',
  NULL,
  'Rosa Flores [SEED]',
  '75555555',
  '75555555',
  'La Paz',
  'Miraflores',
  ARRAY['QR', 'Transferencia'],
  true,
  true,
  4.9,
  320
)
ON CONFLICT (id) DO UPDATE SET
  nombre_completo = EXCLUDED.nombre_completo,
  activo = true;

-- ============================================
-- PARTE 6: VERIFICACION FINAL
-- ============================================

SELECT '--- SEEDERS INSERTADOS ---' as info;

SELECT 'Perfiles profesionales:' as tabla, COUNT(*) as cantidad
FROM public.perfiles_profesionales WHERE activo = true;

SELECT 'Solicitudes activas:' as tabla, COUNT(*) as cantidad
FROM public.solicitudes_trabajo WHERE estado = 'activa';

SELECT 'Preguntas del foro:' as tabla, COUNT(*) as cantidad
FROM public.foro_preguntas WHERE visible = true;

SELECT 'Cajeros activos:' as tabla, COUNT(*) as cantidad
FROM public.cajeros_vendedores WHERE activo = true;

SELECT '011_SEEDERS_DEFINITIVOS ejecutado correctamente!' as resultado;
