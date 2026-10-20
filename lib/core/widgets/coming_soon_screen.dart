import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'aurora_background.dart';
import 'glass_surface.dart';
import 'content_width.dart';

/// Andamio temporal para pantallas aún no construidas.
///
/// Existe para que el flujo de navegación sea real desde el primer día; cada
/// feature lo irá reemplazando por su propia vista.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = actionLabel;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AuroraBackground(baseColor: theme.colorScheme.surface),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ContentWidth(
                  maxWidth: AppLayout.formMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(Insets.xl),
                    child: GlassSurface(
                      padding: const EdgeInsets.all(Insets.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayMedium,
                          ),
                          const SizedBox(height: Insets.md),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (label != null) ...<Widget>[
                            const SizedBox(height: Insets.xl),
                            FilledButton(
                              onPressed: onAction,
                              child: Text(label),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
