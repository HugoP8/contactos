# Configuración de Supabase - CONTACTOS

## Paso 1: Ejecutar Migraciones SQL

Ejecuta los siguientes scripts en el **SQL Editor** de Supabase, en este orden:

1. `database_supabase_script_FIXED.sql` - Estructura base de la BD
2. `migrations/004_fix_rpc_functions.sql` - Funciones RPC y políticas corregidas
3. `migrations/005_seeders_datos_prueba.sql` - Datos de prueba (opcional, solo para desarrollo)

## Paso 2: Configurar Autenticación

### Deshabilitar Confirmación de Email (Recomendado para desarrollo)

1. Ve a **Authentication** > **Providers** > **Email**
2. **Desactiva** "Confirm email" (toggle OFF)
3. Esto permite que los usuarios inicien sesión inmediatamente después de registrarse

### Configurar Google Sign-In

1. Ve a **Authentication** > **Providers** > **Google**
2. **Habilita** Google
3. Configura los siguientes datos:

**En Google Cloud Console:**
1. Crea un proyecto en [Google Cloud Console](https://console.cloud.google.com/)
2. Ve a **APIs & Services** > **Credentials**
3. Crea credenciales **OAuth 2.0 Client ID** (tipo: Web application)
4. Configura las URIs autorizadas:
   - **Orígenes autorizados:** `https://oooewbxjnpospofslrey.supabase.co`
   - **URIs de redirección:** `https://oooewbxjnpospofslrey.supabase.co/auth/v1/callback`

5. Copia el **Client ID** y **Client Secret** a Supabase

**Para Flutter:**
1. Crea otro OAuth 2.0 Client ID (tipo: Android / iOS según corresponda)
2. Configura el `google-services.json` (Android) o `GoogleService-Info.plist` (iOS)

## Paso 3: Configurar Storage

1. Ve a **Storage** > **Create bucket**
2. Crea los siguientes buckets:
   - `avatars` - Para fotos de perfil (público)
   - `solicitudes` - Para fotos de solicitudes (público)
   - `profesionales` - Para galerías de profesionales (público)

3. Configura las políticas RLS para cada bucket:

```sql
-- Política para avatars (permitir a usuarios autenticados)
CREATE POLICY "Users can upload avatars" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Avatars are public" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'avatars');

-- Similar para otros buckets...
```

## Paso 4: Variables de Entorno (.env)

Crea un archivo `.env` en la raíz del proyecto con:

```env
# Supabase
SUPABASE_URL=https://oooewbxjnpospofslrey.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui

# Google AdMob (opcional)
ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxx
ADMOB_BANNER_ID=ca-app-pub-xxxxx/xxxxx
ADMOB_REWARDED_ID=ca-app-pub-xxxxx/xxxxx

# App Info
APP_NAME=CONTACTOS
APP_VERSION=1.0.0
ENVIRONMENT=development
```

## Paso 5: Verificar Funciones RPC

Ejecuta esta consulta para verificar que las funciones existen:

```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'puede_publicar_solicitud_gratis',
    'descontar_creditos',
    'incrementar_creditos',
    'usar_token_especial',
    'handle_new_user'
  )
ORDER BY routine_name;
```

Deberías ver 5 funciones listadas.

## Paso 6: Verificar Políticas RLS

```sql
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

## Troubleshooting

### Error: "Email not confirmed"
- **Solución:** Deshabilita "Confirm email" en Authentication > Email

### Error: "Function not found"
- **Solución:** Ejecuta `migrations/004_fix_rpc_functions.sql`

### Error: "Row-level security policy violation"
- **Solución:** Verifica las políticas RLS en la tabla afectada

### Error: "Invalid login credentials"
- **Solución:** Verifica que el email y contraseña sean correctos

### El nombre del usuario aparece como parte del email
- **Solución:** El trigger `handle_new_user` ahora obtiene el nombre de los metadatos.
  Los nuevos usuarios mostrarán su nombre correctamente.
  Para usuarios existentes, actualiza manualmente:
  ```sql
  UPDATE public.users
  SET nombre_completo = 'Nombre Real'
  WHERE email = 'usuario@email.com';
  ```

## Comandos Útiles de Flutter

```bash
# Limpiar y reconstruir
flutter clean && flutter pub get

# Ejecutar en web
flutter run -d chrome

# Ejecutar en Windows
flutter run -d windows

# Build para producción
flutter build web --release
flutter build apk --release
```

## Contacto

Si tienes problemas, revisa los logs en:
- **Supabase Dashboard** > **Logs** > **Postgres**
- **Flutter Console** para errores de la app
