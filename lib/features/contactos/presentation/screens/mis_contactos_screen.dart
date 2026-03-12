import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/contactos_provider.dart';
import '../../data/models/contacto_model.dart';

/// Pantalla de lista de contactos guardados
class MisContactosScreen extends ConsumerStatefulWidget {
  const MisContactosScreen({super.key});

  @override
  ConsumerState<MisContactosScreen> createState() => _MisContactosScreenState();
}

class _MisContactosScreenState extends ConsumerState<MisContactosScreen> {
  final _searchController = TextEditingController();
  bool _mostrarSoloFavoritos = false;

  @override
  void initState() {
    super.initState();
    // Cargar contactos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).value;
      if (user != null) {
        ref.read(misContactosProvider.notifier).inicializar(user.id);
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
    final state = ref.watch(misContactosProvider);

    // Filtrar contactos según opciones seleccionadas
    List<ContactoModel> contactosFiltrados = _mostrarSoloFavoritos
        ? state.contactosFavoritos
        : state.contactosFiltrados;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Contactos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (state.contactos.isNotEmpty)
              Text(
                '${state.total} contacto${state.total != 1 ? 's' : ''} guardado${state.total != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: AppTheme.grey500),
              ),
          ],
        ),
        actions: [
          // Filtro de favoritos
          IconButton(
            icon: Icon(
              _mostrarSoloFavoritos ? Icons.star : Icons.star_outline,
              color: _mostrarSoloFavoritos ? AppTheme.accent : null,
            ),
            onPressed: () {
              setState(() {
                _mostrarSoloFavoritos = !_mostrarSoloFavoritos;
              });
            },
            tooltip: _mostrarSoloFavoritos
                ? 'Mostrar todos'
                : 'Mostrar solo favoritos',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(misContactosProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contacto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(misContactosProvider.notifier).limpiarBusqueda();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(misContactosProvider.notifier).buscar(value);
              },
            ),
          ),

          // Chips de info rápida
          if (state.contactos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.people,
                    label: '${state.total} Total',
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.star,
                    label: '${state.totalFavoritos} Favoritos',
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Lista de contactos
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildErrorState(state.error!)
                    : contactosFiltrados.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(misContactosProvider.notifier)
                                  .refresh();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: contactosFiltrados.length,
                              itemBuilder: (context, index) {
                                final contacto = contactosFiltrados[index];
                                return _buildContactoCard(contacto);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ir a buscar profesionales para agregar
          context.push('/search');
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactoCard(ContactoModel contacto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: contacto.favorito
            ? BorderSide(color: AppTheme.accent, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // Ir al perfil del profesional
          context.push('/profesional/${contacto.profesionalId}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con foto y nombre
              Row(
                children: [
                  // Foto
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.grey200,
                        backgroundImage: contacto.profesionalFoto != null
                            ? CachedNetworkImageProvider(
                                contacto.profesionalFoto!)
                            : null,
                        child: contacto.profesionalFoto == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      if (contacto.profesionalVerificado == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contacto.profesionalNombre ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.work_outline,
                                size: 14, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                contacto.profesionalCategoria ?? 'Sin categoría',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: AppTheme.grey600),
                            const SizedBox(width: 4),
                            Text(
                              contacto.profesionalCiudad ?? 'Sin ubicación',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey600,
                              ),
                            ),
                            if (contacto.profesionalCalificacion != null) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.star, size: 14, color: AppTheme.accent),
                              const SizedBox(width: 2),
                              Text(
                                contacto.profesionalCalificacion!
                                    .toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.grey700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón de favorito
                  IconButton(
                    icon: Icon(
                      contacto.favorito ? Icons.star : Icons.star_outline,
                      color: contacto.favorito ? AppTheme.accent : AppTheme.grey400,
                    ),
                    onPressed: () async {
                      await ref
                          .read(misContactosProvider.notifier)
                          .toggleFavorito(contacto.id);
                    },
                  ),
                ],
              ),

              // Notas (si hay)
              if (contacto.notas != null && contacto.notas!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 16, color: AppTheme.grey600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contacto.notas!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Botones de acción
              Row(
                children: [
                  // Tiempo agregado
                  Text(
                    'Agregado ${contacto.tiempoAgregado}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey500,
                    ),
                  ),
                  const Spacer(),

                  // Editar notas
                  TextButton.icon(
                    onPressed: () => _editarNotas(contacto),
                    icon: Icon(Icons.edit_note, size: 18),
                    label: const Text('Notas', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  // WhatsApp
                  if (contacto.profesionalWhatsapp != null)
                    TextButton.icon(
                      onPressed: () {
                        WhatsAppService.enviarMensaje(
                          numero: contacto.profesionalWhatsapp!,
                          mensaje:
                              'Hola! Te contacto desde CONTACTOS. Guardé tu perfil porque me interesaron tus servicios.',
                        );
                      },
                      icon: Icon(Icons.phone, size: 18, color: Color(0xFF25D366)),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 12, color: Color(0xFF25D366)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),

                  // Eliminar
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: AppTheme.error),
                    onPressed: () => _eliminarContacto(contacto),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contacts,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _mostrarSoloFavoritos
                  ? 'No tienes contactos favoritos'
                  : 'Tu lista de contactos está vacía',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _mostrarSoloFavoritos
                  ? 'Marca contactos como favoritos para verlos aquí'
                  : 'Guarda los profesionales que te interesen para contactarlos después',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!_mostrarSoloFavoritos)
              ElevatedButton.icon(
                onPressed: () => context.push('/search'),
                icon: const Icon(Icons.search),
                label: const Text('Buscar Profesionales'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: AppTheme.grey700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(misContactosProvider.notifier).refresh();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarNotas(ContactoModel contacto) async {
    final controller = TextEditingController(text: contacto.notas ?? '');

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notas del contacto'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Escribe notas sobre este contacto...',
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      final success = await ref
          .read(misContactosProvider.notifier)
          .actualizarNotas(contactoId: contacto.id, notas: resultado);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notas actualizadas'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  Future<void> _eliminarContacto(ContactoModel contacto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text(
          '¿Deseas eliminar a ${contacto.profesionalNombre ?? 'este profesional'} de tu lista de contactos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await ref
          .read(misContactosProvider.notifier)
          .eliminarContacto(contacto.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacto eliminado'),
          ),
        );
      }
    }
  }
}
