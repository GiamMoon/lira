import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/lira_app.dart';
import 'core/config/app_config.dart';
import 'core/di/core_providers.dart';
import 'core/network/supabase_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  // La URL también refleja las pantallas abiertas con pushNamed: se pueden
  // recargar, compartir y abrir en otra pestaña conservando el destino.
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Única raíz de composición: las dependencias asíncronas se resuelven aquí
  // y se inyectan al árbol ya listas.
  final preferences = await SharedPreferences.getInstance();

  // Sin credenciales, Lira corre igual contra el catálogo semilla local.
  if (AppConfig.hasRemoteBackend) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
    );
    // Sesión anónima: sin ella las tablas del estudiante son inalcanzables
    // (RLS contra auth.uid()) y el progreso se quedaría sólo en el móvil.
    await asegurarSesion();
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const LiraApp(),
    ),
  );
}
