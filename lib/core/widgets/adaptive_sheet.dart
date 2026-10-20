import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// En móvil se alcanza desde abajo; con espacio se abre junto al contenido.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final theme = Theme.of(context);
  if (MediaQuery.sizeOf(context).width >= AppLayout.expandedBreakpoint) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        constraints: const BoxConstraints(maxWidth: AppLayout.modalMaxWidth),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(child: builder(context)),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: AppLayout.modalMaxWidth),
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SingleChildScrollView(child: builder(context)),
  );
}
