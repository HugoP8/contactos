-- ============================================
-- SEEDERS FINALES - DATOS DE PRUEBA
-- APP: CONTACTOS - VERSION CORREGIDA
-- ============================================
-- Usando IDs de usuarios reales:
-- - Hugo: b62b05e2-b714-4b8b-9766-25a33dc7ae9a
-- - H.st4rk: 8f07dcb8-2cd4-4157-a8ba-fe7198137810
-- ============================================

-- ============================================
-- 1. ACTUALIZAR DATOS DE USUARIOS EXISTENTES
-- ============================================

UPDATE public.users SET
  nombre_completo = 'Hugo Porcel',
  telefono = '70000001',
  ciudad = 'La Paz',
  zona = 'Centro',
  creditos = 200,
  creditos_totales_ganados = 200,
  verificado = true,
  perfil_completo = true,
  updated_at = NOW()
WHERE id = 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a';

UPDATE public.users SET
  nombre_completo = 'Hugo Stark',
  creditos = 150,
  creditos_totales_ganados = 150,
  verificado = true,
  perfil_completo = true,
  updated_at = NOW()
WHERE id = '8f07dcb8-2cd4-4157-a8ba-fe7198137810';

-- ============================================
-- 2. CREAR TOKENS DE SOLICITUD GRATUITA
-- ============================================

INSERT INTO public.tokens_especiales (user_id, tipo, cantidad, usado, created_at)
VALUES
  ('b62b05e2-b714-4b8b-9766-25a33dc7ae9a', 'solicitud_gratuita', 1, false, NOW()),
  ('8f07dcb8-2cd4-4157-a8ba-fe7198137810', 'solicitud_gratuita', 1, false, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. CREAR PREGUNTAS DEL FORO
-- Columnas reales: titulo, descripcion, categoria
-- ============================================

INSERT INTO public.foro_preguntas (id, user_id, titulo, descripcion, categoria, total_respuestas, created_at)
VALUES
  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '¿Cuánto cobra un plomero por cambiar un grifo?',
   'Necesito cambiar el grifo de la cocina y el del lavamanos del baño. ¿Cuánto es lo normal que cobran? ¿Es mejor comprar yo los grifos o ellos los consiguen más baratos?',
   'Plomería', 0, NOW() - INTERVAL '2 days'),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '¿Alguien conoce electricista de confianza en Santa Cruz?',
   'Hola! Estoy buscando un electricista que sea de confianza para revisar toda la instalación eléctrica de mi casa. Es una casa antigua y quiero asegurarme de que todo esté bien.',
   'Electricidad', 0, NOW() - INTERVAL '1 day'),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '¿Qué tipo de pintura es mejor para exteriores?',
   'Quiero pintar la fachada de mi casa pero no sé qué tipo de pintura usar. Me han dicho que hay especiales para exteriores. ¿Cuál recomiendan? ¿Qué marcas son buenas en Bolivia?',
   'Pintura', 0, NOW() - INTERVAL '3 hours'),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '¿Cuánto tiempo toma hacer un mueble a medida?',
   'Estoy cotizando un closet empotrado y me dicen diferentes tiempos de entrega. ¿Cuánto es lo normal? ¿Una semana? ¿Dos semanas? Quiero saber para planificar mi mudanza.',
   'Carpintería', 0, NOW() - INTERVAL '12 hours'),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '¿Cómo sé si un técnico de computadoras es confiable?',
   'Mi computadora tiene virus y necesito formatearla, pero me da miedo llevarla a cualquier técnico porque tengo información importante. ¿Qué precauciones debo tomar?',
   'Tecnología', 0, NOW() - INTERVAL '6 hours'),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   '¿Recomiendan algún servicio de limpieza en Sucre?',
   'Necesito contratar servicio de limpieza para mi departamento una vez por semana. ¿Alguien tiene experiencia con algún servicio de limpieza profesional en Sucre?',
   'Limpieza', 0, NOW() - INTERVAL '4 hours'),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   '¿Qué papeles necesito para contratar un albañil?',
   'Voy a hacer una ampliación en mi casa y quiero contratar un albañil. ¿Necesito hacer algún contrato formal? ¿Qué documentos me debe dar?',
   'Construcción', 0, NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. CREAR SOLICITUDES DE TRABAJO
-- ============================================

INSERT INTO public.solicitudes_trabajo (
  id, user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, estado,
  visible, destacada, total_postulaciones, created_at
)
VALUES
  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   'Necesito plomero para reparar fuga de agua urgente',
   'Tengo una fuga de agua en el baño principal, parece ser en la conexión del inodoro. Necesito que vengan hoy si es posible. La fuga está mojando el piso.',
   'Plomería', 'La Paz', 'Centro', 100, 300, 'urgente', 'activa',
   true, true, 0, NOW()),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   'Instalación de 8 puntos de luz LED en oficina',
   'Necesito instalar 8 puntos de luz LED en una oficina de 50m2. También necesito 4 tomacorrientes adicionales. La oficina está en obra gris.',
   'Electricidad', 'La Paz', 'Miraflores', 500, 1200, 'normal', 'activa',
   true, false, 0, NOW()),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   'Fabricación de closet empotrado 2.5m x 2.4m',
   'Necesito un closet empotrado de 2.5 metros de ancho por 2.4 metros de alto. Debe tener cajones, barras para colgar ropa y estantes. Melamina color nogal.',
   'Carpintería', 'La Paz', 'Achumani', 1500, 3000, 'normal', 'activa',
   true, false, 0, NOW()),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   'Limpieza profunda de departamento 3 ambientes',
   'Busco servicio de limpieza profunda para departamento de 3 ambientes (80m2). Incluye cocina, 2 baños, 2 dormitorios y sala. Para este fin de semana.',
   'Limpieza', 'Sucre', 'Centro', 200, 400, 'normal', 'activa',
   true, false, 0, NOW()),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   'Reparación de laptop HP que no enciende',
   'Mi laptop HP Pavilion no enciende, cuando presiono el botón de encendido solo parpadea una luz azul y se apaga. Necesito diagnóstico y reparación urgente.',
   'Tecnología', 'Sucre', 'Centro', 100, 400, 'urgente', 'activa',
   true, true, 0, NOW()),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   'Pintura de casa completa - interior 2 pisos',
   'Necesito pintar el interior de casa de 2 pisos, aproximadamente 200m2 de paredes. Prefiero colores claros. Incluir empastado donde sea necesario.',
   'Pintura', 'Sucre', 'Zona Norte', 2000, 4000, 'normal', 'activa',
   true, false, 0, NOW()),

  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   'Mantenimiento de jardín mensual',
   'Busco jardinero para mantenimiento mensual de jardín de 50m2. Incluye poda de césped, cuidado de plantas, limpieza de hojas.',
   'Jardinería', 'La Paz', 'Calacoto', 150, 300, 'normal', 'activa',
   true, false, 0, NOW()),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   'Cambio de aceite y revisión de frenos',
   'Necesito cambio de aceite completo y revisión de frenos para Toyota Corolla 2019. El auto hace un ruido leve al frenar.',
   'Mecánica', 'Sucre', 'Centro', 200, 500, 'normal', 'activa',
   true, false, 0, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. CREAR PERFILES PROFESIONALES
-- Columnas reales: nombre_comercial, categoria_principal, años_experiencia,
-- rango_precio_desde, rango_precio_hasta, total_trabajos_realizados
-- ============================================

INSERT INTO public.perfiles_profesionales (
  id, user_id, nombre_comercial, descripcion, categoria_principal,
  ciudad, telefono, whatsapp, años_experiencia,
  rango_precio_desde, rango_precio_hasta,
  calificacion_promedio, total_resenas, total_trabajos_realizados,
  activo, visible_busqueda, created_at
)
VALUES
  (uuid_generate_v4(), 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
   'TechSoluciones - Hugo Porcel',
   'Técnico certificado con 5 años de experiencia. Realizo reparación de computadoras, laptops y celulares. Instalación de Windows, formateo, recuperación de datos, instalación de redes WiFi, cámaras de seguridad y soporte técnico remoto. Trabajo garantizado.',
   'Tecnología', 'La Paz', '70000001', '70000001', 5,
   50, 500, 4.8, 12, 45, true, true, NOW()),

  (uuid_generate_v4(), '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
   'Electricidad Stark - Servicio Profesional',
   'Electricista con certificación y 8 años de experiencia. Realizo instalaciones eléctricas domiciliarias e industriales, mantenimiento preventivo, reparación de cortocircuitos, instalación de tableros, iluminación LED. Atención en toda Sucre. Disponible 24/7 para emergencias.',
   'Electricidad', 'Sucre', '75455488', '75455488', 8,
   80, 800, 4.9, 28, 85, true, true, NOW())
ON CONFLICT DO NOTHING;

-- Actualizar rol de usuarios a "dual" (buscador + profesional)
UPDATE public.users SET rol = 'dual' WHERE id IN (
  'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
  '8f07dcb8-2cd4-4157-a8ba-fe7198137810'
);

-- ============================================
-- 6. CREAR RESPUESTAS DEL FORO
-- Columnas reales: contenido, total_votos, es_respuesta_aceptada
-- ============================================

DO $$
DECLARE
  pregunta_plomero UUID;
  pregunta_electricista UUID;
BEGIN
  SELECT id INTO pregunta_plomero FROM public.foro_preguntas
  WHERE titulo LIKE '%plomero%grifo%' LIMIT 1;

  SELECT id INTO pregunta_electricista FROM public.foro_preguntas
  WHERE titulo LIKE '%electricista%Santa Cruz%' LIMIT 1;

  IF pregunta_plomero IS NOT NULL THEN
    INSERT INTO public.foro_respuestas (id, pregunta_id, user_id, contenido, es_respuesta_aceptada, total_votos, created_at)
    VALUES
      (uuid_generate_v4(), pregunta_plomero, '8f07dcb8-2cd4-4157-a8ba-fe7198137810',
       'Por cambiar un grifo normalmente cobran entre Bs. 50 y Bs. 100, dependiendo de la complejidad. Te recomiendo comprar tú los grifos porque así eliges la calidad que quieres.',
       false, 3, NOW() - INTERVAL '1 day'),
      (uuid_generate_v4(), pregunta_plomero, 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
       'Yo pagué Bs. 80 por cambiar dos grifos la semana pasada. El plomero me recomendó comprar grifos de marca FV o similar, son más duraderos.',
       true, 5, NOW() - INTERVAL '12 hours');

    UPDATE public.foro_preguntas SET total_respuestas = 2, respondida = true WHERE id = pregunta_plomero;
  END IF;

  IF pregunta_electricista IS NOT NULL THEN
    INSERT INTO public.foro_respuestas (id, pregunta_id, user_id, contenido, es_respuesta_aceptada, total_votos, created_at)
    VALUES
      (uuid_generate_v4(), pregunta_electricista, 'b62b05e2-b714-4b8b-9766-25a33dc7ae9a',
       'Te recomiendo buscar electricistas certificados. Pide que te muestren su carnet de ENDE o similar. Para una revisión completa de casa, cobran entre Bs. 200 y Bs. 400.',
       false, 2, NOW() - INTERVAL '6 hours');

    UPDATE public.foro_preguntas SET total_respuestas = 1 WHERE id = pregunta_electricista;
  END IF;

  RAISE NOTICE '✅ Respuestas del foro creadas';
END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '📊 RESUMEN DE DATOS:' as info;

SELECT 'Usuarios:' as tabla, COUNT(*)::text as total FROM public.users
UNION ALL
SELECT 'Tokens gratuitos:', COUNT(*)::text FROM public.tokens_especiales
UNION ALL
SELECT 'Preguntas foro:', COUNT(*)::text FROM public.foro_preguntas
UNION ALL
SELECT 'Respuestas foro:', COUNT(*)::text FROM public.foro_respuestas
UNION ALL
SELECT 'Solicitudes:', COUNT(*)::text FROM public.solicitudes_trabajo
UNION ALL
SELECT 'Perfiles prof:', COUNT(*)::text FROM public.perfiles_profesionales;

SELECT '✅ SEEDERS EJECUTADOS EXITOSAMENTE!' as resultado;
