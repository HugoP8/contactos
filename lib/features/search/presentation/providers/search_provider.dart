import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/perfil_profesional_model.dart';
import '../../../../core/services/supabase_service.dart';

/// Estado de búsqueda
class SearchState {
  final List<PerfilProfesionalModel> profesionales;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? categoriaSeleccionada;
  final String? ciudadSeleccionada;
  final String? ordenamiento;

  const SearchState({
    this.profesionales = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.categoriaSeleccionada,
    this.ciudadSeleccionada,
    this.ordenamiento = 'destacado', // destacado, calificacion, reciente
  });

  SearchState copyWith({
    List<PerfilProfesionalModel>? profesionales,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? categoriaSeleccionada,
    String? ciudadSeleccionada,
    String? ordenamiento,
  }) {
    return SearchState(
      profesionales: profesionales ?? this.profesionales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      ciudadSeleccionada: ciudadSeleccionada ?? this.ciudadSeleccionada,
      ordenamiento: ordenamiento ?? this.ordenamiento,
    );
  }
}

/// Provider de búsqueda
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

/// Notifier para manejar la búsqueda
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    cargarProfesionales();
  }

  final _supabase = SupabaseService.instance;

  /// Carga profesionales desde la base de datos
  Future<void> cargarProfesionales() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      var query = _supabase.client
          .from('perfiles_profesionales')
          .select()
          .eq('activo', true)
          .eq('visible_busqueda', true);

      // Aplicar filtro de búsqueda por texto
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        query = query.or(
          'nombre_comercial.ilike.%${state.searchQuery}%,'
          'descripcion.ilike.%${state.searchQuery}%,'
          'categoria_principal.ilike.%${state.searchQuery}%',
        );
      }

      // Aplicar filtro de categoría
      if (state.categoriaSeleccionada != null) {
        query = query.eq('categoria_principal', state.categoriaSeleccionada!);
      }

      // Aplicar filtro de ciudad
      if (state.ciudadSeleccionada != null) {
        query = query.eq('ciudad', state.ciudadSeleccionada!);
      }

      // Aplicar ordenamiento
      switch (state.ordenamiento) {
        case 'destacado':
          query = query.order('destacado', ascending: false);
          break;
        case 'calificacion':
          query = query.order('calificacion_promedio', ascending: false);
          break;
        case 'reciente':
          query = query.order('created_at', ascending: false);
          break;
      }

      final response = await query;
      final profesionales = (response as List)
          .map((json) => PerfilProfesionalModel.fromJson(json))
          .toList();

      state = state.copyWith(
        profesionales: profesionales,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar profesionales: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar profesionales',
      );
    }
  }

  /// Busca por texto
  void buscarPorTexto(String query) {
    state = state.copyWith(searchQuery: query);
    cargarProfesionales();
  }

  /// Filtra por categoría
  void filtrarPorCategoria(String? categoria) {
    state = state.copyWith(categoriaSeleccionada: categoria);
    cargarProfesionales();
  }

  /// Filtra por ciudad
  void filtrarPorCiudad(String? ciudad) {
    state = state.copyWith(ciudadSeleccionada: ciudad);
    cargarProfesionales();
  }

  /// Cambia el ordenamiento
  void cambiarOrdenamiento(String ordenamiento) {
    state = state.copyWith(ordenamiento: ordenamiento);
    cargarProfesionales();
  }

  /// Limpia todos los filtros
  void limpiarFiltros() {
    state = const SearchState();
    cargarProfesionales();
  }

  /// Refresca la lista
  Future<void> refresh() async {
    await cargarProfesionales();
  }
}
