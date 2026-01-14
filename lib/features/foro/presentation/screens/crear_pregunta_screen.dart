import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/foro_provider.dart';

/// Pantalla para crear una nueva pregunta en el foro
class CrearPreguntaScreen extends ConsumerStatefulWidget {
  const CrearPreguntaScreen({super.key});

  @override
  ConsumerState<CrearPreguntaScreen> createState() =>
      _CrearPreguntaScreenState();
}

class _CrearPreguntaScreenState extends ConsumerState<CrearPreguntaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _categoriaSeleccionada = AppConstants.categoriasForo.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _publicarPregunta() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    // Verificar créditos
    if (user.creditos < AppConstants.costoPublicarPreguntaForo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitas ${AppConstants.costoPublicarPreguntaForo} créditos para publicar una pregunta',
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      context.push('/creditos');
      return;
    }

    // Confirmar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Publicar pregunta'),
        content: Text(
          '¿Deseas publicar esta pregunta por ${AppConstants.costoPublicarPreguntaForo} créditos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Publicar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      // Descontar créditos primero
      final creditosDescontados = await SupabaseService.instance.descontarCreditos(
        userId: user.id,
        cantidad: AppConstants.costoPublicarPreguntaForo,
        motivo: 'publicar_pregunta_foro',
      );

      if (!creditosDescontados) {
        throw Exception('Error al descontar créditos');
      }

      // Crear pregunta
      final pregunta = await ref.read(preguntasProvider.notifier).crearPregunta(
            userId: user.id,
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
          );

      if (pregunta != null && mounted) {
        // Actualizar créditos del usuario
        ref.invalidate(authProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pregunta publicada exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Ir al detalle de la pregunta
        context.go('/foro/${pregunta.id}');
      } else {
        throw Exception('Error al crear la pregunta');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Pregunta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner informativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.info.withOpacity(0.1),
                    AppTheme.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppTheme.info),
                      const SizedBox(width: 8),
                      Text(
                        'Costo: ${AppConstants.costoPublicarPreguntaForo} créditos',
                        style: TextStyle(
                          color: AppTheme.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu saldo actual: ${user?.creditos ?? 0} créditos',
                    style: TextStyle(
                      color: AppTheme.grey700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categoría
            Text(
              'Categoría',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: AppConstants.categoriasForo.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Título',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: '¿Cuál es tu pregunta?',
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un título';
                }
                if (value.trim().length < 10) {
                  return 'El título debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(
                hintText: 'Describe tu pregunta con más detalle...',
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                if (value.trim().length < 20) {
                  return 'La descripción debe tener al menos 20 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Botón publicar
            ElevatedButton(
              onPressed: _isLoading ? null : _publicarPregunta,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Publicar por ${AppConstants.costoPublicarPreguntaForo} créditos',
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
}
