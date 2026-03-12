import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/solicitudes_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/categoria_selector.dart';

/// Pantalla para crear una nueva solicitud de trabajo
class CrearSolicitudScreen extends ConsumerStatefulWidget {
  const CrearSolicitudScreen({super.key});

  @override
  ConsumerState<CrearSolicitudScreen> createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends ConsumerState<CrearSolicitudScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _zonaController = TextEditingController();
  final _presupuestoMinController = TextEditingController();
  final _presupuestoMaxController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _ciudadSeleccionada;
  String _urgencia = AppConstants.urgenciaNormal;
  bool _isLoading = false;
  bool _tieneTokenGratuito = false;
  bool _verificandoToken = true;
  String _tipoPresupuesto = 'Negociable';
  String _tiempoEntrega = 'Esta semana';

  @override
  void initState() {
    super.initState();
    _verificarTokenGratuito();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _zonaController.dispose();
    _presupuestoMinController.dispose();
    _presupuestoMaxController.dispose();
    super.dispose();
  }

  /// Verifica si el usuario tiene un token gratuito
  Future<void> _verificarTokenGratuito() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      final supabase = SupabaseService.instance;
      final tieneToken = await supabase.puedePubilcarSolicitudGratis(user.id);

      if (mounted) {
        setState(() {
          _tieneTokenGratuito = tieneToken;
          _verificandoToken = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verificandoToken = false;
        });
      }
    }
  }

  /// Maneja la creación de la solicitud
  Future<void> _handleCrearSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user == null) {
      _showErrorSnackBar('Debes iniciar sesión');
      return;
    }

    // Verificar créditos si no tiene token gratuito
    if (!_tieneTokenGratuito && user.creditos < AppConstants.costoPublicarSolicitud) {
      _showErrorSnackBar(
        'No tienes créditos suficientes. Necesitas ${AppConstants.costoPublicarSolicitud} créditos.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parsear presupuestos
      double? presupuestoMin;
      double? presupuestoMax;

      if (_presupuestoMinController.text.isNotEmpty) {
        presupuestoMin = double.tryParse(_presupuestoMinController.text);
      }
      if (_presupuestoMaxController.text.isNotEmpty) {
        presupuestoMax = double.tryParse(_presupuestoMaxController.text);
      }

      // Crear solicitud
      final solicitud = await ref.read(misSolicitudesProvider.notifier).crearSolicitud(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada!,
            ciudad: _ciudadSeleccionada!,
            zona: _zonaController.text.trim().isEmpty ? null : _zonaController.text.trim(),
            presupuestoMinimo: presupuestoMin,
            presupuestoMaximo: presupuestoMax,
            urgencia: _urgencia,
          );

      if (mounted && solicitud != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tieneTokenGratuito
                  ? '¡Solicitud creada gratis! 🎉'
                  : '¡Solicitud creada! Se descontaron ${AppConstants.costoPublicarSolicitud} créditos',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  /// Chip de presupuesto
  Widget _buildPresupuestoChip(String label, IconData icon) {
    final isSelected = _tipoPresupuesto == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppTheme.grey600,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tipoPresupuesto = label;
          if (label != 'Definir monto') {
            _presupuestoMinController.clear();
            _presupuestoMaxController.clear();
          }
        });
      },
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  /// Chip de tiempo de entrega
  Widget _buildTiempoChip(String label, IconData icon, Color color) {
    final isSelected = _tiempoEntrega == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tiempoEntrega = label;
          // Actualizar urgencia basado en tiempo
          if (label == 'Hoy') {
            _urgencia = AppConstants.urgenciaUrgente;
          } else {
            _urgencia = AppConstants.urgenciaNormal;
          }
        });
      },
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Solicitud'),
      ),
      body: _verificandoToken
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info de créditos/token gratuito
                    if (_tieneTokenGratuito)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¡Tienes 1 solicitud GRATIS! 🎉',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.info),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.info,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Costo: ${AppConstants.costoPublicarSolicitud} créditos • Tus créditos: ${user?.creditos ?? 0}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Título
                    TextFormField(
                      controller: _tituloController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Título de la solicitud *',
                        hintText: 'Ej: Necesito electricista urgente',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un título';
                        }
                        if (value.length < 10) {
                          return 'El título debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría (con buscador y opción Otro)
                    CategoriaSelector(
                      valorSeleccionado: _categoriaSeleccionada,
                      onChanged: (value) {
                        setState(() => _categoriaSeleccionada = value);
                      },
                      labelText: 'Categoría *',
                      hintText: 'Busca o selecciona una categoría',
                      mostrarOtro: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ciudad
                    DropdownButtonFormField<String>(
                      value: _ciudadSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad *',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: AppConstants.ciudades.map((ciudad) {
                        return DropdownMenuItem(
                          value: ciudad,
                          child: Text(ciudad),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _ciudadSeleccionada = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona una ciudad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Zona (opcional)
                    TextFormField(
                      controller: _zonaController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Zona (opcional)',
                        hintText: 'Ej: Zona Sur, Miraflores',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 5,
                      maxLength: AppConstants.maxLongitudDescripcion,
                      decoration: const InputDecoration(
                        labelText: 'Descripción detallada *',
                        hintText: 'Describe lo que necesitas con detalle...',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una descripción';
                        }
                        if (value.length < 20) {
                          return 'La descripción debe tener al menos 20 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Presupuesto mejorado
                    Text(
                      'Presupuesto',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Opciones rápidas de presupuesto
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresupuestoChip('Negociable', Icons.handshake),
                        _buildPresupuestoChip('A convenir', Icons.question_mark),
                        _buildPresupuestoChip('Definir monto', Icons.payments),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Campos de monto (solo si no es negociable)
                    if (_tipoPresupuesto == 'Definir monto') ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _presupuestoMinController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Mínimo (Bs.)',
                                prefixIcon: Icon(Icons.payments_outlined),
                                filled: true,
                                fillColor: AppTheme.grey50,
                              ),
                              validator: (value) {
                                if (_tipoPresupuesto == 'Definir monto' && value != null && value.isNotEmpty) {
                                  final number = double.tryParse(value);
                                  if (number == null || number <= 0) {
                                    return 'Monto inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _presupuestoMaxController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Máximo (Bs.)',
                                prefixIcon: Icon(Icons.payments_outlined),
                                filled: true,
                                fillColor: AppTheme.grey50,
                              ),
                              validator: (value) {
                                if (_tipoPresupuesto == 'Definir monto' && value != null && value.isNotEmpty) {
                                  final number = double.tryParse(value);
                                  if (number == null || number <= 0) {
                                    return 'Monto inválido';
                                  }
                                  if (_presupuestoMinController.text.isNotEmpty) {
                                    final min = double.tryParse(_presupuestoMinController.text);
                                    if (min != null && number < min) {
                                      return 'Debe ser mayor al mínimo';
                                    }
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Tiempo de entrega mejorado
                    Text(
                      '¿Cuándo lo necesitas?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTiempoChip('Hoy', Icons.bolt, AppTheme.error),
                        _buildTiempoChip('Esta semana', Icons.calendar_today, AppTheme.accent),
                        _buildTiempoChip('Este mes', Icons.date_range, AppTheme.info),
                        _buildTiempoChip('Sin prisa', Icons.access_time, AppTheme.grey500),
                      ],
                    ),
                    const SizedBox(height: 16),


                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.grey100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppTheme.grey600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información importante',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Tu solicitud estará visible por ${AppConstants.diasExpiracionSolicitud} días\n'
                            '• Los profesionales podrán postularse\n'
                            '• Recibirás notificaciones de nuevas postulaciones\n'
                            '• Puedes renovar la solicitud por ${AppConstants.costoRenovarSolicitud} créditos',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.grey600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de crear
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleCrearSolicitud,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _tieneTokenGratuito
                                  ? 'Publicar GRATIS'
                                  : 'Publicar (${AppConstants.costoPublicarSolicitud} créditos)',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
