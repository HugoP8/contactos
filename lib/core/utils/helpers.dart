import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Funciones helper generales
class Helpers {
  // ==========================================
  // SNACKBARS
  // ==========================================

  /// Muestra snackbar de éxito
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra snackbar de error
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Muestra snackbar de información
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra snackbar de advertencia
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================
  // DIÁLOGOS
  // ==========================================

  /// Muestra diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Muestra diálogo de información
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de error
  static Future<void> showErrorDialog(
    BuildContext context, {
    String title = 'Error',
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de carga
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Cierra diálogo de carga
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // ==========================================
  // BOTTOM SHEETS
  // ==========================================

  /// Muestra bottom sheet modal
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  // ==========================================
  // CLIPBOARD
  // ==========================================

  /// Copia texto al portapapeles
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSuccess(
        context,
        successMessage ?? 'Copiado al portapapeles',
      );
    }
  }

  // ==========================================
  // TECLADO
  // ==========================================

  /// Oculta el teclado
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Muestra el teclado en un campo específico
  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // ==========================================
  // VIBRACIÓN
  // ==========================================

  /// Vibración ligera
  static Future<void> vibrateLight() async {
    await HapticFeedback.lightImpact();
  }

  /// Vibración media
  static Future<void> vibrateMedium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Vibración fuerte
  static Future<void> vibrateHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Vibración de selección
  static Future<void> vibrateSelection() async {
    await HapticFeedback.selectionClick();
  }

  // ==========================================
  // NÚMEROS ALEATORIOS
  // ==========================================

  /// Genera ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ==========================================
  // NAVEGACIÓN
  // ==========================================

  /// Cierra teclado y navega atrás
  static void goBack(BuildContext context) {
    hideKeyboard(context);
    Navigator.pop(context);
  }

  // ==========================================
  // VALIDACIÓN DE CRÉDITOS
  // ==========================================

  /// Verifica si el usuario tiene suficientes créditos
  static bool hasEnoughCredits(int userCredits, int requiredCredits) {
    return userCredits >= requiredCredits;
  }

  /// Muestra diálogo de créditos insuficientes
  static Future<bool> showInsufficientCreditsDialog(
    BuildContext context, {
    required int required,
    required int current,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Créditos Insuficientes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Esta acción requiere $required créditos.'),
            const SizedBox(height: 8),
            Text('Tienes $current créditos disponibles.'),
            const SizedBox(height: 8),
            Text(
              '¿Deseas recargar créditos?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Recargar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ==========================================
  // MANEJO DE ERRORES
  // ==========================================

  /// Obtiene mensaje de error amigable
  static String getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Error de conexión. Verifica tu internet.';
    }

    if (errorString.contains('timeout')) {
      return 'La operación tardó demasiado. Intenta de nuevo.';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Sesión expirada. Inicia sesión nuevamente.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'No tienes permisos para realizar esta acción.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Recurso no encontrado.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Error del servidor. Intenta más tarde.';
    }

    // Error genérico
    return 'Ocurrió un error. Intenta de nuevo.';
  }

  // ==========================================
  // VALIDACIÓN DE IMÁGENES
  // ==========================================

  /// Verifica si el tamaño de archivo es válido (máximo en MB)
  static bool isFileSizeValid(int bytes, int maxMB) {
    final maxBytes = maxMB * 1024 * 1024;
    return bytes <= maxBytes;
  }

  /// Verifica si la extensión de archivo es válida
  static bool isFileExtensionValid(String filename, List<String> validExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  // ==========================================
  // DELAY
  // ==========================================

  /// Espera un tiempo determinado
  static Future<void> delay([int milliseconds = 500]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // ==========================================
  // DEBOUNCE
  // ==========================================

  static Map<String, DateTime> _debounceTimers = {};

  /// Debounce para funciones (evita ejecuciones múltiples)
  static bool debounce(String key, {int milliseconds = 500}) {
    final now = DateTime.now();
    final lastExecution = _debounceTimers[key];

    if (lastExecution == null ||
        now.difference(lastExecution).inMilliseconds >= milliseconds) {
      _debounceTimers[key] = now;
      return true; // Permitir ejecución
    }

    return false; // Bloquear ejecución
  }

  // ==========================================
  // ORDENAMIENTO
  // ==========================================

  /// Ordena lista por fecha (más reciente primero)
  static List<T> sortByDateDesc<T>(
    List<T> list,
    DateTime Function(T) getDate,
  ) {
    return list..sort((a, b) => getDate(b).compareTo(getDate(a)));
  }

  /// Ordena lista por fecha (más antiguo primero)
  static List<T> sortByDateAsc<T>(
    List<T> list,
    DateTime Function(T) getDate,
  ) {
    return list..sort((a, b) => getDate(a).compareTo(getDate(b)));
  }

  // ==========================================
  // COLOR HELPERS
  // ==========================================

  /// Obtiene color según calificación (1-5)
  static Color getColorByRating(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.orange;
    if (rating >= 1.5) return Colors.deepOrange;
    return Colors.red;
  }

  /// Obtiene color según estado
  static Color getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
      case 'aprobado':
      case 'completado':
        return Colors.green;
      case 'pendiente':
      case 'en_proceso':
        return Colors.orange;
      case 'rechazado':
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
