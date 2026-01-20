import 'package:equatable/equatable.dart';

/// Modelo de datos para el perfil profesional
class PerfilProfesionalModel extends Equatable {
  final String id;
  final String? userId;
  final String? nombreComercial;
  final String? descripcion;
  final String categoriaPrincipal;
  final List<String> subcategorias;
  final String ciudad;
  final String? whatsapp;
  final String? fotoPerfil;
  final List<String> galeriaFotos;
  final double calificacionPromedio;
  final int totalResenas;
  final bool verificado;
  final bool activo;
  final bool destacado; // Para membresía premium
  final bool visibleBusqueda;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PerfilProfesionalModel({
    required this.id,
    this.userId,
    this.nombreComercial,
    this.descripcion,
    required this.categoriaPrincipal,
    this.subcategorias = const [],
    required this.ciudad,
    this.whatsapp,
    this.fotoPerfil,
    this.galeriaFotos = const [],
    this.calificacionPromedio = 0.0,
    this.totalResenas = 0,
    this.verificado = false,
    this.activo = true,
    this.destacado = false,
    this.visibleBusqueda = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea un PerfilProfesionalModel desde un Map (JSON)
  factory PerfilProfesionalModel.fromJson(Map<String, dynamic> json) {
    return PerfilProfesionalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      nombreComercial: json['nombre_comercial'] as String?,
      descripcion: json['descripcion'] as String?,
      categoriaPrincipal: json['categoria_principal'] as String,
      subcategorias: json['subcategorias'] != null
          ? List<String>.from(json['subcategorias'] as List)
          : [],
      ciudad: json['ciudad'] as String,
      whatsapp: json['whatsapp'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      galeriaFotos: json['galeria_fotos'] != null
          ? List<String>.from(json['galeria_fotos'] as List)
          : [],
      calificacionPromedio: (json['calificacion_promedio'] as num?)?.toDouble() ?? 0.0,
      totalResenas: json['total_resenas'] as int? ?? 0,
      verificado: json['verificado'] as bool? ?? false,
      activo: json['activo'] as bool? ?? true,
      destacado: json['destacado'] as bool? ?? false,
      visibleBusqueda: json['visible_busqueda'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el PerfilProfesionalModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre_comercial': nombreComercial,
      'descripcion': descripcion,
      'categoria_principal': categoriaPrincipal,
      'subcategorias': subcategorias,
      'ciudad': ciudad,
      'whatsapp': whatsapp,
      'foto_perfil': fotoPerfil,
      'galeria_fotos': galeriaFotos,
      'calificacion_promedio': calificacionPromedio,
      'total_resenas': totalResenas,
      'verificado': verificado,
      'activo': activo,
      'destacado': destacado,
      'visible_busqueda': visibleBusqueda,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del PerfilProfesionalModel con algunos campos modificados
  PerfilProfesionalModel copyWith({
    String? id,
    String? userId,
    String? nombreComercial,
    String? descripcion,
    String? categoriaPrincipal,
    List<String>? subcategorias,
    String? ciudad,
    String? whatsapp,
    String? fotoPerfil,
    List<String>? galeriaFotos,
    double? calificacionPromedio,
    int? totalResenas,
    bool? verificado,
    bool? activo,
    bool? destacado,
    bool? visibleBusqueda,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerfilProfesionalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      descripcion: descripcion ?? this.descripcion,
      categoriaPrincipal: categoriaPrincipal ?? this.categoriaPrincipal,
      subcategorias: subcategorias ?? this.subcategorias,
      ciudad: ciudad ?? this.ciudad,
      whatsapp: whatsapp ?? this.whatsapp,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      galeriaFotos: galeriaFotos ?? this.galeriaFotos,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      totalResenas: totalResenas ?? this.totalResenas,
      verificado: verificado ?? this.verificado,
      activo: activo ?? this.activo,
      destacado: destacado ?? this.destacado,
      visibleBusqueda: visibleBusqueda ?? this.visibleBusqueda,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el perfil está completo
  bool get perfilCompleto {
    return nombreComercial != null &&
        nombreComercial!.isNotEmpty &&
        descripcion != null &&
        descripcion!.isNotEmpty &&
        whatsapp != null &&
        whatsapp!.isNotEmpty &&
        fotoPerfil != null &&
        fotoPerfil!.isNotEmpty;
  }

  /// Verifica si tiene buena calificación (>= 4.0)
  bool get tieneBuenaCalificacion => calificacionPromedio >= 4.0;

  /// Obtiene el número de estrellas completas
  int get estrellasCompletas => calificacionPromedio.floor();

  /// Verifica si tiene media estrella
  bool get tieneMediaEstrella => (calificacionPromedio - estrellasCompletas) >= 0.5;

  @override
  List<Object?> get props => [
        id,
        userId,
        nombreComercial,
        descripcion,
        categoriaPrincipal,
        subcategorias,
        ciudad,
        whatsapp,
        fotoPerfil,
        galeriaFotos,
        calificacionPromedio,
        totalResenas,
        verificado,
        activo,
        destacado,
        visibleBusqueda,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PerfilProfesionalModel(id: $id, nombreComercial: $nombreComercial, categoria: $categoriaPrincipal, calificacion: $calificacionPromedio)';
  }
}
