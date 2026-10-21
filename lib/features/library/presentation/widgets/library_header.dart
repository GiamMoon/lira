import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({
    required this.onQueryChanged,
    required this.onOpenCreations,
    required this.onOpenSettings,
    required this.onRefresh,
    this.name = '',
    super.key,
  });

  final ValueChanged<String> onQueryChanged;
  final VoidCallback onOpenCreations;
  final VoidCallback onOpenSettings;
  final VoidCallback onRefresh;

  final String name;

  static String _greetingFor(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.xl, Insets.xl, Insets.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name.isEmpty
                      ? _greetingFor(DateTime.now().hour)
                      : '${_greetingFor(DateTime.now().hour)}, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Actualizar biblioteca',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onOpenCreations,
                icon: const Icon(Icons.edit_note_rounded, size: 22),
                tooltip: 'Tu rincón',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.tune_rounded, size: 20),
                tooltip: 'Ajustes',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            '¿Qué vas a leer hoy?',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 30),
          ),
          if (!AppConfig.hasRemoteBackend) ...<Widget>[
            const SizedBox(height: Insets.md),
            const _AvisoCatalogoLocal(),
          ],
          const SizedBox(height: Insets.lg),
          TextField(
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Busca un título o un autor',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              prefixIconColor: AppColors.inkMuted,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.75,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: Insets.md,
                horizontal: Insets.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
                borderSide: const BorderSide(color: AppColors.wine, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoCatalogoLocal extends StatelessWidget {
  const _AvisoCatalogoLocal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: Insets.sm),
          Flexible(
            child: Text(
              'Catálogo de muestra — arranca con --dart-define-from-file=env.json',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
