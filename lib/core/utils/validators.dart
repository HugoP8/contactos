/// Validadores para formularios
class Validators {
  // ==========================================
  // EMAIL
  // ==========================================

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  // ==========================================
  // PASSWORD
  // ==========================================

  /// Valida contraseña (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Valida contraseña fuerte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Al menos una mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }

    // Al menos una minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }

    // Al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    return null;
  }

  /// Valida confirmación de contraseña
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // ==========================================
  // TELÉFONO (BOLIVIA)
  // ==========================================

  /// Valida número de teléfono boliviano (8 dígitos, empieza con 6, 7 o 2)
  static String? telefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Eliminar espacios y caracteres especiales
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // Debe tener 8 dígitos (Bolivia)
    if (cleaned.length != 8) {
      return 'El teléfono debe tener 8 dígitos';
    }

    // Debe empezar con 6, 7 (celulares) o 2 (fijos La Paz)
    if (!RegExp(r'^[672]').hasMatch(cleaned)) {
      return 'Número de teléfono inválido';
    }

    return null;
  }

  /// Valida teléfono opcional
  static String? telefonoOpcional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Es opcional
    }

    return telefono(value);
  }

  // ==========================================
  // DNI
  // ==========================================

  /// Valida DNI peruano (8 dígitos)
  static String? dni(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es requerido';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }

    return null;
  }

  /// Valida DNI opcional
  static String? dniOpcional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return dni(value);
  }

  // ==========================================
  // RUC
  // ==========================================

  /// Valida RUC peruano (11 dígitos)
  static String? ruc(String? value) {
    if (value == null || value.isEmpty) {
      return 'El RUC es requerido';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 11) {
      return 'El RUC debe tener 11 dígitos';
    }

    // Debe empezar con 10 o 20
    if (!cleaned.startsWith('10') && !cleaned.startsWith('20')) {
      return 'RUC inválido';
    }

    return null;
  }

  /// Valida RUC opcional
  static String? rucOpcional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return ruc(value);
  }

  // ==========================================
  // TEXTO
  // ==========================================

  /// Valida campo requerido
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min,
      [String fieldName = 'Este campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max,
      [String fieldName = 'Este campo']) {
    if (value == null) return null;

    if (value.length > max) {
      return '$fieldName no puede tener más de $max caracteres';
    }

    return null;
  }

  /// Valida rango de longitud
  static String? lengthRange(String? value, int min, int max,
      [String fieldName = 'Este campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    if (value.length > max) {
      return '$fieldName no puede tener más de $max caracteres';
    }

    return null;
  }

  // ==========================================
  // NÚMEROS
  // ==========================================

  /// Valida número entero
  static String? integer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un número';
    }

    if (int.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }

    return null;
  }

  /// Valida número decimal
  static String? decimal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un número';
    }

    if (double.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }

    return null;
  }

  /// Valida rango numérico
  static String? numberRange(String? value, num min, num max) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un número';
    }

    final number = num.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < min || number > max) {
      return 'Debe estar entre $min y $max';
    }

    return null;
  }

  /// Valida número positivo
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un número';
    }

    final number = num.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number <= 0) {
      return 'Debe ser mayor a 0';
    }

    return null;
  }

  // ==========================================
  // URL
  // ==========================================

  /// Valida URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL es opcional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }

    return null;
  }

  // ==========================================
  // CALIFICACIÓN
  // ==========================================

  /// Valida calificación (1-5 estrellas)
  static String? calificacion(int? value) {
    if (value == null) {
      return 'Selecciona una calificación';
    }

    if (value < 1 || value > 5) {
      return 'La calificación debe estar entre 1 y 5';
    }

    return null;
  }

  // ==========================================
  // PRECIO
  // ==========================================

  /// Valida precio (debe ser positivo)
  static String? precio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un precio';
    }

    final precio = double.tryParse(value);
    if (precio == null) {
      return 'Ingresa un precio válido';
    }

    if (precio <= 0) {
      return 'El precio debe ser mayor a 0';
    }

    return null;
  }

  // ==========================================
  // COMBINADORES
  // ==========================================

  /// Combina múltiples validadores
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  // ==========================================
  // SEGURIDAD Y SANITIZACIÓN
  // ==========================================

  /// Sanitiza texto eliminando caracteres peligrosos (prevención XSS)
  static String sanitizeText(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  /// Sanitiza texto para uso en SQL (prevención SQL injection)
  /// Nota: Siempre usa consultas parametrizadas, esto es solo una capa extra
  static String sanitizeSql(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll('\\', '\\\\')
        .replaceAll('\x00', '')
        .trim();
  }

  /// Elimina espacios extras y normaliza whitespace
  static String normalizeWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Valida que no contenga scripts o tags HTML
  static String? noHtmlTags(String? value) {
    if (value == null || value.isEmpty) return null;

    if (RegExp(r'<[^>]*>').hasMatch(value)) {
      return 'No se permiten etiquetas HTML';
    }

    // Detectar posibles intentos de XSS
    final xssPatterns = [
      'javascript:',
      'data:',
      'vbscript:',
      'onclick',
      'onerror',
      'onload',
      'onmouseover',
    ];

    final lowerValue = value.toLowerCase();
    for (final pattern in xssPatterns) {
      if (lowerValue.contains(pattern)) {
        return 'Contenido no permitido';
      }
    }

    return null;
  }

  /// Valida que la URL sea segura (https)
  static String? secureUrl(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!value.startsWith('https://')) {
      return 'La URL debe usar HTTPS';
    }

    return url(value);
  }

  /// Valida CI boliviano (7 dígitos + extensión opcional)
  static String? ciBolivia(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CI es requerido';
    }

    // Eliminar todo excepto números y letras
    final cleaned = value.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '').toUpperCase();

    // CI mínimo 7 dígitos, máximo 9 (con extensión LP, SC, CB, etc.)
    if (cleaned.length < 7 || cleaned.length > 9) {
      return 'CI inválido';
    }

    // Los primeros 7 caracteres deben ser números
    if (!RegExp(r'^\d{7,8}').hasMatch(cleaned)) {
      return 'CI inválido';
    }

    return null;
  }

  /// Valida NIT boliviano (opcional)
  static String? nitBolivia(String? value) {
    if (value == null || value.isEmpty) return null;

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // NIT tiene entre 10 y 15 dígitos
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'NIT inválido';
    }

    return null;
  }

  /// Limita longitud de texto y añade ellipsis si es necesario
  static String truncate(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength - 3)}...';
  }

  /// Valida que el texto no contenga solo espacios o caracteres especiales
  static String? meaningfulText(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    // Eliminar espacios y caracteres especiales
    final meaningful = value.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]'), '');

    if (meaningful.isEmpty) {
      return '$fieldName debe contener texto válido';
    }

    return null;
  }
}
