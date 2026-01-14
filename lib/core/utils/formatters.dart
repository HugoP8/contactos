import 'package:intl/intl.dart';

/// Formateadores de texto y números
class Formatters {
  // ==========================================
  // MONEDA
  // ==========================================

  /// Formatea número como moneda peruana (S/ 100.00)
  static String currency(num value) {
    final formatter = NumberFormat.currency(
      symbol: 'S/ ',
      decimalDigits: 2,
      locale: 'es_PE',
    );
    return formatter.format(value);
  }

  /// Formatea como moneda sin decimales (S/ 100)
  static String currencyInt(num value) {
    final formatter = NumberFormat.currency(
      symbol: 'S/ ',
      decimalDigits: 0,
      locale: 'es_PE',
    );
    return formatter.format(value);
  }

  /// Formatea número sin símbolo de moneda (100.00)
  static String number(num value, {int decimals = 2}) {
    final formatter = NumberFormat.decimalPattern('es_PE');
    return formatter.format(value);
  }

  // ==========================================
  // TELÉFONO
  // ==========================================

  /// Formatea número de teléfono peruano (999 999 999)
  static String phone(String phone) {
    // Limpiar el número
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 9) {
      return phone; // Retornar original si no es válido
    }

    // Formatear: 999 999 999
    return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
  }

  /// Formatea teléfono con código de país (+51 999 999 999)
  static String phoneWithCountryCode(String phone) {
    final formatted = Formatters.phone(phone);
    return '+51 $formatted';
  }

  /// Limpia teléfono (solo dígitos)
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ==========================================
  // DNI / RUC
  // ==========================================

  /// Formatea DNI (12345678 → 12 345 678)
  static String dni(String dni) {
    final cleaned = dni.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 8) {
      return dni;
    }

    return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
  }

  /// Formatea RUC (12345678901 → 12 345 678 901)
  static String ruc(String ruc) {
    final cleaned = ruc.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 11) {
      return ruc;
    }

    return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
  }

  // ==========================================
  // FECHA Y HORA
  // ==========================================

  /// Formatea fecha (dd/MM/yyyy)
  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea fecha y hora (dd/MM/yyyy HH:mm)
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formatea solo hora (HH:mm)
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formatea fecha en formato largo (12 de enero de 2024)
  static String dateLong(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES').format(date);
  }

  /// Formatea fecha relativa (hace 2 horas, ayer, etc.)
  static String dateRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? "semana" : "semanas"}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? "mes" : "meses"}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? "año" : "años"}';
    }
  }

  // ==========================================
  // TEXTO
  // ==========================================

  /// Capitaliza primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Trunca texto con puntos suspensivos
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Limpia espacios extra
  static String cleanSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ==========================================
  // PORCENTAJE
  // ==========================================

  /// Formatea como porcentaje (0.5 → 50%)
  static String percentage(double value, {int decimals = 0}) {
    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  /// Formatea porcentaje desde número entero (50 → 50%)
  static String percentageInt(int value) {
    return '$value%';
  }

  // ==========================================
  // CRÉDITOS
  // ==========================================

  /// Formatea créditos con ícono
  static String credits(int credits) {
    return '$credits créditos';
  }

  /// Formatea créditos singular/plural
  static String creditsPlural(int credits) {
    return '$credits ${credits == 1 ? "crédito" : "créditos"}';
  }

  // ==========================================
  // CALIFICACIÓN
  // ==========================================

  /// Formatea calificación (4.5 → 4.5⭐)
  static String rating(double rating, {int decimals = 1}) {
    return '${rating.toStringAsFixed(decimals)}⭐';
  }

  /// Formatea calificación con total de reseñas (4.5 (120 reseñas))
  static String ratingWithReviews(double rating, int totalReviews) {
    return '${rating.toStringAsFixed(1)} ($totalReviews ${totalReviews == 1 ? "reseña" : "reseñas"})';
  }

  // ==========================================
  // DISTANCIA
  // ==========================================

  /// Formatea distancia en km
  static String distance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  // ==========================================
  // TAMAÑO DE ARCHIVO
  // ==========================================

  /// Formatea tamaño de archivo (bytes → KB/MB/GB)
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ==========================================
  // HELPERS DE ENTRADA
  // ==========================================

  /// Limita entrada a solo números
  static String onlyNumbers(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Limita entrada a solo letras
  static String onlyLetters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'), '');
  }

  /// Limita entrada a letras y números
  static String alphanumeric(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'), '');
  }

  // ==========================================
  // NOMBRES
  // ==========================================

  /// Obtiene iniciales de un nombre (Juan Pérez → JP)
  static String initials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Obtiene primer nombre (Juan Carlos Pérez → Juan)
  static String firstName(String fullName) {
    final words = fullName.trim().split(' ');
    return words.isNotEmpty ? words[0] : '';
  }

  /// Obtiene apellido (Juan Pérez García → García)
  static String lastName(String fullName) {
    final words = fullName.trim().split(' ');
    return words.length > 1 ? words.last : '';
  }

  // ==========================================
  // PLURALES
  // ==========================================

  /// Pluraliza palabra según cantidad
  static String pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }

  /// Pluraliza con cantidad (1 usuario, 5 usuarios)
  static String countWithWord(int count, String singular, String plural) {
    return '$count ${pluralize(count, singular, plural)}';
  }
}
