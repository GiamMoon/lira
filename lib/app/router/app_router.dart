import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/coming_soon_screen.dart';
import '../../features/closing/presentation/view/closing_screen.dart';
import '../../features/creations/presentation/view/creations_screen.dart';
import '../../features/library/presentation/view/library_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_screen.dart';
import '../../features/reader/presentation/view/reader_screen.dart';
import '../../features/settings/presentation/view/settings_screen.dart';
import '../../features/splash/presentation/view/splash_screen.dart';
import 'app_route.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: kIsWeb ? AppRoute.library.path : AppRoute.splash.path,
    errorBuilder: (context, _) => ComingSoonScreen(
      title: 'No encontramos esta página',
      subtitle: 'Puedes volver a la biblioteca y elegir una obra.',
      actionLabel: 'Ir a la biblioteca',
      onAction: () => context.goNamed(AppRoute.library.routeName),
    ),
    routes: <RouteBase>[
      _fadeRoute(AppRoute.splash, (_, _) => const SplashScreen()),
      _fadeRoute(AppRoute.onboarding, (_, _) => const OnboardingScreen()),
      _fadeRoute(AppRoute.library, (_, _) => const LibraryScreen()),
      _fadeRoute(
        AppRoute.reader,
        (_, state) =>
            ReaderScreen(bookId: state.pathParameters[AppRoute.bookIdParam]!),
      ),
      _fadeRoute(
        AppRoute.closing,
        (_, state) =>
            ClosingScreen(bookId: state.pathParameters[AppRoute.bookIdParam]!),
      ),
      _fadeRoute(AppRoute.creations, (_, _) => const CreationsScreen()),
      _fadeRoute(AppRoute.settings, (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Todas las transiciones de nivel raíz son fundidos: mantienen la calma
/// editorial y encadenan bien con la salida del splash.
GoRoute _fadeRoute(
  AppRoute route,
  Widget Function(BuildContext, GoRouterState) builder,
) {
  return GoRoute(
    path: route.path,
    name: route.routeName,
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Motion.slow,
      reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Motion.medium,
      child: builder(context, state),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Motion.enter),
        child: child,
      ),
    ),
  );
}
