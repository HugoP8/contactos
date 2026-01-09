import 'package:flutter/foundation.dart';

import '../models/postulacion_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Repositorio para manejar las operaciones de postulaciones
/// Siguiendo el patrón Repository de Clean Architecture
class PostulacionesRepository {
  final _supabase = SupabaseService.instance;

  /// Obtiene las postulaciones de una solicitud específica
  Future<List<PostulacionModel>> obtenerPostulacionesDeSolicitud(
    String solicitudId,
  ) async {
    try {
      // Hacemos JOIN con la tabla de perfiles profesionales para obtener datos del profesional
      final response = await _supabase.client
          .from('postulaciones')
          .select('''
            *,
            profesional:perfiles_profesionales!profesional_id (
              nombre_comercial,
              foto_perfil,
              calificacion_promedio,
              verificado
            )
          ''')
          .eq('solicitud_id', solicitudId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        // Aplanar los datos del profesional
        final profesional = json['profesional'] as Map<String, dynamic>?;
        if (profesional != null) {
          json['profesional_nombre'] = profesional['nombre_comercial'];
          json['profesional_foto'] = profesional['foto_perfil'];
          json['profesional_calificacion'] = profesional['calificacion_promedio'];
          json['profesional_verificado'] = profesional['verificado'];
        }
        return PostulacionModel.fromJson(json);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener postulaciones: $e');
      }
      rethrow;
    }
  }

  /// Obtiene las postulaciones de un profesional específico
  Future<List<PostulacionModel>> obtenerMisPostulaciones(
    String profesionalId,
  ) async {
    try {
      final response = await _supabase.client
          .from('postulaciones')
          .select()
          .eq('profesional_id', profesionalId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostulacionModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener mis postulaciones: $e');
      }
      rethrow;
    }
  }

  /// Crea una nueva postulación
  Future<PostulacionModel> crearPostulacion({
    required String solicitudId,
    required String profesionalId,
    required String mensaje,
    double? presupuestoOfrecido,
    String? tiempoEstimado,
  }) async {
    try {
      final data = {
        'solicitud_id': solicitudId,
        'profesional_id': profesionalId,
        'mensaje': mensaje,
        'presupuesto_ofrecido': presupuestoOfrecido,
        'tiempo_estimado': tiempoEstimado,
        'estado': AppConstants.estadoPostulacionPendiente,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase.client
          .from('postulaciones')
          .insert(data)
          .select()
          .single();

      // Incrementar contador de postulaciones en la solicitud
      await _supabase.client.rpc('incrementar_postulaciones_solicitud', params: {
        'p_solicitud_id': solicitudId,
      });

      return PostulacionModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear postulación: $e');
      }
      rethrow;
    }
  }

  /// Actualiza el estado de una postulación
  Future<void> actualizarEstadoPostulacion({
    required String postulacionId,
    required String nuevoEstado,
  }) async {
    try {
      await _supabase.client
          .from('postulaciones')
          .update({
            'estado': nuevoEstado,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postulacionId);
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar estado: $e');
      }
      rethrow;
    }
  }

  /// Acepta una postulación (solo el dueño de la solicitud)
  Future<void> aceptarPostulacion(String postulacionId) async {
    try {
      await actualizarEstadoPostulacion(
        postulacionId: postulacionId,
        nuevoEstado: AppConstants.estadoPostulacionAceptada,
      );
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
      await actualizarEstadoPostulacion(
        postulacionId: postulacionId,
        nuevoEstado: AppConstants.estadoPostulacionRechazada,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al rechazar postulación: $e');
      }
      rethrow;
    }
  }

  /// Cancela una postulación (el profesional cancela su propia postulación)
  Future<void> cancelarPostulacion(String postulacionId) async {
    try {
      await actualizarEstadoPostulacion(
        postulacionId: postulacionId,
        nuevoEstado: AppConstants.estadoPostulacionCancelada,
      );

      // Decrementar contador de postulaciones
      // TODO: Implementar RPC para decrementar
    } catch (e) {
      if (kDebugMode) {
        print('Error al cancelar postulación: $e');
      }
      rethrow;
    }
  }

  /// Verifica si un profesional ya postuló a una solicitud
  Future<bool> yaPosulo(String profesionalId, String solicitudId) async {
    try {
      final response = await _supabase.client
          .from('postulaciones')
          .select()
          .eq('profesional_id', profesionalId)
          .eq('solicitud_id', solicitudId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar postulación: $e');
      }
      return false;
    }
  }
}
