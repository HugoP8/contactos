import 'package:equatable/equatable.dart';

/// Modelo de datos para reseñas y calificaciones de profesionales
class ResenaModel extends Equatable {
  final String id;
  final String profesionalId;
  final String userId;
  final int calificacion; // 1-5 estrellas
  final String? comentario;
  final String? respuesta; // Respuesta del profesional
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos adicionales que pueden venir del JOIN con otras tablas
  final String? usuarioNombre;
  final String? usuarioFoto;

  const ResenaModel({
    required this.id,
    required this.profesionalId,
    required this.userId,
    required this.calificacion,
    this.comentario,
    this.respuesta,
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
      userId: json['user_id'] as String,
      calificacion: json['calificacion'] as int,
      comentario: json['comentario'] as String?,
      respuesta: json['respuesta'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      usuarioNombre: json['usuario_nombre'] as String?,
      usuarioFoto: json['usuario_foto'] as String?,
    );
  }

  /// Convierte el ResenaModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profesional_id': profesionalId,
      'user_id': userId,
      'calificacion': calificacion,
      'comentario': comentario,
      'respuesta': respuesta,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'usuario_nombre': usuarioNombre,
      'usuario_foto': usuarioFoto,
    };
  }

  /// Crea una copia del ResenaModel con algunos campos modificados
  ResenaModel copyWith({
    String? id,
    String? profesionalId,
    String? userId,
    int? calificacion,
    String? comentario,
    String? respuesta,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioNombre,
    String? usuarioFoto,
  }) {
    return ResenaModel(
      id: id ?? this.id,
      profesionalId: profesionalId ?? this.profesionalId,
      userId: userId ?? this.userId,
      calificacion: calificacion ?? this.calificacion,
      comentario: comentario ?? this.comentario,
      respuesta: respuesta ?? this.respuesta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
    );
  }

  /// Verifica si la reseña tiene comentario
  bool get tieneComentario =>
      comentario != null && comentario!.trim().isNotEmpty;

  /// Verifica si el profesional respondió
  bool get tieneRespuesta =>
      respuesta != null && respuesta!.trim().isNotEmpty;

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
        userId,
        calificacion,
        comentario,
        respuesta,
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
