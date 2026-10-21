import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../view_model/closing_state.dart';
import '../view_model/closing_view_model.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/star_rating.dart';

/// Cierre de una obra: qué sentiste, cuánto te gustó y, si quieres, por qué.
///
/// Es el momento más emocional de Lira y el único sitio donde se le pregunta
/// algo al estudiante. Por eso **todo es opcional** y el botón de salir
/// funciona siempre, con o sin respuestas.
class ClosingScreen extends ConsumerStatefulWidget {
  const ClosingScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends ConsumerState<ClosingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _goToLibrary() {
    // `go` y no `pop`: el lector ya fue sustituido por esta pantalla, así que
    // el camino de vuelta es la biblioteca.
    context.goNamed(AppRoute.library.routeName);
  }

  Future<void> _submit() async {
    await ref.read(closingViewModelProvider(widget.bookId).notifier).submit();
    if (mounted) _goToLibrary();
  }

  @override
  Widget build(BuildContext context) {
    final closing = ref.watch(closingViewModelProvider(widget.bookId));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AuroraBackground(
            baseColor: Theme.of(context).colorScheme.surface,
            intensity: 0.75,
          ),
          SafeArea(
            child: closing.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.wine),
              ),
              error: (_, _) => Center(
                child: FilledButton(
                  onPressed: _goToLibrary,
                  child: const Text('Volver a la biblioteca'),
                ),
              ),
              data: (state) => _ClosingForm(
                state: state,
                entrance: _entrance,
                bookId: widget.bookId,
                onSubmit: _submit,
                onSkip: _goToLibrary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingForm extends ConsumerWidget {
  const _ClosingForm({
    required this.state,
    required this.entrance,
    required this.bookId,
    required this.onSubmit,
    required this.onSkip,
  });

  final ClosingState state;
  final Animation<double> entrance;
  final String bookId;
  final Future<void> Function() onSubmit;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewModel = ref.read(closingViewModelProvider(bookId).notifier);
    final width = math.min(MediaQuery.sizeOf(context).width, 560.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.xxl,
        Insets.xl,
        Insets.xxl,
      ),
      child: Center(
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Staggered(
                animation: entrance,
                begin: 0,
                child: _Celebration(title: state.book.title),
              ),
              const SizedBox(height: Insets.xxxl),
              _Staggered(
                animation: entrance,
                begin: 0.2,
                child: _Section(
                  title: '¿Qué te hizo sentir esta historia?',
                  subtitle: 'Puedes elegir varias.',
                  child: ReactionPicker(
                    selected: state.reactions,
                    onToggle: viewModel.toggleReaction,
                  ),
                ),
              ),
              const SizedBox(height: Insets.xxl),
              _Staggered(
                animation: entrance,
                begin: 0.35,
                child: _Section(
                  title: '¿Cuánto te gustó este libro?',
                  child: StarRating(
                    stars: state.stars,
                    onRate: viewModel.setStars,
                  ),
                ),
              ),
              const SizedBox(height: Insets.xxl),
              _Staggered(
                animation: entrance,
                begin: 0.5,
                child: _Section(
                  title: '¿Quieres contarnos qué opinas?',
                  subtitle: 'Opcional.',
                  child: TextFormField(
                    initialValue: state.comment,
                    onChanged: viewModel.setComment,
                    maxLines: 4,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario…',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      contentPadding: const EdgeInsets.all(Insets.lg),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: const BorderSide(
                          color: AppColors.wine,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Insets.xxxl),
              _Staggered(
                animation: entrance,
                begin: 0.65,
                child: Column(
                  children: <Widget>[
                    FilledButton(
                      onPressed: state.isSaving ? null : onSubmit,
                      child: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.creamLight,
                              ),
                            )
                          : Text(state.hasAnything ? 'Listo' : 'Terminar'),
                    ),
                    const SizedBox(height: Insets.sm),
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      child: const Text('Prefiero no decir nada'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Celebration extends StatelessWidget {
  const _Celebration({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '❦',
          style: TextStyle(
            fontSize: 30,
            color: AppColors.wine.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: Insets.md),
        Text('TERMINASTE', style: theme.textTheme.labelSmall),
        const SizedBox(height: Insets.xs),
        Text(title, style: theme.textTheme.displayMedium),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
        if (caption != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            caption,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
          ),
        ],
        const SizedBox(height: Insets.lg),
        child,
      ],
    );
  }
}

/// Aparición escalonada: cada bloque entra un poco después que el anterior,
/// para que la pantalla se lea de arriba abajo en vez de golpear entera.
class _Staggered extends StatelessWidget {
  const _Staggered({
    required this.animation,
    required this.begin,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        begin,
        (begin + 0.35).clamp(0.0, 1.0),
        curve: Motion.enter,
      ),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, inner) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - curved.value)),
          child: inner,
        ),
      ),
      child: child,
    );
  }
}
