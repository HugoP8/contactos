/// Constantes de la aplicación CONTACTOS
class AppConstants {
  AppConstants._();

  // ==========================================
  // INFORMACIÓN DE LA APP
  // ==========================================

  static const String appName = 'CONTACTOS';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Plataforma de servicios profesionales en Bolivia';

  // ==========================================
  // SISTEMA DE CRÉDITOS
  // ==========================================

  // Créditos iniciales
  static const int creditosInicialesRegistro = 50;

  // Costos en créditos
  static const int costoVerContacto = 2;
  static const int costoPublicarSolicitud = 15;
  static const int costoDestacarSolicitud = 10;
  static const int costoRenovarSolicitud = 5;
  static const int costoPublicarPreguntaForo = 5; // Foro "Alguien Sabe?"

  // Formas de ganar créditos
  static const int creditosPorVideo = 5;
  static const int creditosPorReferido = 30;
  static const int creditosPorPerfilCompleto = 20;
  static const int creditosPorResena = 4;
  static const int creditosPorRachaDiaria = 3;
  static const int creditosPorMejorRespuestaForo = 2; // Foro "Alguien Sabe?"

  // Límites
  static const int maxVideosAdMobPorDia = 10;
  static const int diasExpiracionSolicitud = 7;

  // ==========================================
  // PAQUETES DE CRÉDITOS
  // ==========================================

  static const List<Map<String, dynamic>> paquetesCreditos = [
    {
      'nombre': 'Básico',
      'creditos': 30,
      'precio': 5.0, // Bs.
      'popular': false,
    },
    {
      'nombre': 'Popular',
      'creditos': 75,
      'precio': 10.0,
      'popular': true,
    },
    {
      'nombre': 'Plus',
      'creditos': 200,
      'precio': 25.0,
      'popular': false,
    },
    {
      'nombre': 'Pro',
      'creditos': 500,
      'precio': 50.0,
      'popular': false,
    },
  ];

  // ==========================================
  // MEMBRESÍAS
  // ==========================================

  // Profesionales - Básica
  static const double membresiaProfesionalBasicaMensual = 20.0; // Bs.
  static const double membresiaProfesionalBasicaAnual = 150.0;
  static const int mesesPruebaGratuitaBasica = 3;
  static const int maxFotosGaleriaBasica = 10;

  // Profesionales - Premium
  static const double membresiaProfesionalPremiumMensual = 30.0;
  static const double membresiaProfesionalPremiumAnual = 200.0;
  static const int maxFotosGaleriaPremium = 999; // Ilimitado

  // Buscadores - VIP
  static const double membresiaVIPMensual = 10.0;
  static const double membresiaVIPAnual = 100.0;

  // ==========================================
  // ROLES DE USUARIO
  // ==========================================

  static const String rolBuscador = 'buscador';
  static const String rolProfesional = 'profesional';
  static const String rolDual = 'dual';
  static const String rolCajero = 'cajero';
  static const String rolAdmin = 'admin';

  static const List<String> roles = [
    rolBuscador,
    rolProfesional,
    rolDual,
    rolCajero,
    rolAdmin,
  ];

  // ==========================================
  // TIPOS DE CUENTA / MEMBRESÍA
  // ==========================================

  static const String tipoCuentaGratuita = 'gratuita';
  static const String tipoCuentaBasica = 'basica';
  static const String tipoCuentaPremium = 'premium';
  static const String tipoCuentaVIP = 'vip';

  static const List<String> tiposCuenta = [
    tipoCuentaGratuita,
    tipoCuentaBasica,
    tipoCuentaPremium,
    tipoCuentaVIP,
  ];

  // ==========================================
  // CATEGORÍAS DE SERVICIOS
  // ==========================================

  static const Map<String, List<String>> categorias = {
    'Construcción y Mantenimiento': [
      'Plomero',
      'Electricista',
      'Albañil',
      'Pintor',
      'Carpintero',
      'Cerrajero',
      'Soldador',
      'Techador',
      'Vidriero',
      'Instalador de aires',
    ],
    'Tecnología': [
      'Desarrollador web',
      'Desarrollador móvil',
      'Diseñador gráfico',
      'Diseñador UI/UX',
      'Soporte técnico',
      'Reparación celulares',
      'Reparación computadoras',
      'Instalación redes',
      'Técnico de impresoras',
      'Community manager',
    ],
    'Salud y Bienestar': [
      'Médico general',
      'Dentista',
      'Psicólogo',
      'Nutricionista',
      'Enfermera',
      'Fisioterapeuta',
      'Masajista',
      'Quiropráctico',
      'Entrenador personal',
      'Terapeuta',
    ],
    'Educación': [
      'Profesor particular',
      'Tutor matemáticas',
      'Tutor física',
      'Tutor química',
      'Profesor de inglés',
      'Profesor de idiomas',
      'Profesor de música',
      'Profesor de arte',
      'Clases de baile',
      'Coach educativo',
    ],
    'Hogar y Limpieza': [
      'Limpieza del hogar',
      'Limpieza profunda',
      'Jardinería',
      'Fumigación',
      'Lavado de alfombras',
      'Limpieza de muebles',
      'Organización del hogar',
      'Lavandería',
      'Planchado',
      'Cuidado de plantas',
    ],
    'Automotriz': [
      'Mecánico',
      'Electricista automotriz',
      'Tapicería de autos',
      'Pintura de autos',
      'Lavado de autos',
      'Cambio de aceite',
      'Polarizado',
      'Instalación de audio',
      'Chapista',
      'Vulcanización',
    ],
    'Estética y Belleza': [
      'Peluquero',
      'Barbero',
      'Estilista',
      'Manicurista',
      'Pedicurista',
      'Maquillador',
      'Depilación',
      'Tratamientos faciales',
      'Spa',
      'Estética',
    ],
    'Eventos': [
      'Fotógrafo',
      'Videógrafo',
      'DJ',
      'Animador',
      'Decorador',
      'Organizador de eventos',
      'Catering',
      'Pastelero',
      'Sonido e iluminación',
      'Alquiler de equipos',
    ],
    'Transporte': [
      'Mudanzas',
      'Transporte de carga',
      'Flete',
      'Taxi',
      'Chofer particular',
      'Mensajería',
      'Delivery',
      'Transporte escolar',
      'Alquiler de vehículos',
      'Transporte turístico',
    ],
    'Legal y Administrativo': [
      'Abogado',
      'Contador',
      'Asesor legal',
      'Asesor tributario',
      'Notario',
      'Tramitador',
      'Gestor',
      'Consultor empresarial',
      'Recursos humanos',
      'Auditor',
    ],
  };

  /// Obtiene todas las categorías principales
  static List<String> get categoriasPrincipales => categorias.keys.toList();

  /// Obtiene todas las subcategorías de una categoría
  static List<String> getSubcategorias(String categoria) {
    return categorias[categoria] ?? [];
  }

  /// Obtiene todas las subcategorías (flat list)
  static List<String> get todasLasSubcategorias {
    final List<String> todas = [];
    categorias.forEach((categoria, subcategorias) {
      todas.addAll(subcategorias);
    });
    return todas;
  }

  // ==========================================
  // CIUDADES DE BOLIVIA
  // ==========================================

  static const List<String> ciudades = [
    'La Paz',
    'El Alto',
    'Santa Cruz',
    'Cochabamba',
    'Sucre',
    'Oruro',
    'Potosí',
    'Tarija',
    'Trinidad',
  ];

  // ==========================================
  // ESTADOS DE SOLICITUDES
  // ==========================================

  static const String estadoSolicitudActiva = 'activa';
  static const String estadoSolicitudEnProceso = 'en_proceso';
  static const String estadoSolicitudCompletada = 'completada';
  static const String estadoSolicitudCancelada = 'cancelada';
  static const String estadoSolicitudExpirada = 'expirada';

  static const List<String> estadosSolicitud = [
    estadoSolicitudActiva,
    estadoSolicitudEnProceso,
    estadoSolicitudCompletada,
    estadoSolicitudCancelada,
    estadoSolicitudExpirada,
  ];

  // ==========================================
  // URGENCIA DE SOLICITUDES
  // ==========================================

  static const String urgenciaNormal = 'normal';
  static const String urgenciaUrgente = 'urgente';

  static const List<String> nivelesUrgencia = [
    urgenciaNormal,
    urgenciaUrgente,
  ];

  // ==========================================
  // ESTADOS DE POSTULACIONES
  // ==========================================

  static const String estadoPostulacionPendiente = 'pendiente';
  static const String estadoPostulacionAceptada = 'aceptada';
  static const String estadoPostulacionRechazada = 'rechazada';
  static const String estadoPostulacionCancelada = 'cancelada';

  static const List<String> estadosPostulacion = [
    estadoPostulacionPendiente,
    estadoPostulacionAceptada,
    estadoPostulacionRechazada,
    estadoPostulacionCancelada,
  ];

  // ==========================================
  // VALIDACIONES
  // ==========================================

  // Longitudes
  static const int minLongitudPassword = 6;
  static const int maxLongitudPassword = 50;
  static const int minLongitudNombre = 2;
  static const int maxLongitudNombre = 50;
  static const int maxLongitudDescripcion = 500;
  static const int maxLongitudBio = 200;
  static const int longitudCodigoReferido = 8;

  // Tamaños de archivo
  static const int maxSizeImagenMB = 5; // 5 MB
  static const int maxSizeImagenBytes = maxSizeImagenMB * 1024 * 1024;

  // Límites de galerías
  static const int maxImagenesSolicitud = 5;
  static const int maxImagenesGaleriaProfesional = 20;

  // ==========================================
  // BUCKET NAMES DE SUPABASE STORAGE
  // ==========================================

  static const String bucketPerfiles = 'perfiles';
  static const String bucketSolicitudes = 'solicitudes';
  static const String bucketGalerias = 'galerias';

  // ==========================================
  // TIPOS DE MOVIMIENTOS DE CRÉDITOS
  // ==========================================

  static const String tipoMovimientoGanancia = 'ganancia';
  static const String tipoMovimientoGasto = 'gasto';

  // Orígenes de movimientos
  static const String origenRegistroBienvenida = 'registro_bienvenida';
  static const String origenVideoAdmob = 'video_admob';
  static const String origenReferido = 'referido';
  static const String origenCompra = 'compra';
  static const String origenPerfilCompleto = 'perfil_completo';
  static const String origenResena = 'resena';
  static const String origenRachaDiaria = 'racha_diaria';
  static const String origenVerContacto = 'ver_contacto';
  static const String origenPublicarSolicitud = 'publicar_solicitud';
  static const String origenDestacarSolicitud = 'destacar_solicitud';
  static const String origenRenovarSolicitud = 'renovar_solicitud';

  // ==========================================
  // TIPOS DE TOKENS ESPECIALES
  // ==========================================

  static const String tokenSolicitudGratuita = 'solicitud_gratuita';

  // ==========================================
  // CONFIGURACIÓN DE UI
  // ==========================================

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==========================================
  // MENSAJES
  // ==========================================

  static const String mensajeErrorGenerico =
      'Ocurrió un error. Por favor, intenta nuevamente.';
  static const String mensajeSinConexion =
      'No hay conexión a internet. Verifica tu conexión.';
  static const String mensajeCreditosInsuficientes =
      'No tienes créditos suficientes para esta acción.';
  static const String mensajeExitoGenerico =
      'Operación realizada con éxito.';

  // ==========================================
  // REGEX PATTERNS
  // ==========================================

  static final RegExp regexEmail = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp regexTelefono = RegExp(
    r'^\d{8}$', // 8 dígitos para Bolivia
  );

  static final RegExp regexSoloNumeros = RegExp(r'^\d+$');
  static final RegExp regexSoloLetras = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');

  // ==========================================
  // CATEGORÍAS DEL FORO "ALGUIEN SABE?"
  // ==========================================

  static const List<String> categoriasForo = [
    'Servicios', // ¿Alguien sabe de un buen plomero?
    'Rutas y Transporte', // ¿Está bloqueada la ruta Sucre-Potosí?
    'Recomendaciones', // ¿Dónde puedo comprar...?
    'Trámites', // ¿Cómo saco mi carnet?
    'Salud', // ¿Alguien conoce un buen doctor?
    'Educación', // ¿Alguien recomienda una academia de inglés?
    'Tecnología', // ¿Cómo arreglo mi celular?
    'General', // Cualquier otra pregunta
  ];
}
