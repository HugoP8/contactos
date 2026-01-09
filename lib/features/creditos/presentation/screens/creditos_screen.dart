import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/creditos_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/admob_service.dart';

/// Pantalla principal de créditos
class CreditosScreen extends ConsumerStatefulWidget {
  const CreditosScreen({super.key});

  @override
  ConsumerState<CreditosScreen> createState() => _CreditosScreenState();
}

class _CreditosScreenState extends ConsumerState<CreditosScreen> {
  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    // Pre-cargar video recompensado
    AdMobService.instance.loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final historialState = ref.watch(creditosHistorialProvider);
    final videosVistos = ref.watch(videosVistosHoyProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Créditos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(authProvider.notifier).refreshUser();
              ref.read(creditosHistorialProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUser();
          await ref.read(creditosHistorialProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saldo actual
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Saldo Actual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${user.creditos}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'créditos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total ganados: ${user.creditosTotalesGanados} créditos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formas de ganar créditos
              Text(
                'Gana Créditos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Ver video AdMob
              _buildGanarCreditosCard(
                context: context,
                icon: Icons.play_circle_filled,
                iconColor: AppTheme.error,
                title: 'Ver videos',
                subtitle: videosVistos < AppConstants.maxVideosAdMobPorDia
                    ? 'Gana ${AppConstants.creditosPorVideo} créditos por video'
                    : 'Límite diario alcanzado',
                trailing: videosVistos < AppConstants.maxVideosAdMobPorDia
                    ? Text(
                        '$videosVistos/${AppConstants.maxVideosAdMobPorDia} hoy',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : Icon(Icons.check_circle, color: AppTheme.success),
                enabled: videosVistos < AppConstants.maxVideosAdMobPorDia && !_isLoadingVideo,
                onTap: () => _verVideo(),
              ),
              const SizedBox(height: 12),

              // Invitar amigos
              _buildGanarCreditosCard(
                context: context,
                icon: Icons.person_add,
                iconColor: AppTheme.accent,
                title: 'Invitar amigos',
                subtitle: 'Gana ${AppConstants.creditosPorReferido} créditos por amigo',
                trailing: const Icon(Icons.share),
                onTap: () => _compartirCodigo(),
              ),
              const SizedBox(height: 12),

              // Completar perfil
              _buildGanarCreditosCard(
                context: context,
                icon: Icons.person,
                iconColor: AppTheme.info,
                title: 'Completar perfil',
                subtitle: 'Gana ${AppConstants.creditosPorPerfilCompleto} créditos',
                trailing: user.perfilCompleto
                    ? Icon(Icons.check_circle, color: AppTheme.success)
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: !user.perfilCompleto,
                onTap: () {
                  if (user.perfilCompleto) {
                    // Ya completó el perfil
                    _reclamarCreditosPerfilCompleto();
                  } else {
                    // Ir a completar perfil
                    context.push('/profile');
                  }
                },
              ),
              const SizedBox(height: 12),

              // Escribir reseñas
              _buildGanarCreditosCard(
                context: context,
                icon: Icons.star,
                iconColor: AppTheme.accent,
                title: 'Escribir reseñas',
                subtitle: 'Gana ${AppConstants.creditosPorResena} créditos por reseña',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Califica a un profesional después de contratar sus servicios'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Comprar créditos
              Text(
                'Comprar Créditos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Paquetes de créditos
              ...AppConstants.paquetesCreditos.map((paquete) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPaqueteCard(
                    context: context,
                    nombre: paquete['nombre'] as String,
                    creditos: paquete['creditos'] as int,
                    precio: paquete['precio'] as double,
                    popular: paquete['popular'] as bool,
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // Historial
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(creditosHistorialProvider.notifier).refresh();
                    },
                    child: const Text('Ver todo'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Lista de movimientos
              if (historialState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (historialState.error != null)
                Center(
                  child: Text(
                    historialState.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.error,
                        ),
                  ),
                )
              else if (historialState.movimientos.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No hay movimientos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.grey500,
                          ),
                    ),
                  ),
                )
              else
                ...historialState.movimientos.take(10).map((movimiento) {
                  return _buildMovimientoItem(context, movimiento);
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Card para ganar créditos
  Widget _buildGanarCreditosCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        enabled: enabled,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  /// Card de paquete de créditos
  Widget _buildPaqueteCard({
    required BuildContext context,
    required String nombre,
    required int creditos,
    required double precio,
    required bool popular,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: popular ? AppTheme.accent.withOpacity(0.1) : AppTheme.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.diamond,
            color: popular ? AppTheme.accent : AppTheme.grey500,
          ),
        ),
        title: Row(
          children: [
            Text(
              nombre,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (popular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'POPULAR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('$creditos créditos'),
        trailing: ElevatedButton(
          onPressed: () => _comprarPaquete(nombre, creditos, precio),
          style: ElevatedButton.styleFrom(
            backgroundColor: popular ? AppTheme.accent : AppTheme.primary,
          ),
          child: Text('Bs. ${precio.toStringAsFixed(0)}'),
        ),
      ),
    );
  }

  /// Item de movimiento en el historial
  Widget _buildMovimientoItem(BuildContext context, CreditoMovimiento movimiento) {
    final esGanancia = movimiento.tipoMovimiento == AppConstants.tipoMovimientoGanancia;

    return ListTile(
      leading: Icon(
        esGanancia ? Icons.add_circle : Icons.remove_circle,
        color: esGanancia ? AppTheme.success : AppTheme.error,
      ),
      title: Text(
        movimiento.descripcion ?? _obtenerDescripcionOrigen(movimiento.origen),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        _formatearFecha(movimiento.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${esGanancia ? '+' : '-'}${movimiento.cantidad}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: esGanancia ? AppTheme.success : AppTheme.error,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Ver video recompensado
  Future<void> _verVideo() async {
    setState(() => _isLoadingVideo = true);

    try {
      final actions = ref.read(creditosActionsProvider);
      final success = await actions.verVideoRecompensado();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Ganaste ${AppConstants.creditosPorVideo} créditos! 🎉'),
              backgroundColor: AppTheme.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo completar el video'),
              backgroundColor: AppTheme.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVideo = false);
      }
    }
  }

  /// Compartir código de referido
  Future<void> _compartirCodigo() async {
    final user = ref.read(authProvider).value;
    if (user?.codigoReferido == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu Código de Referido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Text(
                user!.codigoReferido!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comparte este código con tus amigos y ambos ganarán ${AppConstants.creditosPorReferido} créditos cuando se registren.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar compartir
              Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
        ],
      ),
    );
  }

  /// Reclamar créditos por perfil completo
  Future<void> _reclamarCreditosPerfilCompleto() async {
    try {
      final actions = ref.read(creditosActionsProvider);
      await actions.reclamarCreditosPerfilCompleto();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Ganaste ${AppConstants.creditosPorPerfilCompleto} créditos! 🎉'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Comprar paquete de créditos
  void _comprarPaquete(String nombre, int creditos, double precio) {
    context.push('/payments');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Sistema de pagos'),
      ),
    );
  }

  /// Obtiene descripción del origen
  String _obtenerDescripcionOrigen(String origen) {
    switch (origen) {
      case AppConstants.origenRegistroBienvenida:
        return 'Créditos de bienvenida';
      case AppConstants.origenVideoAdmob:
        return 'Video recompensado';
      case AppConstants.origenReferido:
        return 'Amigo referido';
      case AppConstants.origenCompra:
        return 'Compra de créditos';
      case AppConstants.origenPerfilCompleto:
        return 'Perfil completado';
      case AppConstants.origenResena:
        return 'Reseña escrita';
      case AppConstants.origenVerContacto:
        return 'Ver contacto profesional';
      case AppConstants.origenPublicarSolicitud:
        return 'Publicar solicitud';
      default:
        return origen;
    }
  }

  /// Formatea la fecha
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final now = DateTime.now();
    final diff = now.difference(fecha);

    if (diff.inDays > 0) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace unos segundos';
    }
  }
}
