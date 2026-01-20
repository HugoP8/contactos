import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de perfil del usuario
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        automaticallyImplyLeading: false, // No mostrar botón atrás
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto y nombre
            Center(
              child: Column(
                children: [
                  // Foto de perfil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.grey200,
                        backgroundImage: user.fotoPerfil != null
                            ? CachedNetworkImageProvider(user.fotoPerfil!)
                            : null,
                        child: user.fotoPerfil == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.grey400,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primary,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Cambiar foto
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Próximamente: Cambiar foto'),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    user.nombreCompleto ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Badge de verificado
                  if (user.verificado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.success),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verificado',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.diamond,
                    value: '${user.creditos}',
                    label: 'Créditos',
                    color: AppTheme.accent,
                    onTap: () => context.push('/creditos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.work,
                    value: '${user.totalSolicitudesPublicadas}',
                    label: 'Solicitudes',
                    color: AppTheme.primary,
                    onTap: () => context.push('/solicitudes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.visibility,
                    value: '${user.totalContactosVistos}',
                    label: 'Contactos',
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    value: user.tipoCuenta.toUpperCase(),
                    label: 'Plan',
                    color: AppTheme.info,
                    isText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sección de cuenta
            _buildSection(context, 'Cuenta'),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.person,
              title: 'Editar Perfil',
              subtitle: 'Actualiza tu información personal',
              onTap: () {
                context.push('/profile/editar');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.workspace_premium,
              title: 'Membresías',
              subtitle: 'Ver planes y beneficios',
              onTap: () {
                context.push('/membresias');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.payment,
              title: 'Métodos de Pago',
              subtitle: 'Compra créditos o activa membresías',
              onTap: () {
                context.push('/membresias');
              },
            ),
            const SizedBox(height: 24),

            // Sección de configuración
            _buildSection(context, 'Configuración'),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              subtitle: 'Configura tus notificaciones',
              onTap: () {
                context.push('/notifications');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.security,
              title: 'Privacidad y Seguridad',
              subtitle: 'Gestiona tu privacidad',
              onTap: () {
                context.push('/privacy');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              subtitle: 'Obtén ayuda',
              onTap: () {
                context.push('/help');
              },
            ),
            const SizedBox(height: 24),

            // Botón de cerrar sesión
            OutlinedButton.icon(
              onPressed: () => _handleLogout(context, ref),
              icon: Icon(Icons.logout),
              label: Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Versión
            Text(
              'Versión ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey400,
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Perfil
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.grey400,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/solicitudes');
              break;
            case 3:
              context.go('/foro');
              break;
            case 4:
              // Ya estamos aquí
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Foro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  /// Card de estadística
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isText = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: isText ? 14 : null,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Título de sección
  Widget _buildSection(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Item de menú
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Maneja el cierre de sesión
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(authProvider.notifier).signOut();

        // Verificar que realmente cerró sesión
        final authState = ref.read(authProvider);
        if (context.mounted) {
          if (authState.value == null) {
            // Logout exitoso
            context.go('/login');
          } else {
            // Estado inesperado - igual navegar a login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sesión cerrada (con advertencias)'),
                backgroundColor: Colors.orange,
              ),
            );
            context.go('/login');
          }
        }
      } catch (e) {
        // Si hay error, igual forzar navegación a login
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión. Redirigiendo...'),
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/login');
        }
      }
    }
  }
}
