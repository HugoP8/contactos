import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/solicitudes/presentation/screens/mis_solicitudes_screen.dart';
import '../../features/solicitudes/presentation/screens/crear_solicitud_screen.dart';
import '../../features/creditos/presentation/screens/creditos_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/foro/presentation/screens/foro_screen.dart';

/// Provider del router de la aplicación
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Scaffold(
            body: Center(
              child: Text('Search Screen - Próximamente'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/solicitudes',
        name: 'solicitudes',
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
            child: Scaffold(
              appBar: AppBar(title: const Text('Detalle Profesional')),
              body: Center(
                child: Text('Profesional ID: $id - Próximamente'),
              ),
            ),
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
            child: Scaffold(
              appBar: AppBar(title: const Text('Detalle Solicitud')),
              body: Center(
                child: Text('Solicitud ID: $id - Próximamente'),
              ),
            ),
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
            child: Scaffold(
              appBar: AppBar(title: const Text('Postulaciones')),
              body: Center(
                child: Text('Postulaciones de Solicitud $solicitudId - Próximamente'),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/payments',
        name: 'payments',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Scaffold(
            appBar: AppBar(title: Text('Pagos')),
            body: Center(
              child: Text('Payments Screen - Próximamente'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Scaffold(
            appBar: AppBar(title: Text('Panel Admin')),
            body: Center(
              child: Text('Admin Screen - Próximamente'),
            ),
          ),
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '404 - Página no encontrada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Volver al inicio'),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
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
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
