import 'package:equatable/equatable.dart';

/// Modelo para preguntas del foro "Alguien Sabe?"
class PreguntaModel extends Equatable {
  final String id;
  final String userId;
  final String titulo;
  final String contenido;
  final String? categoria; // opcional - puede ser 'servicios', 'rutas', 'general', etc.
  final List<String> fotos;
  final int totalRespuestas;
  final bool tieneMejorRespuesta;
  final String? mejorRespuestaId;
  final int creditosUsados;
  final bool activa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Datos adicionales del usuario (JOIN)
  final String? usuarioNombre;
  final String? usuarioFoto;

  const PreguntaModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.contenido,
    this.categoria,
    this.fotos = const [],
    this.totalRespuestas = 0,
    this.tieneMejorRespuesta = false,
    this.mejorRespuestaId,
    this.creditosUsados = 0,
    this.activa = true,
    this.createdAt,
    this.updatedAt,
    this.usuarioNombre,
    this.usuarioFoto,
  });

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titulo: json['titulo'] as String,
      contenido: json['contenido'] as String,
      categoria: json['categoria'] as String?,
      fotos: json['fotos'] != null
          ? List<String>.from(json['fotos'] as List)
          : [],
      totalRespuestas: json['total_respuestas'] as int? ?? 0,
      tieneMejorRespuesta: json['tiene_mejor_respuesta'] as bool? ?? false,
      mejorRespuestaId: json['mejor_respuesta_id'] as String?,
      creditosUsados: json['creditos_usados'] as int? ?? 0,
      activa: json['activa'] as bool? ?? true,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'contenido': contenido,
      'categoria': categoria,
      'fotos': fotos,
      'total_respuestas': totalRespuestas,
      'tiene_mejor_respuesta': tieneMejorRespuesta,
      'mejor_respuesta_id': mejorRespuestaId,
      'creditos_usados': creditosUsados,
      'activa': activa,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'usuario_nombre': usuarioNombre,
      'usuario_foto': usuarioFoto,
    };
  }

  PreguntaModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? contenido,
    String? categoria,
    List<String>? fotos,
    int? totalRespuestas,
    bool? tieneMejorRespuesta,
    String? mejorRespuestaId,
    int? creditosUsados,
    bool? activa,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioNombre,
    String? usuarioFoto,
  }) {
    return PreguntaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      categoria: categoria ?? this.categoria,
      fotos: fotos ?? this.fotos,
      totalRespuestas: totalRespuestas ?? this.totalRespuestas,
      tieneMejorRespuesta: tieneMejorRespuesta ?? this.tieneMejorRespuesta,
      mejorRespuestaId: mejorRespuestaId ?? this.mejorRespuestaId,
      creditosUsados: creditosUsados ?? this.creditosUsados,
      activa: activa ?? this.activa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFoto: usuarioFoto ?? this.usuarioFoto,
    );
  }

  /// Obtiene el tiempo transcurrido desde la creación
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
        userId,
        titulo,
        contenido,
        categoria,
        fotos,
        totalRespuestas,
        tieneMejorRespuesta,
        mejorRespuestaId,
        creditosUsados,
        activa,
        createdAt,
        updatedAt,
        usuarioNombre,
        usuarioFoto,
      ];

  @override
  String toString() {
    return 'PreguntaModel(id: $id, titulo: $titulo, respuestas: $totalRespuestas)';
  }
}
