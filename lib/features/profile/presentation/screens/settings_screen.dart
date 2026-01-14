import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificacionesActivas = true;
  bool _modoOscuro = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  void _cargarPreferencias() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      setState(() {
        _notificacionesActivas = user.notificacionesPush;
        _modoOscuro = user.modoOscuro;
      });
    }
  }

  Future<void> _actualizarPreferencia(String campo, dynamic valor) async {
    try {
      await ref.read(authProvider.notifier).updateUserData({campo: valor});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencia actualizada'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // PREFERENCIAS
          _buildSectionHeader('Preferencias'),

          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibe alertas de nuevas postulaciones'),
            value: _notificacionesActivas,
            onChanged: (value) {
              setState(() => _notificacionesActivas = value);
              _actualizarPreferencia('notificaciones_push', value);
            },
            secondary: const Icon(Icons.notifications),
          ),

          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Tema oscuro para la aplicación'),
            value: _modoOscuro,
            onChanged: (value) {
              setState(() => _modoOscuro = value);
              _actualizarPreferencia('modo_oscuro', value);

              // Cambiar tema de la app
              ref.read(themeProvider.notifier).toggleTheme();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? '🌙 Modo oscuro activado' : '☀️ Modo claro activado',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          // SEGURIDAD
          _buildSectionHeader('Seguridad'),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar Contraseña'),
            subtitle: const Text('Actualiza tu contraseña'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/cambiar-password');
            },
          ),

          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Verificar Email'),
            subtitle: const Text('Verifica tu dirección de correo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/verificar-email');
            },
          ),

          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacidad y Seguridad'),
            subtitle: const Text('Administra tu privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/privacy');
            },
          ),

          const Divider(),

          // SOPORTE
          _buildSectionHeader('Soporte'),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda y Soporte'),
            subtitle: const Text('Preguntas frecuentes y contacto'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/help');
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            subtitle: Text('Versión ${AppConstants.appVersion}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationIcon: const Icon(Icons.contacts, size: 48),
                children: [
                  const Text(AppConstants.appDescription),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
