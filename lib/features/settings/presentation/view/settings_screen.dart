import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/widgets/content_width.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../reader/presentation/view_model/reader_settings.dart';
import '../../domain/entities/reading_font.dart';
import '../view_model/preferences_view_model.dart';

/// Ajustes: cómo se ve Lira y cómo se lee.
///
/// Todo lo de aquí se aplica al instante y se recuerda. No hay botón de
/// guardar porque no hay nada que confirmar: se toca, se ve el cambio, y ya.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final size = ref.watch(readerSettingsProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AuroraBackground(
            baseColor: theme.colorScheme.surface,
            intensity: 0.4,
          ),
          SafeArea(
            child: ContentWidth(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    title: Text('Ajustes', style: theme.textTheme.titleLarge),
                    leading: IconButton(
                      onPressed: context.backToLibrary,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Volver',
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.xl,
                      0,
                      Insets.xl,
                      Insets.huge,
                    ),
                    sliver: SliverList.list(
                      children: <Widget>[
                        StaggeredEntrance(
                          child: _NameField(
                            initial: prefs.name,
                            onChanged: notifier.setName,
                          ),
                        ),
                        const SizedBox(height: Insets.xl),
                        StaggeredEntrance(
                          index: 1,
                          child: _Section(
                            title: 'Aspecto',
                            subtitle: 'Cómo se ve la app.',
                            child: _ThemePicker(
                              selected: prefs.themeMode,
                              onSelected: notifier.selectTheme,
                            ),
                          ),
                        ),
                        const SizedBox(height: Insets.xl),
                        StaggeredEntrance(
                          index: 2,
                          child: _Section(
                            title: 'Letra de lectura',
                            subtitle: 'La que verás dentro de los libros.',
                            child: _FontPicker(
                              selected: prefs.font,
                              onSelected: notifier.selectFont,
                            ),
                          ),
                        ),
                        const SizedBox(height: Insets.xl),
                        StaggeredEntrance(
                          index: 3,
                          child: _Section(
                            title: 'Tamaño',
                            subtitle: 'También puedes cambiarlo leyendo.',
                            child: _SizePicker(
                              selected: size,
                              onSelected: ref
                                  .read(readerSettingsProvider.notifier)
                                  .select,
                            ),
                          ),
                        ),
                        const SizedBox(height: Insets.xl),
                        StaggeredEntrance(
                          index: 4,
                          child: _Preview(font: prefs.font, scale: size.scale),
                        ),
                        const SizedBox(height: Insets.xxl),
                        const StaggeredEntrance(index: 5, child: _Privacy()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: Insets.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Insets.md),
        child,
      ],
    );
  }
}

/// El nombre es opcional y se puede borrar. Se guarda al escribir, sin botón:
/// pedir "guardar" para un nombre es una ceremonia que no hace falta.
class _NameField extends StatefulWidget {
  const _NameField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassSurface(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('¿Cómo te llamamos?', style: theme.textTheme.titleMedium),
          const SizedBox(height: Insets.xs),
          Text(
            'Sólo para saludarte. Puedes dejarlo en blanco.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Insets.md),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 24,
            onChanged: widget.onChanged,
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
              counterText: '',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selected, required this.onSelected});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  static const Map<ThemeMode, (String, IconData)> _opciones =
      <ThemeMode, (String, IconData)>{
        ThemeMode.light: ('Claro', Icons.light_mode_rounded),
        ThemeMode.dark: ('Oscuro', Icons.dark_mode_rounded),
        ThemeMode.system: ('El del móvil', Icons.brightness_auto_rounded),
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final entrada in _opciones.entries) ...<Widget>[
          Expanded(
            child: _Choice(
              label: entrada.value.$1,
              icon: entrada.value.$2,
              selected: entrada.key == selected,
              onTap: () => onSelected(entrada.key),
            ),
          ),
          if (entrada.key != ThemeMode.system) const SizedBox(width: Insets.sm),
        ],
      ],
    );
  }
}

class _SizePicker extends StatelessWidget {
  const _SizePicker({required this.selected, required this.onSelected});

  final ReaderTextSize selected;
  final ValueChanged<ReaderTextSize> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final tamano in ReaderTextSize.values) ...<Widget>[
          Expanded(
            child: _Choice(
              label: tamano.label,
              selected: tamano == selected,
              onTap: () => onSelected(tamano),
            ),
          ),
          if (tamano != ReaderTextSize.values.last)
            const SizedBox(width: Insets.sm),
        ],
      ],
    );
  }
}

class _FontPicker extends StatelessWidget {
  const _FontPicker({required this.selected, required this.onSelected});

  final ReadingFont selected;
  final ValueChanged<ReadingFont> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        for (final fuente in ReadingFont.values) ...<Widget>[
          Pressable(
            onTap: () => onSelected(fuente),
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.emphasized,
              width: double.infinity,
              padding: const EdgeInsets.all(Insets.lg),
              decoration: BoxDecoration(
                color: fuente == selected
                    ? AppColors.wine
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          fuente.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fuente == selected
                                ? AppColors.creamLight
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: Insets.xs),
                        // La muestra se pinta con la fuente que describe: es
                        // la única forma honesta de elegir una letra.
                        Text(
                          ReadingFont.sample,
                          style: fuente
                              .style(
                                fuente == selected
                                    ? AppColors.creamLight
                                    : theme.colorScheme.onSurface,
                              )
                              .copyWith(fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  if (fuente == selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.creamLight,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          if (fuente != ReadingFont.values.last)
            const SizedBox(height: Insets.sm),
        ],
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? AppColors.creamLight : theme.colorScheme.onSurface;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.emphasized,
        padding: const EdgeInsets.symmetric(vertical: Insets.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wine
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Column(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(height: Insets.xs),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un trozo de libro de verdad, con la letra y el tamaño elegidos.
class _Preview extends StatelessWidget {
  const _Preview({required this.font, required this.scale});

  final ReadingFont font;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = font.style(theme.colorScheme.onSurface);

    return GlassSurface(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('ASÍ SE VERÁ', style: theme.textTheme.labelSmall),
          const SizedBox(height: Insets.md),
          AnimatedDefaultTextStyle(
            duration: Motion.fast,
            style: base.copyWith(fontSize: (base.fontSize ?? 19) * scale),
            child: const Text(
              'El sol estaba ya muy alto cuando cruzó la puerta, y por un '
              'momento pensó que aquello era exactamente lo que había '
              'estado esperando toda la semana.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Privacy extends StatelessWidget {
  const _Privacy();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: theme.textTheme.bodyMedium?.color,
        ),
        const SizedBox(width: Insets.sm),
        Expanded(
          child: Text(
            'Lo que escribes en las dinámicas es tuyo y se queda en tu '
            'cuenta. Nadie de tu colegio lo lee.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
