import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MetodoPagoScreen extends ConsumerStatefulWidget {
  final String tipoProducto; // 'creditos' o 'membresia'
  final Map<String, dynamic> detallesProducto;

  const MetodoPagoScreen({
    Key? key,
    required this.tipoProducto,
    required this.detallesProducto,
  }) : super(key: key);

  @override
  ConsumerState<MetodoPagoScreen> createState() => _MetodoPagoScreenState();
}

class _MetodoPagoScreenState extends ConsumerState<MetodoPagoScreen> {
  String? metodoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Método de Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen del producto
            _buildResumenProducto(),
            const SizedBox(height: 24),

            // Título
            Text(
              '¿Cómo deseas pagar?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Método 1: Pago Manual (Cajero)
            _buildMetodoCard(
              contexto: context,
              icono: Icons.person,
              titulo: 'Pago Manual (Cajero/Vendedor)',
              descripcion: 'Paga con Tigo Money, transferencia o efectivo',
              tiempoActivacion: 'Activación en 5-30 minutos',
              disponible: true,
              onTap: () {
                setState(() => metodoSeleccionado = 'cajero');
              },
              seleccionado: metodoSeleccionado == 'cajero',
            ),
            const SizedBox(height: 12),

            // Método 2: Stripe (Próximamente)
            _buildMetodoCard(
              contexto: context,
              icono: Icons.credit_card,
              titulo: 'Pago con Tarjeta - Stripe',
              descripcion: 'Tarjeta de crédito/débito',
              tiempoActivacion: 'Activación instantánea',
              disponible: false,
              onTap: () {
                // Por ahora no hace nada
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Próximamente disponible'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              },
              seleccionado: false,
            ),
            const SizedBox(height: 12),

            // Método 3: QR Bancario (Próximamente)
            _buildMetodoCard(
              contexto: context,
              icono: Icons.qr_code,
              titulo: 'QR Bancario',
              descripcion: 'Escanea y paga desde tu banco',
              tiempoActivacion: 'Validación automática',
              disponible: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Próximamente disponible'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              },
              seleccionado: false,
            ),

            const SizedBox(height: 32),

            // Botón continuar
            ElevatedButton(
              onPressed: metodoSeleccionado == null
                  ? null
                  : () {
                      if (metodoSeleccionado == 'cajero') {
                        _navegarASeleccionCajero();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text(
                'CONTINUAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenProducto() {
    String titulo = '';
    String monto = '';

    if (widget.tipoProducto == 'creditos') {
      final creditos = widget.detallesProducto['creditos'] as int;
      final precio = widget.detallesProducto['precio'] as double;
      titulo = '$creditos créditos';
      monto = 'Bs. ${precio.toStringAsFixed(2)}';
    } else {
      final tipo = widget.detallesProducto['tipo'] as String;
      final duracion = widget.detallesProducto['duracion'] as String;
      final precio = widget.detallesProducto['precio'] as double;
      titulo = 'Membresía $tipo';
      monto = 'Bs. ${precio.toStringAsFixed(2)} ($duracion)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Producto',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monto,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetodoCard({
    required BuildContext contexto,
    required IconData icono,
    required String titulo,
    required String descripcion,
    required String tiempoActivacion,
    required bool disponible,
    required VoidCallback onTap,
    required bool seleccionado,
  }) {
    return InkWell(
      onTap: disponible ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado
                ? AppTheme.primaryColor
                : AppTheme.grey300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: disponible
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : AppTheme.grey200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: disponible ? AppTheme.primaryColor : AppTheme.grey400,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: disponible
                                ? AppTheme.grey900
                                : AppTheme.grey400,
                          ),
                        ),
                      ),
                      if (!disponible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Próximamente',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      color: disponible
                          ? AppTheme.grey600
                          : AppTheme.grey400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: disponible
                            ? AppTheme.successColor
                            : AppTheme.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tiempoActivacion,
                        style: TextStyle(
                          fontSize: 12,
                          color: disponible
                              ? AppTheme.successColor
                              : AppTheme.grey400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (seleccionado)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  void _navegarASeleccionCajero() {
    // Navegar a la pantalla de selección de cajero
    context.push('/payments/seleccionar-cajero', extra: {
      'tipoProducto': widget.tipoProducto,
      'detallesProducto': widget.detallesProducto,
    });
  }
}
