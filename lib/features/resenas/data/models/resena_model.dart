import 'package:equatable/equatable.dart';

/// Modelo de datos para reseñas y calificaciones de profesionales
class ResenaModel extends Equatable {
  final String id;
  final String profesionalId;
  final String usuarioId; // Quien escribe la reseña (usuario_id en BD)
  final String? solicitudId; // Solicitud relacionada (opcional)
  final int calificacion; // 1-5 estrellas
  final String? contenido; // Texto de la reseña
  final List<String> fotos; // Fotos adjuntas
  final String? respuestaProfesional; // Respuesta del profesional
  final DateTime? fechaRespuesta;
  final bool visible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos adicionales que pueden venir del JOIN con otras tablas
  final String? usuarioNombre;
  final String? usuarioFoto;

  const ResenaModel({
    required this.id,
    required this.profesionalId,
    required this.usuarioId,
    this.solicitudId,
    required this.calificacion,
    this.contenido,
    this.fotos = const [],
    this.respuestaProfesional,
    this.fechaRespuesta,
    this.visible = true,
    this.createdAt,
    this.updatedAt,
    this.usuarioNombre,
    this.usuarioFoto,
  });

  /// Crea un ResenaModel desde un Map (JSON)
  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: json['id'] as String,
      profesionalId: json['profesional_id'] as String,
      usuarioId: json['usuario_id'] as String,
      solicitudId: json['solicitud_id'] as String?,
      calificacion: json['calificacion'] as int,
      contenido: json['contenido'] as String?,
      fotos: json['fotos'] != null
          ? List<String>.from(json['fotos'] as List)
          : [],
      respuestaProfesional: json['respuesta_profesional'] as String?,
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.parse(json['fecha_respuesta'] as String)
          : null,
      visible: json['visible'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      usuarioNombre: json['usuario']?['nombre_completo'] as String? ??
          json['usuario_nombre'] as String?,
      usuarioFoto: json['usuario']?['foto_perfil'] as String? ??
          json['usuario_foto'] as String?,
    );
  }

  /// Convierte el ResenaModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profesional_id': profesionalId,
      'usuario_id': usuarioId,
      'solicitud_id': solicitudId,
      'calificacion': calificacion,
      'contenido': contenido,
      'fotos': fotos,
      'respuesta_profesional': respuestaProfesional,
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
      'visible': visible,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del ResenaModel con algunos campos modificados
  ResenaModel copyWith({
    String? id,
    String? profesionalId,
    String? usuarioId,
    String? solicitudId,
    int? calificacion,
    String? contenido,
    List<String>? fotos,
    String? respuestaProfesional,
    DateTime? fechaRespuesta,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioNombre,
    String? usuarioFoto,
  }) {
    return ResenaModel(
      id: id ?? this.id,
      profesionalId: profesionalId ?? this.profesionalId,
      usuarioId: usuarioId ?? this.usuarioId,
      solicitudId: solicitudId ?? this.solicitudId,
      calificacion: calificacion ?? this.calificacion,
      contenido: contenido ?? this.contenido,
      fotos: fotos ?? this.fotos,
      respuestaProfesional: respuestaProfesional ?? this.respuestaProfesional,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
    );
  }

  /// Verifica si la reseña tiene contenido
  bool get tieneContenido =>
      contenido != null && contenido!.trim().isNotEmpty;

  /// Verifica si la reseña tiene fotos
  bool get tieneFotos => fotos.isNotEmpty;

  /// Verifica si el profesional respondió
  bool get tieneRespuesta =>
      respuestaProfesional != null && respuestaProfesional!.trim().isNotEmpty;

  /// Verifica si es una buena calificación (>= 4 estrellas)
  bool get esBuenaCalificacion => calificacion >= 4;

  /// Verifica si es una mala calificación (<= 2 estrellas)
  bool get esMalaCalificacion => calificacion <= 2;

  /// Obtiene el tiempo transcurrido desde la reseña
  String get tiempoTranscurrido {
    if (createdAt == null) return '';

    final diferencia = DateTime.now().difference(createdAt!);

    if (diferencia.inDays > 365) {
      final years = (diferencia.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    } else if (diferencia.inDays > 30) {
      final months = (diferencia.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace unos segundos';
    }
  }

  /// Obtiene el texto descriptivo de la calificación
  String get calificacionTexto {
    switch (calificacion) {
      case 5:
        return 'Excelente';
      case 4:
        return 'Muy bueno';
      case 3:
        return 'Bueno';
      case 2:
        return 'Regular';
      case 1:
        return 'Malo';
      default:
        return 'Sin calificación';
    }
  }

  @override
  List<Object?> get props => [
        id,
        profesionalId,
        usuarioId,
        solicitudId,
        calificacion,
        contenido,
        fotos,
        respuestaProfesional,
        fechaRespuesta,
        visible,
        createdAt,
        updatedAt,
        usuarioNombre,
        usuarioFoto,
      ];

  @override
  String toString() {
    return 'ResenaModel(id: $id, calificacion: $calificacion, profesionalId: $profesionalId)';
  }
}
