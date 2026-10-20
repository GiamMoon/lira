import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../domain/start_destination.dart';
import '../view_model/splash_state.dart';
import '../view_model/splash_view_model.dart';
import '../widgets/acronym_tagline.dart';
import '../widgets/brand_progress.dart';
import '../widgets/lira_logo_reveal.dart';

/// Primera pantalla de Lira.
///
/// Es un momento de marca, no una pantalla de espera: el logo entra, el
/// acrónimo se despliega y la app sale por fundido hacia el destino que
/// resolvió el [SplashViewModel].
///
/// Siempre se muestra en paleta clara (crema), incluso si el dispositivo está
/// en modo oscuro: la identidad de Lira no cambia de color.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: Motion.splash,
  )..forward();

  late final AnimationController _outro = AnimationController(
    vsync: this,
    duration: Motion.medium,
  );

  bool _isLeaving = false;

  @override
  void dispose() {
    _intro.dispose();
    _outro.dispose();
    super.dispose();
  }

  Future<void> _leaveTo(StartDestination destination) async {
    if (_isLeaving) return;
    _isLeaving = true;

    await _outro.forward();
    if (!mounted) return;
    context.goNamed(destination.route.routeName);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashViewModelProvider, (previous, next) {
      final destination = next.destination;
      if (next.phase == SplashPhase.ready && destination != null) {
        unawaited(_leaveTo(destination));
      }
    });

    final state = ref.watch(splashViewModelProvider);
    final logoWidth = math.min(
      MediaQuery.sizeOf(context).width * 0.76,
      360.0,
    );

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const AuroraBackground(),
            AnimatedBuilder(
              animation: _outro,
              builder: (context, child) => Opacity(
                opacity: 1 - _outro.value,
                child: Transform.scale(
                  scale: 1 + 0.06 * _outro.value,
                  child: child,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
                  child: Column(
                    children: <Widget>[
                      const Spacer(flex: 3),
                      SizedBox(
                        width: logoWidth,
                        child: LiraLogoReveal(intro: _intro),
                      ),
                      const SizedBox(height: Insets.xl),
                      AcronymTagline(intro: _intro),
                      const Spacer(flex: 2),
                      _SplashFooter(
                        intro: _intro,
                        state: state,
                        onRetry: () => ref
                            .read(splashViewModelProvider.notifier)
                            .retry(),
                      ),
                      const SizedBox(height: Insets.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pie del splash: la hebra de carga o, si el arranque falló, la salida de
/// emergencia. Nunca las dos cosas.
class _SplashFooter extends StatelessWidget {
  const _SplashFooter({
    required this.intro,
    required this.state,
    required this.onRetry,
  });

  final Animation<double> intro;
  final SplashState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: Motion.medium,
      switchInCurve: Motion.enter,
      child: state.hasFailed
          ? GlassSurface(
              key: const ValueKey<String>('splash-error'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    state.errorMessage ?? 'Algo salió mal.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Insets.lg),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Column(
              key: const ValueKey<String>('splash-loading'),
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BrandProgress(intro: intro),
                const SizedBox(height: Insets.xl),
                AnimatedBuilder(
                  animation: intro,
                  builder: (context, child) => Opacity(
                    opacity: const Interval(
                      0.7,
                      1,
                      curve: Motion.enter,
                    ).transform(intro.value),
                    child: child,
                  ),
                  child: Text(
                    'Lee. Crea. Siente.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.wine.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Traducción de intención de dominio a ruta. Vive en presentación porque es
/// la única capa que conoce el router.
extension on StartDestination {
  AppRoute get route => switch (this) {
    StartDestination.onboarding => AppRoute.onboarding,
    StartDestination.library => AppRoute.library,
  };
}
