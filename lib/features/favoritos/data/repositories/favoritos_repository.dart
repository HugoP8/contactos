import 'package:flutter/foundation.dart';

import '../../../../core/services/supabase_service.dart';
import '../models/favorito_model.dart';

/// Repositorio para manejar operaciones de favoritos
class FavoritosRepository {
  final _supabase = SupabaseService.instance;

  // ==========================================
  // OBTENER FAVORITOS
  // ==========================================

  /// Obtiene todos los favoritos de un usuario
  Future<List<FavoritoModel>> obtenerFavoritos(String userId) async {
    try {
      final response = await _supabase.client.from('favoritos').select('''
          *,
          profesional:perfiles_profesionales!favoritos_profesional_id_fkey(
            nombre_comercial,
            foto_perfil,
            categoria_principal,
            ciudad,
            calificacion_promedio,
            total_resenas,
            verificado,
            destacado
          )
        ''').eq('user_id', userId).order('created_at', ascending: false);

      return (response as List)
          .map((json) => FavoritoModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener favoritos: $e');
      }
      rethrow;
    }
  }

  /// Obtiene un favorito específico
  Future<FavoritoModel?> obtenerFavorito(String favoritoId) async {
    try {
      final response = await _supabase.client.from('favoritos').select('''
          *,
          profesional:perfiles_profesionales!favoritos_profesional_id_fkey(
            nombre_comercial,
            foto_perfil,
            categoria_principal,
            ciudad,
            calificacion_promedio,
            total_resenas,
            verificado,
            destacado
          )
        ''').eq('id', favoritoId).single();

      return FavoritoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener favorito: $e');
      }
      return null;
    }
  }

  // ==========================================
  // AGREGAR Y ELIMINAR FAVORITOS
  // ==========================================

  /// Agrega un profesional a favoritos
  Future<FavoritoModel?> agregarFavorito({
    required String userId,
    required String profesionalId,
  }) async {
    try {
      // Verificar si ya está en favoritos
      final yaEsFavorito = await esFavorito(
        userId: userId,
        profesionalId: profesionalId,
      );

      if (yaEsFavorito) {
        throw Exception('Este profesional ya está en tus favoritos');
      }

      final data = {
        'user_id': userId,
        'profesional_id': profesionalId,
      };

      final response = await _supabase.client
          .from('favoritos')
          .insert(data)
          .select('''
            *,
            profesional:perfiles_profesionales!favoritos_profesional_id_fkey(
              nombre_comercial,
              foto_perfil,
              categoria_principal,
              ciudad,
              calificacion_promedio,
              total_resenas,
              verificado,
              destacado
            )
          ''')
          .single();

      return FavoritoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar favorito: $e');
      }
      return null;
    }
  }

  /// Elimina un profesional de favoritos
  Future<bool> eliminarFavorito({
    required String userId,
    required String profesionalId,
  }) async {
    try {
      await _supabase.client
          .from('favoritos')
          .delete()
          .eq('user_id', userId)
          .eq('profesional_id', profesionalId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar favorito: $e');
      }
      return false;
    }
  }

  /// Toggle favorito (agregar si no existe, eliminar si existe)
  Future<bool> toggleFavorito({
    required String userId,
    required String profesionalId,
  }) async {
    try {
      final yaEsFavorito = await esFavorito(
        userId: userId,
        profesionalId: profesionalId,
      );

      if (yaEsFavorito) {
        // Eliminar
        return await eliminarFavorito(
          userId: userId,
          profesionalId: profesionalId,
        );
      } else {
        // Agregar
        final favorito = await agregarFavorito(
          userId: userId,
          profesionalId: profesionalId,
        );
        return favorito != null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al toggle favorito: $e');
      }
      return false;
    }
  }

  // ==========================================
  // VERIFICACIONES
  // ==========================================

  /// Verifica si un profesional está en favoritos del usuario
  Future<bool> esFavorito({
    required String userId,
    required String profesionalId,
  }) async {
    try {
      final response = await _supabase.client
          .from('favoritos')
          .select('id')
          .eq('user_id', userId)
          .eq('profesional_id', profesionalId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar favorito: $e');
      }
      return false;
    }
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================

  /// Obtiene el total de favoritos de un usuario
  Future<int> obtenerTotalFavoritos(String userId) async {
    try {
      final response = await _supabase.client
          .from('favoritos')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener total de favoritos: $e');
      }
      return 0;
    }
  }

  /// Obtiene cuántas personas tienen a un profesional como favorito
  Future<int> obtenerTotalFavoritosDeProfesional(String profesionalId) async {
    try {
      final response = await _supabase.client
          .from('favoritos')
          .select('id')
          .eq('profesional_id', profesionalId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener total de favoritos del profesional: $e');
      }
      return 0;
    }
  }

  // ==========================================
  // FILTRADO
  // ==========================================

  /// Obtiene favoritos filtrados por categoría
  Future<List<FavoritoModel>> obtenerFavoritosPorCategoria({
    required String userId,
    required String categoria,
  }) async {
    try {
      final favoritos = await obtenerFavoritos(userId);

      return favoritos
          .where((f) => f.profesionalCategoria == categoria)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al filtrar favoritos por categoría: $e');
      }
      rethrow;
    }
  }

  /// Obtiene favoritos filtrados por ciudad
  Future<List<FavoritoModel>> obtenerFavoritosPorCiudad({
    required String userId,
    required String ciudad,
  }) async {
    try {
      final favoritos = await obtenerFavoritos(userId);

      return favoritos.where((f) => f.profesionalCiudad == ciudad).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al filtrar favoritos por ciudad: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // LIMPIAR
  // ==========================================

  /// Elimina todos los favoritos de un usuario
  Future<bool> eliminarTodosFavoritos(String userId) async {
    try {
      await _supabase.client.from('favoritos').delete().eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar todos los favoritos: $e');
      }
      return false;
    }
  }
}
