import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/main_bottom_nav.dart';

/// Pantalla principal (Home)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: _buildAppTitle(context),
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

            // Acciones rápidas - 3 en una fila responsiva
            LayoutBuilder(
              builder: (context, constraints) {
                // Si la pantalla es muy pequeña, usar 2 filas
                if (constraints.maxWidth < 360) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCompact(
                              context: context,
                              icon: Icons.search,
                              label: 'Buscar',
                              color: AppTheme.primary,
                              onTap: () => context.push('/search'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCompact(
                              context: context,
                              icon: Icons.question_answer,
                              label: 'Alguien Sabe',
                              color: AppTheme.accent,
                              onTap: () => context.push('/foro'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildQuickActionCompact(
                        context: context,
                        icon: Icons.add_circle,
                        label: 'Publicar Solicitud',
                        color: AppTheme.secondary,
                        onTap: () => context.push('/solicitud/crear'),
                      ),
                    ],
                  );
                }

                // Pantalla normal: 3 botones en una fila
                return Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCompact(
                        context: context,
                        icon: Icons.search,
                        label: 'Buscar Profesional',
                        color: AppTheme.primary,
                        onTap: () => context.push('/search'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionCompact(
                        context: context,
                        icon: Icons.question_answer,
                        label: 'Alguien Sabe',
                        color: AppTheme.accent,
                        onTap: () => context.push('/foro'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionCompact(
                        context: context,
                        icon: Icons.add_circle,
                        label: 'Publicar Solicitud',
                        color: AppTheme.secondary,
                        onTap: () => context.push('/solicitud/crear'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Mi espacio - accesos rápidos personales
            Row(
              children: [
                Expanded(
                  child: _buildMiniAction(
                    context: context,
                    icon: Icons.contacts_rounded,
                    label: 'Mis Contactos',
                    onTap: () => context.push('/mis-contactos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniAction(
                    context: context,
                    icon: Icons.work_outline_rounded,
                    label: 'Mis Solicitudes',
                    onTap: () => context.push('/mis-solicitudes'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniAction(
                    context: context,
                    icon: Icons.favorite_outline_rounded,
                    label: 'Favoritos',
                    onTap: () => context.push('/favoritos'),
                  ),
                ),
              ],
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
                  child: Text('Ver todas'),
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
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }

  /// Título estilizado de la app
  Widget _buildAppTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo/Icono
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        // Texto CONTACTOS con estilo
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ).createShader(bounds),
          child: Text(
            'CONTACTOS',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Mini action para Mi espacio
  Widget _buildMiniAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppTheme.grey700),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action rápida compacta para 3 en fila
  Widget _buildQuickActionCompact({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action rápida (original, para compatibilidad)
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

  /// Card de categoría - ahora pasa el filtro
  Widget _buildCategoriaCard({
    required BuildContext context,
    required Map<String, dynamic> categoria,
  }) {
    return InkWell(
      onTap: () {
        // Navegar a búsqueda con filtro de categoría
        context.push('/search?categoria=${Uri.encodeComponent(categoria['nombre'] as String)}');
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
              context.push('/membresias');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
            ),
            child: Text('Ver Planes'),
          ),
        ],
      ),
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
