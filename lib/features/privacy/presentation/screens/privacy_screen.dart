import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _perfilPublico = true;
  bool _mostrarTelefono = true;
  bool _mostrarEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y Seguridad'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Visibilidad de Perfil'),

          SwitchListTile(
            title: const Text('Perfil Público'),
            subtitle: const Text('Otros usuarios pueden ver tu perfil'),
            value: _perfilPublico,
            onChanged: (value) {
              setState(() => _perfilPublico = value);
              // TODO: Guardar en BD
              _showSavedSnackbar();
            },
          ),

          SwitchListTile(
            title: const Text('Mostrar Teléfono'),
            subtitle: const Text('Visible en tu perfil profesional'),
            value: _mostrarTelefono,
            onChanged: (value) {
              setState(() => _mostrarTelefono = value);
              _showSavedSnackbar();
            },
          ),

          SwitchListTile(
            title: const Text('Mostrar Email'),
            subtitle: const Text('Visible en tu perfil profesional'),
            value: _mostrarEmail,
            onChanged: (value) {
              setState(() => _mostrarEmail = value);
              _showSavedSnackbar();
            },
          ),

          const Divider(),

          _buildSectionHeader('Documentos'),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPlaceholder(context, 'Política de Privacidad');
            },
          ),

          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPlaceholder(context, 'Términos y Condiciones');
            },
          ),

          const Divider(),

          _buildSectionHeader('Cuenta'),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Eliminar Cuenta',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Elimina permanentemente tu cuenta'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Este documento estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción es irreversible. Se eliminarán todos tus datos, '
          'solicitudes, postulaciones y membresías.\n\n'
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación de cuenta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferencia guardada (próximamente)'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
