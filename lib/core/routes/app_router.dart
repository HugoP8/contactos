import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/solicitudes/presentation/screens/mis_solicitudes_screen.dart';
import '../../features/solicitudes/presentation/screens/solicitudes_screen.dart';
import '../../features/solicitudes/presentation/screens/crear_solicitud_screen.dart';
import '../../features/creditos/presentation/screens/creditos_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/editar_perfil_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/cambiar_password_screen.dart';
import '../../features/profile/presentation/screens/verificar_email_screen.dart';
import '../../features/profile/presentation/screens/crear_perfil_profesional_screen.dart';
import '../../features/foro/presentation/screens/foro_screen.dart';
import '../../features/foro/presentation/screens/crear_pregunta_screen.dart';
import '../../features/foro/presentation/screens/pregunta_detalle_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/search/presentation/screens/profesional_detalle_screen.dart';
import '../../features/resenas/presentation/screens/escribir_resena_screen.dart';
import '../../features/resenas/presentation/screens/resenas_profesional_screen.dart';
import '../../features/favoritos/presentation/screens/mis_favoritos_screen.dart';
import '../../features/contactos/presentation/screens/mis_contactos_screen.dart';
import '../../features/payments/presentation/screens/metodo_pago_screen.dart';
import '../../features/payments/presentation/screens/seleccionar_cajero_screen.dart';
import '../../features/payments/presentation/screens/membresias_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/recargas_pendientes_screen.dart';
import '../../features/admin/presentation/screens/gestionar_usuarios_screen.dart';
import '../../features/admin/presentation/screens/gestionar_cajeros_screen.dart';
import '../../features/postulaciones/presentation/screens/postulaciones_solicitud_screen.dart';
import '../../features/solicitudes/presentation/screens/solicitud_detalle_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/privacy/presentation/screens/privacy_screen.dart';
import '../../features/help/presentation/screens/help_screen.dart';

/// Notifica a GoRouter cuando cambia el estado de autenticación sin
/// recrear el GoRouter (que reiniciaría la navegación a initialLocation).
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<AsyncValue<UserModel?>>(authProvider, (previous, next) {
      // Solo refrescar si cambió si hay o no usuario autenticado,
      // no en cada actualización de datos del mismo usuario (créditos, etc.)
      if ((previous?.value != null) != (next.value != null)) {
        notifyListeners();
      }
    });
  }
}

/// Provider del router de la aplicación
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefresh(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Si no está autenticado y no está en login/register, redirigir a login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Si está autenticado y está en login/register, redirigir a home
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      // No redirigir
      return null;
    },
    routes: [
      // ==========================================
      // RUTAS DE AUTENTICACIÓN
      // ==========================================
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),

      // ==========================================
      // RUTAS PRINCIPALES (CON BOTTOM NAV)
      // ==========================================
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) {
          // Obtener categoría del query parameter
          final categoria = state.uri.queryParameters['categoria'];
          return MaterialPage(
            key: state.pageKey,
            child: SearchScreen(categoriaInicial: categoria),
          );
        },
      ),
      GoRoute(
        path: '/solicitudes',
        name: 'solicitudes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SolicitudesScreen(),
        ),
      ),
      GoRoute(
        path: '/mis-solicitudes',
        name: 'mis-solicitudes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MisSolicitudesScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/crear-profesional',
        name: 'crear-perfil-profesional',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CrearPerfilProfesionalScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/editar',
        name: 'editar-perfil',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EditarPerfilScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/cambiar-password',
        name: 'cambiar-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CambiarPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/verificar-email',
        name: 'verificar-email',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const VerificarEmailScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/editar-profesional/:id',
        name: 'editar-perfil-profesional',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: CrearPerfilProfesionalScreen(
              esEdicion: true,
              perfilId: id,
            ),
          );
        },
      ),

      // ==========================================
      // RUTAS SECUNDARIAS
      // ==========================================
      GoRoute(
        path: '/creditos',
        name: 'creditos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CreditosScreen(),
        ),
      ),
      GoRoute(
        path: '/profesional/:id',
        name: 'profesional-detalle',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ProfesionalDetalleScreen(profesionalId: id),
          );
        },
      ),
      GoRoute(
        path: '/solicitud/crear',
        name: 'solicitud-crear',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CrearSolicitudScreen(),
        ),
      ),
      GoRoute(
        path: '/solicitud/:id',
        name: 'solicitud-detalle',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: SolicitudDetalleScreen(solicitudId: id),
          );
        },
      ),
      GoRoute(
        path: '/postulaciones/:solicitudId',
        name: 'postulaciones',
        pageBuilder: (context, state) {
          final solicitudId = state.pathParameters['solicitudId']!;
          return MaterialPage(
            key: state.pageKey,
            child: PostulacionesSolicitudScreen(solicitudId: solicitudId),
          );
        },
      ),
      // ==========================================
      // RUTAS DE PAGOS
      // ==========================================
      GoRoute(
        path: '/membresias',
        name: 'membresias',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MembresiasScreen(),
        ),
      ),
      GoRoute(
        path: '/payments/metodo',
        name: 'metodo-pago',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MaterialPage(
            key: state.pageKey,
            child: MetodoPagoScreen(
              tipoProducto: extra['tipoProducto'] as String,
              detallesProducto: extra['detallesProducto'] as Map<String, dynamic>,
            ),
          );
        },
      ),
      GoRoute(
        path: '/payments/seleccionar-cajero',
        name: 'seleccionar-cajero',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MaterialPage(
            key: state.pageKey,
            child: SeleccionarCajeroScreen(
              tipoProducto: extra['tipoProducto'] as String,
              detallesProducto: extra['detallesProducto'] as Map<String, dynamic>,
            ),
          );
        },
      ),
      // ==========================================
      // RUTAS DE ADMIN
      // ==========================================
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/recargas-pendientes',
        name: 'admin-recargas-pendientes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RecargasPendientesScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/usuarios',
        name: 'admin-usuarios',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const GestionarUsuariosScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/cajeros',
        name: 'admin-cajeros',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const GestionarCajerosScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/transacciones',
        name: 'admin-transacciones',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            appBar: AppBar(title: Text('Transacciones')),
            body: const Center(child: Text('Próximamente')),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/reportes',
        name: 'admin-reportes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            appBar: AppBar(title: Text('Reportes y Estadísticas')),
            body: const Center(child: Text('Próximamente')),
          ),
        ),
      ),

      // ==========================================
      // RUTAS DE FAVORITOS
      // ==========================================
      GoRoute(
        path: '/favoritos',
        name: 'favoritos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MisFavoritosScreen(),
        ),
      ),

      // ==========================================
      // RUTAS DE MIS CONTACTOS
      // ==========================================
      GoRoute(
        path: '/mis-contactos',
        name: 'mis-contactos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MisContactosScreen(),
        ),
      ),

      // ==========================================
      // RUTAS DE RESEÑAS
      // ==========================================
      GoRoute(
        path: '/profesional/:id/resena/crear',
        name: 'resena-crear',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final nombre = state.uri.queryParameters['nombre'];
          return MaterialPage(
            key: state.pageKey,
            child: EscribirResenaScreen(
              profesionalId: id,
              profesionalNombre: nombre,
            ),
          );
        },
      ),
      GoRoute(
        path: '/profesional/:id/resenas',
        name: 'resenas-profesional',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final nombre = state.uri.queryParameters['nombre'];
          return MaterialPage(
            key: state.pageKey,
            child: ResenasProfesionalScreen(
              profesionalId: id,
              profesionalNombre: nombre,
            ),
          );
        },
      ),

      // ==========================================
      // RUTAS DEL FORO
      // ==========================================
      GoRoute(
        path: '/foro',
        name: 'foro',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForoScreen(),
        ),
      ),
      GoRoute(
        path: '/foro/crear',
        name: 'foro-crear',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CrearPreguntaScreen(),
        ),
      ),
      GoRoute(
        path: '/foro/:id',
        name: 'foro-detalle',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: PreguntaDetalleScreen(preguntaId: id),
          );
        },
      ),

      // ==========================================
      // RUTAS DE CONFIGURACIÓN Y AYUDA
      // ==========================================
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PrivacyScreen(),
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HelpScreen(),
        ),
      ),

      // ==========================================
      // RUTA 404
      // ==========================================
      GoRoute(
        path: '/404',
        name: '404',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '404 - Página no encontrada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
