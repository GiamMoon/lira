import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../domain/entities/activity.dart';
import 'activity_invitation.dart';

/// Hoja para responder una dinámica.
///
/// Devuelve el texto escrito, o `null` si el estudiante prefiere dejarlo.
/// No hay validación, ni longitud mínima, ni corrección: esa es justamente la
/// idea.
Future<String?> showActivitySheet(
  BuildContext context, {
  required Activity activity,
  String? previousAnswer,
}) {
  return showAdaptiveSheet<String>(
    context: context,
    builder: (sheetContext) =>
        _ActivitySheet(activity: activity, previousAnswer: previousAnswer),
  );
}

class _ActivitySheet extends StatefulWidget {
  const _ActivitySheet({required this.activity, this.previousAnswer});

  final Activity activity;
  final String? previousAnswer;

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.previousAnswer ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = widget.activity;
    final accent = ActivityInvitation.colorOf(activity.kind);
    final hint = activity.hint;

    return Padding(
      // Sube con el teclado: escribir no debería tapar lo que escribes.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Radii.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      activity.kind.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: Insets.sm),
                    Text(
                      activity.kind.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.lg),
                Text(
                  activity.prompt,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 21),
                ),
                if (hint != null) ...<Widget>[
                  const SizedBox(height: Insets.sm),
                  Text(
                    hint,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                ],
                const SizedBox(height: Insets.xl),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  minLines: 4,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Escribe lo que quieras…',
                    filled: true,
                    fillColor: accent.withValues(alpha: 0.08),
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
                      borderSide: BorderSide(color: accent, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: Insets.lg),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    final text = _controller.text.trim();
                    Navigator.of(context).pop(text.isEmpty ? null : text);
                  },
                  child: const Text('Guardar'),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    child: const Text('Ahora no'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
