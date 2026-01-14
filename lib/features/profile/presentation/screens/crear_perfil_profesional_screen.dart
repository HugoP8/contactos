import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/custom_icons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/supabase_service.dart';

class CrearPerfilProfesionalScreen extends ConsumerStatefulWidget {
  final bool esEdicion;
  final String? perfilId;

  const CrearPerfilProfesionalScreen({
    Key? key,
    this.esEdicion = false,
    this.perfilId,
  }) : super(key: key);

  @override
  ConsumerState<CrearPerfilProfesionalScreen> createState() =>
      _CrearPerfilProfesionalScreenState();
}

class _CrearPerfilProfesionalScreenState
    extends ConsumerState<CrearPerfilProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _nombreComercialController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _esloganController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _precioDesdeController = TextEditingController();
  final _precioHastaController = TextEditingController();

  // Selecciones
  String? _categoriaPrincipal;
  List<String> _subcategorias = [];
  List<String> _servicios = [];
  String? _ciudad;
  List<String> _zonas = [];
  int _anosExperiencia = 0;
  bool _emiteFactura = false;
  bool _ofreceGarantia = false;
  List<String> _metodosPago = [];

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion && widget.perfilId != null) {
      _cargarPerfil();
    }
  }

  Future<void> _cargarPerfil() async {
    // TODO: Cargar datos del perfil existente
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nombreComercialController.dispose();
    _descripcionController.dispose();
    _esloganController.dispose();
    _telefonoController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _sitioWebController.dispose();
    _precioDesdeController.dispose();
    _precioHastaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar Perfil' : 'Crear Perfil Profesional'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info importante
                    _buildInfoBanner(),
                    const SizedBox(height: 24),

                    // Información básica
                    _buildSeccionTitulo('Información Básica'),
                    _buildTextField(
                      controller: _nombreComercialController,
                      label: 'Nombre Comercial *',
                      hint: 'Ej: Plomería Pérez',
                      icon: Icons.business,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _esloganController,
                      label: 'Eslogan',
                      hint: 'Ej: Calidad garantizada en cada trabajo',
                      icon: Icons.campaign,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción *',
                      hint: 'Cuéntanos sobre tus servicios...',
                      icon: Icons.description,
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    // Categoría y servicios
                    _buildSeccionTitulo('Categoría y Servicios'),
                    _buildDropdown(
                      label: 'Categoría Principal *',
                      value: _categoriaPrincipal,
                      items: AppConstants.categoriasPrincipales
                          .map((cat) => DropdownMenuItem<String>(
                                value: cat['id'] as String,
                                child: Text(cat['nombre'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaPrincipal = value;
                          _subcategorias = [];
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subcategorías (chips)
                    if (_categoriaPrincipal != null) ...[
                      Text(
                        'Subcategorías *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildChipsSelector(
                        items: _obtenerSubcategorias(_categoriaPrincipal!),
                        selectedItems: _subcategorias,
                        onChanged: (selected) {
                          setState(() => _subcategorias = selected);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Ubicación
                    _buildSeccionTitulo('Ubicación'),
                    _buildDropdown(
                      label: 'Ciudad *',
                      value: _ciudad,
                      items: AppConstants.ciudadesPrincipales
                          .map((ciudad) => DropdownMenuItem(
                                value: ciudad,
                                child: Text(ciudad),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _ciudad = value;
                          _zonas = [];
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_ciudad != null) ...[
                      Text(
                        'Zonas de Cobertura *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildChipsSelector(
                        items: _obtenerZonas(_ciudad!),
                        selectedItems: _zonas,
                        onChanged: (selected) {
                          setState(() => _zonas = selected);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Contacto
                    _buildSeccionTitulo('Información de Contacto'),
                    _buildTextField(
                      controller: _telefonoController,
                      label: 'Teléfono *',
                      hint: '+591 7123-4567',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _whatsappController,
                      label: 'WhatsApp *',
                      hint: '59171234567',
                      icon: CustomIcons.whatsapp,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'contacto@ejemplo.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _sitioWebController,
                      label: 'Sitio Web',
                      hint: 'https://ejemplo.com',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // Experiencia y precios
                    _buildSeccionTitulo('Experiencia y Precios'),
                    _buildSlider(
                      label: 'Años de Experiencia: $_anosExperiencia años',
                      value: _anosExperiencia.toDouble(),
                      min: 0,
                      max: 50,
                      onChanged: (value) {
                        setState(() => _anosExperiencia = value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _precioDesdeController,
                            label: 'Precio Desde (Bs.)',
                            hint: '50',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _precioHastaController,
                            label: 'Precio Hasta (Bs.)',
                            hint: '500',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Métodos de pago y opciones
                    _buildSeccionTitulo('Métodos de Pago y Opciones'),
                    Text(
                      'Métodos de Pago que Aceptas *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildChipsSelector(
                      items: [
                        'Efectivo',
                        'Transferencia',
                        'QR',
                        'Tarjeta',
                        'Tigo Money',
                      ],
                      selectedItems: _metodosPago,
                      onChanged: (selected) {
                        setState(() => _metodosPago = selected);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildCheckbox(
                      label: 'Emite Factura',
                      value: _emiteFactura,
                      onChanged: (value) {
                        setState(() => _emiteFactura = value ?? false);
                      },
                    ),
                    _buildCheckbox(
                      label: 'Ofrece Garantía',
                      value: _ofreceGarantia,
                      onChanged: (value) {
                        setState(() => _ofreceGarantia = value ?? false);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarPerfil,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR PERFIL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Crea tu perfil profesional!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los campos marcados con * son obligatorios. Completa tu perfil para aparecer en las búsquedas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        counterText: maxLength != null ? null : '',
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildChipsSelector({
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = List<String>.from(selectedItems);
            if (selected) {
              newSelection.add(item);
            } else {
              newSelection.remove(item);
            }
            onChanged(newSelection);
          },
          backgroundColor: AppTheme.grey100,
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          checkmarkColor: AppTheme.primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey700,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: max.toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  List<String> _obtenerSubcategorias(String categoriaId) {
    final categoria = AppConstants.categoriasPrincipales
        .firstWhere((cat) => cat['id'] == categoriaId);
    return List<String>.from(categoria['subcategorias'] as List);
  }

  List<String> _obtenerZonas(String ciudad) {
    // Zonas de ejemplo, deberías tenerlas en AppConstants
    return ['Norte', 'Sur', 'Este', 'Oeste', 'Centro'];
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_subcategorias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona al menos una subcategoría'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_zonas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona al menos una zona de cobertura'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_metodosPago.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona al menos un método de pago'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) throw Exception('Usuario no autenticado');

      final perfil = {
        'user_id': user.id,
        'nombre_comercial': _nombreComercialController.text,
        'descripcion': _descripcionController.text,
        'eslogan': _esloganController.text.isEmpty
            ? null
            : _esloganController.text,
        'categoria_principal': _categoriaPrincipal,
        'subcategorias': _subcategorias,
        'ciudad': _ciudad,
        'zonas_cobertura': _zonas,
        'telefono': _telefonoController.text,
        'whatsapp': _whatsappController.text,
        'email': _emailController.text.isEmpty ? null : _emailController.text,
        'sitio_web': _sitioWebController.text.isEmpty
            ? null
            : _sitioWebController.text,
        'años_experiencia': _anosExperiencia,
        'rango_precio_desde': _precioDesdeController.text.isEmpty
            ? null
            : double.tryParse(_precioDesdeController.text),
        'rango_precio_hasta': _precioHastaController.text.isEmpty
            ? null
            : double.tryParse(_precioHastaController.text),
        'emite_factura': _emiteFactura,
        'ofrece_garantia': _ofreceGarantia,
        'metodos_pago': _metodosPago,
        'activo': true,
        'visible_busqueda': true,
      };

      if (widget.esEdicion && widget.perfilId != null) {
        await SupabaseService.instance.client
            .from('perfiles_profesionales')
            .update(perfil)
            .eq('id', widget.perfilId!);
      } else {
        await SupabaseService.instance.client
            .from('perfiles_profesionales')
            .insert(perfil);

        // Cambiar rol del usuario a profesional
        await SupabaseService.instance.client
            .from('users')
            .update({'rol': 'profesional'})
            .eq('id', user.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.esEdicion
                  ? '✅ Perfil actualizado correctamente'
                  : '✅ Perfil creado correctamente',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Refrescar usuario
        await ref.read(authProvider.notifier).refreshUser();

        // Volver atrás
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
