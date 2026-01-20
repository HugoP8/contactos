import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _whatsappController = TextEditingController();

  String? _ciudadSeleccionada;
  String? _zonaSeleccionada;
  XFile? _imagenSeleccionada;
  Uint8List? _imagenBytes;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosActuales();
  }

  void _cargarDatosActuales() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      _nombreController.text = user.nombreCompleto ?? '';
      _telefonoController.text = user.telefono ?? '';
      _whatsappController.text = user.whatsapp ?? '';
      _ciudadSeleccionada = user.ciudad;
      _zonaSeleccionada = user.zona;
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imagenSeleccionada = image;
          _imagenBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<String?> _subirImagen() async {
    if (_imagenSeleccionada == null || _imagenBytes == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) return null;

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final supabase = ref.read(authProvider.notifier).supabase;
      await supabase.storage
          .from(AppConstants.bucketPerfiles)
          .uploadBinary(fileName, _imagenBytes!);

      final url = supabase.storage
          .from(AppConstants.bucketPerfiles)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Subir imagen si hay una seleccionada
      String? nuevaUrlImagen;
      if (_imagenSeleccionada != null) {
        nuevaUrlImagen = await _subirImagen();
      }

      // Preparar datos a actualizar
      final Map<String, dynamic> updates = {
        'nombre_completo': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'ciudad': _ciudadSeleccionada,
        'zona': _zonaSeleccionada,
      };

      if (nuevaUrlImagen != null) {
        updates['foto_perfil'] = nuevaUrlImagen;
      }

      // Actualizar en Supabase
      await ref.read(authProvider.notifier).updateUserData(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto de perfil
              GestureDetector(
                onTap: _isLoading || _isUploadingImage ? null : _seleccionarImagen,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imagenBytes != null
                          ? MemoryImage(_imagenBytes!)
                          : (user?.fotoPerfil != null
                              ? NetworkImage(user!.fotoPerfil!)
                              : null) as ImageProvider?,
                      child: _imagenBytes == null && user?.fotoPerfil == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para cambiar foto',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              // Nombre completo
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu nombre completo';
                  }
                  if (value.trim().length < AppConstants.minLongitudNombre) {
                    return 'Mínimo ${AppConstants.minLongitudNombre} caracteres';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '12345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!AppConstants.regexTelefono.hasMatch(value)) {
                      return 'Ingresa un teléfono válido (8 dígitos)';
                    }
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // WhatsApp
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  prefixIcon: Icon(Icons.chat),
                  border: OutlineInputBorder(),
                  hintText: '12345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!AppConstants.regexTelefono.hasMatch(value)) {
                      return 'Ingresa un WhatsApp válido (8 dígitos)';
                    }
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Ciudad
              DropdownButtonFormField<String>(
                value: _ciudadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.ciudades.map((ciudad) {
                  return DropdownMenuItem(
                    value: ciudad,
                    child: Text(ciudad),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _ciudadSeleccionada = value);
                      },
              ),
              const SizedBox(height: 16),

              // Zona
              TextFormField(
                initialValue: _zonaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Zona',
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _zonaSeleccionada = value,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCambios,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}
