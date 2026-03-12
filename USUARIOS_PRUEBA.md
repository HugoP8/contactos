# USUARIOS DE PRUEBA - CONTACTOS APP

## CREDENCIALES DE ACCESO

**IMPORTANTE**: La contraseña para todos los usuarios `@test.com` es: **`Test1234!`**

---

## USUARIO ADMINISTRADOR

| Campo | Valor |
|-------|-------|
| **Email** | `h.st4rk.8@gmail.com` |
| **Password** | (tu contraseña personal) |
| **UUID** | `8f07dcb8-2cd4-4157-a8ba-fe7198137810` |
| **Rol** | `admin` |
| **Créditos** | 9999 |
| **Ciudad** | La Paz |

### Funcionalidades Admin:
- Acceso al Panel de Administración desde Perfil
- Dashboard con métricas en tiempo real
- Aprobar/rechazar recargas de créditos
- Gestionar usuarios (suspender/activar)
- Gestionar cajeros (crear, editar, desactivar)
- Ver historial de transacciones
- Ver reportes

---

## USUARIOS BUSCADORES

### Buscador 1: María Fernanda
| Campo | Valor |
|-------|-------|
| **Email** | `maria.fernanda@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | María Fernanda López |
| **Rol** | `buscador` |
| **Créditos** | 50 |
| **Ciudad** | La Paz - Sopocachi |
| **Plan** | Gratuita |

### Buscador 2: Patricia Vargas
| Campo | Valor |
|-------|-------|
| **Email** | `patricia.vargas@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Patricia Vargas Mendoza |
| **Rol** | `buscador` |
| **Créditos** | 100 |
| **Ciudad** | Santa Cruz - Equipetrol |
| **Plan** | Básica |

### Buscador 3: Ana Flores
| Campo | Valor |
|-------|-------|
| **Email** | `ana.flores@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Ana Flores Quispe |
| **Rol** | `buscador` |
| **Créditos** | 30 |
| **Ciudad** | Cochabamba - Norte |
| **Plan** | Gratuita |

---

## USUARIOS PROFESIONALES

### Electricista: Juan Pérez
| Campo | Valor |
|-------|-------|
| **Email** | `juan.electricista@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Juan Pérez Electricista |
| **Rol** | `profesional` |
| **Categoría** | Electricista |
| **Créditos** | 150 |
| **Ciudad** | La Paz - Miraflores |
| **Destacado** | Sí |

### Carpintero: Pedro Gutiérrez
| Campo | Valor |
|-------|-------|
| **Email** | `pedro.carpintero@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Pedro Gutiérrez Carpintero |
| **Rol** | `profesional` |
| **Categoría** | Carpintero |
| **Créditos** | 200 |
| **Ciudad** | La Paz - San Miguel |
| **Destacado** | Sí |

### Plomero: Miguel Condori
| Campo | Valor |
|-------|-------|
| **Email** | `miguel.plomero@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Miguel Condori Plomero |
| **Rol** | `profesional` |
| **Categoría** | Plomero |
| **Créditos** | 120 |
| **Ciudad** | La Paz - Centro |

### Pintora: Rosa Mamani
| Campo | Valor |
|-------|-------|
| **Email** | `rosa.pintora@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Rosa Mamani Pintora |
| **Rol** | `profesional` |
| **Categoría** | Pintor |
| **Créditos** | 80 |
| **Ciudad** | Santa Cruz - Centro |

### Técnico: Luis Fernández
| Campo | Valor |
|-------|-------|
| **Email** | `luis.tecnico@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Luis Fernández Técnico |
| **Rol** | `profesional` |
| **Categoría** | Tecnología |
| **Créditos** | 90 |
| **Ciudad** | Cochabamba - Centro |

---

## USUARIOS DUALES (BUSCAN Y OFRECEN)

### Limpieza: Roberto Choque
| Campo | Valor |
|-------|-------|
| **Email** | `roberto.choque@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Roberto Choque Limpieza |
| **Rol** | `dual` |
| **Categoría** | Limpieza |
| **Créditos** | 250 |
| **Ciudad** | La Paz - Calacoto |
| **Plan** | Premium |
| **Destacado** | Sí |

### Gasista: Carlos Mamani
| Campo | Valor |
|-------|-------|
| **Email** | `carlos.mamani@test.com` |
| **Password** | `Test1234!` |
| **Nombre** | Carlos Mamani Gasista |
| **Rol** | `dual` |
| **Categoría** | Gasista |
| **Créditos** | 180 |
| **Ciudad** | La Paz - Sopocachi |
| **Destacado** | Sí |

---

## FLUJOS DE PRUEBA

### 1. Flujo Admin
```
1. Login: h.st4rk.8@gmail.com
2. Ir a: Perfil (tab inferior)
3. Tocar: "Panel de Administración" (botón azul destacado)
4. Ver: Dashboard con métricas
5. Probar: Gestionar Usuarios
6. Probar: Gestionar Cajeros (crear/editar/eliminar)
7. Probar: Recargas Pendientes (si hay)
```

### 2. Flujo Buscador
```
1. Login: maria.fernanda@test.com / Test1234!
2. Buscar: "Plomero" en pantalla de búsqueda
3. Ver: Lista de profesionales
4. Tocar: Miguel Plomería Express
5. Tocar: "Ver Contacto" (gasta 1 crédito)
6. Verificar: Se muestra WhatsApp y teléfono
7. Tocar: "Guardar en Mis Contactos"
8. Ir a: Foro "Alguien Sabe"
9. Ver: Preguntas existentes
```

### 3. Flujo Profesional
```
1. Login: juan.electricista@test.com / Test1234!
2. Ir a: Perfil
3. Ver: Estadísticas de perfil profesional
4. Ir a: Solicitudes de trabajo
5. Ver: Solicitudes activas de electricista
6. Postularse a una solicitud
7. Ir a: Foro
8. Responder una pregunta (ganar créditos si es premiada)
```

### 4. Flujo Dual
```
1. Login: roberto.choque@test.com / Test1234!
2. Como Buscador: Publicar solicitud de trabajo
3. Como Profesional: Ver su perfil de limpieza
4. Buscar otros profesionales (carpinteros, etc.)
```

### 5. Flujo de Créditos
```
1. Login: ana.flores@test.com / Test1234!
2. Ver: Créditos actuales (30)
3. Buscar un profesional
4. Ver contacto (queda 29 créditos)
5. Ir a: Membresías (comprar más créditos)
6. Seleccionar paquete
7. Elegir cajero
8. (Admin aprueba desde su panel)
```

---

## DATOS DE PRUEBA INCLUIDOS

### Solicitudes de Trabajo Activas:
1. **URGENTE: Fuga de agua en baño** - María busca Plomero (La Paz)
2. **Instalación de luminarias LED** - Patricia busca Electricista (Santa Cruz)
3. **Pintar casa de 2 plantas** - Ana busca Pintor (Cochabamba)
4. **Mueble de cocina a medida** - Roberto busca Carpintero (La Paz)

### Preguntas del Foro:
1. ¿Alguien conoce un buen cerrajero en zona Sur de La Paz?
2. ¿Cuánto cuesta aproximadamente una instalación de gas domiciliario?
3. ¿Qué tipo de pintura es mejor para exteriores en Cochabamba?

### Cajeros Activos:
| Nombre | Ciudad | Zona |
|--------|--------|------|
| Cajero Central La Paz | La Paz | Centro |
| Cajero Sopocachi | La Paz | Sopocachi |
| Cajero Miraflores | La Paz | Miraflores |
| Cajero Equipetrol SCZ | Santa Cruz | Equipetrol |
| Cajero Centro SCZ | Santa Cruz | Centro |
| Cajero Cochabamba Norte | Cochabamba | Norte |

---

## INSTRUCCIONES DE EJECUCIÓN

### Paso 1: Ejecutar SQL
```sql
-- En Supabase SQL Editor ejecutar:
-- Archivo: migrations/019_SEEDERS_PRODUCCION.sql
```

### Paso 2: Verificar datos
El SQL muestra al final un resumen de los datos creados.

### Paso 3: Probar en la app
Usar las credenciales de este documento.

---

## CHECKLIST PRE-PRODUCCIÓN

- [ ] Ejecutar migración 019_SEEDERS_PRODUCCION.sql
- [ ] Login con Admin: h.st4rk.8@gmail.com
- [ ] Verificar Panel de Administración visible en Perfil
- [ ] Login con Buscador: maria.fernanda@test.com
- [ ] Buscar profesional y ver contacto
- [ ] Login con Profesional: juan.electricista@test.com
- [ ] Ver solicitudes de trabajo
- [ ] Probar foro (preguntar/responder)
- [ ] Verificar descuento de créditos al ver contacto
- [ ] Probar flujo de recargas (si aplica)
