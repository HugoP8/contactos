-- ============================================
-- SEEDERS CORREGIDOS - 22 ENERO 2026
-- Basado en la estructura REAL de las tablas
-- ============================================

-- ============================================
-- PASO 1: ACTUALIZAR USUARIOS BUSCADORES
-- ============================================

-- María Fernanda - Buscadora en La Paz
UPDATE public.users SET
    nombre_completo = 'María Fernanda Quispe',
    telefono = '71234567',
    whatsapp = '59171234567',
    ciudad = 'La Paz',
    zona = 'Sopocachi',
    rol = 'buscador',
    tipo_cuenta = 'gratuita',
    creditos = 50,
    verificado = true,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = 'b28ab1f6-2414-4d51-9007-f810feec6159';

-- Carlos Mamani - Buscador en Santa Cruz
UPDATE public.users SET
    nombre_completo = 'Carlos Alberto Mamani',
    telefono = '72345678',
    whatsapp = '59172345678',
    ciudad = 'Santa Cruz',
    zona = 'Equipetrol',
    rol = 'buscador',
    tipo_cuenta = 'gratuita',
    creditos = 75,
    verificado = true,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = '31737974-2c50-4a9d-ba08-c99ed0ddca49';

-- Ana Flores - Buscadora Premium en Cochabamba
UPDATE public.users SET
    nombre_completo = 'Ana Lucía Flores',
    telefono = '73456789',
    whatsapp = '59173456789',
    ciudad = 'Cochabamba',
    zona = 'Zona Norte',
    rol = 'buscador',
    tipo_cuenta = 'premium',
    creditos = 200,
    verificado = true,
    perfil_completo = true,
    activo = true,
    membresia_activa = true,
    updated_at = NOW()
WHERE id = '763363b6-82df-4a23-b12a-26cbfe359f57';

-- Roberto Choque - Buscador en El Alto
UPDATE public.users SET
    nombre_completo = 'Roberto Choque Condori',
    telefono = '74567890',
    whatsapp = '59174567890',
    ciudad = 'El Alto',
    zona = 'Ciudad Satélite',
    rol = 'buscador',
    tipo_cuenta = 'gratuita',
    creditos = 35,
    verificado = false,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = '70cf58f1-05ca-47b5-9384-386663a9b20b';

-- Patricia Vargas - Buscadora en Tarija
UPDATE public.users SET
    nombre_completo = 'Patricia Vargas Mendoza',
    telefono = '75678901',
    whatsapp = '59175678901',
    ciudad = 'Tarija',
    zona = 'Centro',
    rol = 'buscador',
    tipo_cuenta = 'gratuita',
    creditos = 60,
    verificado = true,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = 'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768';

-- ============================================
-- PASO 2: ACTUALIZAR USUARIOS PROFESIONALES
-- ============================================

-- Juan Carlos - Electricista en La Paz
UPDATE public.users SET
    nombre_completo = 'Juan Carlos Pérez',
    telefono = '76789012',
    whatsapp = '59176789012',
    ciudad = 'La Paz',
    zona = 'Miraflores',
    rol = 'profesional',
    tipo_cuenta = 'premium',
    creditos = 150,
    verificado = true,
    perfil_completo = true,
    activo = true,
    membresia_activa = true,
    updated_at = NOW()
WHERE id = 'b3939605-d82b-4327-ba24-7fe4d6826b8b';

-- Miguel - Plomero en Santa Cruz
UPDATE public.users SET
    nombre_completo = 'Miguel Ángel Torres',
    telefono = '77890123',
    whatsapp = '59177890123',
    ciudad = 'Santa Cruz',
    zona = 'Plan 3000',
    rol = 'profesional',
    tipo_cuenta = 'gratuita',
    creditos = 80,
    verificado = true,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = '9b9ba512-d6db-412e-bf13-eff79a49e206';

-- Pedro - Carpintero en Cochabamba
UPDATE public.users SET
    nombre_completo = 'Pedro Gonzales Ríos',
    telefono = '78901234',
    whatsapp = '59178901234',
    ciudad = 'Cochabamba',
    zona = 'Quillacollo',
    rol = 'profesional',
    tipo_cuenta = 'gratuita',
    creditos = 45,
    verificado = true,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = '227e12df-6896-4cbf-a9a4-068987512bc2';

-- Luis - Técnico en computadoras en El Alto
UPDATE public.users SET
    nombre_completo = 'Luis Fernando Mamani',
    telefono = '79012345',
    whatsapp = '59179012345',
    ciudad = 'El Alto',
    zona = 'Villa Adela',
    rol = 'profesional',
    tipo_cuenta = 'gratuita',
    creditos = 90,
    verificado = false,
    perfil_completo = true,
    activo = true,
    updated_at = NOW()
WHERE id = 'd0e5595f-7880-4294-b7f5-a56313a41470';

-- Rosa - Pintora en Sucre
UPDATE public.users SET
    nombre_completo = 'Rosa María Condori',
    telefono = '70123456',
    whatsapp = '59170123456',
    ciudad = 'Sucre',
    zona = 'Centro Histórico',
    rol = 'profesional',
    tipo_cuenta = 'premium',
    creditos = 120,
    verificado = true,
    perfil_completo = true,
    activo = true,
    membresia_activa = true,
    updated_at = NOW()
WHERE id = '1631b7cc-51ca-4d7b-ac56-a219e56d189c';

-- ============================================
-- PASO 3: ELIMINAR PERFILES PROFESIONALES EXISTENTES DE ESTOS USUARIOS
-- ============================================

DELETE FROM public.perfiles_profesionales
WHERE user_id IN (
    'b3939605-d82b-4327-ba24-7fe4d6826b8b',
    '9b9ba512-d6db-412e-bf13-eff79a49e206',
    '227e12df-6896-4cbf-a9a4-068987512bc2',
    'd0e5595f-7880-4294-b7f5-a56313a41470',
    '1631b7cc-51ca-4d7b-ac56-a219e56d189c'
);

-- ============================================
-- PASO 4: CREAR PERFILES PROFESIONALES
-- ============================================

-- Juan Carlos - Electricista
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, eslogan,
    categoria_principal, subcategorias, servicios_ofrecidos,
    ciudad, zonas_cobertura, telefono, whatsapp, email,
    años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, metodos_pago,
    disponible_ahora, verificado, verificado_identidad,
    calificacion_promedio, total_resenas, total_vistas, total_contactos,
    activo, visible_busqueda, destacado, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'b3939605-d82b-4327-ba24-7fe4d6826b8b',
    'Electricista JC',
    'Electricista profesional con más de 10 años de experiencia. Instalaciones eléctricas, reparaciones, tableros, iluminación LED y más. Trabajo garantizado.',
    'Tu solución eléctrica de confianza',
    'Electricidad',
    ARRAY['Instalaciones eléctricas', 'Reparaciones', 'Iluminación'],
    ARRAY['Instalación de tomacorrientes', 'Reparación de cortocircuitos', 'Instalación de tableros', 'Iluminación LED', 'Cableado estructurado'],
    'La Paz',
    ARRAY['Sopocachi', 'Miraflores', 'San Miguel', 'Calacoto', 'Centro'],
    '76789012',
    '59176789012',
    'juan.electricista@test.com',
    10,
    50,
    500,
    true,
    true,
    ARRAY['Efectivo', 'Transferencia', 'QR'],
    true,
    true,
    true,
    4.8,
    25,
    450,
    120,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- Miguel - Plomero
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, eslogan,
    categoria_principal, subcategorias, servicios_ofrecidos,
    ciudad, zonas_cobertura, telefono, whatsapp, email,
    años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, metodos_pago,
    disponible_ahora, verificado, verificado_identidad,
    calificacion_promedio, total_resenas, total_vistas, total_contactos,
    activo, visible_busqueda, destacado, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    '9b9ba512-d6db-412e-bf13-eff79a49e206',
    'Plomería Express Miguel',
    'Plomero certificado especializado en instalaciones sanitarias, destape de cañerías, instalación de termas y griferías. Atención rápida y precios justos.',
    'Soluciones de plomería al instante',
    'Plomería',
    ARRAY['Instalaciones sanitarias', 'Destape', 'Termas'],
    ARRAY['Destape de cañerías', 'Instalación de termas', 'Reparación de fugas', 'Instalación de grifería', 'Mantenimiento de tanques'],
    'Santa Cruz',
    ARRAY['Plan 3000', 'Equipetrol', 'Centro', 'Urbarí', 'Villa 1ro de Mayo'],
    '77890123',
    '59177890123',
    'miguel.plomero@test.com',
    8,
    40,
    400,
    false,
    true,
    ARRAY['Efectivo', 'QR'],
    true,
    true,
    false,
    4.5,
    18,
    320,
    85,
    true,
    true,
    false,
    NOW(),
    NOW()
);

-- Pedro - Carpintero
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, eslogan,
    categoria_principal, subcategorias, servicios_ofrecidos,
    ciudad, zonas_cobertura, telefono, whatsapp, email,
    años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, metodos_pago,
    disponible_ahora, verificado, verificado_identidad,
    calificacion_promedio, total_resenas, total_vistas, total_contactos,
    activo, visible_busqueda, destacado, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    '227e12df-6896-4cbf-a9a4-068987512bc2',
    'Carpintería Gonzales',
    'Carpintero especializado en muebles a medida, closets, cocinas integrales y restauración de muebles antiguos. Trabajos en madera de primera calidad.',
    'Muebles con dedicación y calidad',
    'Carpintería',
    ARRAY['Muebles a medida', 'Closets', 'Cocinas integrales'],
    ARRAY['Muebles a medida', 'Closets empotrados', 'Cocinas integrales', 'Restauración de muebles', 'Puertas y ventanas'],
    'Cochabamba',
    ARRAY['Quillacollo', 'Centro', 'Zona Norte', 'Tiquipaya', 'Sacaba'],
    '78901234',
    '59178901234',
    'pedro.carpintero@test.com',
    15,
    100,
    3000,
    true,
    true,
    ARRAY['Efectivo', 'Transferencia', 'QR', '50% adelanto'],
    false,
    true,
    true,
    4.9,
    32,
    580,
    145,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- Luis - Técnico en computadoras
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, eslogan,
    categoria_principal, subcategorias, servicios_ofrecidos,
    ciudad, zonas_cobertura, telefono, whatsapp, email,
    años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, metodos_pago,
    disponible_ahora, verificado, verificado_identidad,
    calificacion_promedio, total_resenas, total_vistas, total_contactos,
    activo, visible_busqueda, destacado, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'd0e5595f-7880-4294-b7f5-a56313a41470',
    'TechSupport Luis',
    'Técnico en computadoras y redes. Reparación de PCs y laptops, instalación de software, recuperación de datos, redes WiFi y soporte técnico a domicilio.',
    'Tu computadora en buenas manos',
    'Tecnología',
    ARRAY['Reparación de computadoras', 'Redes', 'Software'],
    ARRAY['Formateo e instalación de Windows', 'Reparación de hardware', 'Recuperación de datos', 'Instalación de redes WiFi', 'Limpieza de virus'],
    'El Alto',
    ARRAY['Villa Adela', 'Ciudad Satélite', 'Río Seco', '16 de Julio', 'Senkata'],
    '79012345',
    '59179012345',
    'luis.tecnico@test.com',
    5,
    30,
    300,
    false,
    true,
    ARRAY['Efectivo', 'QR'],
    true,
    false,
    false,
    4.3,
    12,
    210,
    55,
    true,
    true,
    false,
    NOW(),
    NOW()
);

-- Rosa - Pintora
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, eslogan,
    categoria_principal, subcategorias, servicios_ofrecidos,
    ciudad, zonas_cobertura, telefono, whatsapp, email,
    años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, metodos_pago,
    disponible_ahora, verificado, verificado_identidad,
    calificacion_promedio, total_resenas, total_vistas, total_contactos,
    activo, visible_busqueda, destacado, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    '1631b7cc-51ca-4d7b-ac56-a219e56d189c',
    'Pinturas Rosa María',
    'Pintora profesional especializada en interiores y exteriores. Pintura decorativa, texturas, impermeabilización y acabados de primera. Más de 12 años embelleciendo hogares.',
    'Dale color a tu vida',
    'Pintura',
    ARRAY['Pintura interior', 'Pintura exterior', 'Decorativa'],
    ARRAY['Pintura de interiores', 'Pintura de exteriores', 'Texturas decorativas', 'Impermeabilización', 'Pintura epóxica'],
    'Sucre',
    ARRAY['Centro Histórico', 'Zona Norte', 'Villa Armonía', 'Tucsupaya', 'Libertadores'],
    '70123456',
    '59170123456',
    'rosa.pintora@test.com',
    12,
    80,
    800,
    true,
    true,
    ARRAY['Efectivo', 'Transferencia', 'QR'],
    true,
    true,
    true,
    4.7,
    28,
    390,
    98,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- ============================================
-- PASO 5: ACTUALIZAR CONTADORES DE RESPUESTAS EN PREGUNTAS
-- ============================================

UPDATE public.foro_preguntas fp
SET total_respuestas = (
    SELECT COUNT(*) FROM public.foro_respuestas fr WHERE fr.pregunta_id = fp.id
);

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ SEEDERS CORREGIDOS - EJECUTADO CORRECTAMENTE' as resultado;
