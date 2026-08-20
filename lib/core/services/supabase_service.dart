import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio centralizado para Supabase
/// Maneja la inicialización y proporciona acceso al cliente de Supabase
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Inicializa Supabase con las credenciales del .env
  static Future<void> initialize() async {
    try {
      // Cargar variables de entorno
      await dotenv.load(fileName: '.env');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception('SUPABASE_URL no está configurado en .env');
      }

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw Exception('SUPABASE_ANON_KEY no está configurado en .env');
      }

      // Inicializar Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      if (kDebugMode) {
        print('✅ Supabase inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al inicializar Supabase: $e');
      }
      rethrow;
    }
  }

  /// Cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Autenticación
  GoTrueClient get auth => client.auth;

  /// Base de datos
  PostgrestClient get database => client.rest;

  /// Almacenamiento
  SupabaseStorageClient get storage => client.storage;

  /// Usuario actual
  User? get currentUser => auth.currentUser;

  /// Stream del estado de autenticación
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// ID del usuario actual
  String? get currentUserId => currentUser?.id;

  /// Email del usuario actual
  String? get currentUserEmail => currentUser?.email;

  // ==========================================
  // FUNCIONES RPC (Remote Procedure Calls)
  // ==========================================

  /// Verifica si el usuario puede publicar una solicitud gratis
  Future<bool> puedePubilcarSolicitudGratis(String userId) async {
    try {
      final response = await client.rpc(
        'puede_publicar_solicitud_gratis',
        params: {'p_user_id': userId},
      );
      return response as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error en puedePubilcarSolicitudGratis: $e');
      }
      return false;
    }
  }

  /// Usa un token especial (como el de solicitud gratuita)
  Future<bool> usarTokenEspecial(String userId, String tipo) async {
    try {
      await client.rpc(
        'usar_token_especial',
        params: {
          'p_user_id': userId,
          'p_tipo': tipo,
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error en usarTokenEspecial: $e');
      }
      return false;
    }
  }

  /// Descuenta créditos del usuario
  Future<bool> descontarCreditos({
    required String userId,
    required int cantidad,
    required String motivo,
  }) async {
    try {
      final response = await client.rpc(
        'descontar_creditos',
        params: {
          'p_user_id': userId,
          'p_cantidad': cantidad,
          'p_motivo': motivo,
        },
      );
      return response == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error en descontarCreditos: $e');
      }
      return false;
    }
  }

  /// Incrementa créditos del usuario
  Future<bool> incrementarCreditos({
    required String userId,
    required int cantidad,
    required String motivo,
    String? descripcion,
  }) async {
    try {
      final response = await client.rpc(
        'incrementar_creditos',
        params: {
          'p_user_id': userId,
          'p_cantidad': cantidad,
          'p_motivo': motivo,
          'p_descripcion': descripcion ?? '',
        },
      );
      return response == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error en incrementarCreditos: $e');
      }
      return false;
    }
  }

  // ==========================================
  // HELPERS DE ALMACENAMIENTO (Storage)
  // ==========================================

  /// Sube una imagen al bucket especificado
  Future<String?> uploadImage({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      await storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      // Obtener URL pública
      final publicUrl = storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
      }
      return null;
    }
  }

  /// Elimina una imagen del bucket
  Future<bool> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar imagen: $e');
      }
      return false;
    }
  }

  /// Obtiene la URL pública de una imagen
  String getPublicUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }

  // ==========================================
  // CIERRE DE SESIÓN
  // ==========================================

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      await auth.signOut();
      if (kDebugMode) {
        print('✅ Sesión cerrada correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al cerrar sesión: $e');
      }
      rethrow;
    }
  }
}
