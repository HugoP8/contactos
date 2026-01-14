import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para gestionar la integración con WhatsApp
/// Permite enviar mensajes predefinidos a profesionales
class WhatsAppService {
  WhatsAppService._();

  static WhatsAppService? _instance;
  static WhatsAppService get instance {
    _instance ??= WhatsAppService._();
    return _instance!;
  }

  /// Abre WhatsApp con un mensaje predefinido para contactar a un profesional
  ///
  /// [phoneNumber]: Número de teléfono del profesional (formato: 591XXXXXXXX)
  /// [nombreProfesional]: Nombre del profesional
  /// [categoria]: Categoría del servicio
  Future<bool> contactarProfesional({
    required String phoneNumber,
    required String nombreProfesional,
    required String categoria,
  }) async {
    try {
      // Limpiar número de teléfono (quitar espacios, guiones, etc.)
      final cleanPhone = _cleanPhoneNumber(phoneNumber);

      // Mensaje predefinido
      final mensaje = '''
Hola $nombreProfesional! 👋

Te encontré en *CONTACTOS App* 📱

Me interesa contratar tus servicios de $categoria.

¿Cuándo podrías atenderme?

Gracias! 😊
''';

      // Codificar mensaje para URL
      final encodedMessage = Uri.encodeComponent(mensaje);

      // Crear URL de WhatsApp
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';

      if (kDebugMode) {
        print('📱 Abriendo WhatsApp: $whatsappUrl');
      }

      return await _launchUrl(whatsappUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir WhatsApp: $e');
      }
      return false;
    }
  }

  /// Abre WhatsApp para responder a una postulación
  ///
  /// [phoneNumber]: Número de teléfono del profesional
  /// [nombreProfesional]: Nombre del profesional
  /// [tituloSolicitud]: Título de la solicitud de trabajo
  Future<bool> responderPostulacion({
    required String phoneNumber,
    required String nombreProfesional,
    required String tituloSolicitud,
  }) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phoneNumber);

      final mensaje = '''
Hola $nombreProfesional! 👋

Te encontré en *CONTACTOS App* 📱 y vi tu postulación para mi solicitud.

📋 *Solicitud:* $tituloSolicitud

Me interesa tu propuesta.

¿Cuándo podríamos hablar sobre los detalles?

Gracias! 😊
''';

      final encodedMessage = Uri.encodeComponent(mensaje);
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';

      if (kDebugMode) {
        print('📱 Abriendo WhatsApp para postulación: $whatsappUrl');
      }

      return await _launchUrl(whatsappUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir WhatsApp: $e');
      }
      return false;
    }
  }

  /// Abre WhatsApp con un mensaje personalizado
  ///
  /// [phoneNumber]: Número de teléfono
  /// [mensaje]: Mensaje a enviar
  Future<bool> enviarMensajePersonalizado({
    required String phoneNumber,
    required String mensaje,
  }) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phoneNumber);
      final encodedMessage = Uri.encodeComponent(mensaje);
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';

      if (kDebugMode) {
        print('📱 Abriendo WhatsApp con mensaje personalizado');
      }

      return await _launchUrl(whatsappUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir WhatsApp: $e');
      }
      return false;
    }
  }

  /// Abre WhatsApp sin mensaje predefinido
  ///
  /// [phoneNumber]: Número de teléfono
  Future<bool> abrirChat({
    required String phoneNumber,
  }) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phoneNumber);
      final whatsappUrl = 'https://wa.me/$cleanPhone';

      if (kDebugMode) {
        print('📱 Abriendo chat de WhatsApp');
      }

      return await _launchUrl(whatsappUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir WhatsApp: $e');
      }
      return false;
    }
  }

  /// Compartir código de referido por WhatsApp
  ///
  /// [codigoReferido]: Código de referido del usuario
  Future<bool> compartirCodigoReferido({
    required String codigoReferido,
  }) async {
    try {
      final mensaje = '''
¡Únete a CONTACTOS! 🎉

La mejor app para encontrar profesionales en Bolivia 🇧🇴

Usa mi código de referido: *$codigoReferido*

✨ Ambos ganamos 30 créditos gratis

📲 Descarga la app ahora
''';

      final encodedMessage = Uri.encodeComponent(mensaje);
      final whatsappUrl = 'https://wa.me/?text=$encodedMessage';

      if (kDebugMode) {
        print('📱 Compartiendo código de referido por WhatsApp');
      }

      return await _launchUrl(whatsappUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al compartir por WhatsApp: $e');
      }
      return false;
    }
  }

  // ==========================================
  // HELPERS PRIVADOS
  // ==========================================

  /// Limpia el número de teléfono
  /// Elimina espacios, guiones, paréntesis y otros caracteres
  /// Asegura que tenga el formato correcto
  String _cleanPhoneNumber(String phoneNumber) {
    // Eliminar caracteres no numéricos excepto el +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Si empieza con +591, quitarlo temporalmente
    if (cleaned.startsWith('+591')) {
      cleaned = cleaned.substring(4);
    } else if (cleaned.startsWith('591')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // Agregar código de país de Bolivia (591)
    return '591$cleaned';
  }

  /// Intenta abrir una URL
  Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        if (kDebugMode) {
          print('⚠️ No se puede abrir la URL: $url');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir URL: $e');
      }
      return false;
    }
  }

  /// Verifica si el número de teléfono es válido
  bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);
    // Número boliviano: 591 + 8 dígitos = 11 dígitos en total
    return cleaned.length == 11 && cleaned.startsWith('591');
  }

  // ==========================================
  // MÉTODOS ESTÁTICOS PARA COMPATIBILIDAD
  // ==========================================

  /// Método estático para enviar mensaje (alias para mantener compatibilidad)
  static Future<bool> enviarMensaje({
    required String numero,
    required String mensaje,
  }) async {
    return await instance.enviarMensajePersonalizado(
      phoneNumber: numero,
      mensaje: mensaje,
    );
  }
}
