import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/admob_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Modelo para movimientos de créditos
class CreditoMovimiento {
  final String id;
  final String usuarioId;
  final String tipoMovimiento; // ganancia, gasto
  final int cantidad;
  final int saldoAnterior;
  final int saldoNuevo;
  final String origen;
  final String? descripcion;
  final DateTime? createdAt;

  const CreditoMovimiento({
    required this.id,
    required this.usuarioId,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.saldoAnterior,
    required this.saldoNuevo,
    required this.origen,
    this.descripcion,
    this.createdAt,
  });

  factory CreditoMovimiento.fromJson(Map<String, dynamic> json) {
    return CreditoMovimiento(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      tipoMovimiento: json['tipo_movimiento'] as String,
      cantidad: json['cantidad'] as int,
      saldoAnterior: json['saldo_anterior'] as int,
      saldoNuevo: json['saldo_nuevo'] as int,
      origen: json['origen'] as String,
      descripcion: json['descripcion'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// Estado del historial de créditos
class CreditosHistorialState {
  final List<CreditoMovimiento> movimientos;
  final bool isLoading;
  final String? error;

  const CreditosHistorialState({
    this.movimientos = const [],
    this.isLoading = false,
    this.error,
  });

  CreditosHistorialState copyWith({
    List<CreditoMovimiento>? movimientos,
    bool? isLoading,
    String? error,
  }) {
    return CreditosHistorialState(
      movimientos: movimientos ?? this.movimientos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider del historial de créditos
final creditosHistorialProvider = StateNotifierProvider<CreditosHistorialNotifier, CreditosHistorialState>((ref) {
  return CreditosHistorialNotifier(ref);
});

/// Notifier para el historial de créditos
class CreditosHistorialNotifier extends StateNotifier<CreditosHistorialState> {
  CreditosHistorialNotifier(this.ref) : super(const CreditosHistorialState()) {
    cargarHistorial();
  }

  final Ref ref;
  final _supabase = SupabaseService.instance;

  /// Carga el historial de movimientos de créditos
  Future<void> cargarHistorial() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabase.client
          .from('creditos_movimientos')
          .select()
          .eq('usuario_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      final movimientos = (response as List)
          .map((json) => CreditoMovimiento.fromJson(json))
          .toList();

      state = state.copyWith(
        movimientos: movimientos,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar historial: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar historial',
      );
    }
  }

  /// Refresca el historial
  Future<void> refresh() async {
    await cargarHistorial();
  }
}

/// Provider para controlar videos AdMob vistos hoy
final videosVistosHoyProvider = StateProvider<int>((ref) => 0);

/// Provider para manejar las acciones de créditos
final creditosActionsProvider = Provider<CreditosActions>((ref) {
  return CreditosActions(ref);
});

/// Clase para manejar acciones relacionadas con créditos
class CreditosActions {
  final Ref ref;

  CreditosActions(this.ref);

  final _supabase = SupabaseService.instance;
  final _admob = AdMobService.instance;

  /// Muestra un video recompensado y otorga créditos
  Future<bool> verVideoRecompensado() async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Verificar límite diario
    final videosVistos = ref.read(videosVistosHoyProvider);
    if (videosVistos >= AppConstants.maxVideosAdMobPorDia) {
      throw Exception('Has alcanzado el límite diario de videos (${AppConstants.maxVideosAdMobPorDia})');
    }

    try {
      // Cargar video si no está listo
      if (!_admob.isRewardedAdReady) {
        await _admob.loadRewardedAd();
        // Esperar un poco para que cargue
        await Future.delayed(const Duration(seconds: 2));
      }

      // Mostrar video
      final rewardEarned = await _admob.showRewardedAd();

      if (rewardEarned) {
        // Otorgar créditos
        final success = await _supabase.incrementarCreditos(
          userId: user.id,
          cantidad: AppConstants.creditosPorVideo,
          motivo: AppConstants.origenVideoAdmob,
          descripcion: 'Créditos ganados por ver video',
        );

        if (success) {
          // Incrementar contador de videos vistos hoy
          ref.read(videosVistosHoyProvider.notifier).state = videosVistos + 1;

          // Refrescar usuario y historial
          await ref.read(authProvider.notifier).refreshUser();
          await ref.read(creditosHistorialProvider.notifier).refresh();

          // Cargar siguiente video
          _admob.loadRewardedAd();

          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al ver video recompensado: $e');
      }
      rethrow;
    }
  }

  /// Comparte el código de referido
  Future<void> compartirCodigoReferido() async {
    final user = ref.read(authProvider).value;
    if (user == null || user.codigoReferido == null) {
      throw Exception('Código de referido no disponible');
    }

    // TODO: Implementar compartir (Share plugin o WhatsApp)
    if (kDebugMode) {
      print('Compartir código: ${user.codigoReferido}');
    }
  }

  /// Reclama créditos por completar perfil
  Future<bool> reclamarCreditosPerfilCompleto() async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    if (!user.perfilCompleto) {
      throw Exception('Debes completar tu perfil primero');
    }

    try {
      // Verificar si ya reclamó estos créditos
      final yaReclamo = await _supabase.client
          .from('creditos_movimientos')
          .select()
          .eq('usuario_id', user.id)
          .eq('origen', AppConstants.origenPerfilCompleto)
          .maybeSingle();

      if (yaReclamo != null) {
        throw Exception('Ya reclamaste estos créditos');
      }

      // Otorgar créditos
      final success = await _supabase.incrementarCreditos(
        userId: user.id,
        cantidad: AppConstants.creditosPorPerfilCompleto,
        motivo: AppConstants.origenPerfilCompleto,
        descripcion: 'Créditos por completar perfil',
      );

      if (success) {
        await ref.read(authProvider.notifier).refreshUser();
        await ref.read(creditosHistorialProvider.notifier).refresh();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al reclamar créditos: $e');
      }
      rethrow;
    }
  }

  /// Obtiene estadísticas de créditos del usuario
  Future<Map<String, int>> obtenerEstadisticas() async {
    final user = ref.read(authProvider).value;
    if (user == null) return {};

    try {
      // Total ganado
      final ganados = await _supabase.client
          .from('creditos_movimientos')
          .select('cantidad')
          .eq('usuario_id', user.id)
          .eq('tipo_movimiento', AppConstants.tipoMovimientoGanancia);

      int totalGanado = 0;
      for (var mov in ganados) {
        totalGanado += mov['cantidad'] as int;
      }

      // Total gastado
      final gastados = await _supabase.client
          .from('creditos_movimientos')
          .select('cantidad')
          .eq('usuario_id', user.id)
          .eq('tipo_movimiento', AppConstants.tipoMovimientoGasto);

      int totalGastado = 0;
      for (var mov in gastados) {
        totalGastado += mov['cantidad'] as int;
      }

      return {
        'ganados': totalGanado,
        'gastados': totalGastado,
        'saldo': user.creditos,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener estadísticas: $e');
      }
      return {};
    }
  }
}
