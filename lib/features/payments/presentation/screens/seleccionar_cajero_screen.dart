import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/payments_provider.dart';

class SeleccionarCajeroScreen extends ConsumerStatefulWidget {
  final String tipoProducto;
  final Map<String, dynamic> detallesProducto;

  const SeleccionarCajeroScreen({
    Key? key,
    required this.tipoProducto,
    required this.detallesProducto,
  }) : super(key: key);

  @override
  ConsumerState<SeleccionarCajeroScreen> createState() =>
      _SeleccionarCajeroScreenState();
}

class _SeleccionarCajeroScreenState
    extends ConsumerState<SeleccionarCajeroScreen> {
  Cajero? cajeroSeleccionado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCajeros();
  }

  Future<void> _cargarCajeros() async {
    final user = ref.read(authProvider).value;
    if (user != null && user.ciudad != null) {
      await ref
          .read(paymentsProvider.notifier)
          .obtenerCajerosDisponibles(user.ciudad!);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final paymentsState = ref.watch(paymentsProvider);
    final user = ref.watch(authProvider).value;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Seleccionar Cajero')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (paymentsState.cajeros.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Seleccionar Cajero')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: AppTheme.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay cajeros disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No encontramos cajeros activos en tu ciudad en este momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _contactarSoporte(),
                  icon: Icon(Icons.support_agent),
                  label: Text('Contactar Soporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cajero'),
      ),
      body: Column(
        children: [
          // Información del producto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.grey100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producto a comprar:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _obtenerTituloProducto(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: Bs. ${_obtenerPrecioProducto().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Lista de cajeros
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentsState.cajeros.length,
              itemBuilder: (context, index) {
                final cajero = paymentsState.cajeros[index];
                final esSeleccionado = cajeroSeleccionado?.id == cajero.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCajeroCard(cajero, esSeleccionado),
                );
              },
            ),
          ),

          // Botón continuar
          if (cajeroSeleccionado != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _procederConCajero(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  'CONTINUAR CON ESTE CAJERO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCajeroCard(Cajero cajero, bool seleccionado) {
    return InkWell(
      onTap: () {
        setState(() {
          cajeroSeleccionado = cajero;
        });
        ref.read(paymentsProvider.notifier).seleccionarCajero(cajero);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppTheme.primaryColor : AppTheme.grey300,
            width: seleccionado ? 2 : 1,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    cajero.nombreCompleto[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cajero.nombreCompleto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cajero.disponibleAhora
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cajero.disponibleAhora
                                ? 'Disponible ahora'
                                : 'Responde en 15 min',
                            style: TextStyle(
                              fontSize: 12,
                              color: cajero.disponibleAhora
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.grey600),
                const SizedBox(width: 4),
                Text(
                  '${cajero.ciudad} - ${cajero.zona}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payment, size: 16, color: AppTheme.grey600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cajero.metodosPago.join(' • '),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.grey600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: AppTheme.warningColor),
                const SizedBox(width: 4),
                Text(
                  cajero.calificacionPromedio.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' (${cajero.totalTransacciones} transacciones)',
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
    );
  }

  String _obtenerTituloProducto() {
    if (widget.tipoProducto == 'creditos') {
      final creditos = widget.detallesProducto['creditos'] as int;
      return '$creditos créditos';
    } else {
      final tipo = widget.detallesProducto['tipo'] as String;
      final duracion = widget.detallesProducto['duracion'] as String;
      return 'Membresía $tipo ($duracion)';
    }
  }

  double _obtenerPrecioProducto() {
    return widget.detallesProducto['precio'] as double;
  }

  Future<void> _procederConCajero() async {
    if (cajeroSeleccionado == null) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    // Crear la solicitud de recarga
    SolicitudRecarga? solicitud;

    if (widget.tipoProducto == 'creditos') {
      solicitud = await ref.read(paymentsProvider.notifier).crearSolicitudCreditos(
            userId: user.id,
            cajeroId: cajeroSeleccionado!.userId,
            cantidadCreditos: widget.detallesProducto['creditos'] as int,
            monto: widget.detallesProducto['precio'] as double,
            metodoPago: 'Por coordinar',
          );
    } else {
      solicitud = await ref.read(paymentsProvider.notifier).crearSolicitudMembresia(
            userId: user.id,
            cajeroId: cajeroSeleccionado!.userId,
            tipoMembresia: widget.detallesProducto['tipo'] as String,
            duracion: widget.detallesProducto['duracion'] as String,
            monto: widget.detallesProducto['precio'] as double,
            metodoPago: 'Por coordinar',
          );
    }

    if (solicitud != null) {
      // Abrir WhatsApp con mensaje predefinido
      await _abrirWhatsApp(cajeroSeleccionado!, user.nombreCompleto ?? 'Usuario', solicitud);
    }
  }

  Future<void> _abrirWhatsApp(Cajero cajero, String nombreUsuario, SolicitudRecarga solicitud) async {
    final mensaje = _construirMensajeWhatsApp(
      nombreUsuario: nombreUsuario,
      cajeroNombre: cajero.nombreCompleto,
      solicitudId: solicitud.id,
    );

    final url = Uri.parse(
      'https://wa.me/${cajero.whatsapp.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      if (mounted) {
        // Mostrar diálogo de confirmación
        _mostrarDialogoWhatsAppAbierto();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir WhatsApp'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _construirMensajeWhatsApp({
    required String nombreUsuario,
    required String cajeroNombre,
    required String solicitudId,
  }) {
    final productoTexto = widget.tipoProducto == 'creditos'
        ? '${widget.detallesProducto['creditos']} créditos'
        : 'Membresía ${widget.detallesProducto['tipo']} (${widget.detallesProducto['duracion']})';

    final precio = widget.detallesProducto['precio'] as double;

    return '''
🛒 *NUEVA SOLICITUD DE RECARGA - CONTACTOS APP*

📋 *Detalles del pedido:*
• Producto: $productoTexto
• Precio: Bs. ${precio.toStringAsFixed(2)}

👤 *Datos del cliente:*
• Nombre: $nombreUsuario
• Solicitud ID: $solicitudId

💳 *Método de pago preferido:*
Por coordinar

⏰ *Fecha solicitud:* ${DateTime.now().toString().substring(0, 16)}

---
*Por favor, coordina el pago conmigo y confirma cuando valides la transacción. Gracias!* 😊
''';
  }

  void _mostrarDialogoWhatsAppAbierto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Solicitud Enviada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu solicitud ha sido enviada al cajero por WhatsApp.',
            ),
            const SizedBox(height: 12),
            Text(
              'Próximos pasos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('1. Coordina el pago con el cajero'),
            Text('2. Realiza el pago'),
            Text('3. Envía el comprobante'),
            Text('4. El cajero validará tu pago'),
            Text('5. Recibirás tus créditos en minutos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a pantalla anterior
              Navigator.of(context).pop(); // Volver a pantalla anterior
            },
            child: Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactarSoporte() async {
    final url = Uri.parse('https://wa.me/59169169169?text=Hola,%20necesito%20ayuda%20con%20CONTACTOS%20App');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
