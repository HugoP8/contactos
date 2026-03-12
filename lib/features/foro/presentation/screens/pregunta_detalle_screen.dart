import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/foro_provider.dart';
import '../../data/models/pregunta_model.dart';
import '../../data/models/respuesta_model.dart';

/// Pantalla de detalle de una pregunta del foro
class PreguntaDetalleScreen extends ConsumerStatefulWidget {
  final String preguntaId;

  const PreguntaDetalleScreen({
    super.key,
    required this.preguntaId,
  });

  @override
  ConsumerState<PreguntaDetalleScreen> createState() =>
      _PreguntaDetalleScreenState();
}

class _PreguntaDetalleScreenState
    extends ConsumerState<PreguntaDetalleScreen> {
  final _respuestaController = TextEditingController();
  bool _isEnviando = false;

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  Future<void> _enviarRespuesta() async {
    final contenido = _respuestaController.text.trim();
    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Escribe una respuesta')),
      );
      return;
    }

    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    setState(() => _isEnviando = true);

    try {
      final respuesta = await ref
          .read(respuestasProvider(widget.preguntaId).notifier)
          .crearRespuesta(
            userId: user.id,
            contenido: contenido,
          );

      if (respuesta != null && mounted) {
        _respuestaController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Respuesta publicada'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Refrescar la pregunta para actualizar el contador
        ref.invalidate(preguntaDetalleProvider(widget.preguntaId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isEnviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preguntaAsync = ref.watch(preguntaDetalleProvider(widget.preguntaId));
    final respuestasState = ref.watch(respuestasProvider(widget.preguntaId));
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Pregunta'),
      ),
      body: preguntaAsync.when(
        data: (pregunta) {
          if (pregunta == null) {
            return const Center(
              child: Text('Pregunta no encontrada'),
            );
          }

          return Column(
            children: [
              // Pregunta
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Card de la pregunta
                    _buildPreguntaCard(pregunta, user),
                    const SizedBox(height: 24),

                    // Título de respuestas
                    Row(
                      children: [
                        Icon(Icons.comment, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Respuestas (${pregunta.totalRespuestas})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista de respuestas
                    _buildListaRespuestas(respuestasState, pregunta, user),
                  ],
                ),
              ),

              // Campo de respuesta
              if (!pregunta.resuelta)
                _buildCampoRespuesta(),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(preguntaDetalleProvider(widget.preguntaId));
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de la pregunta
  Widget _buildPreguntaCard(PreguntaModel pregunta, dynamic user) {
    final esMiPregunta = user != null && pregunta.userId == user.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuario y categoría
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.grey200,
                  backgroundImage: pregunta.usuarioFoto != null
                      ? CachedNetworkImageProvider(pregunta.usuarioFoto!)
                      : null,
                  child: pregunta.usuarioFoto == null
                      ? Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pregunta.usuarioNombre ?? 'Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pregunta.tiempoTranscurrido,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pregunta.categoria,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              pregunta.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Descripción
            Text(
              pregunta.descripcion,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.grey700,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),

            // Estado
            if (pregunta.resuelta)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pregunta resuelta',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Lista de respuestas
  Widget _buildListaRespuestas(
    RespuestasState state,
    PreguntaModel pregunta,
    dynamic user,
  ) {
    if (state.isLoading && state.respuestas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.error!,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.respuestas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 64,
                color: AppTheme.grey400,
              ),
              const SizedBox(height: 16),
              Text('Aún no hay respuestas'),
              const SizedBox(height: 8),
              Text(
                '¡Sé el primero en responder!',
                style: TextStyle(
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: state.respuestas.map((respuesta) {
        return _buildRespuestaCard(respuesta, pregunta, user);
      }).toList(),
    );
  }

  /// Card de respuesta
  Widget _buildRespuestaCard(
    RespuestaModel respuesta,
    PreguntaModel pregunta,
    dynamic user,
  ) {
    final esMiRespuesta = user != null && respuesta.userId == user.id;
    final esMiPregunta = user != null && pregunta.userId == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: respuesta.esMejorRespuesta
          ? AppTheme.successColor.withOpacity(0.05)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuario
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.grey200,
                  backgroundImage: respuesta.usuarioFoto != null
                      ? CachedNetworkImageProvider(respuesta.usuarioFoto!)
                      : null,
                  child: respuesta.usuarioFoto == null
                      ? Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            respuesta.usuarioNombre ?? 'Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (respuesta.usuarioVerificado == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        respuesta.tiempoTranscurrido,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de mejor respuesta
                if (respuesta.esMejorRespuesta)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Mejor respuesta',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Contenido
            Text(
              respuesta.contenido,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 12),

            // Acciones
            Row(
              children: [
                // Votos
                TextButton.icon(
                  onPressed: () async {
                    await ref
                        .read(respuestasProvider(pregunta.id).notifier)
                        .votarRespuesta(respuesta.id);
                  },
                  icon: Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: AppTheme.grey600,
                  ),
                  label: Text(
                    '${respuesta.totalVotos}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.grey600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const Spacer(),

                // Marcar como mejor respuesta (solo el autor de la pregunta)
                if (esMiPregunta &&
                    !pregunta.resuelta &&
                    !respuesta.esMejorRespuesta)
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.emoji_events, color: AppTheme.accent),
                              const SizedBox(width: 8),
                              Text('Premiar respuesta'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Marcar esta respuesta como la mejor?',
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppTheme.successColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'El autor de esta respuesta recibirá 2 créditos como premio.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.successColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context, true),
                              icon: Icon(Icons.check),
                              label: Text('Premiar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        final success = await ref
                            .read(respuestasProvider(pregunta.id).notifier)
                            .marcarComoMejorRespuesta(
                              respuestaId: respuesta.id,
                              userId: user!.id,
                            );

                        if (success && mounted) {
                          // Refrescar la pregunta
                          ref.invalidate(preguntaDetalleProvider(widget.preguntaId));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('Respuesta premiada correctamente'),
                                ],
                              ),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al premiar la respuesta'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: AppTheme.accent,
                    ),
                    label: Text(
                      'Premiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Campo para escribir respuesta
  Widget _buildCampoRespuesta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _respuestaController,
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  filled: true,
                  fillColor: AppTheme.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: IconButton(
                icon: _isEnviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.send, color: Colors.white),
                onPressed: _isEnviando ? null : _enviarRespuesta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
