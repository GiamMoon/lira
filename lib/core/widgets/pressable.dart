import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// Envoltorio táctil de Lira: el contenido se hunde ligeramente al pulsarlo y
/// devuelve un pulso háptico.
///
/// Es un detalle diminuto que hace que la app se sienta "viva" en la mano; se
/// centraliza aquí para que toda la app responda igual al tacto.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Mantener pulsado. Devuelve un háptico más firme que el del toque,
  /// porque es una acción distinta y tiene que notarse distinta.
  final VoidCallback? onLongPress;

  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;
  bool _hasFocus = false;

  void _activate() {
    if (!kIsWeb) unawaited(HapticFeedback.selectionClick());
    widget.onTap?.call();
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (value) => setState(() => _hasFocus = value),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: enabled,
        onTap: enabled ? _activate : null,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.sm),
            border: _hasFocus
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: AppLayout.focusBorderWidth,
                  )
                : null,
          ),
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => _setPressed(true) : null,
            onTapCancel: enabled ? () => _setPressed(false) : null,
            onTapUp: enabled ? (_) => _setPressed(false) : null,
            onTap: enabled ? _activate : null,
            onLongPress: widget.onLongPress == null
                ? null
                : () {
                    _setPressed(false);
                    if (!kIsWeb) unawaited(HapticFeedback.mediumImpact());
                    widget.onLongPress!.call();
                  },
            child: AnimatedScale(
              scale: _isPressed && !MediaQuery.disableAnimationsOf(context)
                  ? widget.pressedScale
                  : 1,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : Motion.instant,
              curve: Motion.enter,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ignora deliberadamente un future sin silenciar el lint en todo el fichero.
void unawaited(Future<void> future) {
  // Intencionalmente vacío: sólo marca la intención.
}
