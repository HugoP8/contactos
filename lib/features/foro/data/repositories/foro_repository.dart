import 'package:flutter/foundation.dart';

import '../../../../core/services/supabase_service.dart';
import '../models/pregunta_model.dart';
import '../models/respuesta_model.dart';

/// Repositorio para manejar operaciones del foro
class ForoRepository {
  final _supabase = SupabaseService.instance;

  // ==========================================
  // PREGUNTAS
  // ==========================================

  /// Obtiene todas las preguntas con filtro opcional de categoría
  Future<List<PreguntaModel>> obtenerPreguntas({
    String? categoria,
    String? ordenarPor = 'reciente', // reciente, resueltas, sin_resolver
  }) async {
    try {
      dynamic query = _supabase.client.from('foro_preguntas').select('''
          *,
          usuario:users!foro_preguntas_user_id_fkey(
            nombre_completo,
            foto_perfil
          )
        ''');

      // Filtrar por categoría si se proporciona
      if (categoria != null && categoria.isNotEmpty) {
        query = query.eq('categoria', categoria);
      }

      // Ordenar según el criterio
      switch (ordenarPor) {
        case 'resueltas':
          query = query.eq('resuelta', true).order('updated_at', ascending: false);
          break;
        case 'sin_resolver':
          query = query.eq('resuelta', false).order('created_at', ascending: false);
          break;
        case 'reciente':
        default:
          query = query.order('created_at', ascending: false);
          break;
      }

      final response = await query;

      return (response as List)
          .map((json) => PreguntaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener preguntas: $e');
      }
      rethrow;
    }
  }

  /// Obtiene una pregunta específica por ID
  Future<PreguntaModel?> obtenerPregunta(String preguntaId) async {
    try {
      final response = await _supabase.client
          .from('foro_preguntas')
          .select('''
            *,
            usuario:users!foro_preguntas_user_id_fkey(
              nombre_completo,
              foto_perfil
            )
          ''')
          .eq('id', preguntaId)
          .single();

      // Incrementar vistas
      await _supabase.client.rpc('incrementar_vistas_pregunta', params: {
        'p_pregunta_id': preguntaId,
      });

      return PreguntaModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener pregunta: $e');
      }
      return null;
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
      final data = {
        'user_id': userId,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'resuelta': false,
        'total_respuestas': 0,
        'total_vistas': 0,
      };

      final response = await _supabase.client
          .from('foro_preguntas')
          .insert(data)
          .select('''
            *,
            usuario:users!foro_preguntas_user_id_fkey(
              nombre_completo,
              foto_perfil
            )
          ''')
          .single();

      return PreguntaModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear pregunta: $e');
      }
      return null;
    }
  }

  /// Marca una pregunta como resuelta
  Future<bool> marcarComoResuelta({
    required String preguntaId,
    required String mejorRespuestaId,
  }) async {
    try {
      await _supabase.client.from('foro_preguntas').update({
        'resuelta': true,
        'mejor_respuesta_id': mejorRespuestaId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', preguntaId);

      // Marcar la respuesta como mejor respuesta
      await _supabase.client.from('foro_respuestas').update({
        'es_mejor_respuesta': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', mejorRespuestaId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al marcar como resuelta: $e');
      }
      return false;
    }
  }

  /// Elimina una pregunta (solo el autor)
  Future<bool> eliminarPregunta(String preguntaId) async {
    try {
      await _supabase.client
          .from('foro_preguntas')
          .delete()
          .eq('id', preguntaId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar pregunta: $e');
      }
      return false;
    }
  }

  // ==========================================
  // RESPUESTAS
  // ==========================================

  /// Obtiene todas las respuestas de una pregunta
  Future<List<RespuestaModel>> obtenerRespuestas(String preguntaId) async {
    try {
      final response = await _supabase.client
          .from('foro_respuestas')
          .select('''
            *,
            usuario:users!foro_respuestas_user_id_fkey(
              nombre_completo,
              foto_perfil,
              verificado
            )
          ''')
          .eq('pregunta_id', preguntaId)
          .order('es_mejor_respuesta', ascending: false)
          .order('total_votos', ascending: false)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => RespuestaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener respuestas: $e');
      }
      rethrow;
    }
  }

  /// Crea una nueva respuesta
  Future<RespuestaModel?> crearRespuesta({
    required String preguntaId,
    required String userId,
    required String contenido,
    List<String>? imagenes,
  }) async {
    try {
      final data = {
        'pregunta_id': preguntaId,
        'user_id': userId,
        'contenido': contenido,
        'es_mejor_respuesta': false,
        'total_votos': 0,
      };

      final response = await _supabase.client
          .from('foro_respuestas')
          .insert(data)
          .select('''
            *,
            usuario:users!foro_respuestas_user_id_fkey(
              nombre_completo,
              foto_perfil,
              verificado
            )
          ''')
          .single();

      // Incrementar contador de respuestas en la pregunta
      await _supabase.client.rpc('incrementar_respuestas_pregunta', params: {
        'p_pregunta_id': preguntaId,
      });

      return RespuestaModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear respuesta: $e');
      }
      return null;
    }
  }

  /// Vota por una respuesta (upvote)
  Future<bool> votarRespuesta(String respuestaId) async {
    try {
      await _supabase.client.rpc('votar_respuesta', params: {
        'p_respuesta_id': respuestaId,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al votar respuesta: $e');
      }
      return false;
    }
  }

  /// Elimina una respuesta (solo el autor)
  Future<bool> eliminarRespuesta({
    required String respuestaId,
    required String preguntaId,
  }) async {
    try {
      await _supabase.client
          .from('foro_respuestas')
          .delete()
          .eq('id', respuestaId);

      // Decrementar contador de respuestas
      await _supabase.client.rpc('decrementar_respuestas_pregunta', params: {
        'p_pregunta_id': preguntaId,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar respuesta: $e');
      }
      return false;
    }
  }

  // ==========================================
  // BÚSQUEDA
  // ==========================================

  /// Busca preguntas por texto
  Future<List<PreguntaModel>> buscarPreguntas(String query) async {
    try {
      final response = await _supabase.client
          .from('foro_preguntas')
          .select('''
            *,
            usuario:users!foro_preguntas_user_id_fkey(
              nombre_completo,
              foto_perfil
            )
          ''')
          .or('titulo.ilike.%$query%,descripcion.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PreguntaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al buscar preguntas: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================

  /// Obtiene el total de preguntas de un usuario
  Future<int> obtenerTotalPreguntasUsuario(String userId) async {
    try {
      final response = await _supabase.client
          .from('foro_preguntas')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener total de preguntas: $e');
      }
      return 0;
    }
  }

  /// Obtiene el total de respuestas de un usuario
  Future<int> obtenerTotalRespuestasUsuario(String userId) async {
    try {
      final response = await _supabase.client
          .from('foro_respuestas')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener total de respuestas: $e');
      }
      return 0;
    }
  }
}
