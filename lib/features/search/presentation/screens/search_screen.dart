import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../providers/search_provider.dart';
import '../widgets/profesional_card.dart';

/// Pantalla de búsqueda de profesionales
class SearchScreen extends ConsumerStatefulWidget {
  final String? categoriaInicial;

  const SearchScreen({super.key, this.categoriaInicial});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarFiltros = false;

  @override
  void initState() {
    super.initState();
    // Cargar profesionales al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si viene con categoría, aplicar filtro
      if (widget.categoriaInicial != null && widget.categoriaInicial!.isNotEmpty) {
        ref.read(searchProvider.notifier).filtrarPorCategoria(widget.categoriaInicial);
        setState(() {
          _mostrarFiltros = true; // Mostrar filtros para que vea qué está activo
        });
      } else {
        ref.read(searchProvider.notifier).cargarProfesionales();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Profesionales'),
        actions: [
          // Botón de filtros
          IconButton(
            icon: Badge(
              isLabelVisible: _tieneFiltrosActivos(),
              backgroundColor: AppTheme.accent,
              child: Icon(
                _mostrarFiltros ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
            ),
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar profesional o servicio...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchProvider.notifier)
                              .buscarPorTexto('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                // Buscar después de 500ms de inactividad
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    ref.read(searchProvider.notifier).buscarPorTexto(value);
                  }
                });
              },
            ),
          ),

          // Panel de filtros (desplegable)
          if (_mostrarFiltros)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.grey200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Text(
                    'Categoría',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: searchState.categoriaSeleccionada,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: Text('Todas las categorías'),
                    items: _obtenerCategoriasItems(),
                    onChanged: (value) {
                      ref
                          .read(searchProvider.notifier)
                          .filtrarPorCategoria(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Departamento/Ciudad
                  Text(
                    'Departamento',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: searchState.ciudadSeleccionada,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primary),
                    ),
                    hint: Text('Todos los departamentos'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(Icons.public, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Todos los departamentos'),
                          ],
                        ),
                      ),
                      ...AppConstants.ciudadesBolivia.map((ciudad) {
                        return DropdownMenuItem<String>(
                          value: ciudad,
                          child: Row(
                            children: [
                              Icon(Icons.location_city, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Text(ciudad),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      ref.read(searchProvider.notifier).filtrarPorCiudad(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ordenamiento
                  Text(
                    'Ordenar por',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'destacado',
                        label: Text('Destacado'),
                        icon: Icon(Icons.star, size: 16),
                      ),
                      ButtonSegment(
                        value: 'calificacion',
                        label: Text('Mejor'),
                        icon: Icon(Icons.thumb_up, size: 16),
                      ),
                      ButtonSegment(
                        value: 'reciente',
                        label: Text('Nuevo'),
                        icon: Icon(Icons.schedule, size: 16),
                      ),
                    ],
                    selected: {searchState.ordenamiento ?? 'destacado'},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref
                          .read(searchProvider.notifier)
                          .cambiarOrdenamiento(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón limpiar filtros
                  if (_tieneFiltrosActivos())
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).limpiarFiltros();
                        },
                        icon: Icon(Icons.clear_all),
                        label: Text('Limpiar filtros'),
                      ),
                    ),
                ],
              ),
            ),

          // Contador de resultados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.grey200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${searchState.profesionales.length} profesionales encontrados',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey600,
                      ),
                ),
              ],
            ),
          ),

          // Lista de profesionales
          Expanded(
            child: _buildListaProfesionales(searchState),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }

  /// Widget que construye la lista de profesionales según el estado
  Widget _buildListaProfesionales(SearchState state) {
    // Estado de carga
    if (state.isLoading && state.profesionales.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado de error
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(searchProvider.notifier).cargarProfesionales();
              },
              icon: Icon(Icons.refresh),
              label: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Estado vacío
    if (state.profesionales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron profesionales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros o buscar otra cosa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grey600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).limpiarFiltros();
              },
              icon: Icon(Icons.clear_all),
              label: Text('Limpiar filtros'),
            ),
          ],
        ),
      );
    }

    // Lista de profesionales
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(searchProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.profesionales.length,
        itemBuilder: (context, index) {
          final profesional = state.profesionales[index];
          return ProfesionalCard(profesional: profesional);
        },
      ),
    );
  }

  /// Obtiene los items del dropdown de categorías
  List<DropdownMenuItem<String>> _obtenerCategoriasItems() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Todas las categorías'),
      ),
    ];

    // Agregar categorías de AppConstants
    for (var categoria in AppConstants.categorias.entries) {
      // Agregar categoría principal
      items.add(
        DropdownMenuItem<String>(
          value: categoria.key,
          child: Text(categoria.key, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

      // Agregar subcategorías
      for (var subcategoria in categoria.value) {
        items.add(
          DropdownMenuItem<String>(
            value: subcategoria,
            child: Text('  • $subcategoria'),
          ),
        );
      }
    }

    return items;
  }

  /// Verifica si hay filtros activos
  bool _tieneFiltrosActivos() {
    final state = ref.read(searchProvider);
    return state.categoriaSeleccionada != null ||
        state.ciudadSeleccionada != null ||
        (state.searchQuery != null && state.searchQuery!.isNotEmpty);
  }
}
