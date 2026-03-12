import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contacto_model.dart';
import '../../data/repositories/contactos_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provider del repositorio
final contactosRepositoryProvider = Provider<ContactosRepository>((ref) {
  return ContactosRepository();
});

/// Estado de la lista de contactos
class ContactosState {
  final List<ContactoModel> contactos;
  final bool isLoading;
  final String? error;
  final String? busqueda;

  const ContactosState({
    this.contactos = const [],
    this.isLoading = false,
    this.error,
    this.busqueda,
  });

  ContactosState copyWith({
    List<ContactoModel>? contactos,
    bool? isLoading,
    String? error,
    String? busqueda,
  }) {
    return ContactosState(
      contactos: contactos ?? this.contactos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      busqueda: busqueda ?? this.busqueda,
    );
  }

  /// Contactos filtrados por búsqueda
  List<ContactoModel> get contactosFiltrados {
    if (busqueda == null || busqueda!.isEmpty) return contactos;

    return contactos.where((c) {
      final query = busqueda!.toLowerCase();
      return (c.profesionalNombre?.toLowerCase().contains(query) ?? false) ||
          (c.profesionalCategoria?.toLowerCase().contains(query) ?? false) ||
          (c.notas?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Contactos favoritos
  List<ContactoModel> get contactosFavoritos {
    return contactos.where((c) => c.favorito).toList();
  }

  /// Total de contactos
  int get total => contactos.length;

  /// Total de favoritos
  int get totalFavoritos => contactosFavoritos.length;
}

/// Provider principal de contactos
final misContactosProvider =
    StateNotifierProvider<MisContactosNotifier, ContactosState>((ref) {
  return MisContactosNotifier(ref);
});

/// Notifier para gestionar los contactos
class MisContactosNotifier extends StateNotifier<ContactosState> {
  MisContactosNotifier(this.ref) : super(const ContactosState());

  final Ref ref;

  /// Inicializa cargando los contactos del usuario
  Future<void> inicializar(String userId) async {
    await cargarContactos(userId);
  }

  /// Carga los contactos del usuario
  Future<void> cargarContactos(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(contactosRepositoryProvider);
      final contactos = await repository.obtenerMisContactos(userId);

      state = state.copyWith(
        contactos: contactos,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar contactos: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar tus contactos',
      );
    }
  }

  /// Agrega un profesional a los contactos
  Future<bool> agregarContacto({
    required String profesionalId,
    String? notas,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) return false;

    try {
      final repository = ref.read(contactosRepositoryProvider);
      final contacto = await repository.agregarContacto(
        userId: user.id,
        profesionalId: profesionalId,
        notas: notas,
      );

      if (contacto != null) {
        state = state.copyWith(
          contactos: [contacto, ...state.contactos],
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar contacto: $e');
      }
      return false;
    }
  }

  /// Elimina un contacto
  Future<bool> eliminarContacto(String contactoId) async {
    try {
      final repository = ref.read(contactosRepositoryProvider);
      final success = await repository.eliminarContacto(contactoId);

      if (success) {
        state = state.copyWith(
          contactos: state.contactos.where((c) => c.id != contactoId).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar contacto: $e');
      }
      return false;
    }
  }

  /// Toggle favorito de un contacto
  Future<bool> toggleFavorito(String contactoId) async {
    final contacto = state.contactos.firstWhere((c) => c.id == contactoId);

    try {
      final repository = ref.read(contactosRepositoryProvider);
      final success =
          await repository.toggleFavorito(contactoId, contacto.favorito);

      if (success) {
        state = state.copyWith(
          contactos: state.contactos.map((c) {
            if (c.id == contactoId) {
              return c.copyWith(favorito: !c.favorito);
            }
            return c;
          }).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar favorito: $e');
      }
      return false;
    }
  }

  /// Actualiza las notas de un contacto
  Future<bool> actualizarNotas({
    required String contactoId,
    required String notas,
  }) async {
    try {
      final repository = ref.read(contactosRepositoryProvider);
      final success = await repository.actualizarNotas(
        contactoId: contactoId,
        notas: notas,
      );

      if (success) {
        state = state.copyWith(
          contactos: state.contactos.map((c) {
            if (c.id == contactoId) {
              return c.copyWith(notas: notas);
            }
            return c;
          }).toList(),
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar notas: $e');
      }
      return false;
    }
  }

  /// Buscar contactos
  void buscar(String query) {
    state = state.copyWith(busqueda: query);
  }

  /// Limpiar búsqueda
  void limpiarBusqueda() {
    state = state.copyWith(busqueda: null);
  }

  /// Refrescar lista
  Future<void> refresh() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      await cargarContactos(user.id);
    }
  }
}

/// Provider para verificar si un profesional es contacto
final esContactoProvider =
    FutureProvider.family<bool, String>((ref, profesionalId) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return false;

  final repository = ref.read(contactosRepositoryProvider);
  return await repository.esContacto(
    userId: user.id,
    profesionalId: profesionalId,
  );
});
