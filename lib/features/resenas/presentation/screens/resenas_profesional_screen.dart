import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resenas_provider.dart';
import '../../data/models/resena_model.dart';

/// Pantalla para ver todas las reseñas de un profesional
class ResenasProfesionalScreen extends ConsumerWidget {
  final String profesionalId;
  final String? profesionalNombre;

  const ResenasProfesionalScreen({
    super.key,
    required this.profesionalId,
    this.profesionalNombre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resenasState = ref.watch(resenasProvider(profesionalId));
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(profesionalNombre ?? 'Reseñas'),
      ),
      body: Column(
        children: [
          // Header con estadísticas
          _buildHeader(context, resenasState),

          const Divider(height: 1),

          // Lista de reseñas
          Expanded(
            child: _buildListaResenas(context, ref, resenasState, user),
          ),
        ],
      ),
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Verificar si ya reseñó
                final yaReseno = await ref.read(
                  yaResenoProvider((
                    profesionalId: profesionalId,
                    userId: user.id,
                  )).future,
                );

                if (yaReseno && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ya has reseñado a este profesional'),
                    ),
                  );
                  return;
                }

                if (context.mounted) {
                  context.push(
                    '/profesional/$profesionalId/resena/crear',
                  );
                }
              },
              icon: Icon(Icons.rate_review),
              label: Text('Escribir Reseña'),
            )
          : null,
    );
  }

  /// Header con estadísticas
  Widget _buildHeader(BuildContext context, ResenasState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Calificación promedio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 48,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.calificacionPromedio.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${state.totalResenas} reseñas',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Distribución de estrellas
          ...List.generate(5, (index) {
            final estrellas = 5 - index;
            final cantidad = state.distribucion[estrellas] ?? 0;
            final porcentaje = state.totalResenas > 0
                ? (cantidad / state.totalResenas) * 100
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$estrellas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, size: 14, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje / 100,
                        minHeight: 8,
                        backgroundColor: AppTheme.grey200,
                        valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$cantidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Lista de reseñas
  Widget _buildListaResenas(
    BuildContext context,
    WidgetRef ref,
    ResenasState state,
    dynamic user,
  ) {
    if (state.isLoading && state.resenas.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(resenasProvider(profesionalId).notifier).refresh();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.resenas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppTheme.grey400,
            ),
            const SizedBox(height: 16),
            Text('Aún no hay reseñas'),
            const SizedBox(height: 8),
            Text(
              '¡Sé el primero en reseñar!',
              style: TextStyle(
                color: AppTheme.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(resenasProvider(profesionalId).notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.resenas.length,
        itemBuilder: (context, index) {
          final resena = state.resenas[index];
          final esMiResena = user != null && resena.userId == user.id;
          return _buildResenaCard(context, ref, resena, esMiResena);
        },
      ),
    );
  }

  /// Card de reseña
  Widget _buildResenaCard(
    BuildContext context,
    WidgetRef ref,
    ResenaModel resena,
    bool esMiResena,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuario y fecha
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.grey200,
                  backgroundImage: resena.usuarioFoto != null
                      ? CachedNetworkImageProvider(resena.usuarioFoto!)
                      : null,
                  child: resena.usuarioFoto == null
                      ? Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            resena.usuarioNombre ?? 'Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (esMiResena) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tú',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        resena.tiempoTranscurrido,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Opciones
                if (esMiResena)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: AppTheme.grey600),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'eliminar') {
                        _confirmarEliminar(context, ref, resena);
                      } else if (value == 'editar') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Editar próximamente'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Calificación
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < resena.calificacion ? Icons.star : Icons.star_border,
                  size: 18,
                  color: AppTheme.accent,
                );
              }),
            ),
            const SizedBox(height: 8),

            // Comentario
            if (resena.comentario != null) ...[
              Text(
                resena.comentario!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],

            // Respuesta del profesional
            if (resena.respuesta != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Respuesta del profesional:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resena.respuesta!,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    ResenaModel resena,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar reseña'),
        content: Text('¿Estás seguro de que deseas eliminar esta reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      final success = await ref
          .read(resenasProvider(profesionalId).notifier)
          .eliminarResena(
            resenaId: resena.id,
            userId: user.id,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reseña eliminada'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la reseña'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
