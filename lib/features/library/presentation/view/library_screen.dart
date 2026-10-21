import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/widgets/content_width.dart';
import '../../../../core/widgets/desktop_frame.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../settings/presentation/view_model/preferences_view_model.dart';
import '../../domain/entities/book.dart';
import '../view_model/library_state.dart';
import '../view_model/library_view_model.dart';
import '../widgets/book_sheet.dart';
import '../widgets/book_tile.dart';
import '../widgets/category_filter.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/desktop_library.dart';
import '../widgets/library_header.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryViewModelProvider);

    return DesktopFrame(
      selected: AppRoute.library,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (MediaQuery.sizeOf(context).width < AppLayout.desktopBreakpoint)
              AuroraBackground(
                baseColor: Theme.of(context).colorScheme.surface,
                intensity: 0.5,
              ),
            SafeArea(
              bottom: false,
              child: ContentWidth(
                maxWidth:
                    MediaQuery.sizeOf(context).width >=
                        AppLayout.desktopBreakpoint
                    ? AppLayout.desktopMaxWidth
                    : AppLayout.libraryMaxWidth,
                child: library.when(
                  loading: () => const _LibrarySkeleton(),
                  error: (error, _) => _LibraryError(
                    onRetry: () => ref.invalidate(libraryViewModelProvider),
                  ),
                  data: (state) => _LibraryContent(state: state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryContent extends ConsumerWidget {
  const _LibraryContent({required this.state});

  final LibraryState state;

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          margin: const EdgeInsets.all(Insets.lg),
        ),
      );
  }

  /// Recarga el progreso al volver del lector.
  Future<void> _openReader(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    await context.pushNamed(
      AppRoute.reader.routeName,
      pathParameters: <String, String>{AppRoute.bookIdParam: book.id},
    );
    await ref.read(libraryViewModelProvider.notifier).refresh();
  }

  Future<void> _jumpIn(BuildContext context, WidgetRef ref, Book book) async {
    await ref.read(libraryViewModelProvider.notifier).startReading(book);
    if (context.mounted) await _openReader(context, ref, book);
  }

  Future<void> _openBook(BuildContext context, WidgetRef ref, Book book) async {
    final viewModel = ref.read(libraryViewModelProvider.notifier);

    await showBookSheet(
      context,
      book: book,
      progress: state.progressFor(book.id),
      onStart: () async {
        await viewModel.startReading(book);
        if (context.mounted) await _openReader(context, ref, book);
      },
      onAbandon: () async {
        await viewModel.abandon(book);
        if (context.mounted) {
          _notify(context, 'Listo. Tu avance queda guardado por si vuelves.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewModel = ref.read(libraryViewModelProvider.notifier);
    final current = state.currentBook;
    final currentProgress = state.currentProgress;
    final books = state.visibleBooks;

    if (MediaQuery.sizeOf(context).width >= AppLayout.desktopBreakpoint) {
      return DesktopLibrary(
        state: state,
        readerName: ref.watch(preferencesProvider).name,
        onSearch: viewModel.search,
        onFilterByCategory: viewModel.filterByCategory,
        onRefresh: viewModel.refresh,
        onOpenBook: (book) => _openBook(context, ref, book),
        onContinue: (book) => _openReader(context, ref, book),
        onAbandon: (book) async {
          await viewModel.abandon(book);
          if (context.mounted) {
            _notify(context, 'Tu avance queda guardado por si vuelves.');
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: AppColors.wine,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: StaggeredEntrance(
              child: LibraryHeader(
                name: ref.watch(preferencesProvider).name,
                onQueryChanged: viewModel.search,
                onRefresh: viewModel.refresh,
                onOpenCreations: () =>
                    context.pushNamed(AppRoute.creations.routeName),
                onOpenSettings: () =>
                    context.pushNamed(AppRoute.settings.routeName),
              ),
            ),
          ),
          if (current != null && currentProgress != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.xl,
                Insets.xl,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: ContinueReadingCard(
                  book: current,
                  progress: currentProgress,
                  onContinue: () async => _openReader(context, ref, current),
                  onAbandon: () async {
                    await viewModel.abandon(current);
                    if (context.mounted) {
                      _notify(
                        context,
                        'Listo. Tu avance queda guardado por si vuelves.',
                      );
                    }
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Insets.xl)),
          SliverToBoxAdapter(
            child: StaggeredEntrance(
              index: 1,
              child: CategoryFilter(
                selected: state.category,
                onSelected: viewModel.filterByCategory,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              Insets.xl,
              Insets.xl,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      state.isFiltering ? 'Resultados' : 'Toda la biblioteca',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${books.length} obras',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          if (books.isEmpty)
            const SliverToBoxAdapter(child: _EmptyResults())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.lg,
                Insets.xl,
                Insets.huge,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      (constraints.crossAxisExtent / AppLayout.bookMaxWidth)
                          .ceil()
                          .clamp(1, 8);
                  final coverWidth =
                      (constraints.crossAxisExtent -
                          Insets.lg * (columns - 1)) /
                      columns;
                  final textScale = MediaQuery.textScalerOf(context).scale(1);
                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: Insets.lg,
                      mainAxisSpacing: Insets.xl,
                      mainAxisExtent:
                          coverWidth * 1.5 +
                          AppLayout.bookDetailsHeight * textScale,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return StaggeredEntrance(
                        key: ValueKey<String>(book.id),
                        index: index + 2,
                        child: BookTile(
                          book: book,
                          progress: state.progressFor(book.id),
                          onTap: () => _openBook(context, ref, book),
                          onLongPress: () => _jumpIn(context, ref, book),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.xxl,
        Insets.huge,
        Insets.xxl,
        Insets.huge,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Nada por aquí',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Insets.sm),
          Text(
            'Ningún título coincide con lo que buscas. Prueba con otra '
            'categoría o con el nombre del autor.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.onRetry});

  final VoidCallback onRetry;

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
              'No pudimos abrir la biblioteca',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              'Revisa tu conexión e inténtalo otra vez.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Insets.xl),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _LibrarySkeleton extends StatefulWidget {
  const _LibrarySkeleton();

  @override
  State<_LibrarySkeleton> createState() => _LibrarySkeletonState();
}

class _LibrarySkeletonState extends State<_LibrarySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.8).animate(_pulse),
      child: Padding(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SkeletonBox(width: 180, height: 28),
            const SizedBox(height: Insets.lg),
            const _SkeletonBox(height: 46, radius: Radii.pill),
            const SizedBox(height: Insets.xl),
            const _SkeletonBox(height: 116, radius: Radii.lg),
            const SizedBox(height: Insets.xl),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 210,
                  crossAxisSpacing: Insets.lg,
                  mainAxisSpacing: Insets.xl,
                  childAspectRatio: 0.44,
                ),
                itemCount: 4,
                itemBuilder: (context, index) =>
                    const _SkeletonBox(radius: Radii.md),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, this.height, this.radius = Radii.sm});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.wine.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
