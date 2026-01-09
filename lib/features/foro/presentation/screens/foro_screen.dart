import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Pantalla principal del Foro "Alguien Sabe?"
class ForoScreen extends ConsumerStatefulWidget {
  const ForoScreen({super.key});

  @override
  ConsumerState<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends ConsumerState<ForoScreen> {
  String? _categoriaFiltro;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alguien Sabe? 🤔'),
        actions: [
          // Filtro de categoría
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (categoria) {
              setState(() {
                _categoriaFiltro = categoria == 'Todas' ? null : categoria;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todas',
                child: Text('Todas las categorías'),
              ),
              const PopupMenuDivider(),
              ...AppConstants.categoriasForo.map(
                (cat) => PopupMenuItem(
                  value: cat,
                  child: Text(cat),
                ),
              ).toList(),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo
          Container(
            margin: const EdgeInsets.all(16),
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
                    Icon(Icons.lightbulb, color: AppTheme.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¿Tienes una pregunta?',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.info,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pregunta lo que sea: servicios, rutas, consejos, etc.\n'
                  'Cuesta ${AppConstants.costoPublicarPreguntaForo} créditos.\n'
                  'Premia con ${AppConstants.creditosPorMejorRespuestaForo} créditos a quien te ayude.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey700,
                      ),
                ),
              ],
            ),
          ),

          // Filtro activo
          if (_categoriaFiltro != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Categoría: $_categoriaFiltro',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _categoriaFiltro = null);
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Lista de preguntas
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Refrescar preguntas
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5, // TODO: Cargar preguntas reales
                itemBuilder: (context, index) {
                  return _buildPreguntaCardPlaceholder(context);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión')),
            );
            return;
          }

          if (user.creditos < AppConstants.costoPublicarPreguntaForo) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Necesitas ${AppConstants.costoPublicarPreguntaForo} créditos para preguntar',
                ),
                backgroundColor: AppTheme.error,
              ),
            );
            return;
          }

          // TODO: Ir a crear pregunta
          context.push('/foro/crear');
        },
        icon: const Icon(Icons.add),
        label: const Text('Preguntar'),
      ),
    );
  }

  /// Card placeholder de pregunta (temporal)
  Widget _buildPreguntaCardPlaceholder(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Ir a detalle de pregunta
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usuario y tiempo
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.grey200,
                    child: Icon(Icons.person, size: 16, color: AppTheme.grey400),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario ejemplo',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          'Hace 2 horas',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Servicios',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                '¿Alguien conoce un buen electricista en La Paz?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Contenido
              Text(
                'Necesito que revisen la instalación eléctrica de mi casa, se van mucho las luces...',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  Icon(Icons.comment_outlined, size: 16, color: AppTheme.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '3 respuestas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    'Resuelta',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
