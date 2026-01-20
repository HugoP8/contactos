import 'package:flutter/foundation.dart';

/// Servicio para gestionar anuncios de AdMob
/// Incluye videos recompensados y banners
/// En web, este servicio está deshabilitado
class AdMobService {
  AdMobService._();

  static AdMobService? _instance;
  static AdMobService get instance {
    _instance ??= AdMobService._();
    return _instance!;
  }

  // Verificar si AdMob está soportado en esta plataforma
  static bool get isSupported => !kIsWeb;

  bool _isRewardedAdReady = false;

  /// Inicializa el SDK de AdMob
  /// En web, simplemente retorna sin hacer nada
  static Future<void> initialize() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ AdMob no está soportado en web - omitiendo inicialización');
      }
      return;
    }

    // En móvil, la inicialización real se haría aquí
    // Por ahora dejamos como stub para que la app compile en web
    if (kDebugMode) {
      print('✅ AdMob inicializado (stub para web)');
    }
  }

  // ==========================================
  // VIDEO RECOMPENSADO
  // ==========================================

  /// Carga un video recompensado
  Future<void> loadRewardedAd() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ Videos recompensados no disponibles en web');
      }
      return;
    }

    // Implementación real solo para móvil
    if (kDebugMode) {
      print('📺 Cargando video recompensado (stub)');
    }
  }

  /// Muestra el video recompensado
  /// Retorna true si el usuario vio el video completo
  Future<bool> showRewardedAd() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ Videos recompensados no disponibles en web');
      }
      return false;
    }

    // Stub para compilación web
    return false;
  }

  /// Verifica si hay un video recompensado listo para mostrar
  bool get isRewardedAdReady => !kIsWeb && _isRewardedAdReady;

  // ==========================================
  // BANNER - Stub para web
  // ==========================================

  /// En web retornamos null ya que no hay soporte de banners
  dynamic createBannerAd() {
    if (kIsWeb) {
      return null;
    }
    // Retorna null en web, en móvil se crearía el BannerAd real
    return null;
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  /// Libera recursos del servicio
  void dispose() {
    _isRewardedAdReady = false;
  }
}
