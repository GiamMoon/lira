import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class LibrarySearchToolbar extends StatelessWidget {
  const LibrarySearchToolbar({
    required this.readerName,
    required this.searchController,
    required this.searchFocus,
    required this.onSearch,
    required this.onRefresh,
    super.key,
  });

  final String readerName;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.xxl,
        vertical: Insets.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TU BIBLIOTECA', style: theme.textTheme.labelSmall),
                const SizedBox(height: Insets.xs),
                Text(
                  readerName.isEmpty
                      ? 'Un buen día empieza con una historia.'
                      : 'Tu próxima historia, $readerName.',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: AppLayout.searchWidth,
            child: TextField(
              controller: searchController,
              focusNode: searchFocus,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Busca un título o un autor',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? const Tooltip(
                        message: 'Buscar: Ctrl K o ⌘ K',
                        child: Icon(Icons.keyboard_command_key_rounded),
                      )
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          searchController.clear();
                          onSearch('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: Insets.md),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Actualizar biblioteca',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
