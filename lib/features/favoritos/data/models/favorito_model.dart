import 'package:intl/intl.dart';

/// Modelo de favorito (profesional guardado por un usuario)
class FavoritoModel {
  final String id;
  final String userId;
  final String profesionalId;
  final DateTime createdAt;

  // Campos JOIN desde perfiles_profesionales
  final String? profesionalNombre;
  final String? profesionalFoto;
  final String? profesionalCategoria;
  final String? profesionalCiudad;
  final double? profesionalCalificacion;
  final int? profesionalTotalResenas;
  final bool? profesionalVerificado;
  final bool? profesionalDestacado;

  const FavoritoModel({
    required this.id,
    required this.userId,
    required this.profesionalId,
    required this.createdAt,
    this.profesionalNombre,
    this.profesionalFoto,
    this.profesionalCategoria,
    this.profesionalCiudad,
    this.profesionalCalificacion,
    this.profesionalTotalResenas,
    this.profesionalVerificado,
    this.profesionalDestacado,
  });

  /// Crea una instancia desde JSON
  factory FavoritoModel.fromJson(Map<String, dynamic> json) {
    return FavoritoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      profesionalId: json['profesional_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      profesionalNombre: json['profesional']?['nombre_comercial'] as String?,
      profesionalFoto: json['profesional']?['foto_perfil'] as String?,
      profesionalCategoria:
          json['profesional']?['categoria_principal'] as String?,
      profesionalCiudad: json['profesional']?['ciudad'] as String?,
      profesionalCalificacion:
          (json['profesional']?['calificacion_promedio'] as num?)?.toDouble(),
      profesionalTotalResenas:
          json['profesional']?['total_resenas'] as int?,
      profesionalVerificado: json['profesional']?['verificado'] as bool?,
      profesionalDestacado: json['profesional']?['destacado'] as bool?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'profesional_id': profesionalId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  FavoritoModel copyWith({
    String? id,
    String? userId,
    String? profesionalId,
    DateTime? createdAt,
    String? profesionalNombre,
    String? profesionalFoto,
    String? profesionalCategoria,
    String? profesionalCiudad,
    double? profesionalCalificacion,
    int? profesionalTotalResenas,
    bool? profesionalVerificado,
    bool? profesionalDestacado,
  }) {
    return FavoritoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profesionalId: profesionalId ?? this.profesionalId,
      createdAt: createdAt ?? this.createdAt,
      profesionalNombre: profesionalNombre ?? this.profesionalNombre,
      profesionalFoto: profesionalFoto ?? this.profesionalFoto,
      profesionalCategoria: profesionalCategoria ?? this.profesionalCategoria,
      profesionalCiudad: profesionalCiudad ?? this.profesionalCiudad,
      profesionalCalificacion:
          profesionalCalificacion ?? this.profesionalCalificacion,
      profesionalTotalResenas:
          profesionalTotalResenas ?? this.profesionalTotalResenas,
      profesionalVerificado: profesionalVerificado ?? this.profesionalVerificado,
      profesionalDestacado: profesionalDestacado ?? this.profesionalDestacado,
    );
  }

  // ==========================================
  // GETTERS CALCULADOS
  // ==========================================

  /// Tiempo transcurrido desde que se agregó a favoritos
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

  /// Fecha formateada
  String get fechaFormateada {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  @override
  String toString() {
    return 'FavoritoModel(id: $id, profesionalId: $profesionalId, profesionalNombre: $profesionalNombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FavoritoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
