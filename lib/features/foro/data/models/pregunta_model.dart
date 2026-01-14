import 'package:intl/intl.dart';

/// Modelo de pregunta del foro "Alguien Sabe?"
class PreguntaModel {
  final String id;
  final String userId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final List<String> imagenes;
  final bool resuelta;
  final String? mejorRespuestaId;
  final int totalRespuestas;
  final int totalVistas;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos JOIN desde users
  final String? usuarioNombre;
  final String? usuarioFoto;

  const PreguntaModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    this.imagenes = const [],
    this.resuelta = false,
    this.mejorRespuestaId,
    this.totalRespuestas = 0,
    this.totalVistas = 0,
    required this.createdAt,
    required this.updatedAt,
    this.usuarioNombre,
    this.usuarioFoto,
  });

  /// Crea una instancia desde JSON
  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'] as List)
          : [],
      resuelta: json['resuelta'] as bool? ?? false,
      mejorRespuestaId: json['mejor_respuesta_id'] as String?,
      totalRespuestas: json['total_respuestas'] as int? ?? 0,
      totalVistas: json['total_vistas'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      usuarioNombre: json['usuario']?['nombre_completo'] as String?,
      usuarioFoto: json['usuario']?['foto_perfil'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'imagenes': imagenes,
      'resuelta': resuelta,
      'mejor_respuesta_id': mejorRespuestaId,
      'total_respuestas': totalRespuestas,
      'total_vistas': totalVistas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  PreguntaModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? descripcion,
    String? categoria,
    List<String>? imagenes,
    bool? resuelta,
    String? mejorRespuestaId,
    int? totalRespuestas,
    int? totalVistas,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioNombre,
    String? usuarioFoto,
  }) {
    return PreguntaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      imagenes: imagenes ?? this.imagenes,
      resuelta: resuelta ?? this.resuelta,
      mejorRespuestaId: mejorRespuestaId ?? this.mejorRespuestaId,
      totalRespuestas: totalRespuestas ?? this.totalRespuestas,
      totalVistas: totalVistas ?? this.totalVistas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
    );
  }

  // ==========================================
  // GETTERS CALCULADOS
  // ==========================================

  /// Indica si tiene respuestas
  bool get tieneRespuestas => totalRespuestas > 0;

  /// Indica si tiene imágenes
  bool get tieneImagenes => imagenes.isNotEmpty;

  /// Tiempo transcurrido desde la creación (formato legible)
  String get tiempoTranscurrido {
    final diferencia = DateTime.now().difference(createdAt);

    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes}m';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours}h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays}d';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'Hace ${semanas}sem';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace ${meses}m';
    } else {
      return DateFormat('dd/MM/yy').format(createdAt);
    }
  }

  /// Fecha formateada (día/mes/año)
  String get fechaFormateada {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  /// Hora formateada (HH:mm)
  String get horaFormateada {
    return DateFormat('HH:mm').format(createdAt);
  }

  /// Obtiene el icono de la categoría
  String get iconoCategoria {
    switch (categoria.toLowerCase()) {
      case 'construcción y mantenimiento':
        return '🔨';
      case 'tecnología':
        return '💻';
      case 'servicios del hogar':
        return '🏠';
      case 'salud y bienestar':
        return '⚕️';
      case 'educación':
        return '📚';
      case 'transporte':
        return '🚗';
      case 'alimentación':
        return '🍽️';
      case 'eventos':
        return '🎉';
      case 'legal y finanzas':
        return '⚖️';
      case 'belleza y estética':
        return '💅';
      case 'mascotas':
        return '🐾';
      default:
        return '❓';
    }
  }

  @override
  String toString() {
    return 'PreguntaModel(id: $id, titulo: $titulo, categoria: $categoria, resuelta: $resuelta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreguntaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
