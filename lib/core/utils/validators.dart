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
  // TELÉFONO
  // ==========================================

  /// Valida número de teléfono peruano
  static String? telefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Eliminar espacios y caracteres especiales
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // Debe tener 9 dígitos
    if (cleaned.length != 9) {
      return 'El teléfono debe tener 9 dígitos';
    }

    // Debe empezar con 9
    if (!cleaned.startsWith('9')) {
      return 'El teléfono debe empezar con 9';
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
}
