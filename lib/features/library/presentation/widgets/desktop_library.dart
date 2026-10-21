import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/book.dart';
import '../view_model/library_catalog_options.dart';
import '../view_model/library_state.dart';
import 'category_filter.dart';
import 'continue_reading_card.dart';
import 'featured_book_banner.dart';
import 'library_catalog.dart';
import 'library_catalog_controls.dart';
import 'library_search_toolbar.dart';

class DesktopLibrary extends StatefulWidget {
  const DesktopLibrary({
    required this.state,
    required this.readerName,
    required this.onSearch,
    required this.onFilterByCategory,
    required this.onRefresh,
    required this.onOpenBook,
    required this.onContinue,
    required this.onAbandon,
    super.key,
  });

  final LibraryState state;
  final String readerName;
  final ValueChanged<String> onSearch;
  final ValueChanged<BookCategory?> onFilterByCategory;
  final VoidCallback onRefresh;
  final ValueChanged<Book> onOpenBook;
  final ValueChanged<Book> onContinue;
  final ValueChanged<Book> onAbandon;

  @override
  State<DesktopLibrary> createState() => _DesktopLibraryState();
}

class _DesktopLibraryState extends State<DesktopLibrary> {
  final _searchFocusNode = FocusNode();
  late final _searchController = TextEditingController(
    text: widget.state.query,
  );
  final _scrollController = ScrollController();
  LibrarySortOrder _sortOrder = LibrarySortOrder.title;
  LibraryDisplayMode _displayMode = LibraryDisplayMode.covers;

  @override
  void didUpdateWidget(covariant DesktopLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchController.text != widget.state.query) {
      _searchController.text = widget.state.query;
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final books = _sortOrder.sorted(state.visibleBooks);
    final current = state.currentBook;
    final featured = current ?? state.books.firstOrNull;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _searchFocusNode.requestFocus,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _searchFocusNode.requestFocus,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            LibrarySearchToolbar(
              readerName: widget.readerName,
              searchController: _searchController,
              searchFocus: _searchFocusNode,
              onSearch: widget.onSearch,
              onRefresh: widget.onRefresh,
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (!state.isFiltering && featured != null)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Insets.xxl,
                          Insets.md,
                          Insets.xxl,
                          Insets.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: FeaturedBookBanner(
                            book: featured,
                            onOpen: () => widget.onOpenBook(featured),
                          ),
                        ),
                      ),
                    if (current != null && state.currentProgress != null)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Insets.xxl,
                          0,
                          Insets.xxl,
                          Insets.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ContinueReadingCard(
                            book: current,
                            progress: state.currentProgress!,
                            onContinue: () => widget.onContinue(current),
                            onAbandon: () => widget.onAbandon(current),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Insets.xxl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: LibraryCatalogControls(
                          bookCount: books.length,
                          isFiltering: state.isFiltering,
                          sortOrder: _sortOrder,
                          displayMode: _displayMode,
                          onSortChanged: (order) =>
                              setState(() => _sortOrder = order),
                          onDisplayModeChanged: (mode) =>
                              setState(() => _displayMode = mode),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: Insets.xl),
                    ),
                    SliverToBoxAdapter(
                      child: CategoryFilter(
                        selected: state.category,
                        onSelected: widget.onFilterByCategory,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: Insets.xl),
                    ),
                    LibraryCatalog(
                      books: books,
                      progressByBook: state.progressByBook,
                      displayMode: _displayMode,
                      onOpenBook: widget.onOpenBook,
                      onClearFilters: () {
                        widget.onSearch('');
                        widget.onFilterByCategory(null);
                      },
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(Insets.xxl),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const Divider(),
                            const SizedBox(height: Insets.lg),
                            Text(
                              'Lira · Lectura, Información, Recursos y Aprendizaje',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
