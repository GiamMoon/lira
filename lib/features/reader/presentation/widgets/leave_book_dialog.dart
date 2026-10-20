import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// Confirmación al dejar un libro.
///
/// El texto importa: promete explícitamente que el progreso se guarda. Dejar
/// una obra no puede sentirse como perder lo leído, o nadie se atreverá a
/// empezar otra.
Future<bool> confirmLeaveBook(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return AlertDialog(
        // Colores y forma salen del tema: fijarlos a mano dejaba el diálogo en
        // crema con texto claro cuando el móvil está en modo oscuro.
        title: const Text('¿Quieres dejar este libro?'),
        content: const Text(
          'Tu progreso se guardará para que puedas volver cuando quieras.',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          Insets.lg,
          0,
          Insets.lg,
          Insets.lg,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('Continuar leyendo'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
            child: const Text('Guardar y salir'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
