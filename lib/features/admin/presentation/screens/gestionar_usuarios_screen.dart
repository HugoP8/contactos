import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class GestionarUsuariosScreen extends ConsumerStatefulWidget {
  const GestionarUsuariosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GestionarUsuariosScreen> createState() =>
      _GestionarUsuariosScreenState();
}

class _GestionarUsuariosScreenState
    extends ConsumerState<GestionarUsuariosScreen> {
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => isLoading = true);
    final actions = ref.read(adminActionsProvider);
    final result = await actions.obtenerUsuarios();
    setState(() {
      usuarios = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return _buildUsuarioCard(usuario);
                  },
                ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final suspendido = usuario['suspendido'] as bool? ?? false;
    final rol = usuario['rol'] as String? ?? 'buscador';
    final creditos = usuario['creditos'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: suspendido
              ? AppTheme.errorColor.withOpacity(0.2)
              : AppTheme.primaryColor.withOpacity(0.2),
          child: Text(
            (usuario['nombre_completo'] as String?)?.substring(0, 1).toUpperCase() ??
                'U',
            style: TextStyle(
              color: suspendido ? AppTheme.errorColor : AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          usuario['nombre_completo'] ?? 'Sin nombre',
          style: TextStyle(
            decoration: suspendido ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario['email'] ?? 'Sin email'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(rol.toUpperCase(), AppTheme.primaryColor),
                const SizedBox(width: 8),
                if (suspendido)
                  _buildBadge('SUSPENDIDO', AppTheme.errorColor),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoRow('Teléfono:', usuario['telefono'] ?? 'N/A'),
                _buildInfoRow('Ciudad:', usuario['ciudad'] ?? 'N/A'),
                _buildInfoRow('Créditos:', '$creditos'),
                _buildInfoRow(
                  'Registrado:',
                  _formatearFecha(usuario['created_at']),
                ),
                if (suspendido && usuario['razon_suspension'] != null) ...[
                  const Divider(height: 24),
                  Text(
                    'Razón de suspensión:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.grey700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario['razon_suspension'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (suspendido)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _activarUsuario(usuario['id']),
                          icon: Icon(Icons.check_circle),
                          label: Text('Activar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _suspenderUsuario(usuario['id']),
                          icon: Icon(Icons.block),
                          label: Text('Suspender'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'N/A';
    try {
      final dt = DateTime.parse(fecha.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _suspenderUsuario(String userId) async {
    String? razon;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspender Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Indica la razón de la suspensión:'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ej: Incumplimiento de términos',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => razon = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Suspender'),
          ),
        ],
      ),
    );

    if (confirmar != true || razon == null || razon!.trim().isEmpty) return;

    final actions = ref.read(adminActionsProvider);
    final success = await actions.suspenderUsuario(userId, razon!);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario suspendido'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        _cargarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al suspender usuario'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _activarUsuario(String userId) async {
    final actions = ref.read(adminActionsProvider);
    final success = await actions.activarUsuario(userId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Usuario activado'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _cargarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al activar usuario'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
