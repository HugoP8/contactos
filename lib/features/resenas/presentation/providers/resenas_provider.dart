import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/resena_model.dart';
import '../../data/repositories/resenas_repository.dart';

// ==========================================
// PROVIDER DE REPOSITORY
// ==========================================

/// Provider del repositorio de reseñas
final resenasRepositoryProvider = Provider<ResenasRepository>((ref) {
  return ResenasRepository();
});

// ==========================================
// ESTADO DE RESEÑAS
// ==========================================

/// Estado de las reseñas de un profesional
class ResenasState {
  final List<ResenaModel> resenas;
  final bool isLoading;
  final String? error;
  final int totalResenas;
  final double calificacionPromedio;
  final Map<int, int> distribucion;

  const ResenasState({
    this.resenas = const [],
    this.isLoading = false,
    this.error,
    this.totalResenas = 0,
    this.calificacionPromedio = 0.0,
    this.distribucion = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  });

  ResenasState copyWith({
    List<ResenaModel>? resenas,
    bool? isLoading,
    String? error,
    int? totalResenas,
    double? calificacionPromedio,
    Map<int, int>? distribucion,
  }) {
    return ResenasState(
      resenas: resenas ?? this.resenas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalResenas: totalResenas ?? this.totalResenas,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      distribucion: distribucion ?? this.distribucion,
    );
  }
}

/// Provider de reseñas de un profesional
final resenasProvider = StateNotifierProvider.family<ResenasNotifier,
    ResenasState, String>((ref, profesionalId) {
  final repository = ref.watch(resenasRepositoryProvider);
  return ResenasNotifier(repository, profesionalId);
});

/// Notifier para manejar las reseñas
class ResenasNotifier extends StateNotifier<ResenasState> {
  ResenasNotifier(this._repository, this._profesionalId)
      : super(const ResenasState()) {
    cargarResenas();
  }

  final ResenasRepository _repository;
  final String _profesionalId;

  /// Carga las reseñas del profesional
  Future<void> cargarResenas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Cargar reseñas
      final resenas = await _repository.obtenerResenasDeProfesional(
        profesionalId: _profesionalId,
      );

      // Cargar estadísticas
      final total = await _repository.obtenerTotalResenas(_profesionalId);
      final promedio =
          await _repository.obtenerCalificacionPromedio(_profesionalId);
      final distribucion =
          await _repository.obtenerDistribucionCalificaciones(_profesionalId);

      state = state.copyWith(
        resenas: resenas,
        totalResenas: total,
        calificacionPromedio: promedio,
        distribucion: distribucion,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar reseñas: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las reseñas',
      );
    }
  }

  /// Crea una nueva reseña
  Future<ResenaModel?> crearResena({
    required String userId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      final resena = await _repository.crearResena(
        profesionalId: _profesionalId,
        userId: userId,
        calificacion: calificacion,
        comentario: comentario,
      );

      if (resena != null) {
        // Recargar todas las reseñas y estadísticas
        await cargarResenas();
      }

      return resena;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear reseña: $e');
      }
      return null;
    }
  }

  /// Actualiza una reseña
  Future<bool> actualizarResena({
    required String resenaId,
    required String userId,
    int? calificacion,
    String? comentario,
  }) async {
    try {
      final success = await _repository.actualizarResena(
        resenaId: resenaId,
        userId: userId,
        calificacion: calificacion,
        comentario: comentario,
      );

      if (success) {
        // Recargar
        await cargarResenas();
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar reseña: $e');
      }
      return false;
    }
  }

  /// Elimina una reseña
  Future<bool> eliminarResena({
    required String resenaId,
    required String userId,
  }) async {
    try {
      final success = await _repository.eliminarResena(
        resenaId: resenaId,
        userId: userId,
      );

      if (success) {
        // Recargar
        await cargarResenas();
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar reseña: $e');
      }
      return false;
    }
  }

  /// Responde a una reseña (solo profesionales)
  Future<bool> responderResena({
    required String resenaId,
    required String respuesta,
  }) async {
    try {
      final success = await _repository.responderResena(
        resenaId: resenaId,
        profesionalId: _profesionalId,
        respuesta: respuesta,
      );

      if (success) {
        // Actualizar localmente
        state = state.copyWith(
          resenas: state.resenas.map((r) {
            if (r.id == resenaId) {
              return r.copyWith(respuesta: respuesta);
            }
            return r;
          }).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al responder reseña: $e');
      }
      return false;
    }
  }

  /// Reporta una reseña
  Future<bool> reportarResena({
    required String resenaId,
    required String userId,
    required String motivo,
  }) async {
    try {
      return await _repository.reportarResena(
        resenaId: resenaId,
        userId: userId,
        motivo: motivo,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al reportar reseña: $e');
      }
      return false;
    }
  }

  /// Refresca las reseñas
  Future<void> refresh() async {
    await cargarResenas();
  }
}

// ==========================================
// PROVIDERS AUXILIARES
// ==========================================

/// Provider para verificar si el usuario ya reseñó al profesional
final yaResenoProvider = FutureProvider.family
    .autoDispose<bool, ({String profesionalId, String userId})>(
  (ref, params) async {
    final repository = ref.watch(resenasRepositoryProvider);
    return await repository.yaReseno(
      profesionalId: params.profesionalId,
      userId: params.userId,
    );
  },
);

/// Provider para verificar si el usuario puede reseñar
final puedeResenarProvider = FutureProvider.family
    .autoDispose<bool, ({String profesionalId, String userId})>(
  (ref, params) async {
    final repository = ref.watch(resenasRepositoryProvider);
    return await repository.puedeResenar(
      profesionalId: params.profesionalId,
      userId: params.userId,
    );
  },
);

/// Provider de reseñas escritas por un usuario
final misResenasProvider =
    FutureProvider.family.autoDispose<List<ResenaModel>, String>(
  (ref, userId) async {
    final repository = ref.watch(resenasRepositoryProvider);
    return await repository.obtenerResenasDeUsuario(userId);
  },
);
