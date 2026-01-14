import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/favoritos_provider.dart';
import '../../data/models/favorito_model.dart';

/// Pantalla de favoritos del usuario
class MisFavoritosScreen extends ConsumerStatefulWidget {
  const MisFavoritosScreen({super.key});

  @override
  ConsumerState<MisFavoritosScreen> createState() => _MisFavoritosScreenState();
}

class _MisFavoritosScreenState extends ConsumerState<MisFavoritosScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar favoritos con el usuario actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).value;
      if (user != null) {
        ref.read(misFavoritosProvider.notifier).inicializar(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritosState = ref.watch(misFavoritosProvider);
    final user = ref.watch(authProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mis Favoritos'),
        ),
        body: const Center(
          child: Text('Debes iniciar sesión'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Favoritos'),
        actions: [
          // Botón para eliminar todos
          if (favoritosState.favoritos.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () => _confirmarEliminarTodos(context),
              tooltip: 'Eliminar todos',
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner con total
          if (favoritosState.totalFavoritos > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Tienes ${favoritosState.totalFavoritos} ${favoritosState.totalFavoritos == 1 ? "profesional favorito" : "profesionales favoritos"}',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Lista de favoritos
          Expanded(
            child: _buildListaFavoritos(favoritosState),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de favoritos
  Widget _buildListaFavoritos(FavoritosState state) {
    // Estado de carga
    if (state.isLoading && state.favoritos.isEmpty) {
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
            Icon(Icons.error_outline, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(misFavoritosProvider.notifier).refresh();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Estado vacío
    if (state.favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppTheme.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega profesionales a favoritos para\nacceder rápidamente a ellos',
              style: TextStyle(
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/search');
              },
              icon: Icon(Icons.search),
              label: Text('Buscar Profesionales'),
            ),
          ],
        ),
      );
    }

    // Lista de favoritos
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(misFavoritosProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.favoritos.length,
        itemBuilder: (context, index) {
          final favorito = state.favoritos[index];
          return _buildFavoritoCard(favorito);
        },
      ),
    );
  }

  /// Card de favorito
  Widget _buildFavoritoCard(FavoritoModel favorito) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/profesional/${favorito.profesionalId}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: favorito.profesionalFoto != null
                    ? CachedNetworkImage(
                        imageUrl: favorito.profesionalFoto!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.grey200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.grey200,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.grey400,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.grey200,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.grey400,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            favorito.profesionalNombre ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (favorito.profesionalVerificado == true)
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        if (favorito.profesionalDestacado == true)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Categoría
                    if (favorito.profesionalCategoria != null)
                      Text(
                        favorito.profesionalCategoria!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    const SizedBox(height: 8),

                    // Calificación y ciudad
                    Row(
                      children: [
                        // Calificación
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (favorito.profesionalCalificacion ?? 0)
                              .toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${favorito.profesionalTotalResenas ?? 0})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),

                        // Ciudad
                        if (favorito.profesionalCiudad != null) ...[
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.grey400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            favorito.profesionalCiudad!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Tiempo agregado
                    Text(
                      'Agregado ${favorito.tiempoTranscurrido}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey500,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                icon: Icon(Icons.favorite, color: AppTheme.error),
                onPressed: () => _confirmarEliminar(context, favorito),
                tooltip: 'Quitar de favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirma eliminar un favorito
  Future<void> _confirmarEliminar(
    BuildContext context,
    FavoritoModel favorito,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quitar de favoritos'),
        content: Text(
          '¿Deseas quitar a ${favorito.profesionalNombre ?? "este profesional"} de tus favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final success = await ref
          .read(misFavoritosProvider.notifier)
          .eliminarFavorito(favorito.profesionalId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Confirma eliminar todos los favoritos
  Future<void> _confirmarEliminarTodos(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar todos los favoritos'),
        content: Text(
          '¿Estás seguro de que deseas eliminar TODOS tus favoritos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Eliminar Todos'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final success =
          await ref.read(misFavoritosProvider.notifier).eliminarTodos();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todos los favoritos eliminados'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
