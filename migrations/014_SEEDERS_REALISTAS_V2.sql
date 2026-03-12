-- ============================================
-- SEEDERS REALISTAS V2 - 21 ENERO 2026
-- Versión que respeta la FK con auth.users
-- ============================================

-- IMPORTANTE: En Supabase, los usuarios en public.users deben existir primero en auth.users
-- Hay 2 opciones:

-- ============================================
-- OPCIÓN 1: Usar usuarios existentes de auth.users
-- Ejecuta esta consulta primero para ver qué usuarios tienes:
-- ============================================

-- SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 10;

-- ============================================
-- OPCIÓN 2: Desactivar temporalmente la FK (RECOMENDADO PARA DESARROLLO)
-- ============================================

-- Desactivar la restricción FK temporalmente
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- ============================================
-- PASO 1: USUARIOS BUSCADORES (Clientes)
-- ============================================

-- Usuario 1: María Fernanda
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'a1111111-1111-1111-1111-111111111111',
  'maria.fernanda@gmail.com',
  'María Fernanda Quispe',
  '71234567',
  'La Paz',
  'buscador',
  'gratuita',
  50,
  true,
  NOW() - INTERVAL '30 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- Usuario 2: Carlos Alberto
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'a2222222-2222-2222-2222-222222222222',
  'carlos.mamani@gmail.com',
  'Carlos Alberto Mamani',
  '72345678',
  'Santa Cruz',
  'buscador',
  'gratuita',
  75,
  true,
  NOW() - INTERVAL '25 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- Usuario 3: Ana Lucía
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'a3333333-3333-3333-3333-333333333333',
  'ana.lucia.flores@gmail.com',
  'Ana Lucía Flores',
  '73456789',
  'Cochabamba',
  'buscador',
  'premium',
  200,
  true,
  NOW() - INTERVAL '60 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- Usuario 4: Roberto
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'a4444444-4444-4444-4444-444444444444',
  'roberto.choque@hotmail.com',
  'Roberto Choque',
  '74567890',
  'El Alto',
  'buscador',
  'gratuita',
  35,
  false,
  NOW() - INTERVAL '15 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- Usuario 5: Patricia
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'a5555555-5555-5555-5555-555555555555',
  'patricia.vargas@yahoo.com',
  'Patricia Vargas Mendoza',
  '75678901',
  'Tarija',
  'buscador',
  'gratuita',
  60,
  true,
  NOW() - INTERVAL '20 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- ============================================
-- PASO 2: PROFESIONALES
-- ============================================

-- Profesional 1: Electricista en La Paz
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'p1111111-1111-1111-1111-111111111111',
  'juan.electricista@gmail.com',
  'Juan Carlos Pérez',
  '76789012',
  'La Paz',
  'profesional',
  'premium',
  150,
  true,
  NOW() - INTERVAL '90 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado, created_at
) VALUES (
  'pp111111-1111-1111-1111-111111111111',
  'p1111111-1111-1111-1111-111111111111',
  'Electricidad JC',
  'Electricista',
  'Electricista profesional con más de 10 años de experiencia. Instalaciones eléctricas residenciales y comerciales, reparaciones, mantenimiento y emergencias 24/7. Trabajo garantizado.',
  'La Paz',
  'Zona San Pedro, Calle Murillo #234',
  '76789012',
  '76789012',
  'juan.electricista@gmail.com',
  4.8,
  25,
  50,
  true,
  true,
  true,
  true,
  NOW() - INTERVAL '90 days'
) ON CONFLICT (id) DO UPDATE SET nombre_negocio = EXCLUDED.nombre_negocio;

-- Profesional 2: Plomero en Santa Cruz
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'p2222222-2222-2222-2222-222222222222',
  'miguel.plomero@gmail.com',
  'Miguel Ángel Rojas',
  '77890123',
  'Santa Cruz',
  'profesional',
  'gratuita',
  80,
  true,
  NOW() - INTERVAL '60 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado, created_at
) VALUES (
  'pp222222-2222-2222-2222-222222222222',
  'p2222222-2222-2222-2222-222222222222',
  'Plomería Rojas',
  'Plomero',
  'Plomero certificado. Destapes, instalación de sanitarios, griferías, calentadores de agua. Atención rápida y precios justos.',
  'Santa Cruz',
  'Av. Cañoto, Barrio Equipetrol',
  '77890123',
  '77890123',
  'miguel.plomero@gmail.com',
  4.5,
  18,
  35,
  true,
  true,
  true,
  false,
  NOW() - INTERVAL '60 days'
) ON CONFLICT (id) DO UPDATE SET nombre_negocio = EXCLUDED.nombre_negocio;

-- Profesional 3: Carpintero en Cochabamba
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'p3333333-3333-3333-3333-333333333333',
  'pedro.carpintero@gmail.com',
  'Pedro Gutiérrez',
  '78901234',
  'Cochabamba',
  'profesional',
  'premium',
  200,
  true,
  NOW() - INTERVAL '120 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado, created_at
) VALUES (
  'pp333333-3333-3333-3333-333333333333',
  'p3333333-3333-3333-3333-333333333333',
  'Muebles a Medida PG',
  'Carpintero',
  'Maestro carpintero especializado en muebles a medida. Closets, cocinas empotradas, muebles de TV, escritorios. Maderas de calidad y acabados finos.',
  'Cochabamba',
  'Zona Quillacollo, Av. Blanco Galindo',
  '78901234',
  '78901234',
  'pedro.carpintero@gmail.com',
  4.9,
  42,
  80,
  true,
  true,
  true,
  true,
  NOW() - INTERVAL '120 days'
) ON CONFLICT (id) DO UPDATE SET nombre_negocio = EXCLUDED.nombre_negocio;

-- Profesional 4: Técnico en Computadoras
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'p4444444-4444-4444-4444-444444444444',
  'luis.tecnico@gmail.com',
  'Luis Fernando Condori',
  '79012345',
  'La Paz',
  'profesional',
  'gratuita',
  45,
  true,
  NOW() - INTERVAL '45 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado, created_at
) VALUES (
  'pp444444-4444-4444-4444-444444444444',
  'p4444444-4444-4444-4444-444444444444',
  'TechSupport Bolivia',
  'Reparación de computadoras',
  'Técnico en computadoras. Reparación de laptops y PCs, formateo, instalación de programas, recuperación de datos, redes. Servicio a domicilio.',
  'La Paz',
  'Zona Miraflores, Calle 16 de Julio',
  '79012345',
  '79012345',
  'luis.tecnico@gmail.com',
  4.6,
  15,
  28,
  true,
  true,
  true,
  false,
  NOW() - INTERVAL '45 days'
) ON CONFLICT (id) DO UPDATE SET nombre_negocio = EXCLUDED.nombre_negocio;

-- Profesional 5: Pintora
INSERT INTO public.users (id, email, nombre_completo, telefono, ciudad, rol, tipo_cuenta, creditos, verificado, created_at)
VALUES (
  'p5555555-5555-5555-5555-555555555555',
  'rosa.pintora@gmail.com',
  'Rosa María Aguilar',
  '70123456',
  'Santa Cruz',
  'profesional',
  'gratuita',
  65,
  true,
  NOW() - INTERVAL '30 days'
) ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado, created_at
) VALUES (
  'pp555555-5555-5555-5555-555555555555',
  'p5555555-5555-5555-5555-555555555555',
  'Pinturas Rosa',
  'Pintor',
  'Pintora profesional. Pintura interior y exterior, estuco, texturado, decoración de interiores. Trabajo limpio y puntual.',
  'Santa Cruz',
  'Plan 3000, UV 120',
  '70123456',
  '70123456',
  'rosa.pintora@gmail.com',
  4.7,
  22,
  40,
  true,
  true,
  true,
  false,
  NOW() - INTERVAL '30 days'
) ON CONFLICT (id) DO UPDATE SET nombre_negocio = EXCLUDED.nombre_negocio;

-- ============================================
-- PASO 3: SOLICITUDES DE TRABAJO
-- ============================================

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones, created_at
) VALUES (
  'sol11111-1111-1111-1111-111111111111',
  'a1111111-1111-1111-1111-111111111111',
  'Necesito electricista para instalación en mi casa',
  'Requiero un electricista para revisar toda la instalación eléctrica de mi casa. Hay algunos tomacorrientes que no funcionan y necesito agregar puntos de luz en el jardín. La casa tiene 3 pisos.',
  'Electricista',
  'La Paz',
  'Zona Sur, Calacoto',
  500,
  1500,
  'normal',
  true,
  3,
  NOW() - INTERVAL '5 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones, created_at
) VALUES (
  'sol22222-2222-2222-2222-222222222222',
  'a2222222-2222-2222-2222-222222222222',
  'Plomero urgente - Fuga de agua',
  'Tengo una fuga de agua en el baño principal. El agua está saliendo por debajo del inodoro. Necesito alguien que pueda venir hoy o mañana temprano.',
  'Plomero',
  'Santa Cruz',
  'Barrio Urbari',
  200,
  800,
  'urgente',
  true,
  5,
  NOW() - INTERVAL '2 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones, created_at
) VALUES (
  'sol33333-3333-3333-3333-333333333333',
  'a3333333-3333-3333-3333-333333333333',
  'Muebles de cocina a medida',
  'Busco carpintero para hacer muebles de cocina empotrados. Tengo los diseños y medidas. Material: melamina blanca con tiradores metálicos. Incluye isla central.',
  'Carpintero',
  'Cochabamba',
  'Zona Norte, Cala Cala',
  3000,
  8000,
  'normal',
  true,
  2,
  NOW() - INTERVAL '7 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones, created_at
) VALUES (
  'sol44444-4444-4444-4444-444444444444',
  'a4444444-4444-4444-4444-444444444444',
  'Reparar mi laptop - No enciende',
  'Mi laptop Dell no enciende. Hace un mes funcionaba bien pero ahora al presionar el botón de encendido no pasa nada. Creo que puede ser la batería o el cargador.',
  'Reparación de computadoras',
  'El Alto',
  'Ciudad Satélite',
  100,
  400,
  'normal',
  true,
  4,
  NOW() - INTERVAL '3 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones, created_at
) VALUES (
  'sol55555-5555-5555-5555-555555555555',
  'a5555555-5555-5555-5555-555555555555',
  'Pintar departamento completo',
  'Necesito pintar mi departamento de 80m2. Son 2 dormitorios, sala, comedor, cocina y 2 baños. Quiero colores claros, pueden sugerirme combinaciones.',
  'Pintor',
  'Tarija',
  'Zona Central',
  1200,
  2500,
  'normal',
  true,
  3,
  NOW() - INTERVAL '4 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

-- ============================================
-- PASO 4: PREGUNTAS DEL FORO
-- ============================================

INSERT INTO public.foro_preguntas (
  id, user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible, created_at
) VALUES (
  'fq111111-1111-1111-1111-111111111111',
  'a1111111-1111-1111-1111-111111111111',
  '¿Alguien conoce un buen electricista en Zona Sur?',
  'Estoy buscando un electricista de confianza para un trabajo grande en mi casa. ¿Alguien puede recomendarme uno que sea puntual y trabaje bien?',
  'Recomendaciones',
  false,
  3,
  45,
  true,
  NOW() - INTERVAL '10 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.foro_preguntas (
  id, user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible, created_at
) VALUES (
  'fq222222-2222-2222-2222-222222222222',
  'a2222222-2222-2222-2222-222222222222',
  '¿Cuánto debería costar arreglar una fuga de agua?',
  'Tengo una fuga en el baño y me están cobrando 500 Bs. ¿Es un precio justo o me están cobrando de más? La fuga es debajo del inodoro.',
  'Precios y Costos',
  true,
  5,
  120,
  true,
  NOW() - INTERVAL '15 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

INSERT INTO public.foro_preguntas (
  id, user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible, created_at
) VALUES (
  'fq333333-3333-3333-3333-333333333333',
  'a3333333-3333-3333-3333-333333333333',
  '¿Qué madera es mejor para muebles de cocina?',
  'Estoy por hacer mis muebles de cocina y no sé qué material elegir. ¿Melamina, MDF o madera natural? ¿Cuál dura más y es más fácil de limpiar?',
  'Consejos',
  false,
  4,
  89,
  true,
  NOW() - INTERVAL '8 days'
) ON CONFLICT (id) DO UPDATE SET titulo = EXCLUDED.titulo;

-- ============================================
-- PASO 5: RESPUESTAS DEL FORO
-- ============================================

INSERT INTO public.foro_respuestas (
  id, pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos, created_at
) VALUES (
  'fr111111-1111-1111-1111-111111111111',
  'fq111111-1111-1111-1111-111111111111',
  'p1111111-1111-1111-1111-111111111111',
  'Hola! Yo trabajo en Zona Sur y tengo más de 10 años de experiencia. Si quieres puedes contactarme por la app y te paso mi número para coordinar una visita.',
  false,
  8,
  NOW() - INTERVAL '9 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.foro_respuestas (
  id, pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos, created_at
) VALUES (
  'fr222222-2222-2222-2222-222222222222',
  'fq111111-1111-1111-1111-111111111111',
  'a2222222-2222-2222-2222-222222222222',
  'Yo trabajé con Juan Carlos (Electricidad JC) y quedé muy satisfecho. Es puntual y explica todo lo que hace. Lo recomiendo.',
  false,
  12,
  NOW() - INTERVAL '8 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.foro_respuestas (
  id, pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos, created_at
) VALUES (
  'fr333333-3333-3333-3333-333333333333',
  'fq222222-2222-2222-2222-222222222222',
  'p2222222-2222-2222-2222-222222222222',
  'El precio puede variar dependiendo del problema. Si es solo cambiar el empaque del inodoro puede costar entre 150-200 Bs. Pero si hay que romper piso y cambiar tuberías puede llegar a 500-800 Bs. Recomiendo que pidas un diagnóstico primero.',
  true,
  25,
  NOW() - INTERVAL '14 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.foro_respuestas (
  id, pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos, created_at
) VALUES (
  'fr444444-4444-4444-4444-444444444444',
  'fq333333-3333-3333-3333-333333333333',
  'p3333333-3333-3333-3333-333333333333',
  'Como carpintero te recomiendo melamina de buena calidad para cocinas. Es fácil de limpiar, resistente a la humedad y más económica que la madera natural. El MDF es bueno pero se hincha con el agua. Si quieres algo más premium, puedes usar melamina para el cuerpo y madera solo para las puertas.',
  false,
  18,
  NOW() - INTERVAL '7 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

-- ============================================
-- PASO 6: RESEÑAS
-- ============================================

INSERT INTO public.resenas (
  id, profesional_id, usuario_id, calificacion, contenido, visible, created_at
) VALUES (
  'res11111-1111-1111-1111-111111111111',
  'pp111111-1111-1111-1111-111111111111',
  'a1111111-1111-1111-1111-111111111111',
  5,
  'Excelente trabajo! Juan Carlos llegó puntual, revisó toda la instalación y solucionó todos los problemas. Muy profesional y limpio. Lo recomiendo 100%.',
  true,
  NOW() - INTERVAL '20 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.resenas (
  id, profesional_id, usuario_id, calificacion, contenido, visible, created_at
) VALUES (
  'res22222-2222-2222-2222-222222222222',
  'pp111111-1111-1111-1111-111111111111',
  'a2222222-2222-2222-2222-222222222222',
  4,
  'Buen trabajo, aunque tardó un poco más de lo esperado. El resultado final quedó muy bien.',
  true,
  NOW() - INTERVAL '15 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.resenas (
  id, profesional_id, usuario_id, calificacion, contenido, visible, created_at
) VALUES (
  'res33333-3333-3333-3333-333333333333',
  'pp222222-2222-2222-2222-222222222222',
  'a3333333-3333-3333-3333-333333333333',
  5,
  'Miguel es muy profesional. Arregló la fuga rápidamente y me explicó cómo prevenir el problema en el futuro. Precio justo.',
  true,
  NOW() - INTERVAL '10 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.resenas (
  id, profesional_id, usuario_id, calificacion, contenido, visible, created_at
) VALUES (
  'res44444-4444-4444-4444-444444444444',
  'pp333333-3333-3333-3333-333333333333',
  'a4444444-4444-4444-4444-444444444444',
  5,
  'Los muebles quedaron espectaculares! Pedro es un verdadero artista. Cumplió con los tiempos y el presupuesto acordado.',
  true,
  NOW() - INTERVAL '30 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

INSERT INTO public.resenas (
  id, profesional_id, usuario_id, calificacion, contenido, visible, created_at
) VALUES (
  'res55555-5555-5555-5555-555555555555',
  'pp444444-4444-4444-4444-444444444444',
  'a5555555-5555-5555-5555-555555555555',
  4,
  'Luis arregló mi laptop y ahora funciona perfecta. El único detalle es que tardó 3 días en tenerla lista, pero el resultado valió la pena.',
  true,
  NOW() - INTERVAL '5 days'
) ON CONFLICT (id) DO UPDATE SET contenido = EXCLUDED.contenido;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT 'SEEDERS REALISTAS V2 - EJECUTADO CORRECTAMENTE' as resultado;
SELECT 'Total usuarios: ' || COUNT(*) as info FROM public.users;
SELECT 'Total profesionales: ' || COUNT(*) as info FROM public.perfiles_profesionales;
SELECT 'Total solicitudes: ' || COUNT(*) as info FROM public.solicitudes_trabajo;
SELECT 'Total preguntas foro: ' || COUNT(*) as info FROM public.foro_preguntas;
SELECT 'Total reseñas: ' || COUNT(*) as info FROM public.resenas;
