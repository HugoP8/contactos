import 'package:equatable/equatable.dart';

/// Modelo de datos para solicitudes de trabajo
class SolicitudTrabajoModel extends Equatable {
  final String id;
  final String userId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String ciudad;
  final String? zona;
  final double? presupuestoMinimo;
  final double? presupuestoMaximo;
  final String urgencia; // normal, urgente
  final List<String> fotos;
  final String estado; // activa, en_proceso, completada, cancelada, expirada
  final int totalPostulaciones;
  final int creditosUsados;
  final bool visible;
  final bool destacada;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  const SolicitudTrabajoModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.ciudad,
    this.zona,
    this.presupuestoMinimo,
    this.presupuestoMaximo,
    this.urgencia = 'normal',
    this.fotos = const [],
    this.estado = 'activa',
    this.totalPostulaciones = 0,
    this.creditosUsados = 0,
    this.visible = true,
    this.destacada = false,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  /// Crea un SolicitudTrabajoModel desde un Map (JSON)
  factory SolicitudTrabajoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudTrabajoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      ciudad: json['ciudad'] as String,
      zona: json['zona'] as String?,
      presupuestoMinimo: (json['presupuesto_minimo'] as num?)?.toDouble(),
      presupuestoMaximo: (json['presupuesto_maximo'] as num?)?.toDouble(),
      urgencia: json['urgencia'] as String? ?? 'normal',
      fotos: json['fotos'] != null
          ? List<String>.from(json['fotos'] as List)
          : [],
      estado: json['estado'] as String? ?? 'activa',
      totalPostulaciones: json['total_postulaciones'] as int? ?? 0,
      creditosUsados: json['creditos_usados'] as int? ?? 0,
      visible: json['visible'] as bool? ?? true,
      destacada: json['destacada'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convierte el SolicitudTrabajoModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'ciudad': ciudad,
      'zona': zona,
      'presupuesto_minimo': presupuestoMinimo,
      'presupuesto_maximo': presupuestoMaximo,
      'urgencia': urgencia,
      'fotos': fotos,
      'estado': estado,
      'total_postulaciones': totalPostulaciones,
      'creditos_usados': creditosUsados,
      'visible': visible,
      'destacada': destacada,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Crea una copia del SolicitudTrabajoModel con algunos campos modificados
  SolicitudTrabajoModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? ciudad,
    String? zona,
    double? presupuestoMinimo,
    double? presupuestoMaximo,
    String? urgencia,
    List<String>? fotos,
    String? estado,
    int? totalPostulaciones,
    int? creditosUsados,
    bool? visible,
    bool? destacada,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return SolicitudTrabajoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      ciudad: ciudad ?? this.ciudad,
      zona: zona ?? this.zona,
      presupuestoMinimo: presupuestoMinimo ?? this.presupuestoMinimo,
      presupuestoMaximo: presupuestoMaximo ?? this.presupuestoMaximo,
      urgencia: urgencia ?? this.urgencia,
      fotos: fotos ?? this.fotos,
      estado: estado ?? this.estado,
      totalPostulaciones: totalPostulaciones ?? this.totalPostulaciones,
      creditosUsados: creditosUsados ?? this.creditosUsados,
      visible: visible ?? this.visible,
      destacada: destacada ?? this.destacada,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Verifica si la solicitud está activa
  bool get isActiva => estado == 'activa';

  /// Verifica si la solicitud está expirada
  bool get isExpirada {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Verifica si es urgente
  bool get isUrgente => urgencia == 'urgente';

  /// Verifica si tiene postulaciones
  bool get tienePostulaciones => totalPostulaciones > 0;

  /// Verifica si tiene presupuesto definido
  bool get tienePresupuesto =>
      presupuestoMinimo != null || presupuestoMaximo != null;

  /// Obtiene el texto del presupuesto formateado
  String get presupuestoTexto {
    if (presupuestoMinimo != null && presupuestoMaximo != null) {
      return 'Bs. ${presupuestoMinimo!.toStringAsFixed(0)} - Bs. ${presupuestoMaximo!.toStringAsFixed(0)}';
    } else if (presupuestoMinimo != null) {
      return 'Desde Bs. ${presupuestoMinimo!.toStringAsFixed(0)}';
    } else if (presupuestoMaximo != null) {
      return 'Hasta Bs. ${presupuestoMaximo!.toStringAsFixed(0)}';
    }
    return 'A convenir';
  }

  /// Obtiene los días restantes hasta expiración
  int? get diasRestantes {
    if (expiresAt == null) return null;
    final diferencia = expiresAt!.difference(DateTime.now());
    return diferencia.inDays;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        titulo,
        descripcion,
        categoria,
        ciudad,
        zona,
        presupuestoMinimo,
        presupuestoMaximo,
        urgencia,
        fotos,
        estado,
        totalPostulaciones,
        creditosUsados,
        visible,
        destacada,
        createdAt,
        updatedAt,
        expiresAt,
      ];

  @override
  String toString() {
    return 'SolicitudTrabajoModel(id: $id, titulo: $titulo, categoria: $categoria, estado: $estado)';
  }
}
