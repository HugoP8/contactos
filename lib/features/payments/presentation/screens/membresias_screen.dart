import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MembresiasScreen extends ConsumerStatefulWidget {
  const MembresiasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MembresiasScreen> createState() => _MembresiasScreenState();
}

class _MembresiasScreenState extends ConsumerState<MembresiasScreen> {
  String tipoUsuario = 'profesional'; // profesional o buscador

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Membresías'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de tipo de usuario
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.grey200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Para Profesionales',
                      isSelected: tipoUsuario == 'profesional',
                      onTap: () => setState(() => tipoUsuario = 'profesional'),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Para Buscadores',
                      isSelected: tipoUsuario == 'buscador',
                      onTap: () => setState(() => tipoUsuario = 'buscador'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mostrar membresías según tipo
            if (tipoUsuario == 'profesional') ...[
              _buildSeccionProfesionales(),
            ] else ...[
              _buildSeccionBuscadores(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionProfesionales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner de prueba gratis
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.successColor,
                AppTheme.successColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 ¡PRUEBA GRATIS!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 meses gratis de Plan Básico al crear tu perfil profesional por primera vez',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Plan Básico
        _buildMembresiaCard(
          titulo: 'Plan Básico',
          descripcion: 'Para comenzar a ofrecer tus servicios',
          precioMensual: AppConstants.precioBasicoMensual,
          precioAnual: AppConstants.precioBasicoAnual,
          ahorroAnual: 37,
          color: AppTheme.primaryColor,
          caracteristicas: [
            '✅ Perfil visible en búsquedas',
            '✅ Hasta 5 fotos en galería',
            '✅ Recibir notificaciones de solicitudes',
            '✅ Postular ilimitadamente',
            '✅ Sistema de calificaciones',
            '✅ Estadísticas básicas',
          ],
          tipo: 'basico',
        ),
        const SizedBox(height: 16),

        // Plan Premium (destacado)
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildMembresiaCard(
              titulo: 'Plan Premium',
              descripcion: '¡Lo mejor para tu negocio!',
              precioMensual: AppConstants.precioPremiumMensual,
              precioAnual: AppConstants.precioPremiumAnual,
              ahorroAnual: 44,
              color: AppTheme.accentColor,
              caracteristicas: [
                '🥇 Aparece PRIMERO en búsquedas',
                '👑 Badge dorado "PREMIUM"',
                '⚡ Badge "Respuesta rápida"',
                '📸 Hasta 15 fotos en galería',
                '📊 Estadísticas detalladas',
                '🎯 Destacado en tu categoría',
                '📢 1 publicidad gratis/mes (24h)',
                '💬 Respuestas automáticas',
                '🔔 Notificaciones prioritarias',
                '+ TODO del Plan Básico',
              ],
              tipo: 'premium',
              esDestacado: true,
            ),
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '⭐ RECOMENDADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionBuscadores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Explicación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¿Buscas servicios frecuentemente?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Con la membresía VIP Buscador, realizas búsquedas ilimitadas sin gastar créditos, además de beneficios exclusivos.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.grey700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Plan VIP Buscador
        _buildMembresiaCard(
          titulo: 'VIP Buscador',
          descripcion: 'Búsquedas ilimitadas y más beneficios',
          precioMensual: AppConstants.precioVIPMensual,
          precioAnual: AppConstants.precioVIPAnual,
          ahorroAnual: 16,
          color: AppTheme.accentColor,
          caracteristicas: [
            '🔓 Búsquedas ILIMITADAS (no gasta créditos)',
            '🚫 Sin publicidad en la app',
            '⭐ Badge "Usuario VIP"',
            '📊 Historial completo de contactos',
            '🔔 Notificaciones prioritarias',
            '💾 Favoritos ilimitados',
            '📞 Soporte prioritario',
            '🎁 20 créditos mensuales gratis',
            '📝 Plantillas de solicitudes',
          ],
          tipo: 'vip_buscador',
        ),
      ],
    );
  }

  Widget _buildMembresiaCard({
    required String titulo,
    required String descripcion,
    required double precioMensual,
    required double precioAnual,
    required int ahorroAnual,
    required Color color,
    required List<String> caracteristicas,
    required String tipo,
    bool esDestacado = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esDestacado ? color : AppTheme.grey300,
          width: esDestacado ? 2 : 1,
        ),
        boxShadow: esDestacado
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      esDestacado ? Icons.workspace_premium : Icons.card_membership,
                      color: color,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            descripcion,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Características
                ...caracteristicas.map((caracteristica) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      caracteristica,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Opciones de pago
                Text(
                  'Elige tu plan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey800,
                  ),
                ),
                const SizedBox(height: 16),

                // Mensual
                _buildOpcionPago(
                  duracion: 'Mensual',
                  precio: precioMensual,
                  detalle: 'Bs. ${precioMensual.toStringAsFixed(0)}/mes',
                  onTap: () => _comprarMembresia(tipo, 'mensual', precioMensual),
                ),
                const SizedBox(height: 12),

                // Anual
                _buildOpcionPago(
                  duracion: 'Anual',
                  precio: precioAnual,
                  detalle:
                      'Bs. ${(precioAnual / 12).toStringAsFixed(2)}/mes - Ahorra $ahorroAnual%',
                  esDestacado: true,
                  onTap: () => _comprarMembresia(tipo, 'anual', precioAnual),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionPago({
    required String duracion,
    required double precio,
    required String detalle,
    bool esDestacado = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: esDestacado
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: esDestacado ? AppTheme.successColor : AppTheme.grey300,
            width: esDestacado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        duracion,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey900,
                        ),
                      ),
                      if (esDestacado) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MEJOR PRECIO',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detalle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Bs. ${precio.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: esDestacado ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: esDestacado ? AppTheme.successColor : AppTheme.grey600,
            ),
          ],
        ),
      ),
    );
  }

  void _comprarMembresia(String tipo, String duracion, double precio) {
    // Navegar al flujo de pagos
    context.push(
      '/payments/metodo',
      extra: {
        'tipoProducto': 'membresia',
        'detallesProducto': {
          'tipo': tipo,
          'duracion': duracion,
          'precio': precio,
        },
      },
    );
  }
}
