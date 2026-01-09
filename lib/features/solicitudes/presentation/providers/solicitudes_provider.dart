import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/solicitud_trabajo_model.dart';
import '../../data/repositories/solicitudes_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Provider del repositorio
final solicitudesRepositoryProvider = Provider<SolicitudesRepository>((ref) {
  return SolicitudesRepository();
});

/// Estado de las solicitudes
class SolicitudesState {
  final List<SolicitudTrabajoModel> solicitudes;
  final bool isLoading;
  final String? error;

  const SolicitudesState({
    this.solicitudes = const [],
    this.isLoading = false,
    this.error,
  });

  SolicitudesState copyWith({
    List<SolicitudTrabajoModel>? solicitudes,
    bool? isLoading,
    String? error,
  }) {
    return SolicitudesState(
      solicitudes: solicitudes ?? this.solicitudes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider de las solicitudes del usuario actual
final misSolicitudesProvider = StateNotifierProvider<MisSolicitudesNotifier, SolicitudesState>((ref) {
  return MisSolicitudesNotifier(ref);
});

/// Notifier para las solicitudes del usuario
class MisSolicitudesNotifier extends StateNotifier<SolicitudesState> {
  MisSolicitudesNotifier(this.ref) : super(const SolicitudesState()) {
    cargarMisSolicitudes();
  }

  final Ref ref;

  /// Carga las solicitudes del usuario actual
  Future<void> cargarMisSolicitudes() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(solicitudesRepositoryProvider);
      final solicitudes = await repository.obtenerMisSolicitudes(user.id);

      state = state.copyWith(
        solicitudes: solicitudes,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar mis solicitudes: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar tus solicitudes',
      );
    }
  }

  /// Crea una nueva solicitud
  Future<SolicitudTrabajoModel?> crearSolicitud({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String ciudad,
    String? zona,
    double? presupuestoMinimo,
    double? presupuestoMaximo,
    required String urgencia,
    List<Uint8List>? imagenes,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final repository = ref.read(solicitudesRepositoryProvider);
      final supabase = SupabaseService.instance;

      // Verificar si tiene token gratuito
      final tieneTokenGratuito = await supabase.puedePubilcarSolicitudGratis(user.id);

      int creditosUsados = 0;

      if (tieneTokenGratuito) {
        // Usar token gratuito
        await supabase.usarTokenEspecial(
          user.id,
          AppConstants.tokenSolicitudGratuita,
        );
      } else {
        // Verificar si tiene créditos suficientes
        if (user.creditos < AppConstants.costoPublicarSolicitud) {
          throw Exception('No tienes créditos suficientes');
        }

        // Descontar créditos
        await supabase.descontarCreditos(
          userId: user.id,
          cantidad: AppConstants.costoPublicarSolicitud,
          motivo: AppConstants.origenPublicarSolicitud,
        );

        creditosUsados = AppConstants.costoPublicarSolicitud;
      }

      // Subir imágenes si hay
      List<String> fotosUrls = [];
      if (imagenes != null && imagenes.isNotEmpty) {
        fotosUrls = await repository.subirImagenesSolicitud(
          userId: user.id,
          imagenes: imagenes,
        );
      }

      // Crear solicitud
      final nuevaSolicitud = await repository.crearSolicitud(
        userId: user.id,
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        ciudad: ciudad,
        zona: zona,
        presupuestoMinimo: presupuestoMinimo,
        presupuestoMaximo: presupuestoMaximo,
        urgencia: urgencia,
        fotos: fotosUrls,
        creditosUsados: creditosUsados,
      );

      // Refrescar el usuario y la lista
      await ref.read(authProvider.notifier).refreshUser();
      await cargarMisSolicitudes();

      return nuevaSolicitud;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear solicitud: $e');
      }
      rethrow;
    }
  }

  /// Elimina una solicitud
  Future<void> eliminarSolicitud(String solicitudId) async {
    try {
      final repository = ref.read(solicitudesRepositoryProvider);
      await repository.eliminarSolicitud(solicitudId);
      await cargarMisSolicitudes();
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Cambia el estado de una solicitud
  Future<void> cambiarEstado(String solicitudId, String nuevoEstado) async {
    try {
      final repository = ref.read(solicitudesRepositoryProvider);
      await repository.cambiarEstadoSolicitud(
        solicitudId: solicitudId,
        nuevoEstado: nuevoEstado,
      );
      await cargarMisSolicitudes();
    } catch (e) {
      if (kDebugMode) {
        print('Error al cambiar estado: $e');
      }
      rethrow;
    }
  }

  /// Renueva una solicitud expirada
  Future<void> renovarSolicitud(String solicitudId) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // Verificar créditos
      if (user.creditos < AppConstants.costoRenovarSolicitud) {
        throw Exception('No tienes créditos suficientes');
      }

      final supabase = SupabaseService.instance;
      final repository = ref.read(solicitudesRepositoryProvider);

      // Descontar créditos
      await supabase.descontarCreditos(
        userId: user.id,
        cantidad: AppConstants.costoRenovarSolicitud,
        motivo: AppConstants.origenRenovarSolicitud,
      );

      // Renovar solicitud
      await repository.renovarSolicitud(solicitudId);

      // Refrescar
      await ref.read(authProvider.notifier).refreshUser();
      await cargarMisSolicitudes();
    } catch (e) {
      if (kDebugMode) {
        print('Error al renovar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Destaca una solicitud
  Future<void> destacarSolicitud(String solicitudId) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // Verificar créditos
      if (user.creditos < AppConstants.costoDestacarSolicitud) {
        throw Exception('No tienes créditos suficientes');
      }

      final supabase = SupabaseService.instance;
      final repository = ref.read(solicitudesRepositoryProvider);

      // Descontar créditos
      await supabase.descontarCreditos(
        userId: user.id,
        cantidad: AppConstants.costoDestacarSolicitud,
        motivo: AppConstants.origenDestacarSolicitud,
      );

      // Destacar solicitud
      await repository.destacarSolicitud(solicitudId);

      // Refrescar
      await ref.read(authProvider.notifier).refreshUser();
      await cargarMisSolicitudes();
    } catch (e) {
      if (kDebugMode) {
        print('Error al destacar solicitud: $e');
      }
      rethrow;
    }
  }

  /// Refresca la lista
  Future<void> refresh() async {
    await cargarMisSolicitudes();
  }
}

/// Provider de solicitudes activas (feed público para profesionales)
final solicitudesActivasProvider = StateNotifierProvider<SolicitudesActivasNotifier, SolicitudesState>((ref) {
  return SolicitudesActivasNotifier(ref);
});

/// Notifier para solicitudes activas
class SolicitudesActivasNotifier extends StateNotifier<SolicitudesState> {
  SolicitudesActivasNotifier(this.ref) : super(const SolicitudesState()) {
    cargarSolicitudesActivas();
  }

  final Ref ref;
  String? _categoria;
  String? _ciudad;
  String _ordenamiento = 'reciente';

  /// Carga las solicitudes activas
  Future<void> cargarSolicitudesActivas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(solicitudesRepositoryProvider);
      final solicitudes = await repository.obtenerSolicitudesActivas(
        categoria: _categoria,
        ciudad: _ciudad,
        ordenamiento: _ordenamiento,
      );

      state = state.copyWith(
        solicitudes: solicitudes,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar solicitudes activas: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar solicitudes',
      );
    }
  }

  /// Filtra por categoría
  void filtrarPorCategoria(String? categoria) {
    _categoria = categoria;
    cargarSolicitudesActivas();
  }

  /// Filtra por ciudad
  void filtrarPorCiudad(String? ciudad) {
    _ciudad = ciudad;
    cargarSolicitudesActivas();
  }

  /// Cambia el ordenamiento
  void cambiarOrdenamiento(String ordenamiento) {
    _ordenamiento = ordenamiento;
    cargarSolicitudesActivas();
  }

  /// Limpia filtros
  void limpiarFiltros() {
    _categoria = null;
    _ciudad = null;
    _ordenamiento = 'reciente';
    cargarSolicitudesActivas();
  }

  /// Refresca la lista
  Future<void> refresh() async {
    await cargarSolicitudesActivas();
  }
}
