import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/solicitud_trabajo_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Card para mostrar una solicitud de trabajo
class SolicitudCard extends StatelessWidget {
  final SolicitudTrabajoModel solicitud;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRenovar;
  final VoidCallback? onDestacar;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onRenovar,
    this.onDestacar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/solicitud/${solicitud.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Título y badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      solicitud.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge de urgente
                  if (solicitud.isUrgente)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'URGENTE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  // Badge de destacada
                  if (solicitud.destacada)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DESTACADA',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Categoría y ciudad
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    solicitud.categoria,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.grey500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    solicitud.ciudad,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (solicitud.zona != null) ...[
                    Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      solicitud.zona!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                solicitud.descripcion,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Presupuesto y postulaciones
              Row(
                children: [
                  // Presupuesto
                  if (solicitud.tienePresupuesto) ...[
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      solicitud.presupuestoTexto,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),

                  // Postulaciones
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppTheme.grey500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${solicitud.totalPostulaciones} postulaciones',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Estado y días restantes
              Row(
                children: [
                  // Badge de estado
                  _buildEstadoBadge(context),
                  const Spacer(),

                  // Días restantes
                  if (solicitud.isActiva && solicitud.diasRestantes != null)
                    Text(
                      solicitud.diasRestantes! > 0
                          ? 'Expira en ${solicitud.diasRestantes} días'
                          : 'Expira hoy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: solicitud.diasRestantes! <= 2
                                ? AppTheme.error
                                : AppTheme.grey500,
                            fontWeight: solicitud.diasRestantes! <= 2
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                ],
              ),

              // Acciones (solo si showActions es true)
              if (showActions) ...[
                const SizedBox(height: 12),
                Divider(color: AppTheme.grey200),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Renovar (si está expirada)
                    if (solicitud.isExpirada && onRenovar != null)
                      TextButton.icon(
                        onPressed: onRenovar,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Renovar'),
                      ),

                    // Destacar (si no está destacada)
                    if (solicitud.isActiva &&
                        !solicitud.destacada &&
                        onDestacar != null)
                      TextButton.icon(
                        onPressed: onDestacar,
                        icon: Icon(Icons.star_outline, size: 18),
                        label: Text('Destacar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                        ),
                      ),

                    // Eliminar
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, size: 18),
                        label: Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el badge del estado
  Widget _buildEstadoBadge(BuildContext context) {
    Color color;
    String texto;

    switch (solicitud.estado) {
      case AppConstants.estadoSolicitudActiva:
        color = AppTheme.success;
        texto = 'Activa';
        break;
      case AppConstants.estadoSolicitudEnProceso:
        color = AppTheme.info;
        texto = 'En proceso';
        break;
      case AppConstants.estadoSolicitudCompletada:
        color = AppTheme.grey500;
        texto = 'Completada';
        break;
      case AppConstants.estadoSolicitudCancelada:
        color = AppTheme.error;
        texto = 'Cancelada';
        break;
      case AppConstants.estadoSolicitudExpirada:
        color = AppTheme.warning;
        texto = 'Expirada';
        break;
      default:
        color = AppTheme.grey500;
        texto = solicitud.estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
