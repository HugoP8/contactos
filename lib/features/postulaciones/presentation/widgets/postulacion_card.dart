import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/postulacion_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Card para mostrar una postulación
class PostulacionCard extends StatelessWidget {
  final PostulacionModel postulacion;
  final VoidCallback? onAceptar;
  final VoidCallback? onRechazar;
  final VoidCallback? onContactar;
  final bool showActions;

  const PostulacionCard({
    super.key,
    required this.postulacion,
    this.onAceptar,
    this.onRechazar,
    this.onContactar,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profesional
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.grey200,
                  backgroundImage: postulacion.profesionalFoto != null
                      ? CachedNetworkImageProvider(postulacion.profesionalFoto!)
                      : null,
                  child: postulacion.profesionalFoto == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              postulacion.profesionalNombre ?? 'Profesional',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          if (postulacion.profesionalVerificado == true)
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                        ],
                      ),
                      if (postulacion.profesionalCalificacion != null)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              postulacion.profesionalCalificacion!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              postulacion.mensaje,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Presupuesto y tiempo
            Row(
              children: [
                if (postulacion.presupuestoOfrecido != null) ...[
                  Icon(Icons.payments_outlined, size: 16, color: AppTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    postulacion.presupuestoTexto,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (postulacion.tiempoEstimado != null) ...[
                  Icon(Icons.schedule, size: 16, color: AppTheme.grey500),
                  const SizedBox(width: 4),
                  Text(
                    postulacion.tiempoEstimado!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Tiempo transcurrido
            Text(
              postulacion.tiempoTranscurrido,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey500,
                  ),
            ),

            // Acciones
            if (showActions && postulacion.isPendiente) ...[
              const SizedBox(height: 12),
              Divider(color: AppTheme.grey200),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onRechazar != null)
                    TextButton.icon(
                      onPressed: onRechazar,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rechazar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                      ),
                    ),
                  if (onAceptar != null)
                    ElevatedButton.icon(
                      onPressed: onAceptar,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aceptar'),
                    ),
                  if (onContactar != null)
                    ElevatedButton.icon(
                      onPressed: onContactar,
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Contactar'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
