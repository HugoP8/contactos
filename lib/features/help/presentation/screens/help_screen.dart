import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
      ),
      body: ListView(
        children: [
          // Botón de contacto directo
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text('Contactar Soporte'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => _contactarSoporte(context),
            ),
          ),

          const Divider(),

          _buildSectionHeader('Preguntas Frecuentes'),

          _buildFAQ(
            '¿Cómo funciona el sistema de créditos?',
            'Los créditos te permiten publicar solicitudes y ver contactos de profesionales. '
            'Recibes 50 créditos gratis al registrarte y puedes ganar más viendo videos, '
            'refiriendo amigos, o completando tu perfil.',
          ),

          _buildFAQ(
            '¿Cómo publico una solicitud de trabajo?',
            'Ve a "Mis Solicitudes" y presiona el botón "+". Llena el formulario con '
            'los detalles de tu necesidad y publica. Los profesionales podrán postularse.',
          ),

          _buildFAQ(
            '¿Cómo me convierto en profesional?',
            'Ve a tu perfil y selecciona "Crear Perfil Profesional". Completa la información '
            'de tus servicios y publica. Podrás recibir solicitudes de clientes.',
          ),

          _buildFAQ(
            '¿Qué son las membresías?',
            'Las membresías te dan beneficios adicionales como destacar tu perfil, '
            'más fotos en galería, y prioridad en búsquedas. Hay planes para profesionales '
            'y para buscadores.',
          ),

          _buildFAQ(
            '¿Cómo funcionan los referidos?',
            'Cada usuario tiene un código único. Cuando alguien se registra con tu código, '
            'ambos reciben 30 créditos extra. Comparte tu código desde "Mis Créditos".',
          ),

          _buildFAQ(
            '¿Es seguro compartir mi número de teléfono?',
            'Tú decides qué información mostrar en tu perfil. Puedes configurar la privacidad '
            'desde Configuración > Privacidad y Seguridad.',
          ),

          const Divider(),

          _buildSectionHeader('Tutoriales'),

          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Cómo publicar una solicitud'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTutorialPlaceholder(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Cómo crear perfil profesional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTutorialPlaceholder(context);
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFAQ(String pregunta, String respuesta) {
    return ExpansionTile(
      title: Text(
        pregunta,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            respuesta,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Future<void> _contactarSoporte(BuildContext context) async {
    // TODO: Cambiar por número real de soporte
    const telefono = '59112345678';
    const mensaje = 'Hola, necesito ayuda con la app CONTACTOS';

    final url = Uri.parse(
      'https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showTutorialPlaceholder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial'),
        content: const Text('Los tutoriales en video estarán disponibles próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
