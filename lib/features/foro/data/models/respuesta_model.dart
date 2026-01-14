import 'package:intl/intl.dart';

/// Modelo de respuesta a una pregunta del foro
class RespuestaModel {
  final String id;
  final String preguntaId;
  final String userId;
  final String contenido;
  final List<String> imagenes;
  final bool esMejorRespuesta;
  final int totalVotos;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos JOIN desde users
  final String? usuarioNombre;
  final String? usuarioFoto;
  final bool? usuarioVerificado;

  const RespuestaModel({
    required this.id,
    required this.preguntaId,
    required this.userId,
    required this.contenido,
    this.imagenes = const [],
    this.esMejorRespuesta = false,
    this.totalVotos = 0,
    required this.createdAt,
    required this.updatedAt,
    this.usuarioNombre,
    this.usuarioFoto,
    this.usuarioVerificado,
  });

  /// Crea una instancia desde JSON
  factory RespuestaModel.fromJson(Map<String, dynamic> json) {
    return RespuestaModel(
      id: json['id'] as String,
      preguntaId: json['pregunta_id'] as String,
      userId: json['user_id'] as String,
      contenido: json['contenido'] as String,
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'] as List)
          : [],
      esMejorRespuesta: json['es_mejor_respuesta'] as bool? ?? false,
      totalVotos: json['total_votos'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      usuarioNombre: json['usuario']?['nombre_completo'] as String?,
      usuarioFoto: json['usuario']?['foto_perfil'] as String?,
      usuarioVerificado: json['usuario']?['verificado'] as bool?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta_id': preguntaId,
      'user_id': userId,
      'contenido': contenido,
      'imagenes': imagenes,
      'es_mejor_respuesta': esMejorRespuesta,
      'total_votos': totalVotos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  RespuestaModel copyWith({
    String? id,
    String? preguntaId,
    String? userId,
    String? contenido,
    List<String>? imagenes,
    bool? esMejorRespuesta,
    int? totalVotos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioNombre,
    String? usuarioFoto,
    bool? usuarioVerificado,
  }) {
    return RespuestaModel(
      id: id ?? this.id,
      preguntaId: preguntaId ?? this.preguntaId,
      userId: userId ?? this.userId,
      contenido: contenido ?? this.contenido,
      imagenes: imagenes ?? this.imagenes,
      esMejorRespuesta: esMejorRespuesta ?? this.esMejorRespuesta,
      totalVotos: totalVotos ?? this.totalVotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
      usuarioVerificado: usuarioVerificado ?? this.usuarioVerificado,
    );
  }

  // ==========================================
  // GETTERS CALCULADOS
  // ==========================================

  /// Indica si tiene imágenes
  bool get tieneImagenes => imagenes.isNotEmpty;

  /// Indica si tiene votos positivos
  bool get tieneVotos => totalVotos > 0;

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

  @override
  String toString() {
    return 'RespuestaModel(id: $id, preguntaId: $preguntaId, esMejorRespuesta: $esMejorRespuesta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RespuestaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
