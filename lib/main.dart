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

  if (AppConfig.requireRemoteBackend && !AppConfig.hasRemoteBackend) {
    throw StateError('Falta la configuración del catálogo de Lira.');
  }

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;

  final preferences = await SharedPreferences.getInstance();

  if (AppConfig.hasRemoteBackend) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
    );
    await asegurarSesion();
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const LiraApp(),
    ),
  );
}
