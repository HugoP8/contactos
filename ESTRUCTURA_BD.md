# ESTRUCTURA DE BASE DE DATOS - CONTACTOS APP

## Tabla: users
| Columna | Tipo |
|---------|------|
| id | uuid |
| email | varchar |
| nombre_completo | varchar |
| telefono | varchar |
| whatsapp | varchar |
| foto_perfil | text |
| ciudad | varchar |
| zona | varchar |
| rol | varchar | (buscador, profesional, dual, cajero, admin)
| tipo_cuenta | varchar | (gratuita, basica, premium, vip)
| creditos | integer |
| membresia_activa | boolean |
| verificado | boolean |
| perfil_completo | boolean |
| created_at | timestamptz |
| updated_at | timestamptz |

---

## Tabla: perfiles_profesionales
| Columna | Tipo |
|---------|------|
| id | uuid |
| user_id | uuid |
| nombre_comercial | varchar |
| descripcion | text |
| eslogan | varchar |
| categoria_principal | varchar |
| subcategorias | ARRAY |
| servicios_ofrecidos | ARRAY |
| ciudad | varchar |
| zonas_cobertura | ARRAY |
| telefono | varchar |
| whatsapp | varchar |
| email | varchar |
| sitio_web | varchar |
| redes_sociales | jsonb |
| años_experiencia | integer |
| rango_precio_desde | numeric |
| rango_precio_hasta | numeric |
| emite_factura | boolean |
| ofrece_garantia | boolean |
| metodos_pago | ARRAY |
| horario_atencion | jsonb |
| disponible_ahora | boolean |
| foto_perfil | text |
| galeria_fotos | ARRAY |
| video_presentacion | text |
| verificado | boolean |
| verificado_identidad | boolean |
| verificado_comercial | boolean |
| documentos_verificacion | ARRAY |
| total_vistas | integer |
| total_contactos | integer |
| total_postulaciones | integer |
| total_trabajos_realizados | integer |
| calificacion_promedio | numeric |
| total_resenas | integer |
| mensaje_automatico | text |
| respuesta_rapida_activa | boolean |
| activo | boolean |
| visible_busqueda | boolean |
| destacado | boolean |
| created_at | timestamptz |
| updated_at | timestamptz |

---

## Tabla: solicitudes_trabajo
| Columna | Tipo |
|---------|------|
| id | uuid |
| user_id | uuid |
| titulo | varchar |
| descripcion | text |
| categoria | varchar |
| subcategoria | varchar |
| ciudad | varchar |
| zona | varchar |
| direccion_exacta | text |
| presupuesto_minimo | numeric |
| presupuesto_maximo | numeric |
| urgencia | varchar | (normal, urgente, muy_urgente)
| fecha_limite | timestamptz |
| fotos | ARRAY |
| estado | varchar | (activa, en_proceso, completada, cancelada)
| total_postulaciones | integer |
| profesional_seleccionado | uuid |
| fecha_seleccion | timestamptz |
| calificacion | integer |
| resena | text |
| fecha_calificacion | timestamptz |
| creditos_usados | integer |
| visible | boolean |
| destacada | boolean |
| created_at | timestamptz |
| updated_at | timestamptz |
| expires_at | timestamptz |

---

## Tabla: foro_preguntas
| Columna | Tipo |
|---------|------|
| id | uuid |
| user_id | uuid |
| titulo | varchar |
| descripcion | text |
| categoria | varchar |
| imagenes | ARRAY |
| total_respuestas | integer |
| total_votos | integer |
| total_vistas | integer |
| respondida | boolean |
| resuelta | boolean |
| respuesta_aceptada | uuid |
| mejor_respuesta_id | uuid |
| visible | boolean |
| created_at | timestamptz |
| updated_at | timestamptz |

---

## Tabla: cajeros
| Columna | Tipo |
|---------|------|
| id | uuid |
| user_id | uuid |
| nombre | text |
| ciudad | text |
| zona | text |
| telefono | text |
| whatsapp | text |
| qr_image | text |
| activo | boolean |
| total_recargas | integer |
| monto_total_recargado | numeric |
| created_at | timestamptz |
| updated_at | timestamptz |

---

## Tabla: mis_contactos
| Columna | Tipo |
|---------|------|
| id | uuid |
| user_id | uuid |
| profesional_id | uuid |
| notas | text |
| favorito | boolean |
| created_at | timestamptz |
| updated_at | timestamptz |

---

## Valores de Enums

### Roles (users.rol)
- `buscador` - Solo busca profesionales
- `profesional` - Ofrece servicios
- `dual` - Busca y ofrece servicios
- `cajero` - Punto de recarga
- `admin` - Administrador del sistema

### Tipo de Cuenta (users.tipo_cuenta)
- `gratuita` - Plan gratuito
- `basica` - Plan básico
- `premium` - Plan premium
- `vip` - Plan VIP

### Estado Solicitud (solicitudes_trabajo.estado)
- `activa` - Publicada y recibiendo postulaciones
- `en_proceso` - Profesional seleccionado, trabajo en curso
- `completada` - Trabajo finalizado
- `cancelada` - Cancelada por el usuario

### Urgencia (solicitudes_trabajo.urgencia)
- `normal` - Sin urgencia
- `urgente` - Urgente
- `muy_urgente` - Muy urgente

---

## Notas Importantes

1. **Arrays**: Se usan para listas como `subcategorias`, `servicios_ofrecidos`, `zonas_cobertura`, `fotos`, etc.

2. **JSONB**: Se usa para datos estructurados como `redes_sociales` y `horario_atencion`.

3. **Foreign Keys**:
   - `perfiles_profesionales.user_id` → `users.id`
   - `solicitudes_trabajo.user_id` → `users.id`
   - `foro_preguntas.user_id` → `users.id`
   - `mis_contactos.profesional_id` → `perfiles_profesionales.id`

4. **Timestamps**: Todas las tablas tienen `created_at` y `updated_at`.
