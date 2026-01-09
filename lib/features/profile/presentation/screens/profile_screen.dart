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
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Ir a configuración
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
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Cambiar foto
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
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
                // TODO: Ir a editar perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente: Editar perfil')),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.workspace_premium,
              title: 'Membresías',
              subtitle: 'Ver planes y beneficios',
              onTap: () {
                // TODO: Ir a membresías
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.payment,
              title: 'Métodos de Pago',
              subtitle: 'Administra tus métodos de pago',
              onTap: () {
                context.push('/payments');
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
                // TODO: Ir a notificaciones
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.security,
              title: 'Privacidad y Seguridad',
              subtitle: 'Gestiona tu privacidad',
              onTap: () {
                // TODO: Ir a privacidad
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              subtitle: 'Obtén ayuda',
              onTap: () {
                // TODO: Ir a ayuda
              },
            ),
            const SizedBox(height: 24),

            // Botón de cerrar sesión
            OutlinedButton.icon(
              onPressed: () => _handleLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Maneja el cierre de sesión
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
