import 'package:equatable/equatable.dart';

/// Modelo para respuestas del foro "Alguien Sabe?"
class RespuestaModel extends Equatable {
  final String id;
  final String preguntaId;
  final String userId;
  final String contenido;
  final bool esMejorRespuesta;
  final int creditosGanados;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Datos adicionales del usuario (JOIN)
  final String? usuarioNombre;
  final String? usuarioFoto;
  final bool? usuarioVerificado;

  const RespuestaModel({
    required this.id,
    required this.preguntaId,
    required this.userId,
    required this.contenido,
    this.esMejorRespuesta = false,
    this.creditosGanados = 0,
    this.createdAt,
    this.updatedAt,
    this.usuarioNombre,
    this.usuarioFoto,
    this.usuarioVerificado,
  });

  factory RespuestaModel.fromJson(Map<String, dynamic> json) {
    return RespuestaModel(
      id: json['id'] as String,
      preguntaId: json['pregunta_id'] as String,
      userId: json['user_id'] as String,
      contenido: json['contenido'] as String,
      esMejorRespuesta: json['es_mejor_respuesta'] as bool? ?? false,
      creditosGanados: json['creditos_ganados'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      usuarioNombre: json['usuario_nombre'] as String?,
      usuarioFoto: json['usuario_foto'] as String?,
      usuarioVerificado: json['usuario_verificado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta_id': preguntaId,
      'user_id': userId,
      'contenido': contenido,
      'es_mejor_respuesta': esMejorRespuesta,
      'creditos_ganados': creditosGanados,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'usuario_nombre': usuarioNombre,
      'usuario_foto': usuarioFoto,
      'usuario_verificado': usuarioVerificado,
    };
  }

  RespuestaModel copyWith({
    String? id,
    String? preguntaId,
    String? userId,
    String? contenido,
    bool? esMejorRespuesta,
    int? creditosGanados,
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
      esMejorRespuesta: esMejorRespuesta ?? this.esMejorRespuesta,
      creditosGanados: creditosGanados ?? this.creditosGanados,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
      usuarioVerificado: usuarioVerificado ?? this.usuarioVerificado,
    );
  }

  /// Obtiene el tiempo transcurrido desde la respuesta
  String get tiempoTranscurrido {
    if (createdAt == null) return '';

    final diferencia = DateTime.now().difference(createdAt!);

    if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace unos segundos';
    }
  }

  @override
  List<Object?> get props => [
        id,
        preguntaId,
        userId,
        contenido,
        esMejorRespuesta,
        creditosGanados,
        createdAt,
        updatedAt,
        usuarioNombre,
        usuarioFoto,
        usuarioVerificado,
      ];

  @override
  String toString() {
    return 'RespuestaModel(id: $id, esMejorRespuesta: $esMejorRespuesta)';
  }
}
