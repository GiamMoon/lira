import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

/// Bienvenida de primera ejecución.
///
/// Andamio por ahora: lo único real es que marca el flag de onboarding, para
/// que el arranque ya se comporte como se comportará en producción.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComingSoonScreen(
      title: 'Hola, soy Lira',
      subtitle:
          'Te voy a acompañar con libros, ideas y actividades que no se '
          'parecen en nada a una tarea.',
      actionLabel: 'Entrar',
      onAction: () async {
        await ref
            .read(keyValueStoreProvider)
            .writeBool(StorageKeys.onboardingCompleted, value: true);
        if (context.mounted) context.goNamed(AppRoute.library.routeName);
      },
    );
  }
}
