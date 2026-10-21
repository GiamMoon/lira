import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/swipe_navigator.dart';
import '../../../library/domain/book_not_found_exception.dart';
import '../../../settings/presentation/view_model/preferences_view_model.dart';
import '../../domain/entities/activity.dart';
import '../view_model/reader_settings.dart';
import '../view_model/reader_state.dart';
import '../view_model/reader_view_model.dart';
import '../widgets/activity_invitation.dart';
import '../widgets/activity_sheet.dart';
import '../widgets/chapter_content.dart';
import '../widgets/chapter_index.dart';
import '../widgets/leave_book_dialog.dart';
import '../widgets/text_size_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Se reinicia al cerrar el lector; no modifica las respuestas guardadas.
  final Set<String> _dismissedChapters = <String>{};

  bool _chromeVisible = true;

  bool _forward = true;
  bool _changingChapter = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final posicion = _scrollController.position;

    final visible =
        posicion.pixels <= 24 ||
        posicion.userScrollDirection == ScrollDirection.forward;

    if (visible != _chromeVisible) {
      setState(() => _chromeVisible = visible);
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(0);
    if (!_chromeVisible) setState(() => _chromeVisible = true);
  }

  Future<void> _leave() async {
    final shouldLeave = await confirmLeaveBook(context);
    if (!shouldLeave || !mounted) return;

    await ref.read(readerViewModelProvider(widget.bookId).notifier).leaveBook();
    if (mounted) context.backToLibrary();
  }

  Future<void> _openActivity(Activity activity, ReaderState state) async {
    final answer = await showActivitySheet(
      context,
      activity: activity,
      previousAnswer: state.responseFor(activity.id)?.content,
    );
    if (answer == null || !mounted) return;

    await ref
        .read(readerViewModelProvider(widget.bookId).notifier)
        .answerActivity(activity, answer);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Guardado. Es tuyo, nadie más lo ve.'),
          margin: EdgeInsets.all(Insets.lg),
        ),
      );
  }

  void _previous() {
    if (_changingChapter) return;
    setState(() => _forward = false);
    ref.read(readerViewModelProvider(widget.bookId).notifier).previousChapter();
    _scrollToTop();
  }

  Future<void> _next() async {
    final provider = readerViewModelProvider(widget.bookId);
    final state = ref.read(provider).value;
    if (_changingChapter ||
        state == null ||
        !state.hasContent ||
        state.isFinished) {
      return;
    }
    _changingChapter = true;
    try {
      setState(() => _forward = true);
      await ref.read(provider.notifier).nextChapter();
      if (!mounted) return;

      if (ref.read(provider).value?.isFinished ?? false) {
        // Impide regresar al lector después del cierre de la obra.
        context.pushReplacementNamed(
          AppRoute.closing.routeName,
          pathParameters: <String, String>{AppRoute.bookIdParam: widget.bookId},
        );
        return;
      }

      _scrollToTop();
    } finally {
      _changingChapter = false;
    }
  }

  Future<void> _goToChapter(int index) async {
    if (_changingChapter) return;
    final current = ref.read(readerViewModelProvider(widget.bookId)).value;
    if (current == null || index == current.currentIndex) return;
    _changingChapter = true;
    try {
      setState(() => _forward = index > current.currentIndex);
      await ref
          .read(readerViewModelProvider(widget.bookId).notifier)
          .goToChapter(index);
      if (mounted) _scrollToTop();
    } finally {
      _changingChapter = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = readerViewModelProvider(widget.bookId);
    final reader = ref.watch(provider);
    final escala = ref.watch(readerSettingsProvider).scale;
    final fuente = ref.watch(preferencesProvider).font;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            _next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            _previous,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: reader.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.wine),
              ),
              error: (error, _) => _ReaderError(
                message: error is BookNotFoundException
                    ? 'Esta obra ya no está disponible.'
                    : 'No pudimos abrir el texto. Revisa tu conexión.',
                onBack: context.backToLibrary,
              ),
              data: (state) => Row(
                children: [
                  if (MediaQuery.sizeOf(context).width >=
                      AppLayout.desktopBreakpoint)
                    ChapterIndex(state: state, onSelect: _goToChapter),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _ReaderBar(
                          title: state.book.title,
                          fraction: state.fraction,
                          visible:
                              _chromeVisible ||
                              MediaQuery.sizeOf(context).width >=
                                  AppLayout.desktopBreakpoint,
                          onBack: context.backToLibrary,
                          onLeave: _leave,
                          onTextSize: () => showTextSizeSheet(context),
                        ),
                        Expanded(
                          child: !state.hasContent
                              ? const _NoContentYet()
                              : _ChapterView(
                                  state: state,
                                  controller: _scrollController,
                                  scale: escala,
                                  forward: _forward,
                                  textStyle: fuente.style(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                  isDismissed: _dismissedChapters.contains(
                                    state.currentChapter?.id,
                                  ),
                                  onDismissActivities: () => setState(() {
                                    _dismissedChapters.add(
                                      state.currentChapter!.id,
                                    );
                                  }),
                                  onChooseActivity: (activity) =>
                                      _openActivity(activity, state),
                                  onPrevious: _previous,
                                  onNext: _next,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderBar extends StatelessWidget {
  const _ReaderBar({
    required this.title,
    required this.fraction,
    required this.visible,
    required this.onBack,
    required this.onLeave,
    required this.onTextSize,
  });

  final String title;
  final double fraction;
  final bool visible;
  final VoidCallback onBack;
  final VoidCallback onLeave;
  final VoidCallback onTextSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        AnimatedSize(
          duration: Motion.medium,
          curve: Motion.emphasized,
          alignment: Alignment.topCenter,
          child: visible
              ? Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      tooltip: 'Volver',
                    ),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onTextSize,
                      icon: const Icon(Icons.text_fields_rounded, size: 20),
                      tooltip: 'Tamaño del texto',
                    ),
                    PopupMenuButton<void>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      tooltip: 'Más opciones',
                      itemBuilder: (context) => <PopupMenuEntry<void>>[
                        PopupMenuItem<void>(
                          onTap: onTextSize,
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.text_fields_rounded, size: 18),
                              SizedBox(width: Insets.sm),
                              Text('Tamaño del texto'),
                            ],
                          ),
                        ),
                        PopupMenuItem<void>(
                          onTap: onLeave,
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.bookmark_remove_outlined, size: 18),
                              SizedBox(width: Insets.sm),
                              Text('Dejar de leer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
        AnimatedProgressBar(
          value: fraction,
          height: 2,
          background: AppColors.wine.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

class _ChapterView extends StatelessWidget {
  const _ChapterView({
    required this.state,
    required this.controller,
    required this.scale,
    required this.forward,
    required this.textStyle,
    required this.isDismissed,
    required this.onDismissActivities,
    required this.onChooseActivity,
    required this.onPrevious,
    required this.onNext,
  });

  final ReaderState state;
  final ScrollController controller;
  final double scale;
  final bool forward;
  final TextStyle textStyle;
  final bool isDismissed;
  final VoidCallback onDismissActivities;
  final ValueChanged<Activity> onChooseActivity;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chapter = state.currentChapter!;
    final activities = state.currentActivities;
    const width = AppLayout.readingMaxWidth;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SwipeNavigator(
      onNext: onNext,
      onPrevious: state.isFirstChapter ? null : onPrevious,
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : Motion.medium,
        switchInCurve: Motion.emphasized,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: reduceMotion
                  ? Offset.zero
                  : Offset(forward ? 0.06 : -0.06, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: SingleChildScrollView(
          key: ValueKey<String>(chapter.id),
          controller: controller,
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.xl,
            Insets.xl,
            Insets.huge,
          ),
          child: Center(
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CAPÍTULO ${state.currentIndex + 1} DE ${state.chapters.length}',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(chapter.title, style: theme.textTheme.displayMedium),
                  const SizedBox(height: Insets.xl),
                  SelectionArea(
                    child: ChapterContent(
                      blocks: chapter.blocks,
                      scale: scale,
                      style: textStyle,
                    ),
                  ),
                  const SizedBox(height: Insets.xl),
                  if (activities.isNotEmpty && !isDismissed) ...<Widget>[
                    ActivityInvitation(
                      activities: activities,
                      answeredIds: state.responses.keys.toSet(),
                      onChoose: onChooseActivity,
                      onSkip: onDismissActivities,
                    ),
                    const SizedBox(height: Insets.xl),
                  ],
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: Insets.lg,
                    runSpacing: Insets.sm,
                    children: <Widget>[
                      if (!state.isFirstChapter)
                        TextButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Anterior'),
                        ),
                      FilledButton.icon(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(170, 50),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: Icon(
                          state.isLastChapter
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: Text(
                          state.isLastChapter
                              ? 'Terminar el libro'
                              : 'Siguiente capítulo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoContentYet extends StatelessWidget {
  const _NoContentYet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Todavía no cargamos este texto',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              'La obra está en el catálogo, pero sus capítulos aún no. '
              'Pronto podrás leerla aquí.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: Insets.xl),
            FilledButton(onPressed: onBack, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}
