import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/favorito_model.dart';
import '../../data/repositories/favoritos_repository.dart';

// ==========================================
// PROVIDER DE REPOSITORY
// ==========================================

/// Provider del repositorio de favoritos
final favoritosRepositoryProvider = Provider<FavoritosRepository>((ref) {
  return FavoritosRepository();
});

// ==========================================
// ESTADO DE FAVORITOS
// ==========================================

/// Estado de los favoritos del usuario
class FavoritosState {
  final List<FavoritoModel> favoritos;
  final bool isLoading;
  final String? error;
  final int totalFavoritos;

  const FavoritosState({
    this.favoritos = const [],
    this.isLoading = false,
    this.error,
    this.totalFavoritos = 0,
  });

  FavoritosState copyWith({
    List<FavoritoModel>? favoritos,
    bool? isLoading,
    String? error,
    int? totalFavoritos,
  }) {
    return FavoritosState(
      favoritos: favoritos ?? this.favoritos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalFavoritos: totalFavoritos ?? this.totalFavoritos,
    );
  }
}

/// Provider de favoritos del usuario
final misFavoritosProvider =
    StateNotifierProvider<FavoritosNotifier, FavoritosState>((ref) {
  final repository = ref.watch(favoritosRepositoryProvider);
  return FavoritosNotifier(repository);
});

/// Notifier para manejar los favoritos
class FavoritosNotifier extends StateNotifier<FavoritosState> {
  FavoritosNotifier(this._repository) : super(const FavoritosState());

  final FavoritosRepository _repository;
  String? _userId;

  /// Inicializa cargando los favoritos del usuario
  void inicializar(String userId) {
    _userId = userId;
    cargarFavoritos();
  }

  /// Carga los favoritos del usuario
  Future<void> cargarFavoritos() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final favoritos = await _repository.obtenerFavoritos(_userId!);
      final total = await _repository.obtenerTotalFavoritos(_userId!);

      state = state.copyWith(
        favoritos: favoritos,
        totalFavoritos: total,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar favoritos: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar favoritos',
      );
    }
  }

  /// Agrega un profesional a favoritos
  Future<bool> agregarFavorito(String profesionalId) async {
    if (_userId == null) return false;

    try {
      final favorito = await _repository.agregarFavorito(
        userId: _userId!,
        profesionalId: profesionalId,
      );

      if (favorito != null) {
        // Agregar a la lista localmente
        state = state.copyWith(
          favoritos: [favorito, ...state.favoritos],
          totalFavoritos: state.totalFavoritos + 1,
        );
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar favorito: $e');
      }
      return false;
    }
  }

  /// Elimina un profesional de favoritos
  Future<bool> eliminarFavorito(String profesionalId) async {
    if (_userId == null) return false;

    try {
      final success = await _repository.eliminarFavorito(
        userId: _userId!,
        profesionalId: profesionalId,
      );

      if (success) {
        // Eliminar de la lista localmente
        state = state.copyWith(
          favoritos: state.favoritos
              .where((f) => f.profesionalId != profesionalId)
              .toList(),
          totalFavoritos: state.totalFavoritos - 1,
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar favorito: $e');
      }
      return false;
    }
  }

  /// Toggle favorito (agregar/eliminar)
  Future<bool> toggleFavorito(String profesionalId) async {
    if (_userId == null) return false;

    try {
      // Verificar si ya es favorito
      final yaEsFavorito = state.favoritos.any(
        (f) => f.profesionalId == profesionalId,
      );

      if (yaEsFavorito) {
        return await eliminarFavorito(profesionalId);
      } else {
        return await agregarFavorito(profesionalId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al toggle favorito: $e');
      }
      return false;
    }
  }

  /// Verifica si un profesional está en favoritos
  bool esFavorito(String profesionalId) {
    return state.favoritos.any((f) => f.profesionalId == profesionalId);
  }

  /// Filtra por categoría
  List<FavoritoModel> filtrarPorCategoria(String categoria) {
    return state.favoritos
        .where((f) => f.profesionalCategoria == categoria)
        .toList();
  }

  /// Filtra por ciudad
  List<FavoritoModel> filtrarPorCiudad(String ciudad) {
    return state.favoritos
        .where((f) => f.profesionalCiudad == ciudad)
        .toList();
  }

  /// Elimina todos los favoritos
  Future<bool> eliminarTodos() async {
    if (_userId == null) return false;

    try {
      final success = await _repository.eliminarTodosFavoritos(_userId!);

      if (success) {
        state = state.copyWith(
          favoritos: [],
          totalFavoritos: 0,
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar todos los favoritos: $e');
      }
      return false;
    }
  }

  /// Refresca los favoritos
  Future<void> refresh() async {
    await cargarFavoritos();
  }
}

// ==========================================
// PROVIDERS AUXILIARES
// ==========================================

/// Provider para verificar si un profesional es favorito
final esFavoritoProvider = Provider.family<bool, String>((ref, profesionalId) {
  final favoritosState = ref.watch(misFavoritosProvider);
  return favoritosState.favoritos.any((f) => f.profesionalId == profesionalId);
});

/// Provider async para verificar favorito directo de BD
final verificarFavoritoProvider = FutureProvider.family
    .autoDispose<bool, ({String userId, String profesionalId})>(
  (ref, params) async {
    final repository = ref.watch(favoritosRepositoryProvider);
    return await repository.esFavorito(
      userId: params.userId,
      profesionalId: params.profesionalId,
    );
  },
);

/// Provider para obtener total de favoritos de un profesional
final totalFavoritosProfesionalProvider =
    FutureProvider.family.autoDispose<int, String>(
  (ref, profesionalId) async {
    final repository = ref.watch(favoritosRepositoryProvider);
    return await repository.obtenerTotalFavoritosDeProfesional(profesionalId);
  },
);
