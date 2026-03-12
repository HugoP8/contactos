-- ============================================
-- SEEDERS DEFINITIVOS - 21 ENERO 2026
-- Con IDs reales de auth.users
-- ============================================
--
-- USUARIOS DE PRUEBA (creados en Supabase Dashboard):
-- ┌─────────────────────────────┬─────────────┬──────────────────┐
-- │ Email                       │ Password    │ Rol              │
-- ├─────────────────────────────┼─────────────┼──────────────────┤
-- │ maria.fernanda@test.com     │ Test1234!   │ Buscador         │
-- │ carlos.mamani@test.com      │ Test1234!   │ Buscador         │
-- │ ana.flores@test.com         │ Test1234!   │ Buscador Premium │
-- │ roberto.choque@test.com     │ Test1234!   │ Buscador         │
-- │ patricia.vargas@test.com    │ Test1234!   │ Buscador         │
-- │ juan.electricista@test.com  │ Test1234!   │ Profesional      │
-- │ miguel.plomero@test.com     │ Test1234!   │ Profesional      │
-- │ pedro.carpintero@test.com   │ Test1234!   │ Profesional      │
-- │ luis.tecnico@test.com       │ Test1234!   │ Profesional      │
-- │ rosa.pintora@test.com       │ Test1234!   │ Profesional      │
-- └─────────────────────────────┴─────────────┴──────────────────┘
--
-- ============================================

-- ============================================
-- PASO 1: ACTUALIZAR DATOS DE USUARIOS BUSCADORES
-- ============================================

-- María Fernanda - Buscadora en La Paz
UPDATE public.users SET
  nombre_completo = 'María Fernanda Quispe',
  telefono = '71234567',
  ciudad = 'La Paz',
  rol = 'buscador',
  tipo_cuenta = 'gratuita',
  creditos = 50,
  verificado = true,
  perfil_completo = true
WHERE id = 'b28ab1f6-2414-4d51-9007-f810feec6159';

-- Carlos Mamani - Buscador en Santa Cruz
UPDATE public.users SET
  nombre_completo = 'Carlos Alberto Mamani',
  telefono = '72345678',
  ciudad = 'Santa Cruz',
  rol = 'buscador',
  tipo_cuenta = 'gratuita',
  creditos = 75,
  verificado = true,
  perfil_completo = true
WHERE id = '31737974-2c50-4a9d-ba08-c99ed0ddca49';

-- Ana Flores - Buscadora Premium en Cochabamba
UPDATE public.users SET
  nombre_completo = 'Ana Lucía Flores',
  telefono = '73456789',
  ciudad = 'Cochabamba',
  rol = 'buscador',
  tipo_cuenta = 'premium',
  creditos = 200,
  verificado = true,
  perfil_completo = true
WHERE id = '763363b6-82df-4a23-b12a-26cbfe359f57';

-- Roberto Choque - Buscador en El Alto
UPDATE public.users SET
  nombre_completo = 'Roberto Choque Condori',
  telefono = '74567890',
  ciudad = 'El Alto',
  rol = 'buscador',
  tipo_cuenta = 'gratuita',
  creditos = 35,
  verificado = false,
  perfil_completo = true
WHERE id = '70cf58f1-05ca-47b5-9384-386663a9b20b';

-- Patricia Vargas - Buscadora en Tarija
UPDATE public.users SET
  nombre_completo = 'Patricia Vargas Mendoza',
  telefono = '75678901',
  ciudad = 'Tarija',
  rol = 'buscador',
  tipo_cuenta = 'gratuita',
  creditos = 60,
  verificado = true,
  perfil_completo = true
WHERE id = 'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768';

-- ============================================
-- PASO 2: ACTUALIZAR DATOS DE PROFESIONALES
-- ============================================

-- Juan Carlos Pérez - Electricista en La Paz
UPDATE public.users SET
  nombre_completo = 'Juan Carlos Pérez',
  telefono = '76789012',
  ciudad = 'La Paz',
  rol = 'profesional',
  tipo_cuenta = 'premium',
  creditos = 150,
  verificado = true,
  perfil_completo = true
WHERE id = 'b3939605-d82b-4327-ba24-7fe4d6826b8b';

-- Miguel Ángel Rojas - Plomero en Santa Cruz
UPDATE public.users SET
  nombre_completo = 'Miguel Ángel Rojas',
  telefono = '77890123',
  ciudad = 'Santa Cruz',
  rol = 'profesional',
  tipo_cuenta = 'gratuita',
  creditos = 80,
  verificado = true,
  perfil_completo = true
WHERE id = '9b9ba512-d6db-412e-bf13-eff79a49e206';

-- Pedro Gutiérrez - Carpintero en Cochabamba
UPDATE public.users SET
  nombre_completo = 'Pedro Gutiérrez',
  telefono = '78901234',
  ciudad = 'Cochabamba',
  rol = 'profesional',
  tipo_cuenta = 'premium',
  creditos = 200,
  verificado = true,
  perfil_completo = true
WHERE id = '227e12df-6896-4cbf-a9a4-068987512bc2';

-- Luis Fernando Condori - Técnico en La Paz
UPDATE public.users SET
  nombre_completo = 'Luis Fernando Condori',
  telefono = '79012345',
  ciudad = 'La Paz',
  rol = 'profesional',
  tipo_cuenta = 'gratuita',
  creditos = 45,
  verificado = true,
  perfil_completo = true
WHERE id = 'd0e5595f-7880-4294-b7f5-a56313a41470';

-- Rosa María Aguilar - Pintora en Santa Cruz
UPDATE public.users SET
  nombre_completo = 'Rosa María Aguilar',
  telefono = '70123456',
  ciudad = 'Santa Cruz',
  rol = 'profesional',
  tipo_cuenta = 'gratuita',
  creditos = 65,
  verificado = true,
  perfil_completo = true
WHERE id = '1631b7cc-51ca-4d7b-ac56-a219e56d189c';

-- ============================================
-- PASO 3: CREAR PERFILES PROFESIONALES
-- ============================================

-- Eliminar perfiles existentes de estos usuarios (por si acaso)
DELETE FROM public.perfiles_profesionales WHERE user_id IN (
  'b3939605-d82b-4327-ba24-7fe4d6826b8b',
  '9b9ba512-d6db-412e-bf13-eff79a49e206',
  '227e12df-6896-4cbf-a9a4-068987512bc2',
  'd0e5595f-7880-4294-b7f5-a56313a41470',
  '1631b7cc-51ca-4d7b-ac56-a219e56d189c'
);

-- Juan Carlos - Electricista
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado
) VALUES (
  'b3939605-d82b-4327-ba24-7fe4d6826b8b',
  'Electricidad JC',
  'Electricista',
  'Electricista profesional con más de 10 años de experiencia. Instalaciones eléctricas residenciales y comerciales, reparaciones, mantenimiento y emergencias 24/7. Trabajo garantizado.',
  'La Paz',
  'Zona San Pedro, Calle Murillo #234',
  '76789012',
  '76789012',
  'juan.electricista@test.com',
  4.8, 25, 50, true, true, true, true
);

-- Miguel - Plomero
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado
) VALUES (
  '9b9ba512-d6db-412e-bf13-eff79a49e206',
  'Plomería Rojas',
  'Plomero',
  'Plomero certificado. Destapes, instalación de sanitarios, griferías, calentadores de agua. Atención rápida y precios justos. Más de 8 años de experiencia.',
  'Santa Cruz',
  'Av. Cañoto, Barrio Equipetrol',
  '77890123',
  '77890123',
  'miguel.plomero@test.com',
  4.5, 18, 35, true, true, true, false
);

-- Pedro - Carpintero
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado
) VALUES (
  '227e12df-6896-4cbf-a9a4-068987512bc2',
  'Muebles a Medida PG',
  'Carpintero',
  'Maestro carpintero especializado en muebles a medida. Closets, cocinas empotradas, muebles de TV, escritorios. Maderas de calidad y acabados finos. 15 años de experiencia.',
  'Cochabamba',
  'Zona Quillacollo, Av. Blanco Galindo',
  '78901234',
  '78901234',
  'pedro.carpintero@test.com',
  4.9, 42, 80, true, true, true, true
);

-- Luis - Técnico en Computadoras
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado
) VALUES (
  'd0e5595f-7880-4294-b7f5-a56313a41470',
  'TechSupport Bolivia',
  'Reparación de computadoras',
  'Técnico en computadoras. Reparación de laptops y PCs, formateo, instalación de programas, recuperación de datos, redes WiFi. Servicio a domicilio disponible.',
  'La Paz',
  'Zona Miraflores, Calle 16 de Julio',
  '79012345',
  '79012345',
  'luis.tecnico@test.com',
  4.6, 15, 28, true, true, true, false
);

-- Rosa - Pintora
INSERT INTO public.perfiles_profesionales (
  user_id, nombre_negocio, categoria, descripcion, ciudad,
  direccion, telefono_negocio, whatsapp, email_negocio,
  calificacion_promedio, total_resenas, total_trabajos,
  verificado, activo, visible_busqueda, destacado
) VALUES (
  '1631b7cc-51ca-4d7b-ac56-a219e56d189c',
  'Pinturas Rosa',
  'Pintor',
  'Pintora profesional. Pintura interior y exterior, estuco, texturado, decoración de interiores. Trabajo limpio y puntual. Presupuestos sin compromiso.',
  'Santa Cruz',
  'Plan 3000, UV 120',
  '70123456',
  '70123456',
  'rosa.pintora@test.com',
  4.7, 22, 40, true, true, true, false
);

-- ============================================
-- PASO 4: CREAR SOLICITUDES DE TRABAJO
-- ============================================

-- Limpiar solicitudes de prueba anteriores
DELETE FROM public.solicitudes_trabajo WHERE titulo LIKE '%test%' OR titulo LIKE '%prueba%';

-- Solicitud 1: María busca electricista
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones
) VALUES (
  'b28ab1f6-2414-4d51-9007-f810feec6159',
  'Necesito electricista para instalación completa',
  'Requiero un electricista para revisar toda la instalación eléctrica de mi casa. Hay algunos tomacorrientes que no funcionan y necesito agregar puntos de luz en el jardín. La casa tiene 3 pisos. Preferiblemente alguien con experiencia.',
  'Electricista',
  'La Paz',
  'Zona Sur, Calacoto',
  500, 1500, 'normal', true, 2
);

-- Solicitud 2: Carlos busca plomero urgente
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones
) VALUES (
  '31737974-2c50-4a9d-ba08-c99ed0ddca49',
  'URGENTE: Plomero para fuga de agua',
  'Tengo una fuga de agua en el baño principal. El agua está saliendo por debajo del inodoro y ya está mojando el piso. Necesito alguien que pueda venir HOY o mañana temprano como máximo.',
  'Plomero',
  'Santa Cruz',
  'Barrio Urbari',
  200, 800, 'urgente', true, 3
);

-- Solicitud 3: Ana busca carpintero para cocina
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones
) VALUES (
  '763363b6-82df-4a23-b12a-26cbfe359f57',
  'Muebles de cocina empotrados a medida',
  'Busco carpintero para hacer muebles de cocina empotrados. Ya tengo los diseños y medidas exactas. Material: melamina blanca con tiradores metálicos. Incluye muebles altos, bajos e isla central. Cocina de 12m2.',
  'Carpintero',
  'Cochabamba',
  'Zona Norte, Cala Cala',
  3000, 8000, 'normal', true, 1
);

-- Solicitud 4: Roberto necesita técnico para laptop
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones
) VALUES (
  '70cf58f1-05ca-47b5-9384-386663a9b20b',
  'Reparar laptop Dell que no enciende',
  'Mi laptop Dell Inspiron no enciende. Hace un mes funcionaba perfectamente pero ahora al presionar el botón de encendido no pasa absolutamente nada. No sé si es la batería, el cargador o algo interno. Necesito recuperar mis archivos.',
  'Reparación de computadoras',
  'El Alto',
  'Ciudad Satélite',
  100, 400, 'normal', true, 2
);

-- Solicitud 5: Patricia busca pintor
INSERT INTO public.solicitudes_trabajo (
  user_id, titulo, descripcion, categoria, ciudad, zona,
  presupuesto_minimo, presupuesto_maximo, urgencia, visible, total_postulaciones
) VALUES (
  'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768',
  'Pintar departamento completo de 80m2',
  'Necesito pintar mi departamento completo. Son 2 dormitorios, sala-comedor, cocina y 2 baños (aproximadamente 80m2). Quiero colores claros y modernos. Pueden sugerirme combinaciones. Incluye preparación de paredes.',
  'Pintor',
  'Tarija',
  'Zona Central',
  1200, 2500, 'normal', true, 1
);

-- ============================================
-- PASO 5: CREAR PREGUNTAS DEL FORO
-- ============================================

-- Limpiar preguntas anteriores de prueba
DELETE FROM public.foro_preguntas WHERE titulo LIKE '%test%';

-- Pregunta 1: María pregunta por electricista
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible
) VALUES (
  'b28ab1f6-2414-4d51-9007-f810feec6159',
  '¿Alguien conoce un buen electricista en Zona Sur de La Paz?',
  'Estoy buscando un electricista de confianza para un trabajo grande en mi casa. Necesito revisar toda la instalación y agregar algunos puntos de luz. ¿Alguien puede recomendarme uno que sea puntual, trabaje bien y cobre justo?',
  'Recomendaciones',
  false, 2, 45, true
);

-- Pregunta 2: Carlos pregunta sobre precios
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible
) VALUES (
  '31737974-2c50-4a9d-ba08-c99ed0ddca49',
  '¿Cuánto debería costar arreglar una fuga de agua del inodoro?',
  'Tengo una fuga en el baño debajo del inodoro y un plomero me está cobrando 500 Bs. ¿Es un precio justo o me están cobrando de más? La fuga parece ser del empaque o la base.',
  'Precios y Costos',
  true, 3, 120, true
);

-- Pregunta 3: Ana pregunta sobre materiales
INSERT INTO public.foro_preguntas (
  user_id, titulo, descripcion, categoria, resuelta, total_respuestas, total_vistas, visible
) VALUES (
  '763363b6-82df-4a23-b12a-26cbfe359f57',
  '¿Qué material es mejor para muebles de cocina: melamina, MDF o madera?',
  'Estoy por mandar a hacer mis muebles de cocina y no sé qué material elegir. He escuchado que la melamina es más económica, el MDF se puede pintar y la madera dura más. ¿Cuál recomiendan para una cocina? ¿Cuál resiste mejor la humedad?',
  'Consejos',
  false, 2, 89, true
);

-- ============================================
-- PASO 6: CREAR RESPUESTAS DEL FORO
-- ============================================

-- Obtener IDs de las preguntas recién creadas
DO $$
DECLARE
  pregunta1_id UUID;
  pregunta2_id UUID;
  pregunta3_id UUID;
BEGIN
  -- Obtener IDs
  SELECT id INTO pregunta1_id FROM public.foro_preguntas
  WHERE user_id = 'b28ab1f6-2414-4d51-9007-f810feec6159' LIMIT 1;

  SELECT id INTO pregunta2_id FROM public.foro_preguntas
  WHERE user_id = '31737974-2c50-4a9d-ba08-c99ed0ddca49' LIMIT 1;

  SELECT id INTO pregunta3_id FROM public.foro_preguntas
  WHERE user_id = '763363b6-82df-4a23-b12a-26cbfe359f57' LIMIT 1;

  -- Respuestas a pregunta 1 (electricista)
  IF pregunta1_id IS NOT NULL THEN
    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta1_id,
      'b3939605-d82b-4327-ba24-7fe4d6826b8b', -- Juan electricista
      '¡Hola! Yo trabajo en Zona Sur y tengo más de 10 años de experiencia en instalaciones eléctricas. Puedo hacer una visita para evaluar el trabajo sin costo. Contáctame por la app y coordinamos.',
      false, 8
    );

    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta1_id,
      '31737974-2c50-4a9d-ba08-c99ed0ddca49', -- Carlos
      'Yo trabajé con Juan Carlos (Electricidad JC) y quedé muy satisfecho. Es puntual, explica todo lo que hace y deja todo limpio. Sus precios son razonables. Lo recomiendo totalmente.',
      false, 15
    );
  END IF;

  -- Respuestas a pregunta 2 (precio plomero)
  IF pregunta2_id IS NOT NULL THEN
    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta2_id,
      '9b9ba512-d6db-412e-bf13-eff79a49e206', -- Miguel plomero
      'El precio puede variar bastante dependiendo del problema real. Si es solo cambiar el empaque del inodoro, debería costar entre 100-200 Bs. Pero si hay que cambiar el flange o hay problemas en la tubería, puede llegar a 400-600 Bs. Te recomiendo pedir un diagnóstico detallado antes de aceptar.',
      true, 28
    );

    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta2_id,
      'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768', -- Patricia
      'A mí me cobraron 350 Bs por un problema similar el mes pasado. Creo que 500 Bs está un poco caro, pero depende de qué incluya el trabajo.',
      false, 12
    );

    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta2_id,
      '763363b6-82df-4a23-b12a-26cbfe359f57', -- Ana
      'Siempre pide que te muestren qué piezas van a cambiar y cuánto cuestan. Así puedes verificar si el precio es justo.',
      false, 9
    );
  END IF;

  -- Respuestas a pregunta 3 (materiales cocina)
  IF pregunta3_id IS NOT NULL THEN
    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta3_id,
      '227e12df-6896-4cbf-a9a4-068987512bc2', -- Pedro carpintero
      'Como carpintero con 15 años de experiencia, te recomiendo melamina de buena calidad (18mm mínimo) para cocinas. Es fácil de limpiar, resistente a la humedad y más económica. El MDF es bueno pero se hincha con el agua si no está bien sellado. La madera natural es hermosa pero requiere más mantenimiento y es más cara. Para cocinas, la melamina es la mejor opción calidad-precio.',
      false, 22
    );

    INSERT INTO public.foro_respuestas (pregunta_id, user_id, contenido, es_mejor_respuesta, total_votos)
    VALUES (
      pregunta3_id,
      '70cf58f1-05ca-47b5-9384-386663a9b20b', -- Roberto
      'Yo hice mi cocina con melamina hace 3 años y sigue como nueva. Solo hay que tener cuidado con los bordes cerca del agua.',
      false, 8
    );
  END IF;

  -- Actualizar mejor_respuesta_id en pregunta 2
  UPDATE public.foro_preguntas
  SET mejor_respuesta_id = (
    SELECT id FROM public.foro_respuestas
    WHERE pregunta_id = pregunta2_id AND es_mejor_respuesta = true
    LIMIT 1
  )
  WHERE id = pregunta2_id;

END $$;

-- ============================================
-- PASO 7: CREAR RESEÑAS
-- ============================================

-- Obtener IDs de perfiles profesionales
DO $$
DECLARE
  perfil_juan UUID;
  perfil_miguel UUID;
  perfil_pedro UUID;
  perfil_luis UUID;
  perfil_rosa UUID;
BEGIN
  SELECT id INTO perfil_juan FROM public.perfiles_profesionales WHERE user_id = 'b3939605-d82b-4327-ba24-7fe4d6826b8b';
  SELECT id INTO perfil_miguel FROM public.perfiles_profesionales WHERE user_id = '9b9ba512-d6db-412e-bf13-eff79a49e206';
  SELECT id INTO perfil_pedro FROM public.perfiles_profesionales WHERE user_id = '227e12df-6896-4cbf-a9a4-068987512bc2';
  SELECT id INTO perfil_luis FROM public.perfiles_profesionales WHERE user_id = 'd0e5595f-7880-4294-b7f5-a56313a41470';
  SELECT id INTO perfil_rosa FROM public.perfiles_profesionales WHERE user_id = '1631b7cc-51ca-4d7b-ac56-a219e56d189c';

  -- Reseñas para Juan (Electricista)
  IF perfil_juan IS NOT NULL THEN
    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_juan, 'b28ab1f6-2414-4d51-9007-f810feec6159', 5,
      '¡Excelente trabajo! Juan Carlos llegó puntual, revisó toda la instalación y solucionó todos los problemas. Muy profesional, limpio y explicó todo lo que hizo. Lo recomiendo 100%.', true);

    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_juan, '31737974-2c50-4a9d-ba08-c99ed0ddca49', 4,
      'Buen trabajo en general. Tardó un poco más de lo esperado pero el resultado final quedó muy bien. Precios razonables.', true);
  END IF;

  -- Reseñas para Miguel (Plomero)
  IF perfil_miguel IS NOT NULL THEN
    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_miguel, '763363b6-82df-4a23-b12a-26cbfe359f57', 5,
      'Miguel es muy profesional. Arregló la fuga rápidamente y me explicó cómo prevenir el problema en el futuro. Precio justo y trabajo garantizado.', true);

    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_miguel, 'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768', 5,
      'Muy recomendado. Vino el mismo día que lo llamé y solucionó el problema en menos de una hora. Excelente servicio.', true);
  END IF;

  -- Reseñas para Pedro (Carpintero)
  IF perfil_pedro IS NOT NULL THEN
    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_pedro, '70cf58f1-05ca-47b5-9384-386663a9b20b', 5,
      '¡Los muebles quedaron espectaculares! Pedro es un verdadero artista. Cumplió con los tiempos y el presupuesto acordado. La calidad del acabado es impresionante.', true);

    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_pedro, 'b28ab1f6-2414-4d51-9007-f810feec6159', 5,
      'Hizo el closet de mi dormitorio y quedó perfecto. Muy detallista y usa materiales de buena calidad. Vale cada boliviano.', true);
  END IF;

  -- Reseñas para Luis (Técnico)
  IF perfil_luis IS NOT NULL THEN
    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_luis, 'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768', 4,
      'Luis arregló mi laptop y ahora funciona perfecta. Tardó 3 días en tenerla lista, pero recuperó todos mis archivos. El resultado valió la pena.', true);

    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_luis, '763363b6-82df-4a23-b12a-26cbfe359f57', 5,
      'Excelente técnico. Configuró toda la red WiFi de mi oficina y ahora funciona mucho mejor. Muy paciente explicando las cosas.', true);
  END IF;

  -- Reseñas para Rosa (Pintora)
  IF perfil_rosa IS NOT NULL THEN
    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_rosa, '31737974-2c50-4a9d-ba08-c99ed0ddca49', 5,
      'Rosa hizo un trabajo increíble pintando mi sala. Los colores que me sugirió quedaron perfectos. Muy limpia y cuidadosa con los muebles.', true);

    INSERT INTO public.resenas (profesional_id, usuario_id, calificacion, contenido, visible)
    VALUES (perfil_rosa, '70cf58f1-05ca-47b5-9384-386663a9b20b', 4,
      'Buen trabajo de pintura. El estuco quedó muy bien. Solo un pequeño detalle en una esquina que corrigió sin problema.', true);
  END IF;

END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================
SELECT '✅ SEEDERS EJECUTADOS CORRECTAMENTE' as resultado;
SELECT '👥 Total usuarios: ' || COUNT(*) as info FROM public.users WHERE email LIKE '%@test.com';
SELECT '🔧 Total profesionales: ' || COUNT(*) as info FROM public.perfiles_profesionales;
SELECT '📋 Total solicitudes: ' || COUNT(*) as info FROM public.solicitudes_trabajo;
SELECT '❓ Total preguntas foro: ' || COUNT(*) as info FROM public.foro_preguntas;
SELECT '💬 Total respuestas foro: ' || COUNT(*) as info FROM public.foro_respuestas;
SELECT '⭐ Total reseñas: ' || COUNT(*) as info FROM public.resenas;
