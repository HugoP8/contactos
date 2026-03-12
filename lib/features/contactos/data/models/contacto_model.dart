/// Modelo para representar un contacto guardado
class ContactoModel {
  final String id;
  final String userId;
  final String profesionalId;
  final String? notas;
  final bool favorito;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Datos del profesional (join)
  final String? profesionalNombre;
  final String? profesionalFoto;
  final String? profesionalCategoria;
  final String? profesionalCiudad;
  final String? profesionalWhatsapp;
  final double? profesionalCalificacion;
  final bool? profesionalVerificado;

  const ContactoModel({
    required this.id,
    required this.userId,
    required this.profesionalId,
    this.notas,
    this.favorito = false,
    required this.createdAt,
    this.updatedAt,
    this.profesionalNombre,
    this.profesionalFoto,
    this.profesionalCategoria,
    this.profesionalCiudad,
    this.profesionalWhatsapp,
    this.profesionalCalificacion,
    this.profesionalVerificado,
  });

  factory ContactoModel.fromJson(Map<String, dynamic> json) {
    final profesional = json['profesional'] as Map<String, dynamic>?;

    return ContactoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      profesionalId: json['profesional_id'] as String,
      notas: json['notas'] as String?,
      favorito: json['favorito'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      profesionalNombre: profesional?['nombre_comercial'] as String?,
      profesionalFoto: profesional?['foto_perfil'] as String?,
      profesionalCategoria: profesional?['categoria_principal'] as String?,
      profesionalCiudad: profesional?['ciudad'] as String?,
      profesionalWhatsapp: profesional?['whatsapp'] as String?,
      profesionalCalificacion:
          (profesional?['calificacion_promedio'] as num?)?.toDouble(),
      profesionalVerificado: profesional?['verificado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'profesional_id': profesionalId,
        'notas': notas,
        'favorito': favorito,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  ContactoModel copyWith({
    String? id,
    String? userId,
    String? profesionalId,
    String? notas,
    bool? favorito,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profesionalNombre,
    String? profesionalFoto,
    String? profesionalCategoria,
    String? profesionalCiudad,
    String? profesionalWhatsapp,
    double? profesionalCalificacion,
    bool? profesionalVerificado,
  }) {
    return ContactoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profesionalId: profesionalId ?? this.profesionalId,
      notas: notas ?? this.notas,
      favorito: favorito ?? this.favorito,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profesionalNombre: profesionalNombre ?? this.profesionalNombre,
      profesionalFoto: profesionalFoto ?? this.profesionalFoto,
      profesionalCategoria: profesionalCategoria ?? this.profesionalCategoria,
      profesionalCiudad: profesionalCiudad ?? this.profesionalCiudad,
      profesionalWhatsapp: profesionalWhatsapp ?? this.profesionalWhatsapp,
      profesionalCalificacion:
          profesionalCalificacion ?? this.profesionalCalificacion,
      profesionalVerificado:
          profesionalVerificado ?? this.profesionalVerificado,
    );
  }

  /// Tiempo transcurrido desde que se agregó el contacto
  String get tiempoAgregado {
    final diferencia = DateTime.now().difference(createdAt);

    if (diferencia.inDays > 365) {
      return 'hace ${diferencia.inDays ~/ 365} año${diferencia.inDays ~/ 365 > 1 ? 's' : ''}';
    } else if (diferencia.inDays > 30) {
      return 'hace ${diferencia.inDays ~/ 30} mes${diferencia.inDays ~/ 30 > 1 ? 'es' : ''}';
    } else if (diferencia.inDays > 0) {
      return 'hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'hace ${diferencia.inHours}h';
    } else {
      return 'hace ${diferencia.inMinutes}min';
    }
  }
}
