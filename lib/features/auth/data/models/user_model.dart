import 'package:equatable/equatable.dart';

/// Modelo de datos para el usuario
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? nombreCompleto;
  final String? telefono;
  final String? whatsapp;
  final String? fotoPerfil;
  final String? ciudad;
  final String? zona;
  final String rol; // buscador, profesional, dual, cajero, admin
  final String tipoCuenta; // gratuita, basica, premium, vip
  final int creditos;
  final int creditosTotalesGanados;
  final bool membresiaActiva;
  final bool verificado;
  final String? codigoReferido;
  final int totalSolicitudesPublicadas;
  final int totalContactosVistos;
  final bool notificacionesPush;
  final bool modoOscuro;
  final bool perfilCompletoRecompensa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.nombreCompleto,
    this.telefono,
    this.whatsapp,
    this.fotoPerfil,
    this.ciudad,
    this.zona,
    this.rol = 'buscador',
    this.tipoCuenta = 'gratuita',
    this.creditos = 0,
    this.creditosTotalesGanados = 0,
    this.membresiaActiva = false,
    this.verificado = false,
    this.codigoReferido,
    this.totalSolicitudesPublicadas = 0,
    this.totalContactosVistos = 0,
    this.notificacionesPush = true,
    this.modoOscuro = false,
    this.perfilCompletoRecompensa = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea un UserModel desde un Map (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombreCompleto: json['nombre_completo'] as String?,
      telefono: json['telefono'] as String?,
      whatsapp: json['whatsapp'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      ciudad: json['ciudad'] as String?,
      zona: json['zona'] as String?,
      rol: json['rol'] as String? ?? 'buscador',
      tipoCuenta: json['tipo_cuenta'] as String? ?? 'gratuita',
      creditos: json['creditos'] as int? ?? 0,
      creditosTotalesGanados: json['creditos_totales_ganados'] as int? ?? 0,
      membresiaActiva: json['membresia_activa'] as bool? ?? false,
      verificado: json['verificado'] as bool? ?? false,
      codigoReferido: json['codigo_referido'] as String?,
      totalSolicitudesPublicadas: json['total_solicitudes_publicadas'] as int? ?? 0,
      totalContactosVistos: json['total_contactos_vistos'] as int? ?? 0,
      notificacionesPush: json['notificaciones_push'] as bool? ?? true,
      modoOscuro: json['modo_oscuro'] as bool? ?? false,
      perfilCompletoRecompensa: json['perfil_completo'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el UserModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre_completo': nombreCompleto,
      'telefono': telefono,
      'whatsapp': whatsapp,
      'foto_perfil': fotoPerfil,
      'ciudad': ciudad,
      'zona': zona,
      'rol': rol,
      'tipo_cuenta': tipoCuenta,
      'creditos': creditos,
      'creditos_totales_ganados': creditosTotalesGanados,
      'membresia_activa': membresiaActiva,
      'verificado': verificado,
      'codigo_referido': codigoReferido,
      'total_solicitudes_publicadas': totalSolicitudesPublicadas,
      'total_contactos_vistos': totalContactosVistos,
      'notificaciones_push': notificacionesPush,
      'modo_oscuro': modoOscuro,
      'perfil_completo': perfilCompletoRecompensa,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del UserModel con algunos campos modificados
  UserModel copyWith({
    String? id,
    String? email,
    String? nombreCompleto,
    String? telefono,
    String? whatsapp,
    String? fotoPerfil,
    String? ciudad,
    String? zona,
    String? rol,
    String? tipoCuenta,
    int? creditos,
    int? creditosTotalesGanados,
    bool? membresiaActiva,
    bool? verificado,
    String? codigoReferido,
    int? totalSolicitudesPublicadas,
    int? totalContactosVistos,
    bool? notificacionesPush,
    bool? modoOscuro,
    bool? perfilCompletoRecompensa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      whatsapp: whatsapp ?? this.whatsapp,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      ciudad: ciudad ?? this.ciudad,
      zona: zona ?? this.zona,
      rol: rol ?? this.rol,
      tipoCuenta: tipoCuenta ?? this.tipoCuenta,
      creditos: creditos ?? this.creditos,
      creditosTotalesGanados: creditosTotalesGanados ?? this.creditosTotalesGanados,
      membresiaActiva: membresiaActiva ?? this.membresiaActiva,
      verificado: verificado ?? this.verificado,
      codigoReferido: codigoReferido ?? this.codigoReferido,
      totalSolicitudesPublicadas: totalSolicitudesPublicadas ?? this.totalSolicitudesPublicadas,
      totalContactosVistos: totalContactosVistos ?? this.totalContactosVistos,
      notificacionesPush: notificacionesPush ?? this.notificacionesPush,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      perfilCompletoRecompensa: perfilCompletoRecompensa ?? this.perfilCompletoRecompensa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el usuario es profesional
  bool get isProfesional => rol == 'profesional' || rol == 'dual';

  /// Verifica si el usuario es buscador
  bool get isBuscador => rol == 'buscador' || rol == 'dual';

  /// Verifica si el usuario es admin
  bool get isAdmin => rol == 'admin';

  /// Verifica si el usuario es cajero
  bool get isCajero => rol == 'cajero';

  /// Verifica si el usuario tiene membresía premium
  bool get isPremium => tipoCuenta == 'premium';

  /// Verifica si el usuario tiene membresía VIP
  bool get isVIP => tipoCuenta == 'vip';

  /// Verifica si el perfil está completo
  bool get perfilCompleto {
    return nombreCompleto != null &&
        nombreCompleto!.isNotEmpty &&
        telefono != null &&
        telefono!.isNotEmpty &&
        ciudad != null &&
        ciudad!.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        nombreCompleto,
        telefono,
        whatsapp,
        fotoPerfil,
        ciudad,
        zona,
        rol,
        tipoCuenta,
        creditos,
        creditosTotalesGanados,
        membresiaActiva,
        verificado,
        codigoReferido,
        totalSolicitudesPublicadas,
        totalContactosVistos,
        notificacionesPush,
        modoOscuro,
        perfilCompletoRecompensa,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nombreCompleto: $nombreCompleto, creditos: $creditos, rol: $rol)';
  }
}
