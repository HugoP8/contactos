import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';

class RecargasPendientesScreen extends ConsumerWidget {
  const RecargasPendientesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recargasAsync = ref.watch(recargasPendientesProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recargas Pendientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.invalidate(recargasPendientesProvider),
          ),
        ],
      ),
      body: recargasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Error al cargar recargas'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: AppTheme.grey600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(recargasPendientesProvider),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (recargas) {
          if (recargas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Todo al día!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay recargas pendientes de aprobación',
                    style: TextStyle(color: AppTheme.grey600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recargas.length,
            itemBuilder: (context, index) {
              final recarga = recargas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRecargaCard(context, ref, recarga, user?.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecargaCard(
    BuildContext context,
    WidgetRef ref,
    SolicitudRecarga recarga,
    String? adminId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pendiente de Aprobación',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${recarga.id.substring(0, 8)}',
                  style: TextStyle(
                    color: AppTheme.grey600,
                    fontSize: 12,
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
                // Información del producto
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        recarga.tipoProducto == 'creditos'
                            ? Icons.diamond
                            : Icons.card_membership,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _obtenerNombreProducto(recarga),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monto: Bs. ${recarga.montoTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Comisión cajero: Bs. ${recarga.comisionCajero.toStringAsFixed(2)} (5%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Información del usuario
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Cliente',
                  value: 'Usuario ID: ${recarga.userId.substring(0, 8)}...',
                ),
                const SizedBox(height: 8),

                // Información del cajero
                _buildInfoRow(
                  icon: Icons.point_of_sale,
                  label: 'Cajero',
                  value: 'Cajero ID: ${recarga.cajeroId?.substring(0, 8) ?? 'N/A'}...',
                ),
                const SizedBox(height: 8),

                // Método de pago
                _buildInfoRow(
                  icon: Icons.payment,
                  label: 'Método',
                  value: recarga.metodoPago,
                ),
                const SizedBox(height: 8),

                // Fecha
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Solicitado',
                  value: _formatearFecha(recarga.createdAt),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rechazarRecarga(context, ref, recarga.id),
                        icon: Icon(Icons.close),
                        label: Text('RECHAZAR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(color: AppTheme.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: adminId != null
                            ? () => _aprobarRecarga(context, ref, recarga.id, adminId)
                            : null,
                        icon: Icon(Icons.check),
                        label: Text('ACTIVAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.grey600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _obtenerNombreProducto(SolicitudRecarga recarga) {
    if (recarga.tipoProducto == 'creditos') {
      return '${recarga.cantidadCreditos} Créditos';
    } else {
      return 'Membresía ${recarga.tipoMembresia ?? ''} (${recarga.duracion ?? ''})';
    }
  }

  String _formatearFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _aprobarRecarga(
    BuildContext context,
    WidgetRef ref,
    String solicitudId,
    String adminId,
  ) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Activación'),
        content: Text(
          '¿Estás seguro de que deseas activar esta recarga?\n\n'
          'Esta acción agregará los créditos/membresía al usuario inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text('ACTIVAR'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Ejecutar aprobación
    final actions = ref.read(adminActionsProvider);
    final success = await actions.aprobarRecarga(solicitudId, adminId);

    if (context.mounted) {
      Navigator.of(context).pop(); // Cerrar loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Recarga activada exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al activar la recarga'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _rechazarRecarga(
    BuildContext context,
    WidgetRef ref,
    String solicitudId,
  ) async {
    // Pedir razón del rechazo
    String? razon;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rechazar Recarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Indica la razón del rechazo:'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ej: Comprobante no válido',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => razon = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('RECHAZAR'),
          ),
        ],
      ),
    );

    if (confirmar != true || razon == null || razon!.trim().isEmpty) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Ejecutar rechazo
    final actions = ref.read(adminActionsProvider);
    final success = await actions.rechazarRecarga(solicitudId, razon!);

    if (context.mounted) {
      Navigator.of(context).pop(); // Cerrar loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recarga rechazada'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar la recarga'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
