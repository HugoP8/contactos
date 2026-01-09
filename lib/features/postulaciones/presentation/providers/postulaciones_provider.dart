import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/postulacion_model.dart';
import '../../data/repositories/postulaciones_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provider del repositorio
final postulacionesRepositoryProvider = Provider<PostulacionesRepository>((ref) {
  return PostulacionesRepository();
});

/// Estado de postulaciones
class PostulacionesState {
  final List<PostulacionModel> postulaciones;
  final bool isLoading;
  final String? error;

  const PostulacionesState({
    this.postulaciones = const [],
    this.isLoading = false,
    this.error,
  });

  PostulacionesState copyWith({
    List<PostulacionModel>? postulaciones,
    bool? isLoading,
    String? error,
  }) {
    return PostulacionesState(
      postulaciones: postulaciones ?? this.postulaciones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider para postulaciones de una solicitud específica
final postulacionesDeSolicitudProvider = StateNotifierProvider.family<
    PostulacionesSolicitudNotifier,
    PostulacionesState,
    String>((ref, solicitudId) {
  return PostulacionesSolicitudNotifier(ref, solicitudId);
});

/// Notifier para postulaciones de una solicitud
class PostulacionesSolicitudNotifier extends StateNotifier<PostulacionesState> {
  PostulacionesSolicitudNotifier(this.ref, this.solicitudId)
      : super(const PostulacionesState()) {
    cargarPostulaciones();
  }

  final Ref ref;
  final String solicitudId;

  /// Carga las postulaciones de la solicitud
  Future<void> cargarPostulaciones() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(postulacionesRepositoryProvider);
      final postulaciones = await repository.obtenerPostulacionesDeSolicitud(solicitudId);

      state = state.copyWith(
        postulaciones: postulaciones,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar postulaciones: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar postulaciones',
      );
    }
  }

  /// Acepta una postulación
  Future<void> aceptarPostulacion(String postulacionId) async {
    try {
      final repository = ref.read(postulacionesRepositoryProvider);
      await repository.aceptarPostulacion(postulacionId);
      await cargarPostulaciones();
    } catch (e) {
      if (kDebugMode) {
        print('Error al aceptar postulación: $e');
      }
      rethrow;
    }
  }

  /// Rechaza una postulación
  Future<void> rechazarPostulacion(String postulacionId) async {
    try {
      final repository = ref.read(postulacionesRepositoryProvider);
      await repository.rechazarPostulacion(postulacionId);
      await cargarPostulaciones();
    } catch (e) {
      if (kDebugMode) {
        print('Error al rechazar postulación: $e');
      }
      rethrow;
    }
  }

  /// Refresca las postulaciones
  Future<void> refresh() async {
    await cargarPostulaciones();
  }
}

/// Provider para crear postulaciones
final crearPostulacionProvider = Provider<CrearPostulacionActions>((ref) {
  return CrearPostulacionActions(ref);
});

/// Acciones para crear postulaciones
class CrearPostulacionActions {
  final Ref ref;

  CrearPostulacionActions(this.ref);

  /// Crea una nueva postulación
  Future<PostulacionModel> crearPostulacion({
    required String solicitudId,
    required String mensaje,
    double? presupuestoOfrecido,
    String? tiempoEstimado,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Obtener el perfil profesional del usuario
    // TODO: Implementar obtención de perfil profesional
    final profesionalId = user.id; // Por ahora usamos el user ID directamente

    try {
      final repository = ref.read(postulacionesRepositoryProvider);

      // Verificar si ya postuló
      final yaPostulo = await repository.yaPosulo(profesionalId, solicitudId);
      if (yaPostulo) {
        throw Exception('Ya postulaste a esta solicitud');
      }

      // Crear postulación
      final postulacion = await repository.crearPostulacion(
        solicitudId: solicitudId,
        profesionalId: profesionalId,
        mensaje: mensaje,
        presupuestoOfrecido: presupuestoOfrecido,
        tiempoEstimado: tiempoEstimado,
      );

      return postulacion;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear postulación: $e');
      }
      rethrow;
    }
  }
}
