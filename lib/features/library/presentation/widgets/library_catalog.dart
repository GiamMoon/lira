import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/hover_lift.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import '../view_model/library_catalog_options.dart';
import 'book_list_row.dart';
import 'book_tile.dart';

class LibraryCatalog extends StatelessWidget {
  const LibraryCatalog({
    required this.books,
    required this.progressByBook,
    required this.displayMode,
    required this.onOpenBook,
    required this.onClearFilters,
    super.key,
  });

  final List<Book> books;
  final Map<String, ReadingProgress> progressByBook;
  final LibraryDisplayMode displayMode;
  final ValueChanged<Book> onOpenBook;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (books.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: AppLayout.emptyIconSize,
              ),
              const SizedBox(height: Insets.lg),
              Text(
                'No encontramos esa historia',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: Insets.sm),
              const Text('Prueba con otro título, autor o categoría.'),
              const SizedBox(height: Insets.lg),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Ver toda la biblioteca'),
              ),
            ],
          ),
        ),
      );
    }
    if (displayMode == LibraryDisplayMode.list) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
        sliver: SliverList.separated(
          itemCount: books.length,
          separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
          itemBuilder: (context, index) => BookListRow(
            book: books[index],
            progress: progressByBook[books[index].id],
            onTap: () => onOpenBook(books[index]),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final columns =
              (constraints.crossAxisExtent / AppLayout.desktopCardWidth)
                  .floor()
                  .clamp(2, 7);
          final width =
              (constraints.crossAxisExtent - Insets.xl * (columns - 1)) /
              columns;
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: Insets.xl,
              mainAxisSpacing: Insets.xxl,
              mainAxisExtent:
                  width * 1.5 +
                  AppLayout.bookDetailsHeight *
                      MediaQuery.textScalerOf(context).scale(1),
            ),
            itemCount: books.length,
            itemBuilder: (context, index) => HoverLift(
              child: BookTile(
                book: books[index],
                progress: progressByBook[books[index].id],
                onTap: () => onOpenBook(books[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
