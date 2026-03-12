-- ============================================
-- MIGRACIÓN 019: SEEDERS CON USUARIOS REALES
-- Fecha: 2025 - VERSIÓN FINAL CORREGIDA
-- ============================================
-- USUARIOS REALES DE SUPABASE AUTH
-- Contraseña de usuarios @test.com: Test1234!
-- ============================================

-- ============================================
-- 1. LIMPIAR DATOS ANTERIORES
-- ============================================
DELETE FROM public.foro_respuestas;
DELETE FROM public.foro_preguntas;
DELETE FROM public.postulaciones;
DELETE FROM public.solicitudes_trabajo;
DELETE FROM public.resenas;
DELETE FROM public.mis_contactos;
DELETE FROM public.perfiles_profesionales;
DELETE FROM public.cajeros;

-- ============================================
-- 2. CONFIGURAR USUARIOS CON SUS ROLES
-- ============================================

-- ADMIN: h.st4rk.8@gmail.com
UPDATE public.users SET
    rol = 'admin',
    nombre_completo = 'Hugo Admin',
    tipo_cuenta = 'premium',
    creditos = 9999,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'Centro',
    telefono = '70000001',
    whatsapp = '59170000001',
    updated_at = NOW()
WHERE id = '8f07dcb8-2cd4-4157-a8ba-fe7198137810';

-- BUSCADOR 1: maria.fernanda@test.com
UPDATE public.users SET
    rol = 'buscador',
    nombre_completo = 'María Fernanda López',
    tipo_cuenta = 'gratuita',
    creditos = 50,
    verificado = TRUE,
    perfil_completo = TRUE,
    ciudad = 'La Paz',
    zona = 'Sopocachi',
    telefono = '71111111',
    whatsapp = '59171111111',
    updated_at = NOW()
WHERE id = 'b28ab1f6-2414-4d51-9007-f810feec6159';

-- BUSCADOR 2: patricia.vargas@test.com
UPDATE public.users SET
    rol = 'buscador',
    nombre_completo = 'Patricia Vargas Mendoza',
    tipo_cuenta = 'basica',
    creditos = 100,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'Santa Cruz',
    zona = 'Equipetrol',
    telefono = '72222222',
    whatsapp = '59172222222',
    updated_at = NOW()
WHERE id = 'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768';

-- BUSCADOR 3: ana.flores@test.com
UPDATE public.users SET
    rol = 'buscador',
    nombre_completo = 'Ana Flores Quispe',
    tipo_cuenta = 'gratuita',
    creditos = 30,
    verificado = TRUE,
    perfil_completo = TRUE,
    ciudad = 'Cochabamba',
    zona = 'Norte',
    telefono = '73333333',
    whatsapp = '59173333333',
    updated_at = NOW()
WHERE id = '763363b6-82df-4a23-b12a-26cbfe359f57';

-- PROFESIONAL: juan.electricista@test.com
UPDATE public.users SET
    rol = 'profesional',
    nombre_completo = 'Juan Pérez',
    tipo_cuenta = 'basica',
    creditos = 150,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'Miraflores',
    telefono = '74444444',
    whatsapp = '59174444444',
    updated_at = NOW()
WHERE id = 'b3939605-d82b-4327-ba24-7fe4d6826b8b';

-- PROFESIONAL: pedro.carpintero@test.com
UPDATE public.users SET
    rol = 'profesional',
    nombre_completo = 'Pedro Gutiérrez',
    tipo_cuenta = 'premium',
    creditos = 200,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'San Miguel',
    telefono = '75555555',
    whatsapp = '59175555555',
    updated_at = NOW()
WHERE id = '227e12df-6896-4cbf-a9a4-068987512bc2';

-- PROFESIONAL: miguel.plomero@test.com
UPDATE public.users SET
    rol = 'profesional',
    nombre_completo = 'Miguel Condori',
    tipo_cuenta = 'basica',
    creditos = 120,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'Centro',
    telefono = '76666666',
    whatsapp = '59176666666',
    updated_at = NOW()
WHERE id = '9b9ba512-d6db-412e-bf13-eff79a49e206';

-- PROFESIONAL: rosa.pintora@test.com
UPDATE public.users SET
    rol = 'profesional',
    nombre_completo = 'Rosa Mamani',
    tipo_cuenta = 'gratuita',
    creditos = 80,
    verificado = TRUE,
    perfil_completo = TRUE,
    ciudad = 'Santa Cruz',
    zona = 'Centro',
    telefono = '77777777',
    whatsapp = '59177777777',
    updated_at = NOW()
WHERE id = '1631b7cc-51ca-4d7b-ac56-a219e56d189c';

-- PROFESIONAL: luis.tecnico@test.com
UPDATE public.users SET
    rol = 'profesional',
    nombre_completo = 'Luis Fernández',
    tipo_cuenta = 'basica',
    creditos = 90,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'Cochabamba',
    zona = 'Centro',
    telefono = '78888888',
    whatsapp = '59178888888',
    updated_at = NOW()
WHERE id = 'd0e5595f-7880-4294-b7f5-a56313a41470';

-- DUAL: roberto.choque@test.com
UPDATE public.users SET
    rol = 'dual',
    nombre_completo = 'Roberto Choque',
    tipo_cuenta = 'premium',
    creditos = 250,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'Calacoto',
    telefono = '79999999',
    whatsapp = '59179999999',
    updated_at = NOW()
WHERE id = '70cf58f1-05ca-47b5-9384-386663a9b20b';

-- DUAL: carlos.mamani@test.com
UPDATE public.users SET
    rol = 'dual',
    nombre_completo = 'Carlos Mamani',
    tipo_cuenta = 'basica',
    creditos = 180,
    verificado = TRUE,
    perfil_completo = TRUE,
    membresia_activa = TRUE,
    ciudad = 'La Paz',
    zona = 'Sopocachi',
    telefono = '70101010',
    whatsapp = '59170101010',
    updated_at = NOW()
WHERE id = '31737974-2c50-4a9d-ba08-c99ed0ddca49';

-- ============================================
-- 3. PERFILES PROFESIONALES
-- ============================================

-- Electricista - Juan
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    'b3939605-d82b-4327-ba24-7fe4d6826b8b',
    'Juan Electricista Certificado',
    'Técnico electricista con más de 8 años de experiencia. Instalaciones eléctricas residenciales e industriales. Reparación de cortocircuitos, instalación de tableros, cableado estructurado. Atención de emergencias 24/7. Trabajo garantizado.',
    'Electricista',
    ARRAY['Instalaciones', 'Reparaciones'],
    ARRAY['Instalación eléctrica', 'Reparación de cortocircuitos', 'Tableros eléctricos', 'Cableado estructurado'],
    'La Paz',
    ARRAY['Miraflores', 'Sopocachi', 'Centro', 'San Miguel', 'Calacoto'],
    '74444444',
    '59174444444',
    8,
    100, 500,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    4.5, 0, 0, 0
);

-- Carpintero - Pedro
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    '227e12df-6896-4cbf-a9a4-068987512bc2',
    'Pedro Carpintería Fina',
    'Maestro carpintero especializado en muebles a medida, closets, cocinas empotradas y restauración de muebles antiguos. Trabajos en madera de alta calidad. 15 años de experiencia. Visita a domicilio sin costo.',
    'Carpintero',
    ARRAY['Muebles', 'Closets', 'Cocinas'],
    ARRAY['Muebles a medida', 'Closets empotrados', 'Cocinas integrales', 'Restauración'],
    'La Paz',
    ARRAY['San Miguel', 'Calacoto', 'Achumani', 'Irpavi', 'Centro'],
    '75555555',
    '59175555555',
    15,
    200, 3000,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    4.8, 0, 0, 0
);

-- Plomero - Miguel
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    '9b9ba512-d6db-412e-bf13-eff79a49e206',
    'Miguel Plomería Express',
    'Plomero profesional. Reparación de fugas, destape de cañerías, instalación de sanitarios, termas y tanques. Servicio rápido y garantizado. Atención inmediata en toda La Paz.',
    'Plomero',
    ARRAY['Reparaciones', 'Instalaciones'],
    ARRAY['Reparación de fugas', 'Destape de cañerías', 'Instalación sanitarios', 'Termas'],
    'La Paz',
    ARRAY['Centro', 'Miraflores', 'Sopocachi', 'Villa Fátima'],
    '76666666',
    '59176666666',
    10,
    50, 400,
    FALSE, TRUE, TRUE, TRUE, FALSE, TRUE,
    4.3, 0, 0, 0
);

-- Pintora - Rosa
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    '1631b7cc-51ca-4d7b-ac56-a219e56d189c',
    'Rosa Pintura Decorativa',
    'Pintora profesional con especialidad en acabados decorativos. Pintura interior y exterior, texturizados, esténcil, murales. Trabajos limpios y puntuales.',
    'Pintor',
    ARRAY['Interior', 'Exterior', 'Decorativo'],
    ARRAY['Pintura interior', 'Pintura exterior', 'Texturizados', 'Murales'],
    'Santa Cruz',
    ARRAY['Centro', 'Equipetrol', 'Plan 3000', 'Urbarí'],
    '77777777',
    '59177777777',
    6,
    80, 600,
    FALSE, TRUE, TRUE, TRUE, FALSE, TRUE,
    4.2, 0, 0, 0
);

-- Técnico - Luis
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    'd0e5595f-7880-4294-b7f5-a56313a41470',
    'Luis Soporte Técnico PC',
    'Técnico en computación. Reparación de computadoras, laptops, formateo, recuperación de datos, instalación de redes. Servicio a domicilio. Diagnóstico gratis.',
    'Tecnología',
    ARRAY['Computadoras', 'Laptops', 'Redes'],
    ARRAY['Reparación PC', 'Formateo', 'Recuperación datos', 'Redes WiFi'],
    'Cochabamba',
    ARRAY['Centro', 'Norte', 'Cala Cala', 'Queru Queru'],
    '78888888',
    '59178888888',
    5,
    50, 300,
    TRUE, TRUE, TRUE, TRUE, FALSE, TRUE,
    4.0, 0, 0, 0
);

-- Limpieza - Roberto (DUAL)
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    '70cf58f1-05ca-47b5-9384-386663a9b20b',
    'Roberto Limpieza Profesional',
    'Servicio de limpieza profunda para hogares y oficinas. Limpieza post-construcción, alfombras, muebles. Personal capacitado. Equipos profesionales.',
    'Limpieza',
    ARRAY['Hogares', 'Oficinas', 'Post-construcción'],
    ARRAY['Limpieza profunda', 'Post-construcción', 'Alfombras', 'Muebles'],
    'La Paz',
    ARRAY['Calacoto', 'San Miguel', 'Achumani', 'Irpavi', 'Obrajes'],
    '79999999',
    '59179999999',
    7,
    150, 800,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    4.7, 0, 0, 0
);

-- Gasista - Carlos (DUAL)
INSERT INTO public.perfiles_profesionales (
    id, user_id, nombre_comercial, descripcion, categoria_principal,
    subcategorias, servicios_ofrecidos, ciudad, zonas_cobertura,
    telefono, whatsapp, años_experiencia, rango_precio_desde, rango_precio_hasta,
    emite_factura, ofrece_garantia, activo, verificado, destacado, visible_busqueda,
    calificacion_promedio, total_resenas, total_vistas, total_contactos
) VALUES (
    gen_random_uuid(),
    '31737974-2c50-4a9d-ba08-c99ed0ddca49',
    'Carlos Instalaciones de Gas',
    'Gasista certificado por YPFB. Instalación de redes de gas domiciliario, mantenimiento de calderos, revisión de fugas. Certificados de conformidad.',
    'Gasista',
    ARRAY['Instalaciones', 'Mantenimiento', 'Certificaciones'],
    ARRAY['Instalación gas', 'Mantenimiento calderos', 'Revisión fugas', 'Certificados YPFB'],
    'La Paz',
    ARRAY['Sopocachi', 'Miraflores', 'Centro', 'San Pedro'],
    '70101010',
    '59170101010',
    12,
    200, 1500,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    4.6, 0, 0, 0
);

-- ============================================
-- 4. SOLICITUDES DE TRABAJO
-- ============================================

-- Solicitud 1: María busca plomero (URGENTE)
INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado, visible
) VALUES (
    gen_random_uuid(),
    'b28ab1f6-2414-4d51-9007-f810feec6159',
    'URGENTE: Fuga de agua en baño',
    'Tengo una fuga de agua debajo del lavamanos del baño principal. El agua está goteando constantemente y necesito que alguien venga lo antes posible.',
    'Plomero',
    'La Paz',
    'Sopocachi',
    100, 250,
    'urgente',
    'activa',
    TRUE
);

-- Solicitud 2: Patricia busca electricista
INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado, visible
) VALUES (
    gen_random_uuid(),
    'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768',
    'Instalación de luminarias LED en departamento',
    'Necesito cambiar todas las luminarias de mi departamento a LED. Son aproximadamente 8 puntos de luz. También quiero agregar 2 tomacorrientes adicionales.',
    'Electricista',
    'Santa Cruz',
    'Equipetrol',
    300, 500,
    'normal',
    'activa',
    TRUE
);

-- Solicitud 3: Ana busca pintor
INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado, visible
) VALUES (
    gen_random_uuid(),
    '763363b6-82df-4a23-b12a-26cbfe359f57',
    'Pintar casa de 2 plantas',
    'Necesito pintar el interior de mi casa. Son 2 plantas, aproximadamente 180 m2. Quiero colores claros, el material lo proporciono yo.',
    'Pintor',
    'Cochabamba',
    'Norte',
    800, 1200,
    'normal',
    'activa',
    TRUE
);

-- Solicitud 4: Roberto busca carpintero
INSERT INTO public.solicitudes_trabajo (
    id, user_id, titulo, descripcion, categoria, ciudad, zona,
    presupuesto_minimo, presupuesto_maximo, urgencia, estado, visible
) VALUES (
    gen_random_uuid(),
    '70cf58f1-05ca-47b5-9384-386663a9b20b',
    'Mueble de cocina a medida',
    'Busco carpintero para hacer un mueble bajo mesón de cocina. Medidas: 2.5m x 0.6m. Material: melamina blanca. Debe incluir cajones y puertas.',
    'Carpintero',
    'La Paz',
    'Calacoto',
    1500, 2500,
    'normal',
    'activa',
    TRUE
);

-- ============================================
-- 5. PREGUNTAS DEL FORO
-- ============================================

INSERT INTO public.foro_preguntas (
    id, user_id, titulo, descripcion, categoria,
    total_respuestas, total_votos, total_vistas, resuelta, visible
) VALUES (
    gen_random_uuid(),
    'b28ab1f6-2414-4d51-9007-f810feec6159',
    '¿Alguien conoce un buen cerrajero en zona Sur de La Paz?',
    'Se me trabó la cerradura de mi departamento en Calacoto y necesito un cerrajero de confianza que no cobre muy caro. ¿Alguna recomendación?',
    'Servicios Generales',
    0, 0, 15, FALSE, TRUE
);

INSERT INTO public.foro_preguntas (
    id, user_id, titulo, descripcion, categoria,
    total_respuestas, total_votos, total_vistas, resuelta, visible
) VALUES (
    gen_random_uuid(),
    'a4a9f9e2-2bad-4f31-9fcd-2e5c46dd2768',
    '¿Cuánto cuesta aproximadamente una instalación de gas domiciliario?',
    'Estoy por mudarme a un departamento nuevo y necesito instalar gas de cañería. El departamento es de 80m2 con cocina y calefón. ¿Cuánto me podría costar?',
    'Gasista',
    0, 0, 22, FALSE, TRUE
);

INSERT INTO public.foro_preguntas (
    id, user_id, titulo, descripcion, categoria,
    total_respuestas, total_votos, total_vistas, resuelta, visible
) VALUES (
    gen_random_uuid(),
    '763363b6-82df-4a23-b12a-26cbfe359f57',
    '¿Qué tipo de pintura es mejor para exteriores en Cochabamba?',
    'Voy a pintar la fachada de mi casa y no sé qué tipo de pintura usar. El clima aquí es bastante soleado. ¿Látex, acrílica, esmalte?',
    'Pintor',
    0, 0, 18, FALSE, TRUE
);

-- ============================================
-- 6. CAJEROS PARA RECARGAS
-- ============================================

INSERT INTO public.cajeros (id, nombre, ciudad, zona, telefono, whatsapp, activo) VALUES
('11111111-1111-1111-1111-111111111111', 'Cajero Central La Paz', 'La Paz', 'Centro', '71234567', '59171234567', TRUE),
('22222222-2222-2222-2222-222222222222', 'Cajero Sopocachi', 'La Paz', 'Sopocachi', '72345678', '59172345678', TRUE),
('33333333-3333-3333-3333-333333333333', 'Cajero Miraflores', 'La Paz', 'Miraflores', '73456789', '59173456789', TRUE),
('44444444-4444-4444-4444-444444444444', 'Cajero Equipetrol SCZ', 'Santa Cruz', 'Equipetrol', '74567890', '59174567890', TRUE),
('55555555-5555-5555-5555-555555555555', 'Cajero Centro SCZ', 'Santa Cruz', 'Centro', '75678901', '59175678901', TRUE),
('66666666-6666-6666-6666-666666666666', 'Cajero Cochabamba Norte', 'Cochabamba', 'Norte', '76789012', '59176789012', TRUE);

-- ============================================
-- 7. VERIFICACIÓN
-- ============================================

SELECT '========== USUARIOS CONFIGURADOS ==========' as info;
SELECT email, rol, nombre_completo, creditos, ciudad FROM public.users
WHERE email LIKE '%@test.com' OR email = 'h.st4rk.8@gmail.com'
ORDER BY rol, email;

SELECT '========== PROFESIONALES ACTIVOS ==========' as info;
SELECT nombre_comercial, categoria_principal, ciudad FROM public.perfiles_profesionales WHERE activo = TRUE;

SELECT '========== SOLICITUDES ACTIVAS ==========' as info;
SELECT titulo, categoria, ciudad, urgencia FROM public.solicitudes_trabajo WHERE estado = 'activa';

SELECT '========== PREGUNTAS FORO ==========' as info;
SELECT titulo, categoria FROM public.foro_preguntas;

SELECT '========== CAJEROS ==========' as info;
SELECT nombre, ciudad, zona FROM public.cajeros WHERE activo = TRUE;

SELECT '========== MIGRACIÓN 019 COMPLETADA ==========' as status;
