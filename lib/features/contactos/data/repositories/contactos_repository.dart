import 'package:flutter/foundation.dart';

import '../../../../core/services/supabase_service.dart';
import '../models/contacto_model.dart';

/// Repositorio para manejar la lista de contactos del usuario
class ContactosRepository {
  final _supabase = SupabaseService.instance;

  /// Obtiene todos los contactos del usuario
  Future<List<ContactoModel>> obtenerMisContactos(String userId) async {
    try {
      final response = await _supabase.client
          .from('mis_contactos')
          .select('''
            *,
            profesional:perfiles_profesionales!mis_contactos_profesional_id_fkey(
              nombre_comercial,
              foto_perfil,
              categoria_principal,
              ciudad,
              whatsapp,
              calificacion_promedio,
              verificado
            )
          ''')
          .eq('user_id', userId)
          .order('favorito', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ContactoModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener contactos: $e');
      }
      rethrow;
    }
  }

  /// Agrega un profesional a la lista de contactos
  Future<ContactoModel?> agregarContacto({
    required String userId,
    required String profesionalId,
    String? notas,
  }) async {
    try {
      final response = await _supabase.client
          .from('mis_contactos')
          .insert({
            'user_id': userId,
            'profesional_id': profesionalId,
            'notas': notas,
            'favorito': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('''
            *,
            profesional:perfiles_profesionales!mis_contactos_profesional_id_fkey(
              nombre_comercial,
              foto_perfil,
              categoria_principal,
              ciudad,
              whatsapp,
              calificacion_promedio,
              verificado
            )
          ''')
          .single();

      return ContactoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar contacto: $e');
      }
      // Si ya existe, retornar null sin error
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique')) {
        return null;
      }
      rethrow;
    }
  }

  /// Elimina un contacto de la lista
  Future<bool> eliminarContacto(String contactoId) async {
    try {
      await _supabase.client
          .from('mis_contactos')
          .delete()
          .eq('id', contactoId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar contacto: $e');
      }
      return false;
    }
  }

  /// Verifica si un profesional está en los contactos
  Future<bool> esContacto({
    required String userId,
    required String profesionalId,
  }) async {
    try {
      final response = await _supabase.client
          .from('mis_contactos')
          .select('id')
          .eq('user_id', userId)
          .eq('profesional_id', profesionalId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar contacto: $e');
      }
      return false;
    }
  }

  /// Toggle favorito de un contacto
  Future<bool> toggleFavorito(String contactoId, bool esFavorito) async {
    try {
      await _supabase.client.from('mis_contactos').update({
        'favorito': !esFavorito,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', contactoId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar favorito: $e');
      }
      return false;
    }
  }

  /// Actualiza las notas de un contacto
  Future<bool> actualizarNotas({
    required String contactoId,
    required String notas,
  }) async {
    try {
      await _supabase.client.from('mis_contactos').update({
        'notas': notas,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', contactoId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar notas: $e');
      }
      return false;
    }
  }

  /// Busca contactos por nombre o categoría
  Future<List<ContactoModel>> buscarContactos({
    required String userId,
    required String query,
  }) async {
    try {
      final response = await _supabase.client
          .from('mis_contactos')
          .select('''
            *,
            profesional:perfiles_profesionales!mis_contactos_profesional_id_fkey(
              nombre_comercial,
              foto_perfil,
              categoria_principal,
              ciudad,
              whatsapp,
              calificacion_promedio,
              verificado
            )
          ''')
          .eq('user_id', userId)
          .order('favorito', ascending: false);

      // Filtrar en el cliente (porque Supabase no permite filtrar en campos anidados fácilmente)
      final contactos = (response as List)
          .map((json) => ContactoModel.fromJson(json))
          .where((c) =>
              (c.profesionalNombre
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false) ||
              (c.profesionalCategoria
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false) ||
              (c.notas?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();

      return contactos;
    } catch (e) {
      if (kDebugMode) {
        print('Error al buscar contactos: $e');
      }
      rethrow;
    }
  }
}
