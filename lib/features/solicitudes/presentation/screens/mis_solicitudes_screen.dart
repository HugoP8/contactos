import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/solicitudes_provider.dart';
import '../widgets/solicitud_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla para ver las solicitudes del usuario
class MisSolicitudesScreen extends ConsumerWidget {
  const MisSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(misSolicitudesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
          tooltip: 'Volver al inicio',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Solicitudes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (state.solicitudes.isNotEmpty)
              Text(
                '${state.solicitudes.length} solicitud${state.solicitudes.length != 1 ? 'es' : ''} activa${state.solicitudes.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: AppTheme.grey500),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(misSolicitudesProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(misSolicitudesProvider.notifier).refresh();
                        },
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : state.solicitudes.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(misSolicitudesProvider.notifier).refresh();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.solicitudes.length,
                        itemBuilder: (context, index) {
                          final solicitud = state.solicitudes[index];
                          return SolicitudCard(
                            solicitud: solicitud,
                            showActions: true,
                            onDelete: () {
                              _showDeleteDialog(context, ref, solicitud.id);
                            },
                            onRenovar: solicitud.isExpirada
                                ? () {
                                    _renovarSolicitud(context, ref, solicitud.id);
                                  }
                                : null,
                            onDestacar: !solicitud.destacada && solicitud.isActiva
                                ? () {
                                    _destacarSolicitud(context, ref, solicitud.id);
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            context.push('/solicitud/crear');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Nueva Solicitud',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: AppTheme.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes solicitudes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.grey600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera solicitud y recibe postulaciones de profesionales',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grey500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/solicitud/crear');
              },
              icon: Icon(Icons.add),
              label: Text('Crear Solicitud'),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar
  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String solicitudId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar solicitud'),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta solicitud? Esta acción no se puede deshacer.',
        ),
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
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(misSolicitudesProvider.notifier).eliminarSolicitud(solicitudId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solicitud eliminada'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  /// Renueva una solicitud
  Future<void> _renovarSolicitud(
    BuildContext context,
    WidgetRef ref,
    String solicitudId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renovar solicitud'),
        content: Text(
          'Renovar la solicitud cuesta ${AppConstants.costoRenovarSolicitud} créditos. '
          'La solicitud estará activa por ${AppConstants.diasExpiracionSolicitud} días más.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Renovar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(misSolicitudesProvider.notifier).renovarSolicitud(solicitudId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solicitud renovada exitosamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  /// Destaca una solicitud
  Future<void> _destacarSolicitud(
    BuildContext context,
    WidgetRef ref,
    String solicitudId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Destacar solicitud'),
        content: Text(
          'Destacar la solicitud cuesta ${AppConstants.costoDestacarSolicitud} créditos. '
          'Tu solicitud aparecerá primero en los resultados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Destacar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(misSolicitudesProvider.notifier).destacarSolicitud(solicitudId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solicitud destacada exitosamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}
