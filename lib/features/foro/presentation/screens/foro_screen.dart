import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/foro_provider.dart';
import '../../data/models/pregunta_model.dart';

/// Pantalla principal del Foro "Alguien Sabe?"
class ForoScreen extends ConsumerStatefulWidget {
  const ForoScreen({super.key});

  @override
  ConsumerState<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends ConsumerState<ForoScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final preguntasState = ref.watch(preguntasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Alguien Sabe? 🤔'),
        actions: [
          // Filtro de categoría
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (categoria) {
              ref.read(preguntasProvider.notifier).filtrarPorCategoria(
                categoria == 'Todas' ? null : categoria,
              );
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
          if (preguntasState.categoriaSeleccionada != null)
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
                    'Categoría: ${preguntasState.categoriaSeleccionada}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(preguntasProvider.notifier).filtrarPorCategoria(null);
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
            child: _buildListaPreguntas(preguntasState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Debes iniciar sesión')),
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

          context.push('/foro/crear');
        },
        icon: Icon(Icons.add),
        label: Text('Preguntar'),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }

  /// Construye la lista de preguntas
  Widget _buildListaPreguntas(PreguntasState state) {
    // Estado de carga
    if (state.isLoading && state.preguntas.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado de error
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(preguntasProvider.notifier).cargarPreguntas();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Estado vacío
    if (state.preguntas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_answer, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text('Aún no hay preguntas'),
            const SizedBox(height: 8),
            Text(
              '¡Sé el primero en preguntar!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grey600,
                  ),
            ),
          ],
        ),
      );
    }

    // Lista de preguntas
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(preguntasProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.preguntas.length,
        itemBuilder: (context, index) {
          final pregunta = state.preguntas[index];
          return _buildPreguntaCard(pregunta);
        },
      ),
    );
  }

  /// Card de pregunta
  Widget _buildPreguntaCard(PreguntaModel pregunta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/foro/${pregunta.id}');
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
                    child: pregunta.usuarioFoto != null
                        ? ClipOval(
                            child: Image.network(
                              pregunta.usuarioFoto!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, size: 16, color: AppTheme.grey400),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pregunta.usuarioNombre ?? 'Usuario',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          pregunta.tiempoTranscurrido,
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
                      pregunta.categoria,
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
                pregunta.titulo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Contenido
              Text(
                pregunta.descripcion,
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
                    '${pregunta.totalRespuestas} respuestas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (pregunta.resuelta) ...[
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
