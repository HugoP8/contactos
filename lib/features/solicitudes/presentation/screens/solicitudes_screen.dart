import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/solicitudes_repository.dart';
import '../../data/models/solicitud_trabajo_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../widgets/solicitud_card.dart';

/// Provider para el repositorio de solicitudes
final solicitudesRepositoryProvider = Provider((ref) => SolicitudesRepository());

/// Provider para todas las solicitudes activas
final solicitudesActivasProvider = FutureProvider.family<List<SolicitudTrabajoModel>, String?>((ref, categoria) async {
  final repository = ref.watch(solicitudesRepositoryProvider);
  return repository.obtenerSolicitudesActivas(categoria: categoria);
});

/// Pantalla de todas las solicitudes de trabajo disponibles
class SolicitudesScreen extends ConsumerStatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  ConsumerState<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends ConsumerState<SolicitudesScreen> {
  String? _categoriaSeleccionada;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Categorías ordenadas alfabéticamente
  List<String> get _categorias {
    final cats = List<String>.from(AppConstants.todasLasSubcategorias);
    cats.sort((a, b) => a.compareTo(b));
    return cats;
  }

  // Filtrar categorías por búsqueda
  List<String> get _categoriasFiltradas {
    if (_searchQuery.isEmpty) return _categorias;
    return _categorias.where((cat) =>
      cat.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesActivasProvider(_categoriaSeleccionada));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Trabajo'),
        actions: [
          // Botón para ver Mis Solicitudes
          TextButton.icon(
            onPressed: () => context.push('/mis-solicitudes'),
            icon: const Icon(Icons.person, size: 20),
            label: const Text('Mis Solicitudes'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador de categorías
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.grey100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar categoría...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),

                // Chips de categorías
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoriasFiltradas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Todas'),
                            selected: _categoriaSeleccionada == null,
                            onSelected: (selected) {
                              setState(() => _categoriaSeleccionada = null);
                              ref.invalidate(solicitudesActivasProvider(_categoriaSeleccionada));
                            },
                            selectedColor: AppTheme.primary.withOpacity(0.2),
                            checkmarkColor: AppTheme.primary,
                          ),
                        );
                      }

                      final categoria = _categoriasFiltradas[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(categoria),
                          selected: _categoriaSeleccionada == categoria,
                          onSelected: (selected) {
                            setState(() => _categoriaSeleccionada = selected ? categoria : null);
                            ref.invalidate(solicitudesActivasProvider(_categoriaSeleccionada));
                          },
                          selectedColor: AppTheme.primary.withOpacity(0.2),
                          checkmarkColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Banner "Mis Solicitudes" estilo Facebook Marketplace
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/mis-solicitudes'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_special,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Solicitudes',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Administra, renueva o elimina tus publicaciones',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lista de solicitudes
          Expanded(
            child: solicitudesAsync.when(
              data: (solicitudes) {
                if (solicitudes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off,
                          size: 80,
                          color: AppTheme.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _categoriaSeleccionada != null
                              ? 'No hay solicitudes en $_categoriaSeleccionada'
                              : 'No hay solicitudes disponibles',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Las nuevas solicitudes aparecerán aquí',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.grey400,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(solicitudesActivasProvider(_categoriaSeleccionada));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: solicitudes.length,
                    itemBuilder: (context, index) {
                      final solicitud = solicitudes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SolicitudCard(
                          solicitud: solicitud,
                          showActions: false, // No mostrar acciones (es solo para ver)
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar solicitudes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        ref.invalidate(solicitudesActivasProvider(_categoriaSeleccionada));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // FAB para crear solicitud
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/solicitud/crear'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Solicitud'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      // Bottom Navigation
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }
}
