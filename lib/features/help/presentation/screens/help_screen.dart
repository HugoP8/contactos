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

          _buildFAQ(
            '¿Cómo puedo recargar créditos?',
            'Ve a "Mis Créditos" y selecciona el paquete que desees. Puedes pagar con Tigo Money, '
            'transferencia bancaria o efectivo a través de nuestros cajeros autorizados. '
            'También puedes ganar créditos gratis viendo videos promocionales.',
          ),

          _buildFAQ(
            '¿Cuánto cuestan las membresías?',
            'Las membresías para profesionales tienen dos planes: Básico (Bs. 50/mes) y Premium (Bs. 99/mes). '
            'Para buscadores existe el plan VIP (Bs. 19/mes). Todos los planes tienen descuento al pagar anualmente.',
          ),

          _buildFAQ(
            '¿Cómo funciona el sistema de calificaciones?',
            'Después de contratar un servicio, puedes calificar al profesional de 1 a 5 estrellas '
            'y dejar un comentario. Las calificaciones ayudan a otros usuarios a elegir mejor.',
          ),

          _buildFAQ(
            '¿Puedo cancelar mi membresía?',
            'Sí, puedes cancelar tu membresía en cualquier momento desde Perfil > Membresías. '
            'Seguirás disfrutando los beneficios hasta el final del período pagado.',
          ),

          _buildFAQ(
            '¿Qué hago si un profesional no responde?',
            'Te recomendamos contactar a otro profesional. Si el profesional tiene muchas quejas, '
            'su cuenta puede ser suspendida. Reporta cualquier problema desde el perfil del profesional.',
          ),

          _buildFAQ(
            '¿Cómo destaco mi solicitud?',
            'Desde "Mis Solicitudes", selecciona la solicitud que deseas destacar y presiona '
            '"Destacar". Esto cuesta 10 créditos y tu solicitud aparecerá primero en los resultados.',
          ),

          _buildFAQ(
            '¿Cuánto tiempo dura una solicitud activa?',
            'Las solicitudes permanecen activas por 7 días. Después de ese tiempo, expiran automáticamente. '
            'Puedes renovarlas por 3 créditos adicionales.',
          ),

          _buildFAQ(
            '¿Qué es el token de solicitud gratuita?',
            'Al registrarte, recibes un token que te permite publicar tu primera solicitud sin gastar créditos. '
            'Es una forma de que conozcas la plataforma sin costo.',
          ),

          _buildFAQ(
            '¿Cómo contacto a un profesional?',
            'Desde el perfil del profesional, presiona "Contactar por WhatsApp". Se abrirá una conversación '
            'directa con el profesional. Esto consume 1 crédito si no tienes membresía VIP.',
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
