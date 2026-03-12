import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/custom_icons.dart';

class PostulacionesSolicitudScreen extends ConsumerWidget {
  final String solicitudId;

  const PostulacionesSolicitudScreen({
    Key? key,
    required this.solicitudId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postulacionesAsync = ref.watch(postulacionesPorSolicitudProvider(solicitudId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Postulaciones'),
      ),
      body: postulacionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Error al cargar postulaciones'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: AppTheme.grey600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(postulacionesPorSolicitudProvider(solicitudId)),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (postulaciones) {
          if (postulaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: AppTheme.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin postulaciones aún',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando los profesionales se postulen,\naparecerán aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grey600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: postulaciones.length,
            itemBuilder: (context, index) {
              final postulacion = postulaciones[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPostulacionCard(context, ref, postulacion),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostulacionCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> postulacion,
  ) {
    final estado = postulacion['estado'] as String;
    final esSeleccionado = estado == 'seleccionado';
    final esRechazado = estado == 'rechazado';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esSeleccionado
              ? AppTheme.successColor
              : esRechazado
                  ? AppTheme.errorColor.withOpacity(0.3)
                  : AppTheme.grey300,
          width: esSeleccionado ? 2 : 1,
        ),
        boxShadow: esSeleccionado
            ? [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          if (esSeleccionado || esRechazado)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (esSeleccionado
                        ? AppTheme.successColor
                        : AppTheme.errorColor)
                    .withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    esSeleccionado ? Icons.check_circle : Icons.cancel,
                    color: esSeleccionado
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    esSeleccionado ? '✅ SELECCIONADO' : '❌ Rechazado',
                    style: TextStyle(
                      color: esSeleccionado
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del profesional
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            postulacion['profesional_nombre'] ?? 'Profesional',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: AppTheme.warningColor),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (25 reseñas)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Propuesta
                Text(
                  'Propuesta:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  postulacion['mensaje_propuesta'] ?? 'Sin mensaje',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey700,
                  ),
                ),

                const SizedBox(height: 16),

                // Precio y tiempo
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.attach_money,
                        label: 'Precio',
                        value: 'Bs. ${postulacion['precio_propuesto']?.toStringAsFixed(0) ?? 'N/A'}',
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (postulacion['tiempo_estimado'] != null &&
                        postulacion['tiempo_estimado'].toString().isNotEmpty)
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.access_time,
                          label: 'Tiempo',
                          value: postulacion['tiempo_estimado'],
                          color: AppTheme.primaryColor,
                        ),
                      )
                    else
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.access_time,
                          label: 'Tiempo',
                          value: 'A convenir',
                          color: AppTheme.grey500,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Fecha de postulación
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.grey500),
                    const SizedBox(width: 6),
                    Text(
                      'Postulado hace 2 horas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botones de acción (solo si está pendiente)
                if (estado == 'pendiente') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rechazarPostulacion(context, ref, postulacion['id']),
                          icon: Icon(Icons.close),
                          label: Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _seleccionarPostulacion(
                            context,
                            ref,
                            postulacion['id'],
                            postulacion['profesional_whatsapp'] ?? '',
                          ),
                          icon: Icon(Icons.check),
                          label: Text('Seleccionar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (esSeleccionado) ...[
                  ElevatedButton.icon(
                    onPressed: () => _contactarPorWhatsApp(
                      postulacion['profesional_whatsapp'] ?? '',
                      postulacion['profesional_nombre'] ?? 'Profesional',
                    ),
                    icon: Icon(CustomIcons.whatsapp),
                    label: Text('Contactar por WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarPostulacion(
    BuildContext context,
    WidgetRef ref,
    String postulacionId,
    String whatsapp,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Seleccionar esta postulación?'),
        content: Text(
          'Al seleccionar esta postulación, se rechazarán automáticamente las demás.\n\n'
          'Podrás contactar al profesional por WhatsApp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text('Seleccionar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // TODO: Implementar lógica de seleccionar postulación
    // Actualizar estado en la base de datos

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Postulación seleccionada'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Abrir WhatsApp
      _contactarPorWhatsApp(whatsapp, 'Profesional');
    }
  }

  Future<void> _rechazarPostulacion(
    BuildContext context,
    WidgetRef ref,
    String postulacionId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Rechazar postulación?'),
        content: Text(
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // TODO: Implementar lógica de rechazar postulación

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Postulación rechazada'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Future<void> _contactarPorWhatsApp(String whatsapp, String nombre) async {
    final mensaje = '¡Hola $nombre! Te contacto por tu postulación en CONTACTOS App.';

    final url = Uri.parse(
      'https://wa.me/${whatsapp.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

// Provider para obtener postulaciones por solicitud
final postulacionesPorSolicitudProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, solicitudId) async {
  // TODO: Implementar consulta real a Supabase
  // Por ahora retorno datos de ejemplo
  await Future.delayed(const Duration(seconds: 1));
  return [];
});
