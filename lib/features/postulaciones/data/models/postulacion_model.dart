import 'package:equatable/equatable.dart';

/// Modelo de datos para postulaciones a solicitudes de trabajo
class PostulacionModel extends Equatable {
  final String id;
  final String solicitudId;
  final String profesionalId;
  final String mensaje;
  final double? presupuestoOfrecido;
  final String? tiempoEstimado;
  final String estado; // pendiente, aceptada, rechazada, cancelada
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos adicionales que pueden venir del JOIN con otras tablas
  final String? profesionalNombre;
  final String? profesionalFoto;
  final double? profesionalCalificacion;
  final bool? profesionalVerificado;

  const PostulacionModel({
    required this.id,
    required this.solicitudId,
    required this.profesionalId,
    required this.mensaje,
    this.presupuestoOfrecido,
    this.tiempoEstimado,
    this.estado = 'pendiente',
    this.createdAt,
    this.updatedAt,
    this.profesionalNombre,
    this.profesionalFoto,
    this.profesionalCalificacion,
    this.profesionalVerificado,
  });

  /// Crea un PostulacionModel desde un Map (JSON)
  factory PostulacionModel.fromJson(Map<String, dynamic> json) {
    return PostulacionModel(
      id: json['id'] as String,
      solicitudId: json['solicitud_id'] as String,
      profesionalId: json['profesional_id'] as String,
      mensaje: json['mensaje'] as String,
      presupuestoOfrecido: (json['presupuesto_ofrecido'] as num?)?.toDouble(),
      tiempoEstimado: json['tiempo_estimado'] as String?,
      estado: json['estado'] as String? ?? 'pendiente',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      profesionalNombre: json['profesional_nombre'] as String?,
      profesionalFoto: json['profesional_foto'] as String?,
      profesionalCalificacion:
          (json['profesional_calificacion'] as num?)?.toDouble(),
      profesionalVerificado: json['profesional_verificado'] as bool?,
    );
  }

  /// Convierte el PostulacionModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitud_id': solicitudId,
      'profesional_id': profesionalId,
      'mensaje': mensaje,
      'presupuesto_ofrecido': presupuestoOfrecido,
      'tiempo_estimado': tiempoEstimado,
      'estado': estado,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profesional_nombre': profesionalNombre,
      'profesional_foto': profesionalFoto,
      'profesional_calificacion': profesionalCalificacion,
      'profesional_verificado': profesionalVerificado,
    };
  }

  /// Crea una copia del PostulacionModel con algunos campos modificados
  PostulacionModel copyWith({
    String? id,
    String? solicitudId,
    String? profesionalId,
    String? mensaje,
    double? presupuestoOfrecido,
    String? tiempoEstimado,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profesionalNombre,
    String? profesionalFoto,
    double? profesionalCalificacion,
    bool? profesionalVerificado,
  }) {
    return PostulacionModel(
      id: id ?? this.id,
      solicitudId: solicitudId ?? this.solicitudId,
      profesionalId: profesionalId ?? this.profesionalId,
      mensaje: mensaje ?? this.mensaje,
      presupuestoOfrecido: presupuestoOfrecido ?? this.presupuestoOfrecido,
      tiempoEstimado: tiempoEstimado ?? this.tiempoEstimado,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profesionalNombre: profesionalNombre ?? this.profesionalNombre,
      profesionalFoto: profesionalFoto ?? this.profesionalFoto,
      profesionalCalificacion:
          profesionalCalificacion ?? this.profesionalCalificacion,
      profesionalVerificado:
          profesionalVerificado ?? this.profesionalVerificado,
    );
  }

  /// Verifica si la postulación está pendiente
  bool get isPendiente => estado == 'pendiente';

  /// Verifica si la postulación fue aceptada
  bool get isAceptada => estado == 'aceptada';

  /// Verifica si la postulación fue rechazada
  bool get isRechazada => estado == 'rechazada';

  /// Obtiene el texto del presupuesto formateado
  String get presupuestoTexto {
    if (presupuestoOfrecido != null) {
      return 'Bs. ${presupuestoOfrecido!.toStringAsFixed(0)}';
    }
    return 'A convenir';
  }

  /// Obtiene el tiempo transcurrido desde la postulación
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
        solicitudId,
        profesionalId,
        mensaje,
        presupuestoOfrecido,
        tiempoEstimado,
        estado,
        createdAt,
        updatedAt,
        profesionalNombre,
        profesionalFoto,
        profesionalCalificacion,
        profesionalVerificado,
      ];

  @override
  String toString() {
    return 'PostulacionModel(id: $id, profesionalId: $profesionalId, estado: $estado)';
  }
}
