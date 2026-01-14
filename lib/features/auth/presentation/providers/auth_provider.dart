import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Expone el cliente de Supabase para uso en otras partes de la app
  SupabaseClient get supabase => _supabase.client;

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
      // Reintentar hasta 3 veces (ahora insertamos directamente)
      for (int i = 0; i < 3; i++) {
        try {
          final response = await _supabase.client
              .from('users')
              .select()
              .eq('id', userId)
              .maybeSingle();

          if (response != null) {
            if (kDebugMode) {
              print('✅ Usuario cargado exitosamente');
            }
            return UserModel.fromJson(response);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error al cargar usuario (intento ${i + 1}): $e');
          }
        }

        // Esperar un poco antes de reintentar
        await Future.delayed(const Duration(milliseconds: 500));
      }

      throw Exception('❌ No se pudo cargar el usuario desde la base de datos');
    } catch (e) {
      if (kDebugMode) {
        print('💥 Error fatal: $e');
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
    String? codigoReferido,
  }) async {
    state = const AsyncValue.loading();
    String? createdUserId;

    try {
      // 1. Crear cuenta en Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      createdUserId = authResponse.user!.id;

      // 2. El trigger ya creó el usuario - esperamos y verificamos
      if (kDebugMode) {
        print('⏳ Esperando a que el trigger termine...');
      }
      await Future.delayed(const Duration(seconds: 2));

      // 3. VERIFICAR que el usuario fue creado en la BD
      if (kDebugMode) {
        print('🔍 Verificando creación de usuario en BD...');
      }

      final userCheck = await _supabase.client
          .from('users')
          .select()
          .eq('id', createdUserId)
          .maybeSingle();

      if (userCheck == null) {
        // El trigger falló - el usuario no fue creado en la BD
        throw Exception(
          'Error al crear perfil de usuario. '
          'Por favor, intenta con otro email o contacta soporte.',
        );
      }

      if (kDebugMode) {
        print('✅ Usuario creado en BD correctamente');
      }

      // 4. Procesar código de referido SI fue proporcionado
      if (codigoReferido != null && codigoReferido.trim().isNotEmpty) {
        try {
          if (kDebugMode) {
            print('🎁 Procesando código de referido: $codigoReferido');
          }

          await _supabase.client.rpc('procesar_referido', params: {
            'nuevo_user_id': createdUserId,
            'codigo_ref': codigoReferido.trim().toUpperCase(),
          });

          if (kDebugMode) {
            print('✅ Código de referido procesado');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error procesando código de referido: $e');
          }
          // No fallar el registro si el código es inválido
        }
      }

      // 5. Crear token de solicitud gratuita
      await _crearTokenSolicitudGratuita(createdUserId);

      // 6. Registrar movimiento de créditos de bienvenida
      await _registrarMovimientoCreditos(
        userId: createdUserId,
        tipo: AppConstants.tipoMovimientoGanancia,
        cantidad: AppConstants.creditosInicialesRegistro,
        saldoAnterior: 0,
        saldoNuevo: AppConstants.creditosInicialesRegistro,
        origen: AppConstants.origenRegistroBienvenida,
        descripcion: 'Créditos de bienvenida por registro',
      );

      // 7. Cargar datos del usuario
      final user = await _loadUserData(createdUserId);
      state = AsyncValue.data(user);

      if (kDebugMode) {
        print('✅ Usuario registrado exitosamente');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error al registrar usuario: $e');

        // Informar si el email puede estar bloqueado
        if (createdUserId != null) {
          print('⚠️ El email $email puede estar bloqueado en Supabase Auth');
          print('💡 Solución: Eliminar usuario manualmente desde el dashboard de Supabase');
        }
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
        // Usuario nuevo - el trigger ya lo creó
        if (kDebugMode) {
          print('⏳ Esperando a que el trigger termine...');
        }
        await Future.delayed(const Duration(seconds: 2));

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
      // Intentar Google sign out (puede fallar si no hay sesión de Google)
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
          if (kDebugMode) {
            print('✅ Google Sign Out exitoso');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Google Sign Out falló (puede ser normal): $e');
        }
        // No lanzar error, continuar con Supabase logout
      }

      // Siempre hacer logout de Supabase
      await _supabase.auth.signOut();

      // Solo actualizar estado si todo salió bien
      state = const AsyncValue.data(null);

      if (kDebugMode) {
        print('✅ Sesión cerrada correctamente');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error crítico al cerrar sesión: $e');
      }

      // Forzar estado null aunque haya error
      // Esto permite que la navegación continúe
      state = const AsyncValue.data(null);

      // No hacer rethrow - dejar que la navegación continúe
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

  /// Actualiza la contraseña del usuario
  Future<void> updatePassword(String newPassword) async {
    try {
      if (newPassword.isEmpty || newPassword.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      // Actualizar contraseña en Supabase Auth
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (kDebugMode) {
        print('✅ Contraseña actualizada correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar contraseña: $e');
      }
      rethrow;
    }
  }

  /// Reenvía el email de verificación al usuario
  Future<void> resendVerificationEmail() async {
    try {
      final currentUser = _supabase.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Supabase no tiene un método directo para reenviar email de verificación
      // pero podemos usar resend para OTP
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser.email!,
      );

      if (kDebugMode) {
        print('✅ Email de verificación reenviado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al reenviar email de verificación: $e');
      }
      rethrow;
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
      await _supabase.client.from('movimientos_creditos').insert({
        'user_id': userId,
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
