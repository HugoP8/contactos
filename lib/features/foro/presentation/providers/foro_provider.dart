import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pregunta_model.dart';
import '../../data/models/respuesta_model.dart';
import '../../data/repositories/foro_repository.dart';

// ==========================================
// PROVIDERS DE REPOSITORY
// ==========================================

/// Provider del repositorio del foro
final foroRepositoryProvider = Provider<ForoRepository>((ref) {
  return ForoRepository();
});

// ==========================================
// ESTADO DE PREGUNTAS
// ==========================================

/// Estado de las preguntas del foro
class PreguntasState {
  final List<PreguntaModel> preguntas;
  final bool isLoading;
  final String? error;
  final String? categoriaSeleccionada;
  final String ordenamiento;

  const PreguntasState({
    this.preguntas = const [],
    this.isLoading = false,
    this.error,
    this.categoriaSeleccionada,
    this.ordenamiento = 'reciente',
  });

  PreguntasState copyWith({
    List<PreguntaModel>? preguntas,
    bool? isLoading,
    String? error,
    String? categoriaSeleccionada,
    String? ordenamiento,
  }) {
    return PreguntasState(
      preguntas: preguntas ?? this.preguntas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      ordenamiento: ordenamiento ?? this.ordenamiento,
    );
  }
}

/// Provider de preguntas del foro
final preguntasProvider =
    StateNotifierProvider<PreguntasNotifier, PreguntasState>((ref) {
  final repository = ref.watch(foroRepositoryProvider);
  return PreguntasNotifier(repository);
});

/// Notifier para manejar las preguntas
class PreguntasNotifier extends StateNotifier<PreguntasState> {
  PreguntasNotifier(this._repository) : super(const PreguntasState()) {
    cargarPreguntas();
  }

  final ForoRepository _repository;

  /// Carga las preguntas del foro
  Future<void> cargarPreguntas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preguntas = await _repository.obtenerPreguntas(
        categoria: state.categoriaSeleccionada,
        ordenarPor: state.ordenamiento,
      );

      state = state.copyWith(
        preguntas: preguntas,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar preguntas: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las preguntas',
      );
    }
  }

  /// Filtra por categoría
  void filtrarPorCategoria(String? categoria) {
    state = state.copyWith(categoriaSeleccionada: categoria);
    cargarPreguntas();
  }

  /// Cambia el ordenamiento
  void cambiarOrdenamiento(String ordenamiento) {
    state = state.copyWith(ordenamiento: ordenamiento);
    cargarPreguntas();
  }

  /// Busca preguntas por texto
  Future<void> buscarPreguntas(String query) async {
    if (query.isEmpty) {
      cargarPreguntas();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final preguntas = await _repository.buscarPreguntas(query);

      state = state.copyWith(
        preguntas: preguntas,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al buscar preguntas: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al buscar preguntas',
      );
    }
  }

  /// Crea una nueva pregunta
  Future<PreguntaModel?> crearPregunta({
    required String userId,
    required String titulo,
    required String descripcion,
    required String categoria,
    List<String>? imagenes,
  }) async {
    try {
      final pregunta = await _repository.crearPregunta(
        userId: userId,
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        imagenes: imagenes,
      );

      if (pregunta != null) {
        // Agregar la nueva pregunta al inicio de la lista
        state = state.copyWith(
          preguntas: [pregunta, ...state.preguntas],
        );
      }

      return pregunta;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear pregunta: $e');
      }
      return null;
    }
  }

  /// Elimina una pregunta
  Future<bool> eliminarPregunta(String preguntaId) async {
    try {
      final success = await _repository.eliminarPregunta(preguntaId);

      if (success) {
        // Eliminar de la lista
        state = state.copyWith(
          preguntas: state.preguntas
              .where((p) => p.id != preguntaId)
              .toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar pregunta: $e');
      }
      return false;
    }
  }

  /// Refresca las preguntas
  Future<void> refresh() async {
    await cargarPreguntas();
  }
}

// ==========================================
// ESTADO DE RESPUESTAS
// ==========================================

/// Estado de las respuestas de una pregunta
class RespuestasState {
  final List<RespuestaModel> respuestas;
  final bool isLoading;
  final String? error;

  const RespuestasState({
    this.respuestas = const [],
    this.isLoading = false,
    this.error,
  });

  RespuestasState copyWith({
    List<RespuestaModel>? respuestas,
    bool? isLoading,
    String? error,
  }) {
    return RespuestasState(
      respuestas: respuestas ?? this.respuestas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider de respuestas (por pregunta)
final respuestasProvider = StateNotifierProvider.family<RespuestasNotifier,
    RespuestasState, String>((ref, preguntaId) {
  final repository = ref.watch(foroRepositoryProvider);
  return RespuestasNotifier(repository, preguntaId);
});

/// Notifier para manejar las respuestas
class RespuestasNotifier extends StateNotifier<RespuestasState> {
  RespuestasNotifier(this._repository, this._preguntaId)
      : super(const RespuestasState()) {
    cargarRespuestas();
  }

  final ForoRepository _repository;
  final String _preguntaId;

  /// Carga las respuestas de una pregunta
  Future<void> cargarRespuestas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final respuestas = await _repository.obtenerRespuestas(_preguntaId);

      state = state.copyWith(
        respuestas: respuestas,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar respuestas: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las respuestas',
      );
    }
  }

  /// Crea una nueva respuesta
  Future<RespuestaModel?> crearRespuesta({
    required String userId,
    required String contenido,
    List<String>? imagenes,
  }) async {
    try {
      final respuesta = await _repository.crearRespuesta(
        preguntaId: _preguntaId,
        userId: userId,
        contenido: contenido,
        imagenes: imagenes,
      );

      if (respuesta != null) {
        // Agregar la nueva respuesta al final de la lista
        state = state.copyWith(
          respuestas: [...state.respuestas, respuesta],
        );
      }

      return respuesta;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear respuesta: $e');
      }
      return null;
    }
  }

  /// Vota por una respuesta
  Future<bool> votarRespuesta(String respuestaId) async {
    try {
      final success = await _repository.votarRespuesta(respuestaId);

      if (success) {
        // Actualizar el contador de votos localmente
        state = state.copyWith(
          respuestas: state.respuestas.map((r) {
            if (r.id == respuestaId) {
              return r.copyWith(totalVotos: r.totalVotos + 1);
            }
            return r;
          }).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al votar respuesta: $e');
      }
      return false;
    }
  }

  /// Elimina una respuesta
  Future<bool> eliminarRespuesta(String respuestaId) async {
    try {
      final success = await _repository.eliminarRespuesta(
        respuestaId: respuestaId,
        preguntaId: _preguntaId,
      );

      if (success) {
        // Eliminar de la lista
        state = state.copyWith(
          respuestas: state.respuestas
              .where((r) => r.id != respuestaId)
              .toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar respuesta: $e');
      }
      return false;
    }
  }

  /// Refresca las respuestas
  Future<void> refresh() async {
    await cargarRespuestas();
  }

  /// Marca una respuesta como mejor respuesta
  Future<bool> marcarComoMejorRespuesta({
    required String respuestaId,
    required String userId,
  }) async {
    try {
      final success = await _repository.marcarComoResuelta(
        preguntaId: _preguntaId,
        mejorRespuestaId: respuestaId,
      );

      if (success) {
        // Actualizar el estado local
        state = state.copyWith(
          respuestas: state.respuestas.map((r) {
            return r.copyWith(
              esMejorRespuesta: r.id == respuestaId,
            );
          }).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al marcar como mejor respuesta: $e');
      }
      return false;
    }
  }
}

// ==========================================
// PROVIDER DE DETALLE DE PREGUNTA
// ==========================================

/// Provider para obtener una pregunta específica
final preguntaDetalleProvider =
    FutureProvider.family<PreguntaModel?, String>((ref, preguntaId) async {
  final repository = ref.watch(foroRepositoryProvider);
  return await repository.obtenerPregunta(preguntaId);
});
