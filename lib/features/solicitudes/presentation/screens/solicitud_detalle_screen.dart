import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../postulaciones/presentation/providers/postulaciones_provider.dart';
import '../../data/models/solicitud_trabajo_model.dart';
import '../../data/repositories/solicitudes_repository.dart';

/// Provider para obtener una solicitud por ID
final solicitudDetalleProvider = FutureProvider.family<SolicitudTrabajoModel?, String>((ref, id) async {
  final repository = SolicitudesRepository();
  return await repository.obtenerSolicitudPorId(id);
});

/// Pantalla de detalle de una solicitud de trabajo
class SolicitudDetalleScreen extends ConsumerWidget {
  final String solicitudId;

  const SolicitudDetalleScreen({
    super.key,
    required this.solicitudId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudAsync = ref.watch(solicitudDetalleProvider(solicitudId));
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Solicitud'),
      ),
      body: solicitudAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error al cargar la solicitud'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(solicitudDetalleProvider(solicitudId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (solicitud) {
          if (solicitud == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: AppTheme.grey400),
                  const SizedBox(height: 16),
                  Text('Solicitud no encontrada'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final esPropia = user?.id == solicitud.userId;
          final esProfesional = user?.rol == AppConstants.rolProfesional ||
              user?.rol == AppConstants.rolDual;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges
                Row(
                  children: [
                    if (solicitud.isUrgente)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.error),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on, size: 16, color: AppTheme.error),
                            const SizedBox(width: 4),
                            Text(
                              'URGENTE',
                              style: TextStyle(
                                color: AppTheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (solicitud.isUrgente) const SizedBox(width: 8),
                    if (solicitud.destacada)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: AppTheme.accent),
                            const SizedBox(width: 4),
                            Text(
                              'DESTACADA',
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Titulo
                Text(
                  solicitud.titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Categoria y ubicacion
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        solicitud.categoria,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on, size: 16, color: AppTheme.grey500),
                    const SizedBox(width: 4),
                    Text(
                      '${solicitud.ciudad}${solicitud.zona != null ? ' - ${solicitud.zona}' : ''}',
                      style: TextStyle(color: AppTheme.grey600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Descripcion
                Text(
                  'Descripcion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    solicitud.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),

                // Presupuesto
                if (solicitud.tienePresupuesto) ...[
                  Text(
                    'Presupuesto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: AppTheme.success),
                        const SizedBox(width: 8),
                        Text(
                          solicitud.presupuestoTexto,
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Fotos
                if (solicitud.fotos.isNotEmpty) ...[
                  Text(
                    'Fotos adjuntas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: solicitud.fotos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(solicitud.fotos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Info adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.grey200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.people,
                        label: 'Postulaciones',
                        value: '${solicitud.totalPostulaciones}',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.schedule,
                        label: 'Expira en',
                        value: solicitud.diasRestantes != null
                            ? '${solicitud.diasRestantes} dias'
                            : 'Sin fecha',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.info_outline,
                        label: 'Estado',
                        value: solicitud.estado.toUpperCase(),
                        valueColor: solicitud.isActiva ? AppTheme.success : AppTheme.grey500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Boton de accion
                if (!esPropia && esProfesional && solicitud.isActiva)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _mostrarDialogoPostulacion(context, ref, solicitud);
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('POSTULARME'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                  ),

                // Si es propia, mostrar opciones
                if (esPropia) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/postulaciones/$solicitudId');
                      },
                      icon: const Icon(Icons.people),
                      label: Text('Ver Postulaciones (${solicitud.totalPostulaciones})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implementar editar
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implementar eliminar
                          },
                          icon: Icon(Icons.delete, color: AppTheme.error),
                          label: Text('Eliminar', style: TextStyle(color: AppTheme.error)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Si no es profesional ni es propia
                if (!esPropia && !esProfesional && solicitud.isActiva)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info, color: AppTheme.info),
                        const SizedBox(height: 8),
                        Text(
                          'Para postularte necesitas un perfil profesional',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.info),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/profile/crear-profesional');
                          },
                          child: const Text('Crear Perfil Profesional'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.grey500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppTheme.grey600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.grey800,
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoPostulacion(
    BuildContext context,
    WidgetRef ref,
    SolicitudTrabajoModel solicitud,
  ) {
    final mensajeController = TextEditingController();
    final presupuestoController = TextEditingController();
    final tiempoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enviar Propuesta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Para: ${solicitud.titulo}',
                style: TextStyle(color: AppTheme.grey600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: mensajeController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tu mensaje *',
                  hintText: 'Describe tu experiencia y como puedes ayudar...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: presupuestoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (Bs.)',
                        prefixText: 'Bs. ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: tiempoController,
                      decoration: const InputDecoration(
                        labelText: 'Tiempo estimado',
                        hintText: 'Ej: 2 horas',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (mensajeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Escribe un mensaje')),
                      );
                      return;
                    }

                    try {
                      // Parsear presupuesto
                      double? presupuesto;
                      if (presupuestoController.text.isNotEmpty) {
                        presupuesto = double.tryParse(presupuestoController.text);
                      }

                      // Enviar postulación
                      await ref.read(crearPostulacionProvider).crearPostulacion(
                        solicitudId: solicitud.id,
                        mensaje: mensajeController.text.trim(),
                        presupuestoOfrecido: presupuesto,
                        tiempoEstimado: tiempoController.text.trim().isEmpty
                            ? null
                            : tiempoController.text.trim(),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Propuesta enviada correctamente'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                        // Refrescar la solicitud para actualizar el contador
                        ref.invalidate(solicitudDetalleProvider(solicitud.id));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('ENVIAR PROPUESTA'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
