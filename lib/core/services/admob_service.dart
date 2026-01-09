import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para gestionar anuncios de AdMob
/// Incluye videos recompensados y banners
class AdMobService {
  AdMobService._();

  static AdMobService? _instance;
  static AdMobService get instance {
    _instance ??= AdMobService._();
    return _instance!;
  }

  // IDs de AdMob según plataforma
  String get _rewardedAdId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_REWARDED_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_REWARDED_ID_IOS'] ?? '';
    }
    return '';
  }

  String get _bannerAdId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_ID_IOS'] ?? '';
    }
    return '';
  }

  // IDs de prueba para desarrollo
  String get _testRewardedAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // ID de prueba Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // ID de prueba iOS
    }
    return '';
  }

  String get _testBannerAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // ID de prueba iOS
    }
    return '';
  }

  // Obtener ID correcto según entorno
  String get rewardedAdUnitId {
    return kDebugMode ? _testRewardedAdId : _rewardedAdId;
  }

  String get bannerAdUnitId {
    return kDebugMode ? _testBannerAdId : _bannerAdId;
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// Inicializa el SDK de AdMob
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();

      if (kDebugMode) {
        print('✅ AdMob inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al inicializar AdMob: $e');
      }
    }
  }

  // ==========================================
  // VIDEO RECOMPENSADO
  // ==========================================

  /// Carga un video recompensado
  Future<void> loadRewardedAd() async {
    if (_isRewardedAdReady) {
      if (kDebugMode) {
        print('⚠️ Ya hay un video recompensado cargado');
      }
      return;
    }

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;

            if (kDebugMode) {
              print('✅ Video recompensado cargado');
            }

            // Configurar callbacks
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                if (kDebugMode) {
                  print('📺 Video recompensado mostrado');
                }
              },
              onAdDismissedFullScreenContent: (ad) {
                if (kDebugMode) {
                  print('🚪 Video recompensado cerrado');
                }
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Cargar el siguiente video
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                if (kDebugMode) {
                  print('❌ Error al mostrar video: $error');
                }
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Intentar cargar otro video
                loadRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print('❌ Error al cargar video recompensado: $error');
            }
            _isRewardedAdReady = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Excepción al cargar video recompensado: $e');
      }
    }
  }

  /// Muestra el video recompensado
  /// Retorna true si el usuario vio el video completo
  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      if (kDebugMode) {
        print('⚠️ Video recompensado no está listo');
      }
      return false;
    }

    bool rewardEarned = false;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          if (kDebugMode) {
            print('💰 Recompensa ganada: ${reward.amount} ${reward.type}');
          }
        },
      );

      _isRewardedAdReady = false;
      _rewardedAd = null;

      return rewardEarned;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al mostrar video recompensado: $e');
      }
      return false;
    }
  }

  /// Verifica si hay un video recompensado listo para mostrar
  bool get isRewardedAdReady => _isRewardedAdReady;

  // ==========================================
  // BANNER
  // ==========================================

  /// Crea un banner de AdMob
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('✅ Banner cargado');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ Error al cargar banner: $error');
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('📱 Banner abierto');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('🚪 Banner cerrado');
          }
        },
      ),
    );
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  /// Libera recursos del servicio
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
