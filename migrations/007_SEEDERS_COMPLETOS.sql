-- ============================================
-- SEEDERS COMPLETOS - DATOS DE PRUEBA
-- APP: CONTACTOS
-- ============================================
-- Usuarios existentes:
-- Hugo Porcel: b62b05e2-b714-4b8b-9766-25a33dc7ae9a
-- Hugo Stark: 8f07dcb8-2cd4-4157-a8ba-fe7198137810
-- ============================================

-- ============================================
-- 1. ACTUALIZAR CREDITOS DE USUARIOS
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
-- 2. CREAR SOLICITUDES DE TRABAJO
-- ============================================

-- Limpiar solicitudes anteriores de prueba
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%[SEED]%';

-- Solicitudes de Hugo Porcel
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, estado,
  visible, destacada, total_postulaciones, created_at, expires_at
) VALUES
  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Necesito plomero para reparar fuga de agua',
   'Tengo una fuga de agua en el baño principal. La fuga está en la conexión del inodoro y está mojando el piso. Necesito que vengan lo antes posible.',
   'Plomeria', 'La Paz', 'Centro',
   100, 300, 'urgente', 'activa',
   true, true, 0, NOW(), NOW() + INTERVAL '7 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Instalación de 8 puntos de luz LED',
   'Necesito instalar 8 puntos de luz LED en una oficina de 50m2. También necesito 4 tomacorrientes adicionales.',
   'Electricidad', 'La Paz', 'Miraflores',
   500, 1200, 'normal', 'activa',
   true, false, 2, NOW() - INTERVAL '1 day', NOW() + INTERVAL '6 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Fabricación de closet empotrado',
   'Necesito un closet empotrado de 2.5 metros de ancho por 2.4 metros de alto. Debe tener cajones, barras para colgar ropa y estantes. Melamina color nogal.',
   'Carpinteria', 'La Paz', 'Achumani',
   1500, 3000, 'normal', 'activa',
   true, false, 5, NOW() - INTERVAL '2 days', NOW() + INTERVAL '5 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Mantenimiento de jardín mensual',
   'Busco jardinero para mantenimiento mensual de jardín de 50m2. Incluye poda de césped, cuidado de plantas, limpieza de hojas.',
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
   '[SEED] Limpieza profunda de departamento',
   'Busco servicio de limpieza profunda para departamento de 3 ambientes (80m2). Incluye cocina, 2 baños, 2 dormitorios y sala.',
   'Limpieza', 'Santa Cruz', 'Centro',
   200, 400, 'normal', 'activa',
   true, false, 1, NOW() - INTERVAL '3 hours', NOW() + INTERVAL '7 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Reparación de laptop HP que no enciende',
   'Mi laptop HP Pavilion no enciende. Cuando presiono el botón de encendido solo parpadea una luz azul y se apaga. Necesito diagnóstico y reparación.',
   'Tecnologia', 'Cochabamba', 'Centro',
   100, 400, 'urgente', 'activa',
   true, true, 3, NOW() - INTERVAL '5 hours', NOW() + INTERVAL '7 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Pintura de casa completa interior',
   'Necesito pintar el interior de casa de 2 pisos, aproximadamente 200m2 de paredes. Prefiero colores claros. Incluir empastado donde sea necesario.',
   'Pintura', 'Sucre', 'Zona Norte',
   2000, 4000, 'normal', 'activa',
   true, false, 0, NOW() - INTERVAL '1 day', NOW() + INTERVAL '6 days'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Cambio de aceite y revisión de frenos',
   'Necesito cambio de aceite completo y revisión de frenos para Toyota Corolla 2019. El auto hace un ruido leve al frenar.',
   'Mecanica', 'Santa Cruz', 'Equipetrol',
   200, 500, 'normal', 'activa',
   true, false, 2, NOW() - INTERVAL '6 hours', NOW() + INTERVAL '7 days');

-- ============================================
-- 3. CREAR PREGUNTAS DEL FORO
-- ============================================

-- Limpiar preguntas anteriores de prueba
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';

-- Preguntas de Hugo Porcel
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria,
  total_respuestas, total_votos, respondida, visible, created_at
) VALUES
  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Cuanto cobra un plomero por cambiar un grifo?',
   'Necesito cambiar el grifo de la cocina y el del lavamanos del baño. Cuanto es lo normal que cobran? Es mejor comprar yo los grifos o ellos los consiguen mas baratos?',
   'Plomeria', 2, 5, false, true, NOW() - INTERVAL '2 days'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Que tipo de pintura es mejor para exteriores?',
   'Quiero pintar la fachada de mi casa pero no se que tipo de pintura usar. Me han dicho que hay especiales para exteriores. Cual recomiendan? Que marcas son buenas?',
   'Pintura', 3, 8, true, true, NOW() - INTERVAL '3 hours'),

  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '[SEED] Como se si un tecnico de computadoras es confiable?',
   'Mi computadora tiene virus y necesito formatearla, pero me da miedo llevarla a cualquier tecnico porque tengo informacion importante. Que precauciones debo tomar?',
   'Tecnologia', 4, 12, false, true, NOW() - INTERVAL '6 hours');

-- Preguntas de Hugo Stark
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria,
  total_respuestas, total_votos, respondida, visible, created_at
) VALUES
  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Alguien conoce electricista de confianza?',
   'Hola! Estoy buscando un electricista que sea de confianza para revisar toda la instalacion electrica de mi casa. Es una casa antigua y quiero asegurarme de que todo este bien.',
   'Electricidad', 1, 3, false, true, NOW() - INTERVAL '1 day'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Cuanto tiempo toma hacer un mueble a medida?',
   'Estoy cotizando un closet empotrado y me dicen diferentes tiempos de entrega. Cuanto es lo normal? Una semana? Dos semanas? Quiero saber para planificar.',
   'Carpinteria', 0, 2, false, true, NOW() - INTERVAL '12 hours'),

  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '[SEED] Recomiendan algun servicio de limpieza?',
   'Necesito contratar servicio de limpieza para mi departamento una vez por semana. Alguien tiene experiencia con algun servicio de limpieza profesional?',
   'Limpieza', 2, 4, false, true, NOW() - INTERVAL '4 hours');

-- ============================================
-- 4. CREAR RESPUESTAS DEL FORO
-- ============================================

-- Limpiar respuestas anteriores
DELETE FROM public.foro_respuestas WHERE contenido LIKE '%[SEED]%';

-- Respuestas a la pregunta del plomero (Hugo Stark responde a Hugo Porcel)
INSERT INTO public.foro_respuestas (
  pregunta_id, user_id, contenido,
  total_votos, es_respuesta_aceptada, es_mejor_respuesta, created_at
)
SELECT
  p.id,
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
  '[SEED] Por cambiar un grifo normalmente cobran entre Bs. 50 y Bs. 100, dependiendo de la complejidad. Te recomiendo comprar tu los grifos porque asi eliges la calidad que quieres.',
  5, false, false, NOW() - INTERVAL '1 day'
FROM public.foro_preguntas p
WHERE p.titulo LIKE '%plomero%grifo%' LIMIT 1;

-- Hugo Porcel responde también
INSERT INTO public.foro_respuestas (
  pregunta_id, user_id, contenido,
  total_votos, es_respuesta_aceptada, es_mejor_respuesta, created_at
)
SELECT
  p.id,
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '[SEED] Gracias! Yo pagué Bs. 80 por cambiar dos grifos la semana pasada. El plomero me recomendó comprar grifos de marca FV o similar, son mas duraderos.',
  8, true, true, NOW() - INTERVAL '12 hours'
FROM public.foro_preguntas p
WHERE p.titulo LIKE '%plomero%grifo%' LIMIT 1;

-- Respuesta a la pregunta del electricista (Hugo Porcel responde a Hugo Stark)
INSERT INTO public.foro_respuestas (
  pregunta_id, user_id, contenido,
  total_votos, es_respuesta_aceptada, es_mejor_respuesta, created_at
)
SELECT
  p.id,
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '[SEED] Te recomiendo buscar electricistas certificados. Pide que te muestren su carnet. Para una revision completa de casa, cobran entre Bs. 200 y Bs. 400.',
  3, false, false, NOW() - INTERVAL '6 hours'
FROM public.foro_preguntas p
WHERE p.titulo LIKE '%electricista%confianza%' LIMIT 1;

-- ============================================
-- 5. CREAR/ACTUALIZAR PERFILES PROFESIONALES
-- user_id es UNIQUE, usar UPSERT
-- ============================================

-- Eliminar perfiles existentes de los usuarios de prueba primero
DELETE FROM public.perfiles_profesionales
WHERE user_id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- Perfil profesional de Hugo Porcel
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, años_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado, created_at
) VALUES (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  'TechSoluciones - Hugo Porcel',
  'Tecnico certificado con experiencia en reparacion de computadoras, laptops y celulares. Instalacion de Windows, formateo, recuperacion de datos, instalacion de redes WiFi y camaras de seguridad. Trabajo garantizado.',
  'Tecnologia',
  'La Paz',
  '70000001',
  '70000001',
  5,
  50, 500,
  4.8, 12, 45,
  true, true, true, NOW()
);

-- Perfil profesional de Hugo Stark
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, años_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, verificado, created_at
) VALUES (
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
  'Electricidad Stark - Servicio Profesional',
  'Electricista con certificacion y 8 años de experiencia. Realizo instalaciones electricas domiciliarias e industriales, mantenimiento preventivo, reparacion de cortocircuitos, instalacion de tableros, iluminacion LED. Disponible 24/7 para emergencias.',
  'Electricidad',
  'Santa Cruz',
  '75455488',
  '75455488',
  8,
  80, 800,
  4.9, 28, 85,
  true, true, true, NOW()
);

-- Actualizar rol de usuarios a "dual" (buscador + profesional)
UPDATE public.users SET rol = 'dual' WHERE id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- ============================================
-- 6. VERIFICACION FINAL
-- ============================================

SELECT '--- RESUMEN DE DATOS INSERTADOS ---' as info;

SELECT 'Usuarios con creditos:' as tabla, COUNT(*)::text as total
FROM public.users WHERE creditos >= 500;

SELECT 'Solicitudes de trabajo:' as tabla, COUNT(*)::text as total
FROM public.solicitudes_trabajo WHERE visible = true AND titulo LIKE '%[SEED]%';

SELECT 'Preguntas del foro:' as tabla, COUNT(*)::text as total
FROM public.foro_preguntas WHERE titulo LIKE '%[SEED]%';

SELECT 'Respuestas del foro:' as tabla, COUNT(*)::text as total
FROM public.foro_respuestas WHERE contenido LIKE '%[SEED]%';

SELECT 'Perfiles profesionales:' as tabla, COUNT(*)::text as total
FROM public.perfiles_profesionales WHERE activo = true;

SELECT 'Cajeros:' as tabla, COUNT(*)::text as total
FROM public.cajeros_vendedores WHERE activo = true;

SELECT '✅ SEEDERS EJECUTADOS CORRECTAMENTE!' as resultado;
