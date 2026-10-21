import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_route.dart';
import '../theme/app_tokens.dart';

class DesktopFrame extends StatelessWidget {
  const DesktopFrame({required this.selected, required this.child, super.key});

  final AppRoute selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < AppLayout.desktopBreakpoint) {
      return child;
    }
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: AppLayout.sidebarWidth,
          child: Material(
            color: theme.colorScheme.surface,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.dividerColor)),
                ),
                padding: const EdgeInsets.all(Insets.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Insets.md),
                        Text('Lira', style: theme.textTheme.displayMedium),
                      ],
                    ),
                    const SizedBox(height: Insets.sm),
                    Text(
                      'UN LUGAR PARA LEER',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: Insets.xxxl),
                    _destination(
                      context,
                      AppRoute.library,
                      Icons.grid_view_rounded,
                      'Biblioteca',
                    ),
                    const SizedBox(height: Insets.sm),
                    _destination(
                      context,
                      AppRoute.creations,
                      Icons.edit_note_rounded,
                      'Tu rincón',
                    ),
                    const SizedBox(height: Insets.sm),
                    _destination(
                      context,
                      AppRoute.settings,
                      Icons.tune_rounded,
                      'Ajustes',
                    ),
                    const Spacer(),
                    const Divider(),
                    const SizedBox(height: Insets.lg),
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Insets.md),
                    Text('A tu ritmo.', style: theme.textTheme.titleMedium),
                    const SizedBox(height: Insets.sm),
                    Text(
                      'Un capítulo, una idea, un mundo por descubrir.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Insets.xl),
                    Text(
                      'LEE · CREA · SIENTE',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _destination(
    BuildContext context,
    AppRoute route,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final active = selected == route;
    return Semantics(
      selected: active,
      child: ListTile(
        selected: active,
        selectedTileColor: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.45,
        ),
        selectedColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.md),
        leading: Icon(icon),
        title: Text(label, style: theme.textTheme.labelLarge),
        onTap: active ? null : () => context.goNamed(route.routeName),
      ),
    );
  }
}
