import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../shared/models/perfil_profesional_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/resenas/data/models/resena_model.dart';
import '../../../../features/favoritos/presentation/providers/favoritos_provider.dart';

/// Provider para cargar un profesional específico
final profesionalDetalleProvider =
    FutureProvider.family<PerfilProfesionalModel?, String>((ref, id) async {
  try {
    final response = await SupabaseService.instance.client
        .from('perfiles_profesionales')
        .select()
        .eq('id', id)
        .single();

    return PerfilProfesionalModel.fromJson(response);
  } catch (e) {
    debugPrint('Error al cargar profesional: $e');
    return null;
  }
});

/// Provider para cargar reseñas de un profesional
final resenasProvider =
    FutureProvider.family<List<ResenaModel>, String>((ref, profesionalId) async {
  try {
    final response = await SupabaseService.instance.client
        .from('resenas')
        .select('''
          *,
          usuario:users!resenas_usuario_id_fkey(
            nombre_completo,
            foto_perfil
          )
        ''')
        .eq('profesional_id', profesionalId)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List)
        .map((json) => ResenaModel.fromJson(json))
        .toList();
  } catch (e) {
    debugPrint('Error al cargar reseñas: $e');
    return [];
  }
});

/// Pantalla de detalle del profesional
class ProfesionalDetalleScreen extends ConsumerStatefulWidget {
  final String profesionalId;

  const ProfesionalDetalleScreen({
    super.key,
    required this.profesionalId,
  });

  @override
  ConsumerState<ProfesionalDetalleScreen> createState() =>
      _ProfesionalDetalleScreenState();
}

class _ProfesionalDetalleScreenState
    extends ConsumerState<ProfesionalDetalleScreen> {
  bool _contactoVisible = false;

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
    final profesionalAsync =
        ref.watch(profesionalDetalleProvider(widget.profesionalId));
    final resenasAsync = ref.watch(resenasProvider(widget.profesionalId));
    final authUser = ref.watch(authProvider).value;
    final esFavorito = ref.watch(esFavoritoProvider(widget.profesionalId));

    return profesionalAsync.when(
      data: (profesional) {
        if (profesional == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Profesional no encontrado'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar con imagen de portada
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: profesional.fotoPerfil != null
                      ? CachedNetworkImage(
                          imageUrl: profesional.fotoPerfil!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.primary,
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
                actions: [
                  // Botón de favorito
                  IconButton(
                    icon: Icon(
                      esFavorito ? Icons.favorite : Icons.favorite_border,
                      color: esFavorito ? AppTheme.error : null,
                    ),
                    onPressed: () => _toggleFavorito(authUser),
                  ),
                  // Botón de compartir
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implementar compartir
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Funcionalidad próximamente'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con nombre y badges
                    _buildHeader(profesional),

                    const Divider(height: 1),

                    // Stats rápidas
                    _buildQuickStats(profesional),

                    const Divider(height: 1),

                    // Descripción
                    if (profesional.descripcion != null)
                      _buildDescripcion(profesional.descripcion!),

                    // Galería de fotos
                    if (profesional.galeriaFotos.isNotEmpty)
                      _buildGaleria(profesional.galeriaFotos),

                    // Botón de contacto
                    _buildContactoSection(profesional, authUser),

                    // Reseñas
                    _buildResenasSection(resenasAsync),

                    const SizedBox(height: 80), // Espacio para el FAB
                  ],
                ),
              ),
            ],
          ),
          // Botón flotante de WhatsApp
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _contactarPorWhatsApp(profesional),
            icon: Icon(Icons.phone),
            label: Text('WhatsApp'),
            backgroundColor: const Color(0xFF25D366),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                      profesionalDetalleProvider(widget.profesionalId));
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con nombre y badges
  Widget _buildHeader(PerfilProfesionalModel profesional) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre y badges
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profesional.nombreComercial ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profesional.categoriaPrincipal,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Badges
              Column(
                children: [
                  if (profesional.verificado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Verificado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (profesional.destacado)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calificación
          Row(
            children: [
              Icon(Icons.star, color: AppTheme.accent, size: 24),
              const SizedBox(width: 4),
              Text(
                profesional.calificacionPromedio.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${profesional.totalResenas} reseñas)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Stats rápidas
  Widget _buildQuickStats(PerfilProfesionalModel profesional) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.location_on,
            profesional.ciudad,
          ),
          _buildStatItem(
            Icons.work_outline,
            '${profesional.totalResenas} trabajos',
          ),
          if (profesional.subcategorias.isNotEmpty)
            _buildStatItem(
              Icons.category_outlined,
              '${profesional.subcategorias.length} servicios',
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  /// Descripción
  Widget _buildDescripcion(String descripcion) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Galería de fotos
  Widget _buildGaleria(List<String> fotos) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Galería',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: fotos[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.grey200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.grey200,
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de contacto
  Widget _buildContactoSection(
      PerfilProfesionalModel profesional, dynamic authUser) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.phone_in_talk, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de contacto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _contactoVisible
                          ? 'WhatsApp: ${profesional.whatsapp}'
                          : 'Desbloquea el contacto por 2 créditos',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_contactoVisible) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _desbloquearContacto(authUser),
              icon: Icon(Icons.lock_open),
              label: Text('Ver contacto (2 créditos)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Sección de reseñas
  Widget _buildResenasSection(AsyncValue<List<ResenaModel>> resenasAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reseñas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Ver todas las reseñas
                },
                child: Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          resenasAsync.when(
            data: (resenas) {
              if (resenas.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aún no hay reseñas',
                      style: TextStyle(color: AppTheme.grey600),
                    ),
                  ),
                );
              }

              return Column(
                children: resenas.take(3).map((resena) {
                  return _buildResenaItem(resena);
                }).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Text('Error al cargar reseñas: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildResenaItem(ResenaModel resena) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: resena.usuarioFoto != null
                    ? CachedNetworkImageProvider(resena.usuarioFoto!)
                    : null,
                child: resena.usuarioFoto == null
                    ? Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resena.usuarioNombre ?? 'Usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < resena.calificacion
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: AppTheme.accent,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                resena.tiempoTranscurrido,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
          if (resena.comentario != null) ...[
            const SizedBox(height: 8),
            Text(
              resena.comentario!,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grey700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Desbloquea el contacto del profesional
  Future<void> _desbloquearContacto(dynamic authUser) async {
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    // Verificar créditos
    if (authUser.creditos < AppConstants.costoVerContacto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes suficientes créditos'),
        ),
      );
      context.push('/creditos');
      return;
    }

    // Confirmar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Desbloquear contacto'),
        content: Text(
          '¿Deseas ver el contacto de este profesional por ${AppConstants.costoVerContacto} créditos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Descontar créditos
    final success = await SupabaseService.instance.descontarCreditos(
      userId: authUser.id,
      cantidad: AppConstants.costoVerContacto,
      motivo: 'ver_contacto',
    );

    if (success && mounted) {
      setState(() {
        _contactoVisible = true;
      });
      ref.invalidate(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contacto desbloqueado'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al desbloquear contacto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Contacta por WhatsApp
  void _contactarPorWhatsApp(PerfilProfesionalModel profesional) {
    if (!_contactoVisible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Primero debes desbloquear el contacto'),
        ),
      );
      return;
    }

    WhatsAppService.enviarMensaje(
      numero: profesional.whatsapp ?? '',
      mensaje:
          'Hola! Te contacto desde CONTACTOS. Estoy interesado en tus servicios de ${profesional.categoriaPrincipal}.',
    );
  }

  /// Toggle favorito
  Future<void> _toggleFavorito(dynamic authUser) async {
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    final esFavorito = ref.read(esFavoritoProvider(widget.profesionalId));

    final success = await ref
        .read(misFavoritosProvider.notifier)
        .toggleFavorito(widget.profesionalId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esFavorito
                ? 'Eliminado de favoritos'
                : 'Agregado a favoritos',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
