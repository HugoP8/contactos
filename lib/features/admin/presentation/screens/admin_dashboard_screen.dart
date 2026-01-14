import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrativo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(recargasPendientesProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recargasPendientesProvider);
        },
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: AppTheme.grey600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección de recargas pendientes (PRIORITARIO)
                if (stats.recargasPendientes > 0) ...[
                  _buildAlertCard(
                    context: context,
                    icon: Icons.warning_amber_rounded,
                    title: '⚠️ Recargas Pendientes de Aprobación',
                    subtitle: '${stats.recargasPendientes} recargas esperando tu aprobación',
                    color: AppTheme.warningColor,
                    onTap: () => context.push('/admin/recargas-pendientes'),
                  ),
                  const SizedBox(height: 16),
                ],

                // Métricas principales
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Usuarios',
                        value: stats.totalUsuarios.toString(),
                        subtitle: '${stats.usuariosActivos} activos',
                        icon: Icons.people,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Profesionales',
                        value: stats.totalProfesionales.toString(),
                        subtitle: 'activos',
                        icon: Icons.work,
                        color: AppTheme.secondaryColor,
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
                        title: 'Solicitudes',
                        value: stats.totalSolicitudes.toString(),
                        subtitle: '${stats.solicitudesPendientes} activas',
                        icon: Icons.assignment,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Ingresos Mes',
                        value: 'Bs. ${stats.ingresosMes.toStringAsFixed(0)}',
                        subtitle: DateTime.now().month.toString(),
                        icon: Icons.attach_money,
                        color: AppTheme.successColor,
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
                        title: 'Recargas Hoy',
                        value: stats.recargasProcesadas.toString(),
                        subtitle: 'procesadas',
                        icon: Icons.check_circle,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: 'Pendientes',
                        value: stats.recargasPendientes.toString(),
                        subtitle: 'por aprobar',
                        icon: Icons.pending_actions,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Menú de acciones
                Text(
                  'Gestión',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  context: context,
                  icon: Icons.pending_actions,
                  title: 'Recargas Pendientes',
                  subtitle: 'Aprobar/rechazar recargas validadas',
                  count: stats.recargasPendientes,
                  onTap: () => context.push('/admin/recargas-pendientes'),
                ),
                const SizedBox(height: 12),

                _buildMenuCard(
                  context: context,
                  icon: Icons.people,
                  title: 'Gestionar Usuarios',
                  subtitle: 'Ver, suspender, activar usuarios',
                  onTap: () => context.push('/admin/usuarios'),
                ),
                const SizedBox(height: 12),

                _buildMenuCard(
                  context: context,
                  icon: Icons.point_of_sale,
                  title: 'Gestionar Cajeros',
                  subtitle: 'Agregar, editar, desactivar cajeros',
                  onTap: () => context.push('/admin/cajeros'),
                ),
                const SizedBox(height: 12),

                _buildMenuCard(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Historial de Transacciones',
                  subtitle: 'Ver todas las transacciones',
                  onTap: () => context.push('/admin/transacciones'),
                ),
                const SizedBox(height: 12),

                _buildMenuCard(
                  context: context,
                  icon: Icons.analytics,
                  title: 'Reportes y Estadísticas',
                  subtitle: 'Análisis detallado de la plataforma',
                  onTap: () => context.push('/admin/reportes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    int? count,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: count != null && count > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
