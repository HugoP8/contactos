import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla principal (Home)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Créditos
          InkWell(
            onTap: () => context.push('/creditos'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user?.creditos ?? 0}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              'Hola${user?.nombreCompleto != null ? ', ${user!.nombreCompleto!.split(' ').first}' : ''}! 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Qué servicio necesitas hoy?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Acciones rápidas
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.search,
                    label: 'Buscar\nProfesional',
                    color: AppTheme.primary,
                    onTap: () => context.push('/search'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.add_circle,
                    label: 'Publicar\nSolicitud',
                    color: AppTheme.secondary,
                    onTap: () => context.push('/solicitud/crear'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nueva acción: Foro "Alguien Sabe?"
            _buildQuickAction(
              context: context,
              icon: Icons.question_answer,
              label: 'Alguien Sabe? 🤔\nPregunta lo que sea',
              color: AppTheme.accent,
              onTap: () => context.push('/foro'),
            ),
            const SizedBox(height: 32),

            // Categorías principales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.push('/search'),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de categorías
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _categoriasDestacadas.length,
              itemBuilder: (context, index) {
                final categoria = _categoriasDestacadas[index];
                return _buildCategoriaCard(
                  context: context,
                  categoria: categoria,
                );
              },
            ),
            const SizedBox(height: 32),

            // Banner de membresía (si no tiene)
            if (user != null && user.tipoCuenta == AppConstants.tipoCuentaGratuita)
              _buildMembershipBanner(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Action rápida
  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de categoría
  Widget _buildCategoriaCard({
    required BuildContext context,
    required Map<String, dynamic> categoria,
  }) {
    return InkWell(
      onTap: () {
        context.push('/search'); // TODO: Pasar filtro de categoría
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: (categoria['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (categoria['color'] as Color).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoria['icon'] as IconData,
              size: 32,
              color: categoria['color'] as Color,
            ),
            const SizedBox(height: 8),
            Text(
              categoria['nombre'] as String,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Banner de membresía
  Widget _buildMembershipBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Hazte Premium!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Accede a beneficios exclusivos y destaca entre los demás profesionales',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Ir a pantalla de membresías
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Membresías')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
            ),
            child: const Text('Ver Planes'),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
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
            context.go('/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
          label: 'Buscar',
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work),
          label: 'Solicitudes',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  /// Categorías destacadas
  static final List<Map<String, dynamic>> _categoriasDestacadas = [
    {
      'nombre': 'Plomero',
      'icon': Icons.plumbing,
      'color': AppTheme.primary,
    },
    {
      'nombre': 'Electricista',
      'icon': Icons.electrical_services,
      'color': AppTheme.accent,
    },
    {
      'nombre': 'Carpintero',
      'icon': Icons.carpenter,
      'color': const Color(0xFF8B4513),
    },
    {
      'nombre': 'Limpieza',
      'icon': Icons.cleaning_services,
      'color': AppTheme.secondary,
    },
    {
      'nombre': 'Tecnología',
      'icon': Icons.computer,
      'color': AppTheme.info,
    },
    {
      'nombre': 'Pintor',
      'icon': Icons.format_paint,
      'color': const Color(0xFFE91E63),
    },
  ];
}
