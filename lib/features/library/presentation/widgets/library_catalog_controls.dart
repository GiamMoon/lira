import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../view_model/library_catalog_options.dart';

class LibraryCatalogControls extends StatelessWidget {
  const LibraryCatalogControls({
    required this.bookCount,
    required this.isFiltering,
    required this.sortOrder,
    required this.displayMode,
    required this.onSortChanged,
    required this.onDisplayModeChanged,
    super.key,
  });

  final int bookCount;
  final bool isFiltering;
  final LibrarySortOrder sortOrder;
  final LibraryDisplayMode displayMode;
  final ValueChanged<LibrarySortOrder> onSortChanged;
  final ValueChanged<LibraryDisplayMode> onDisplayModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFiltering
                    ? 'Resultados de tu búsqueda'
                    : '¿Qué vas a leer hoy?',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: Insets.sm),
              Text(
                '$bookCount ${bookCount == 1 ? 'obra' : 'obras'} para descubrir · elige a tu ritmo',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<LibrarySortOrder>(
            value: sortOrder,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: LibrarySortOrder.title,
                child: Text('Título · A–Z'),
              ),
              DropdownMenuItem(
                value: LibrarySortOrder.author,
                child: Text('Autor · A–Z'),
              ),
              DropdownMenuItem(
                value: LibrarySortOrder.duration,
                child: Text('Menor duración'),
              ),
            ],
          ),
        ),
        const SizedBox(width: Insets.lg),
        SegmentedButton<LibraryDisplayMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: LibraryDisplayMode.covers,
              icon: Icon(Icons.grid_view_rounded),
              tooltip: 'Ver portadas',
            ),
            ButtonSegment(
              value: LibraryDisplayMode.list,
              icon: Icon(Icons.view_list_rounded),
              tooltip: 'Ver lista',
            ),
          ],
          selected: {displayMode},
          onSelectionChanged: (selection) =>
              onDisplayModeChanged(selection.first),
        ),
      ],
    );
  }
}
