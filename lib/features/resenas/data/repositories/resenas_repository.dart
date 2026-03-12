import 'package:flutter/foundation.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/resena_model.dart';

/// Repositorio para manejar operaciones de reseñas
class ResenasRepository {
  final _supabase = SupabaseService.instance;

  // ==========================================
  // OBTENER RESEÑAS
  // ==========================================

  /// Obtiene todas las reseñas de un profesional
  Future<List<ResenaModel>> obtenerResenasDeProfesional({
    required String profesionalId,
    int? limit,
  }) async {
    try {
      var query = _supabase.client.from('resenas').select('''
          *,
          usuario:users!resenas_usuario_id_fkey(
            nombre_completo,
            foto_perfil
          )
        ''').eq('profesional_id', profesionalId)
          .eq('visible', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ResenaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener reseñas: $e');
      }
      rethrow;
    }
  }

  /// Obtiene una reseña específica por ID
  Future<ResenaModel?> obtenerResena(String resenaId) async {
    try {
      final response = await _supabase.client.from('resenas').select('''
          *,
          usuario:users!resenas_usuario_id_fkey(
            nombre_completo,
            foto_perfil
          )
        ''').eq('id', resenaId).single();

      return ResenaModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener reseña: $e');
      }
      return null;
    }
  }

  /// Obtiene las reseñas que un usuario ha escrito
  Future<List<ResenaModel>> obtenerResenasDeUsuario(String usuarioId) async {
    try {
      final response = await _supabase.client.from('resenas').select('''
          *,
          profesional:perfiles_profesionales(
            nombre_comercial,
            foto_perfil,
            categoria_principal
          )
        ''').eq('usuario_id', usuarioId).order('created_at', ascending: false);

      return (response as List)
          .map((json) => ResenaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener reseñas del usuario: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // CREAR Y ACTUALIZAR RESEÑAS
  // ==========================================

  /// Crea una nueva reseña
  Future<ResenaModel?> crearResena({
    required String profesionalId,
    required String usuarioId,
    required int calificacion,
    String? contenido,
    List<String>? fotos,
    String? solicitudId,
  }) async {
    try {
      // Verificar que el usuario no haya reseñado ya a este profesional
      final resenaExistente = await yaReseno(
        profesionalId: profesionalId,
        usuarioId: usuarioId,
      );

      if (resenaExistente) {
        throw Exception('Ya has reseñado a este profesional');
      }

      // Crear la reseña
      final data = {
        'profesional_id': profesionalId,
        'usuario_id': usuarioId,
        'calificacion': calificacion,
        'contenido': contenido,
        'fotos': fotos ?? [],
        'solicitud_id': solicitudId,
      };

      final response = await _supabase.client
          .from('resenas')
          .insert(data)
          .select('''
            *,
            usuario:users!resenas_usuario_id_fkey(
              nombre_completo,
              foto_perfil
            )
          ''')
          .single();

      // Actualizar calificación promedio del profesional
      await _actualizarCalificacionProfesional(profesionalId);

      // Dar créditos al usuario por escribir una reseña (más si tiene fotos)
      final creditosGanados = (fotos != null && fotos.isNotEmpty)
          ? AppConstants.creditosPorResena
          : AppConstants.creditosPorResena - 1; // 4 con foto, 3 sin foto

      await _supabase.incrementarCreditos(
        userId: usuarioId,
        cantidad: creditosGanados,
        motivo: 'escribir_resena',
        descripcion: 'Reseña a profesional',
      );

      return ResenaModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear reseña: $e');
      }
      return null;
    }
  }

  /// Actualiza una reseña existente
  Future<bool> actualizarResena({
    required String resenaId,
    required String usuarioId,
    int? calificacion,
    String? contenido,
    List<String>? fotos,
  }) async {
    try {
      // Verificar que la reseña pertenezca al usuario
      final resena = await obtenerResena(resenaId);
      if (resena == null || resena.usuarioId != usuarioId) {
        throw Exception('No tienes permiso para editar esta reseña');
      }

      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (calificacion != null) data['calificacion'] = calificacion;
      if (contenido != null) data['contenido'] = contenido;
      if (fotos != null) data['fotos'] = fotos;

      await _supabase.client
          .from('resenas')
          .update(data)
          .eq('id', resenaId);

      // Actualizar calificación promedio del profesional
      await _actualizarCalificacionProfesional(resena.profesionalId);

      return true;
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
    required String usuarioId,
  }) async {
    try {
      // Verificar que la reseña pertenezca al usuario
      final resena = await obtenerResena(resenaId);
      if (resena == null || resena.usuarioId != usuarioId) {
        throw Exception('No tienes permiso para eliminar esta reseña');
      }

      await _supabase.client.from('resenas').delete().eq('id', resenaId);

      // Actualizar calificación promedio del profesional
      await _actualizarCalificacionProfesional(resena.profesionalId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar reseña: $e');
      }
      return false;
    }
  }

  // ==========================================
  // RESPUESTAS DEL PROFESIONAL
  // ==========================================

  /// El profesional responde a una reseña
  Future<bool> responderResena({
    required String resenaId,
    required String profesionalId,
    required String respuesta,
  }) async {
    try {
      // Verificar que la reseña sea para este profesional
      final resena = await obtenerResena(resenaId);
      if (resena == null || resena.profesionalId != profesionalId) {
        throw Exception('No tienes permiso para responder esta reseña');
      }

      await _supabase.client.from('resenas').update({
        'respuesta_profesional': respuesta,
        'fecha_respuesta': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', resenaId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al responder reseña: $e');
      }
      return false;
    }
  }

  // ==========================================
  // VERIFICACIONES
  // ==========================================

  /// Verifica si un usuario ya reseñó a un profesional
  Future<bool> yaReseno({
    required String profesionalId,
    required String usuarioId,
  }) async {
    try {
      final response = await _supabase.client
          .from('resenas')
          .select('id')
          .eq('profesional_id', profesionalId)
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar reseña: $e');
      }
      return false;
    }
  }

  /// Verifica si el usuario puede reseñar (ha contratado al profesional)
  Future<bool> puedeResenar({
    required String profesionalId,
    required String usuarioId,
  }) async {
    try {
      // Verificar si ya reseñó
      final yaResenado = await yaReseno(
        profesionalId: profesionalId,
        usuarioId: usuarioId,
      );

      if (yaResenado) {
        return false;
      }

      // TODO: Verificar si ha contratado al profesional
      // Por ahora permitimos que cualquiera reseñe
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar si puede reseñar: $e');
      }
      return false;
    }
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================

  /// Obtiene el total de reseñas de un profesional
  Future<int> obtenerTotalResenas(String profesionalId) async {
    try {
      final response = await _supabase.client
          .from('resenas')
          .select('id')
          .eq('profesional_id', profesionalId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener total de reseñas: $e');
      }
      return 0;
    }
  }

  /// Obtiene la calificación promedio de un profesional
  Future<double> obtenerCalificacionPromedio(String profesionalId) async {
    try {
      final resenas = await obtenerResenasDeProfesional(
        profesionalId: profesionalId,
      );

      if (resenas.isEmpty) {
        return 0.0;
      }

      final suma = resenas.fold<int>(
        0,
        (total, resena) => total + resena.calificacion,
      );

      return suma / resenas.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener calificación promedio: $e');
      }
      return 0.0;
    }
  }

  /// Obtiene la distribución de calificaciones (cuántas de cada estrella)
  Future<Map<int, int>> obtenerDistribucionCalificaciones(
    String profesionalId,
  ) async {
    try {
      final resenas = await obtenerResenasDeProfesional(
        profesionalId: profesionalId,
      );

      final distribucion = <int, int>{
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      };

      for (var resena in resenas) {
        distribucion[resena.calificacion] =
            (distribucion[resena.calificacion] ?? 0) + 1;
      }

      return distribucion;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener distribución: $e');
      }
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
  }

  // ==========================================
  // HELPERS PRIVADOS
  // ==========================================

  /// Actualiza la calificación promedio y total de reseñas del profesional
  Future<void> _actualizarCalificacionProfesional(String profesionalId) async {
    try {
      final total = await obtenerTotalResenas(profesionalId);
      final promedio = await obtenerCalificacionPromedio(profesionalId);

      await _supabase.client.from('perfiles_profesionales').update({
        'calificacion_promedio': promedio,
        'total_resenas': total,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', profesionalId);
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar calificación del profesional: $e');
      }
    }
  }

  // ==========================================
  // REPORTES
  // ==========================================

  /// Reporta una reseña como inapropiada
  Future<bool> reportarResena({
    required String resenaId,
    required String usuarioId,
    required String motivo,
  }) async {
    try {
      // Marcar la reseña como reportada
      await _supabase.client.from('resenas').update({
        'reportada': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', resenaId);

      if (kDebugMode) {
        print('Reporte de reseña: $resenaId por usuario: $usuarioId');
        print('Motivo: $motivo');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al reportar reseña: $e');
      }
      return false;
    }
  }
}
