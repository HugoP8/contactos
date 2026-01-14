import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

// Estados de pago
enum PaymentStatus {
  idle,
  processing,
  success,
  failed,
}

// Modelo de solicitud de recarga
class SolicitudRecarga {
  final String id;
  final String userId;
  final String? cajeroId;
  final String tipoProducto; // creditos, membresia_basica, membresia_premium, vip_buscador
  final int? cantidadCreditos;
  final String? tipoMembresia;
  final String? duracion; // mensual, anual
  final double montoTotal;
  final double comisionCajero;
  final String metodoPago;
  final String estado; // pendiente_pago, validado_cajero, pendiente_aprobacion_admin, completada, rechazada
  final DateTime createdAt;
  final String? comprobantePago;

  SolicitudRecarga({
    required this.id,
    required this.userId,
    this.cajeroId,
    required this.tipoProducto,
    this.cantidadCreditos,
    this.tipoMembresia,
    this.duracion,
    required this.montoTotal,
    required this.comisionCajero,
    required this.metodoPago,
    required this.estado,
    required this.createdAt,
    this.comprobantePago,
  });

  factory SolicitudRecarga.fromJson(Map<String, dynamic> json) {
    return SolicitudRecarga(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cajeroId: json['cajero_id'] as String?,
      tipoProducto: json['tipo_producto'] as String,
      cantidadCreditos: json['cantidad_creditos'] as int?,
      tipoMembresia: json['tipo_membresia'] as String?,
      duracion: json['duracion'] as String?,
      montoTotal: (json['monto_total'] as num).toDouble(),
      comisionCajero: (json['comision_cajero'] as num).toDouble(),
      metodoPago: json['metodo_pago'] as String,
      estado: json['estado'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      comprobantePago: json['comprobante_pago'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cajero_id': cajeroId,
      'tipo_producto': tipoProducto,
      'cantidad_creditos': cantidadCreditos,
      'tipo_membresia': tipoMembresia,
      'duracion': duracion,
      'monto_total': montoTotal,
      'comision_cajero': comisionCajero,
      'metodo_pago': metodoPago,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'comprobante_pago': comprobantePago,
    };
  }
}

// Modelo de cajero
class Cajero {
  final String id;
  final String userId;
  final String nombreCompleto;
  final String telefono;
  final String whatsapp;
  final String ciudad;
  final String zona;
  final List<String> metodosPago;
  final bool disponibleAhora;
  final double calificacionPromedio;
  final int totalTransacciones;

  Cajero({
    required this.id,
    required this.userId,
    required this.nombreCompleto,
    required this.telefono,
    required this.whatsapp,
    required this.ciudad,
    required this.zona,
    required this.metodosPago,
    required this.disponibleAhora,
    required this.calificacionPromedio,
    required this.totalTransacciones,
  });

  factory Cajero.fromJson(Map<String, dynamic> json) {
    return Cajero(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      telefono: json['telefono'] as String,
      whatsapp: json['whatsapp'] as String,
      ciudad: json['ciudad'] as String,
      zona: json['zona'] as String,
      metodosPago: List<String>.from(json['metodos_pago'] as List),
      disponibleAhora: json['disponible_ahora'] as bool,
      calificacionPromedio: (json['calificacion_promedio'] as num).toDouble(),
      totalTransacciones: json['total_transacciones'] as int,
    );
  }
}

// Estado del provider
class PaymentsState {
  final PaymentStatus status;
  final String? errorMessage;
  final List<Cajero> cajeros;
  final Cajero? cajeroSeleccionado;
  final SolicitudRecarga? solicitudActual;

  PaymentsState({
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.cajeros = const [],
    this.cajeroSeleccionado,
    this.solicitudActual,
  });

  PaymentsState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    List<Cajero>? cajeros,
    Cajero? cajeroSeleccionado,
    SolicitudRecarga? solicitudActual,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      cajeros: cajeros ?? this.cajeros,
      cajeroSeleccionado: cajeroSeleccionado ?? this.cajeroSeleccionado,
      solicitudActual: solicitudActual ?? this.solicitudActual,
    );
  }
}

// Provider del estado de pagos
class PaymentsNotifier extends StateNotifier<PaymentsState> {
  PaymentsNotifier() : super(PaymentsState());

  final SupabaseClient _supabase = SupabaseService.instance.client;

  // Obtener cajeros disponibles por ciudad
  Future<void> obtenerCajerosDisponibles(String ciudad) async {
    try {
      state = state.copyWith(status: PaymentStatus.processing);

      final response = await _supabase
          .from('cajeros_vendedores')
          .select()
          .eq('ciudad', ciudad)
          .eq('activo', true)
          .order('calificacion_promedio', ascending: false);

      final cajeros = (response as List)
          .map((json) => Cajero.fromJson(json))
          .toList();

      state = state.copyWith(
        status: PaymentStatus.idle,
        cajeros: cajeros,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Error al cargar cajeros: ${e.toString()}',
      );
    }
  }

  // Seleccionar cajero
  void seleccionarCajero(Cajero cajero) {
    state = state.copyWith(cajeroSeleccionado: cajero);
  }

  // Crear solicitud de recarga de créditos
  Future<SolicitudRecarga?> crearSolicitudCreditos({
    required String userId,
    required String cajeroId,
    required int cantidadCreditos,
    required double monto,
    required String metodoPago,
  }) async {
    try {
      state = state.copyWith(status: PaymentStatus.processing);

      final comision = monto * 0.05; // 5% de comisión

      final solicitudData = {
        'user_id': userId,
        'cajero_id': cajeroId,
        'tipo_producto': 'creditos',
        'cantidad_creditos': cantidadCreditos,
        'monto_total': monto,
        'comision_cajero': comision,
        'metodo_pago': metodoPago,
        'estado': 'pendiente_pago',
      };

      final response = await _supabase
          .from('solicitudes_recarga')
          .insert(solicitudData)
          .select()
          .single();

      final solicitud = SolicitudRecarga.fromJson(response);

      state = state.copyWith(
        status: PaymentStatus.success,
        solicitudActual: solicitud,
      );

      return solicitud;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Error al crear solicitud: ${e.toString()}',
      );
      return null;
    }
  }

  // Crear solicitud de membresía
  Future<SolicitudRecarga?> crearSolicitudMembresia({
    required String userId,
    required String cajeroId,
    required String tipoMembresia, // basica, premium, vip_buscador
    required String duracion, // mensual, anual
    required double monto,
    required String metodoPago,
  }) async {
    try {
      state = state.copyWith(status: PaymentStatus.processing);

      final comision = monto * 0.05; // 5% de comisión

      final solicitudData = {
        'user_id': userId,
        'cajero_id': cajeroId,
        'tipo_producto': 'membresia_$tipoMembresia',
        'tipo_membresia': tipoMembresia,
        'duracion': duracion,
        'monto_total': monto,
        'comision_cajero': comision,
        'metodo_pago': metodoPago,
        'estado': 'pendiente_pago',
      };

      final response = await _supabase
          .from('solicitudes_recarga')
          .insert(solicitudData)
          .select()
          .single();

      final solicitud = SolicitudRecarga.fromJson(response);

      state = state.copyWith(
        status: PaymentStatus.success,
        solicitudActual: solicitud,
      );

      return solicitud;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Error al crear solicitud: ${e.toString()}',
      );
      return null;
    }
  }

  // Obtener mis solicitudes pendientes
  Future<List<SolicitudRecarga>> obtenerMisSolicitudes(String userId) async {
    try {
      final response = await _supabase
          .from('solicitudes_recarga')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SolicitudRecarga.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener solicitudes: $e');
      return [];
    }
  }

  // Limpiar estado
  void limpiarEstado() {
    state = PaymentsState();
  }
}

// Provider principal
final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentsState>(
  (ref) => PaymentsNotifier(),
);
