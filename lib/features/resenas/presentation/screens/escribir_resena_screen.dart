import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resenas_provider.dart';

/// Pantalla para escribir una reseña
class EscribirResenaScreen extends ConsumerStatefulWidget {
  final String profesionalId;
  final String? profesionalNombre;

  const EscribirResenaScreen({
    super.key,
    required this.profesionalId,
    this.profesionalNombre,
  });

  @override
  ConsumerState<EscribirResenaScreen> createState() =>
      _EscribirResenaScreenState();
}

class _EscribirResenaScreenState extends ConsumerState<EscribirResenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  int _calificacion = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _publicarResena() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resena = await ref
          .read(resenasProvider(widget.profesionalId).notifier)
          .crearResena(
            usuarioId: user.id,
            calificacion: _calificacion,
            contenido: _comentarioController.text.trim().isEmpty
                ? null
                : _comentarioController.text.trim(),
          );

      if (resena != null && mounted) {
        // Actualizar el auth para reflejar los créditos ganados
        ref.invalidate(authProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Reseña publicada! Ganaste ${AppConstants.creditosPorResena} créditos',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Volver atrás
        context.pop();
      } else {
        throw Exception('Error al crear la reseña');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Escribir Reseña'),
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
                    AppTheme.accent.withOpacity(0.1),
                    AppTheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppTheme.accent, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Gana ${AppConstants.creditosPorResena} créditos!',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Comparte tu experiencia y ayuda a otros usuarios',
                          style: TextStyle(
                            color: AppTheme.grey700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profesional
            if (widget.profesionalNombre != null) ...[
              Text(
                'Calificando a:',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.grey600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.profesionalNombre!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
            ],

            // Selector de calificación
            Center(
              child: Column(
                children: [
                  Text(
                    'Tu calificación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final estrella = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _calificacion = estrella;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            _calificacion >= estrella
                                ? Icons.star
                                : Icons.star_border,
                            size: 48,
                            color: AppTheme.accent,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _obtenerTextoCalificacion(_calificacion),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Comentario
            Text(
              'Tu opinión',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _comentarioController,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia... (opcional)',
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
                // El comentario es opcional, pero si lo escribe debe tener al menos 10 caracteres
                if (value != null &&
                    value.trim().isNotEmpty &&
                    value.trim().length < 10) {
                  return 'El comentario debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Botón publicar
            ElevatedButton(
              onPressed: _isLoading ? null : _publicarResena,
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
                      'Publicar Reseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Nota
            Center(
              child: Text(
                'Tu reseña será visible para todos los usuarios',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerTextoCalificacion(int calificacion) {
    switch (calificacion) {
      case 5:
        return 'Excelente';
      case 4:
        return 'Muy bueno';
      case 3:
        return 'Bueno';
      case 2:
        return 'Regular';
      case 1:
        return 'Malo';
      default:
        return '';
    }
  }
}
