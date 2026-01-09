import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Provider del estado de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

/// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  final _supabase = SupabaseService.instance;
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Inicializa el estado de autenticación
  Future<void> _initialize() async {
    try {
      // Verificar si hay un usuario autenticado
      final currentUser = _supabase.currentUser;

      if (currentUser != null) {
        // Cargar datos del usuario desde la base de datos
        final userData = await _loadUserData(currentUser.id);
        state = AsyncValue.data(userData);
      } else {
        state = const AsyncValue.data(null);
      }

      // Escuchar cambios en el estado de autenticación
      _supabase.authStateChanges.listen((authState) async {
        final session = authState.session;

        if (session != null) {
          // Usuario autenticado
          final userData = await _loadUserData(session.user.id);
          state = AsyncValue.data(userData);
        } else {
          // Usuario no autenticado
          state = const AsyncValue.data(null);
        }
      });
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error al inicializar auth: $e');
      }
      state = AsyncValue.error(e, stack);
    }
  }

  /// Carga los datos del usuario desde la base de datos
  Future<UserModel> _loadUserData(String userId) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos del usuario: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // REGISTRO CON EMAIL
  // ==========================================

  /// Registra un nuevo usuario con email y contraseña
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String nombreCompleto,
    String? telefono,
    String? ciudad,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 1. Crear cuenta en Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      final userId = authResponse.user!.id;

      // 2. Generar código de referido único
      final codigoReferido = _generarCodigoReferido();

      // 3. Crear registro en la tabla users
      final userData = {
        'id': userId,
        'email': email,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
        'ciudad': ciudad,
        'rol': AppConstants.rolBuscador,
        'tipo_cuenta': AppConstants.tipoCuentaGratuita,
        'creditos': AppConstants.creditosInicialesRegistro,
        'creditos_totales_ganados': AppConstants.creditosInicialesRegistro,
        'membresia_activa': false,
        'verificado': false,
        'codigo_referido': codigoReferido,
        'total_solicitudes_publicadas': 0,
        'total_contactos_vistos': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.client.from('users').insert(userData);

      // 4. Crear token de solicitud gratuita
      await _crearTokenSolicitudGratuita(userId);

      // 5. Registrar movimiento de créditos de bienvenida
      await _registrarMovimientoCreditos(
        userId: userId,
        tipo: AppConstants.tipoMovimientoGanancia,
        cantidad: AppConstants.creditosInicialesRegistro,
        saldoAnterior: 0,
        saldoNuevo: AppConstants.creditosInicialesRegistro,
        origen: AppConstants.origenRegistroBienvenida,
        descripcion: 'Créditos de bienvenida por registro',
      );

      // 6. Cargar datos del usuario
      final user = await _loadUserData(userId);
      state = AsyncValue.data(user);

      if (kDebugMode) {
        print('✅ Usuario registrado exitosamente');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al registrar usuario: $e');
      }
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // ==========================================
  // INICIO DE SESIÓN CON EMAIL
  // ==========================================

  /// Inicia sesión con email y contraseña
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Credenciales incorrectas');
      }

      final user = await _loadUserData(authResponse.user!.id);
      state = AsyncValue.data(user);

      if (kDebugMode) {
        print('✅ Inicio de sesión exitoso');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al iniciar sesión: $e');
      }
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // ==========================================
  // INICIO DE SESIÓN CON GOOGLE
  // ==========================================

  /// Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      // 1. Iniciar sesión con Google
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuario canceló el inicio de sesión
        state = const AsyncValue.data(null);
        return;
      }

      // 2. Obtener tokens de autenticación
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('No se pudo obtener el token de Google');
      }

      // 3. Iniciar sesión en Supabase con el token de Google
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('No se pudo iniciar sesión con Google');
      }

      final userId = authResponse.user!.id;

      // 4. Verificar si el usuario ya existe en la base de datos
      final existingUser = await _supabase.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // Usuario nuevo, crear registro
        final codigoReferido = _generarCodigoReferido();

        final userData = {
          'id': userId,
          'email': authResponse.user!.email,
          'nombre_completo': googleUser.displayName,
          'foto_perfil': googleUser.photoUrl,
          'rol': AppConstants.rolBuscador,
          'tipo_cuenta': AppConstants.tipoCuentaGratuita,
          'creditos': AppConstants.creditosInicialesRegistro,
          'creditos_totales_ganados': AppConstants.creditosInicialesRegistro,
          'membresia_activa': false,
          'verificado': true, // Verificado automáticamente con Google
          'codigo_referido': codigoReferido,
          'total_solicitudes_publicadas': 0,
          'total_contactos_vistos': 0,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.client.from('users').insert(userData);

        // Crear token de solicitud gratuita
        await _crearTokenSolicitudGratuita(userId);

        // Registrar movimiento de créditos
        await _registrarMovimientoCreditos(
          userId: userId,
          tipo: AppConstants.tipoMovimientoGanancia,
          cantidad: AppConstants.creditosInicialesRegistro,
          saldoAnterior: 0,
          saldoNuevo: AppConstants.creditosInicialesRegistro,
          origen: AppConstants.origenRegistroBienvenida,
          descripcion: 'Créditos de bienvenida por registro con Google',
        );
      }

      // 5. Cargar datos del usuario
      final user = await _loadUserData(userId);
      state = AsyncValue.data(user);

      if (kDebugMode) {
        print('✅ Inicio de sesión con Google exitoso');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al iniciar sesión con Google: $e');
      }
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // ==========================================
  // CIERRE DE SESIÓN
  // ==========================================

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.signOut();
      state = const AsyncValue.data(null);

      if (kDebugMode) {
        print('✅ Sesión cerrada');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al cerrar sesión: $e');
      }
      state = AsyncValue.error(e, stack);
    }
  }

  // ==========================================
  // ACTUALIZAR DATOS DEL USUARIO
  // ==========================================

  /// Actualiza los datos del usuario
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return;

      await _supabase.client
          .from('users')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);

      // Recargar datos del usuario
      final updatedUser = await _loadUserData(currentUser.id);
      state = AsyncValue.data(updatedUser);

      if (kDebugMode) {
        print('✅ Datos del usuario actualizados');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al actualizar usuario: $e');
      }
      state = AsyncValue.error(e, stack);
    }
  }

  // ==========================================
  // HELPERS PRIVADOS
  // ==========================================

  /// Genera un código de referido único
  String _generarCodigoReferido() {
    final uuid = const Uuid().v4();
    return uuid.substring(0, 8).toUpperCase();
  }

  /// Crea un token de solicitud gratuita para el usuario
  Future<void> _crearTokenSolicitudGratuita(String userId) async {
    try {
      await _supabase.client.from('tokens_especiales').insert({
        'user_id': userId,
        'tipo': AppConstants.tokenSolicitudGratuita,
        'cantidad': 1,
        'usado': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear token gratuito: $e');
      }
    }
  }

  /// Registra un movimiento de créditos
  Future<void> _registrarMovimientoCreditos({
    required String userId,
    required String tipo,
    required int cantidad,
    required int saldoAnterior,
    required int saldoNuevo,
    required String origen,
    String? descripcion,
  }) async {
    try {
      await _supabase.client.from('creditos_movimientos').insert({
        'usuario_id': userId,
        'tipo_movimiento': tipo,
        'cantidad': cantidad,
        'saldo_anterior': saldoAnterior,
        'saldo_nuevo': saldoNuevo,
        'origen': origen,
        'descripcion': descripcion,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar movimiento de créditos: $e');
      }
    }
  }

  /// Refresca los datos del usuario actual
  Future<void> refreshUser() async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return;

      final updatedUser = await _loadUserData(currentUser.id);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
