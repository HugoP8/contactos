import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/supabase_service.dart';
import 'core/services/admob_service.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación de pantalla (solo portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado y navegación
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Inicializar Hive para almacenamiento local
    await Hive.initFlutter();
    print('✅ Hive inicializado');

    // Inicializar Supabase
    await SupabaseService.initialize();

    // Inicializar AdMob
    await AdMobService.initialize();

    // TODO: Inicializar Firebase cuando se configure
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    print('✅ Todos los servicios inicializados correctamente');
  } catch (e) {
    print('❌ Error durante la inicialización: $e');
  }

  // Ejecutar la aplicación con Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CONTACTOS',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
