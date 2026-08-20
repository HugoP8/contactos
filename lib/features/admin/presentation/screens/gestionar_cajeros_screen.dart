import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';

/// Modelo simple para Cajero
class Cajero {
  final String id;
  final String nombre;
  final String ciudad;
  final String? zona;
  final String telefono;
  final String? whatsapp;
  final String? qrImage;
  final bool activo;
  final int totalRecargas;
  final double montoTotalRecargado;
  final DateTime createdAt;

  Cajero({
    required this.id,
    required this.nombre,
    required this.ciudad,
    this.zona,
    required this.telefono,
    this.whatsapp,
    this.qrImage,
    this.activo = true,
    this.totalRecargas = 0,
    this.montoTotalRecargado = 0,
    required this.createdAt,
  });

  factory Cajero.fromJson(Map<String, dynamic> json) {
    return Cajero(
      id: json['id'] as String,
      nombre: json['nombre_completo'] as String,
      ciudad: json['ciudad'] as String,
      zona: json['zona'] as String?,
      telefono: json['telefono'] as String,
      whatsapp: json['whatsapp'] as String?,
      qrImage: null,
      activo: json['activo'] as bool? ?? true,
      totalRecargas: json['total_transacciones'] as int? ?? 0,
      montoTotalRecargado: (json['total_monto_procesado'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Provider para cargar cajeros
final cajerosProvider = FutureProvider<List<Cajero>>((ref) async {
  final response = await SupabaseService.instance.client
      .from('cajeros_vendedores')
      .select()
      .order('ciudad')
      .order('nombre_completo');

  return (response as List).map((json) => Cajero.fromJson(json)).toList();
});

/// Pantalla para gestionar cajeros (CRUD)
class GestionarCajerosScreen extends ConsumerStatefulWidget {
  const GestionarCajerosScreen({super.key});

  @override
  ConsumerState<GestionarCajerosScreen> createState() => _GestionarCajerosScreenState();
}

class _GestionarCajerosScreenState extends ConsumerState<GestionarCajerosScreen> {
  String _filtroEstado = 'todos'; // todos, activos, inactivos

  @override
  Widget build(BuildContext context) {
    final cajerosAsync = ref.watch(cajerosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Cajeros'),
        actions: [
          // Filtro de estado
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtroEstado = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('Todos')),
              const PopupMenuItem(value: 'activos', child: Text('Solo activos')),
              const PopupMenuItem(value: 'inactivos', child: Text('Solo inactivos')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(cajerosProvider),
          ),
        ],
      ),
      body: cajerosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(cajerosProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (cajeros) {
          // Aplicar filtro
          List<Cajero> cajerosFiltrados = cajeros;
          if (_filtroEstado == 'activos') {
            cajerosFiltrados = cajeros.where((c) => c.activo).toList();
          } else if (_filtroEstado == 'inactivos') {
            cajerosFiltrados = cajeros.where((c) => !c.activo).toList();
          }

          if (cajerosFiltrados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: AppTheme.grey400),
                  const SizedBox(height: 16),
                  Text(
                    cajeros.isEmpty
                        ? 'No hay cajeros registrados'
                        : 'No hay cajeros con este filtro',
                    style: TextStyle(color: AppTheme.grey600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cajerosFiltrados.length,
            itemBuilder: (context, index) {
              final cajero = cajerosFiltrados[index];
              return _buildCajeroCard(cajero);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioCajero(null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cajero'),
      ),
    );
  }

  Widget _buildCajeroCard(Cajero cajero) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cajero.activo ? AppTheme.success.withOpacity(0.3) : AppTheme.grey300,
          width: cajero.activo ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cajero.activo
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.grey200,
                  child: Icon(
                    Icons.store,
                    color: cajero.activo ? AppTheme.success : AppTheme.grey500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cajero.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cajero.activo
                                  ? AppTheme.success.withOpacity(0.1)
                                  : AppTheme.grey200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cajero.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cajero.activo ? AppTheme.success : AppTheme.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppTheme.grey600),
                          const SizedBox(width: 4),
                          Text(
                            '${cajero.ciudad}${cajero.zona != null ? ' - ${cajero.zona}' : ''}',
                            style: TextStyle(fontSize: 13, color: AppTheme.grey600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Info de contacto
            Row(
              children: [
                _buildInfoItem(Icons.phone, cajero.telefono),
                const SizedBox(width: 16),
                if (cajero.whatsapp != null)
                  _buildInfoItem(Icons.chat, cajero.whatsapp!),
              ],
            ),
            const SizedBox(height: 12),

            // Estadísticas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Recargas', cajero.totalRecargas.toString()),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppTheme.grey300,
                  ),
                  _buildStatItem(
                    'Monto Total',
                    'Bs. ${cajero.montoTotalRecargado.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _mostrarFormularioCajero(cajero),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _toggleEstadoCajero(cajero),
                  icon: Icon(
                    cajero.activo ? Icons.block : Icons.check_circle,
                    size: 18,
                    color: cajero.activo ? AppTheme.error : AppTheme.success,
                  ),
                  label: Text(
                    cajero.activo ? 'Desactivar' : 'Activar',
                    style: TextStyle(
                      color: cajero.activo ? AppTheme.error : AppTheme.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _eliminarCajero(cajero),
                  icon: Icon(Icons.delete_outline, color: AppTheme.error),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: AppTheme.grey700),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.grey600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarFormularioCajero(Cajero? cajero) async {
    final nombreController = TextEditingController(text: cajero?.nombre);
    final telefonoController = TextEditingController(text: cajero?.telefono);
    final whatsappController = TextEditingController(text: cajero?.whatsapp);
    final zonaController = TextEditingController(text: cajero?.zona);
    String ciudadSeleccionada = cajero?.ciudad ?? 'La Paz';
    bool activo = cajero?.activo ?? true;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                cajero == null ? Icons.add_business : Icons.edit,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(cajero == null ? 'Nuevo Cajero' : 'Editar Cajero'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del cajero *',
                    prefixIcon: const Icon(Icons.store),
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ciudad
                DropdownButtonFormField<String>(
                  value: ciudadSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Ciudad *',
                    prefixIcon: const Icon(Icons.location_city),
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: AppConstants.ciudadesBolivia.map((ciudad) {
                    return DropdownMenuItem(value: ciudad, child: Text(ciudad));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      ciudadSeleccionada = value ?? 'La Paz';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Zona
                TextField(
                  controller: zonaController,
                  decoration: InputDecoration(
                    labelText: 'Zona (opcional)',
                    prefixIcon: const Icon(Icons.map),
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono *',
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // WhatsApp
                TextField(
                  controller: whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'WhatsApp (opcional)',
                    prefixIcon: const Icon(Icons.chat),
                    hintText: 'Ej: 59171234567',
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Estado activo
                SwitchListTile(
                  title: const Text('Cajero activo'),
                  subtitle: Text(
                    activo
                        ? 'Visible para usuarios'
                        : 'No visible para usuarios',
                    style: TextStyle(fontSize: 12, color: AppTheme.grey600),
                  ),
                  value: activo,
                  onChanged: (value) {
                    setDialogState(() {
                      activo = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isEmpty ||
                    telefonoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nombre y teléfono son obligatorios'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(cajero == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == true) {
      try {
        final data = {
          'nombre_completo': nombreController.text.trim(),
          'ciudad': ciudadSeleccionada,
          'zona': zonaController.text.trim().isEmpty ? null : zonaController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'whatsapp': whatsappController.text.trim().isEmpty
              ? null
              : whatsappController.text.trim(),
          'activo': activo,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (cajero == null) {
          // Crear nuevo
          data['created_at'] = DateTime.now().toIso8601String();
          await SupabaseService.instance.client.from('cajeros_vendedores').insert(data);
        } else {
          // Actualizar existente
          await SupabaseService.instance.client
              .from('cajeros_vendedores')
              .update(data)
              .eq('id', cajero.id);
        }

        ref.invalidate(cajerosProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cajero == null
                  ? 'Cajero creado exitosamente'
                  : 'Cajero actualizado exitosamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleEstadoCajero(Cajero cajero) async {
    try {
      await SupabaseService.instance.client.from('cajeros_vendedores').update({
        'activo': !cajero.activo,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cajero.id);

      ref.invalidate(cajerosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cajero.activo
                ? 'Cajero desactivado'
                : 'Cajero activado'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _eliminarCajero(Cajero cajero) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cajero'),
        content: Text(
          '¿Deseas eliminar el cajero "${cajero.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
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
      try {
        await SupabaseService.instance.client
            .from('cajeros_vendedores')
            .delete()
            .eq('id', cajero.id);

        ref.invalidate(cajerosProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cajero eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}
