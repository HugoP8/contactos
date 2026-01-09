import 'package:flutter/foundation.dart';

import '../models/solicitud_trabajo_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Repositorio para manejar las operaciones de solicitudes de trabajo
/// Siguiendo el patrón Repository de Clean Architecture
class SolicitudesRepository {
  final _supabase = SupabaseService.instance;

  /// Obtiene todas las solicitudes activas (feed público)
  Future<List<SolicitudTrabajoModel>> obtenerSolicitudesActivas({
    String? categoria,
    String? ciudad,
    String? ordenamiento = 'reciente',
  }) async {
    try {
      var query = _supabase.client
          .from('solicitudes_trabajo')
          .select()
          .eq('estado', AppConstants.estadoSolicitudActiva)
          .eq('visible', true);

      // Filtro por categoría
      if (categoria != null && categoria.isNotEmpty) {
        query = query.eq('categoria', categoria);
      }

      // Filtro por ciudad
      if (ciudad != null && ciudad.isNotEmpty) {
        query = query.eq('ciudad', ciudad);
      }

      // Ordenamiento
      switch (ordenamiento) {
        case 'reciente':
          query = query.order('created_at', ascending: false);
          break;
        case 'urgente':
          query = query.order('urgencia', ascending: false);
          break;
        case 'postulaciones':
          query = query.order('total_postulaciones', ascending: false);
          break;
      }

      final response = await query;
      return (response as List)
          .map((json) => SolicitudTrabajoModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener solicitudes activas: $e');
      }
      rethrow;
    }
  }

  /// Obtiene las solicitudes del usuario actual
  Future<List<SolicitudTrabajoModel>> obtenerMisSolicitudes(String userId) async {
    try {
      final response = await _supabase.client
          .from('solicitudes_trabajo')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SolicitudTrabajoModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener mis solicitudes: $e');
      }
      rethrow;
    }
  }

  /// Obtiene una solicitud por ID
  Future<SolicitudTrabajoModel?> obtenerSolicitudPorId(String solicitudId) async {
    try {
      final response = await _supabase.client
          .from('solicitudes_trabajo')
          .select()
          .eq('id', solicitudId)
          .maybeSingle();

      if (response == null) return null;
      return SolicitudTrabajoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener solicitud: $e');
      }
      rethrow;
    }
  }

  /// Crea una nueva solicitud de trabajo
  Future<SolicitudTrabajoModel> crearSolicitud({
    required String userId,
    required String titulo,
    required String descripcion,
    required String categoria,
    required String ciudad,
    String? zona,
    double? presupuestoMinimo,
    double? presupuestoMaximo,
    required String urgencia,
    List<String>? fotos,
    required int creditosUsados,
  }) async {
    try {
      // Calcular fecha de expiración (7 días desde hoy)
      final expiresAt = DateTime.now().add(
        Duration(days: AppConstants.diasExpiracionSolicitud),
      );

      final data = {
        'user_id': userId,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'ciudad': ciudad,
        'zona': zona,
        'presupuesto_minimo': presupuestoMinimo,
        'presupuesto_maximo': presupuestoMaximo,
        'urgencia': urgencia,
        'fotos': fotos ?? [],
        'estado': AppConstants.estadoSolicitudActiva,
        'total_postulaciones': 0,
        'creditos_usados': creditosUsados,
        'visible': true,
        'destacada': false,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };

      final response = await _supabase.client
          .from('solicitudes_trabajo')
          .insert(data)
          .select()
          .single();

      // Incrementar contador de solicitudes del usuario
      await _supabase.client.rpc('incrementar_solicitudes_publicadas', params: {
        'p_user_id': userId,
      });

      return SolicitudTrabajoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear solicitud: $e');
      }
      rethrow;
    }
  }

  /// Actualiza una solicitud existente
  Future<void> actualizarSolicitud({
    required String solicitudId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      await _supabase.client
          .from('solicitudes_trabajo')
          .update({
            ...?updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', solicitudId);
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Cambia el estado de una solicitud
  Future<void> cambiarEstadoSolicitud({
    required String solicitudId,
    required String nuevoEstado,
  }) async {
    try {
      await actualizarSolicitud(
        solicitudId: solicitudId,
        updates: {'estado': nuevoEstado},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cambiar estado: $e');
      }
      rethrow;
    }
  }

  /// Elimina una solicitud (soft delete, solo cambia visible a false)
  Future<void> eliminarSolicitud(String solicitudId) async {
    try {
      await actualizarSolicitud(
        solicitudId: solicitudId,
        updates: {
          'visible': false,
          'estado': AppConstants.estadoSolicitudCancelada,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Destaca una solicitud (requiere créditos)
  Future<void> destacarSolicitud(String solicitudId) async {
    try {
      await actualizarSolicitud(
        solicitudId: solicitudId,
        updates: {'destacada': true},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al destacar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Renueva una solicitud expirada (requiere créditos)
  Future<void> renovarSolicitud(String solicitudId) async {
    try {
      final nuevaExpiracion = DateTime.now().add(
        Duration(days: AppConstants.diasExpiracionSolicitud),
      );

      await actualizarSolicitud(
        solicitudId: solicitudId,
        updates: {
          'expires_at': nuevaExpiracion.toIso8601String(),
          'estado': AppConstants.estadoSolicitudActiva,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al renovar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Sube imágenes de la solicitud a Supabase Storage
  Future<List<String>> subirImagenesSolicitud({
    required String userId,
    required List<Uint8List> imagenes,
  }) async {
    try {
      final List<String> urls = [];

      for (int i = 0; i < imagenes.length; i++) {
        final fileName = 'solicitud_${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final path = '$userId/$fileName';

        final url = await _supabase.uploadImage(
          bucket: AppConstants.bucketSolicitudes,
          path: path,
          fileBytes: imagenes[i],
        );

        if (url != null) {
          urls.add(url);
        }
      }

      return urls;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imágenes: $e');
      }
      rethrow;
    }
  }
}
