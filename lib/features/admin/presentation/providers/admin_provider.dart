import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../payments/presentation/providers/payments_provider.dart';

// Estado del dashboard
class DashboardStats {
  final int totalUsuarios;
  final int usuariosActivos;
  final int totalProfesionales;
  final int totalSolicitudes;
  final int solicitudesPendientes;
  final double ingresosMes;
  final int recargasPendientes;
  final int recargasProcesadas;

  DashboardStats({
    required this.totalUsuarios,
    required this.usuariosActivos,
    required this.totalProfesionales,
    required this.totalSolicitudes,
    required this.solicitudesPendientes,
    required this.ingresosMes,
    required this.recargasPendientes,
    required this.recargasProcesadas,
  });
}

// Provider para obtener estadísticas del dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final supabase = SupabaseService.instance.client;

  try {
    // Total usuarios
    final users = await supabase
        .from('users')
        .select('id');

    // Usuarios activos (último mes)
    final activeUsers = await supabase
        .from('users')
        .select('id')
        .gte('ultimo_acceso', DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

    // Total profesionales
    final professionals = await supabase
        .from('perfiles_profesionales')
        .select('id')
        .eq('activo', true);

    // Total solicitudes
    final solicitudes = await supabase
        .from('solicitudes_trabajo')
        .select('id');

    // Solicitudes pendientes
    final solicitudesPendientes = await supabase
        .from('solicitudes_trabajo')
        .select('id')
        .eq('estado', 'activa');

    // Ingresos del mes
    final firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final ingresosData = await supabase
        .from('transacciones')
        .select('monto_bolivianos')
        .eq('estado', 'completada')
        .gte('created_at', firstDayOfMonth.toIso8601String());

    double ingresosMes = 0.0;
    for (var item in ingresosData as List) {
      ingresosMes += (item['monto_bolivianos'] as num?)?.toDouble() ?? 0.0;
    }

    // Recargas pendientes de aprobación
    final recargasPendientes = await supabase
        .from('solicitudes_recarga')
        .select('id')
        .eq('estado', 'validado_cajero');

    // Recargas procesadas hoy
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final recargasProcesadas = await supabase
        .from('solicitudes_recarga')
        .select('id')
        .eq('estado', 'completada')
        .gte('updated_at', startOfDay.toIso8601String());

    return DashboardStats(
      totalUsuarios: (users as List).length,
      usuariosActivos: (activeUsers as List).length,
      totalProfesionales: (professionals as List).length,
      totalSolicitudes: (solicitudes as List).length,
      solicitudesPendientes: (solicitudesPendientes as List).length,
      ingresosMes: ingresosMes,
      recargasPendientes: (recargasPendientes as List).length,
      recargasProcesadas: (recargasProcesadas as List).length,
    );
  } catch (e) {
    print('Error al cargar estadísticas: $e');
    rethrow;
  }
});

// Provider para obtener recargas pendientes de aprobación
final recargasPendientesProvider = FutureProvider<List<SolicitudRecarga>>((ref) async {
  final supabase = SupabaseService.instance.client;

  try {
    final response = await supabase
        .from('solicitudes_recarga')
        .select('''
          *,
          usuario:users!solicitudes_recarga_user_id_fkey(nombre_completo, email, telefono),
          cajero:users!solicitudes_recarga_cajero_id_fkey(nombre_completo, whatsapp)
        ''')
        .eq('estado', 'validado_cajero')
        .order('fecha_validacion_cajero', ascending: true);

    return (response as List)
        .map((json) => SolicitudRecarga.fromJson(json))
        .toList();
  } catch (e) {
    print('Error al cargar recargas pendientes: $e');
    rethrow;
  }
});

// Actions del admin
class AdminActions {
  final Ref ref;
  final SupabaseClient _supabase = SupabaseService.instance.client;

  AdminActions(this.ref);

  // Aprobar y activar recarga
  Future<bool> aprobarRecarga(String solicitudId, String adminId) async {
    try {
      // Obtener detalles de la solicitud
      final solicitudData = await _supabase
          .from('solicitudes_recarga')
          .select()
          .eq('id', solicitudId)
          .single();

      final solicitud = SolicitudRecarga.fromJson(solicitudData);

      // Iniciar transacción
      if (solicitud.tipoProducto == 'creditos') {
        // Sumar créditos al usuario (la función ya registra el movimiento en movimientos_creditos)
        await _supabase.rpc('incrementar_creditos', params: {
          'p_user_id': solicitud.userId,
          'p_cantidad': solicitud.cantidadCreditos,
          'p_motivo': 'recarga',
          'p_descripcion': 'Compra de ${solicitud.cantidadCreditos} créditos',
        });
      } else {
        // Activar membresía
        final duracionDias = solicitud.duracion == 'anual' ? 365 : 30;
        final fechaFin = DateTime.now().add(Duration(days: duracionDias));

        await _supabase
            .from('users')
            .update({
              'tipo_cuenta': solicitud.tipoMembresia,
              'fecha_inicio_membresia': DateTime.now().toIso8601String(),
              'fecha_fin_membresia': fechaFin.toIso8601String(),
              'membresia_activa': true,
            })
            .eq('id', solicitud.userId);
      }

      // Registrar transacción
      await _supabase.from('transacciones').insert({
        'user_id': solicitud.userId,
        'tipo': solicitud.tipoProducto == 'creditos' ? 'recarga_creditos' : 'pago_membresia',
        'concepto': solicitud.tipoProducto == 'creditos'
            ? 'Recarga de ${solicitud.cantidadCreditos} créditos'
            : 'Membresía ${solicitud.tipoMembresia} (${solicitud.duracion})',
        'cantidad_creditos': solicitud.cantidadCreditos,
        'monto_bolivianos': solicitud.montoTotal,
        'metodo_pago': solicitud.metodoPago,
        'cajero_id': solicitud.cajeroId,
        'admin_id': adminId,
        'estado': 'completada',
      });

      // Registrar comisión del cajero
      await _supabase.from('comisiones_cajeros').insert({
        'cajero_id': solicitud.cajeroId,
        'solicitud_recarga_id': solicitudId,
        'monto_comision': solicitud.comisionCajero,
        'monto_transaccion': solicitud.montoTotal,
        'porcentaje': 5.0,
        'estado': 'pendiente',
      });

      // Actualizar solicitud como completada
      await _supabase
          .from('solicitudes_recarga')
          .update({
            'estado': 'completada',
            'admin_activador': adminId,
            'fecha_activacion_admin': DateTime.now().toIso8601String(),
          })
          .eq('id', solicitudId);

      // Crear notificación para el usuario
      await _supabase.from('notificaciones').insert({
        'user_id': solicitud.userId,
        'titulo': '🎉 ¡Recarga activada!',
        'mensaje': solicitud.tipoProducto == 'creditos'
            ? 'Se agregaron ${solicitud.cantidadCreditos} créditos a tu cuenta'
            : 'Tu membresía ${solicitud.tipoMembresia} ha sido activada',
        'tipo': 'recarga_activada',
        'leida': false,
      });

      // Refrescar la lista de recargas pendientes
      ref.invalidate(recargasPendientesProvider);
      ref.invalidate(dashboardStatsProvider);

      return true;
    } catch (e) {
      print('Error al aprobar recarga: $e');
      return false;
    }
  }

  // Rechazar recarga
  Future<bool> rechazarRecarga(String solicitudId, String razon) async {
    try {
      await _supabase
          .from('solicitudes_recarga')
          .update({
            'estado': 'rechazada',
            'notas_admin': razon,
          })
          .eq('id', solicitudId);

      // Refrescar
      ref.invalidate(recargasPendientesProvider);
      ref.invalidate(dashboardStatsProvider);

      return true;
    } catch (e) {
      print('Error al rechazar recarga: $e');
      return false;
    }
  }

  // Suspender usuario
  Future<bool> suspenderUsuario(String userId, String razon) async {
    try {
      await _supabase
          .from('users')
          .update({
            'suspendido': true,
            'razon_suspension': razon,
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error al suspender usuario: $e');
      return false;
    }
  }

  // Activar usuario
  Future<bool> activarUsuario(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'suspendido': false,
            'razon_suspension': null,
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error al activar usuario: $e');
      return false;
    }
  }

  // Obtener lista de usuarios
  Future<List<Map<String, dynamic>>> obtenerUsuarios({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  // Obtener lista de cajeros
  Future<List<Map<String, dynamic>>> obtenerCajeros() async {
    try {
      final response = await _supabase
          .from('cajeros_vendedores')
          .select('''
            *,
            usuario:users!cajeros_vendedores_user_id_fkey(nombre_completo, email)
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error al obtener cajeros: $e');
      return [];
    }
  }
}

// Provider de acciones del admin
final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref);
});
