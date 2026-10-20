import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/app_tokens.dart';
import '../features/settings/presentation/view_model/preferences_view_model.dart';
import 'router/app_router.dart';

/// Raíz de la aplicación: tema, router y nada más.
class LiraApp extends ConsumerWidget {
  const LiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Lira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // El estudiante manda sobre el sistema: quien lee de noche en la
      // cama quiere oscuro aunque el movil siga en claro.
      themeMode: ref.watch(preferencesProvider).themeMode,
      // Cambiar de claro a oscuro no debe ser un fogonazo.
      themeAnimationDuration: Motion.medium,
      themeAnimationCurve: Motion.emphasized,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
