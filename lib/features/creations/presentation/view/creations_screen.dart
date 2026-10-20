import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/widgets/content_width.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../reader/presentation/widgets/activity_invitation.dart';
import '../view_model/creations_state.dart';
import '../view_model/creations_view_model.dart';

/// Todo lo que el estudiante ha escrito, en un sitio.
///
/// Sin esta pantalla, lo que escribe en las dinámicas desaparece en cuanto
/// pasa de capítulo. Verlo acumularse es lo que convierte esas respuestas
/// sueltas en algo que siente suyo.
class CreationsScreen extends ConsumerWidget {
  const CreationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final creaciones = ref.watch(creationsViewModelProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AuroraBackground(
            baseColor: theme.colorScheme.surface,
            intensity: 0.5,
          ),
          SafeArea(
            child: creaciones.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.wine),
              ),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(Insets.xxl),
                  child: Text(
                    'No pudimos abrir tus creaciones.',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (estado) => ContentWidth(child: _Contenido(estado: estado)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.estado});

  final CreationsState estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const ancho = AppLayout.readingMaxWidth;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: context.backToLibrary,
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                tooltip: 'Volver',
              ),
              Text('TU RINCÓN', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.sm,
            Insets.xl,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: StaggeredEntrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Lo que llevas hecho',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: Insets.xl),
                  _Resumen(estado: estado),
                  const SizedBox(height: Insets.xxl),
                  Text('Tus creaciones', style: theme.textTheme.titleLarge),
                  const SizedBox(height: Insets.xs),
                  Text(
                    'Sólo tú las ves.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                  ),
                  const SizedBox(height: Insets.lg),
                ],
              ),
            ),
          ),
        ),
        if (estado.isEmpty)
          const SliverToBoxAdapter(child: _SinCreaciones())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              0,
              Insets.xl,
              Insets.huge,
            ),
            sliver: SliverList.separated(
              itemCount: estado.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
              itemBuilder: (context, index) => Center(
                child: SizedBox(
                  width: ancho,
                  child: StaggeredEntrance(
                    index: index + 1,
                    child: _Creacion(entrada: estado.entries[index]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tres números, todos sacados de lo que hay guardado de verdad.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.estado});

  final CreationsState estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _Dato(
          numero: '${estado.chaptersRead}',
          etiqueta: estado.chaptersRead == 1 ? 'capítulo' : 'capítulos',
          color: AppColors.wine,
        ),
        _Dato(
          numero: '${estado.booksFinished}',
          etiqueta: estado.booksFinished == 1 ? 'terminado' : 'terminados',
          color: AppColors.gold,
        ),
        _Dato(
          numero: '${estado.entries.length}',
          etiqueta: estado.entries.length == 1 ? 'creación' : 'creaciones',
          color: AppColors.clay,
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.numero,
    required this.etiqueta,
    required this.color,
  });

  final String numero;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: Insets.sm),
        padding: const EdgeInsets.symmetric(vertical: Insets.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              numero,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 26,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9.5,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Creacion extends StatelessWidget {
  const _Creacion({required this.entrada});

  final CreationEntry entrada;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipo = entrada.activity.kind;
    final acento = ActivityInvitation.colorOf(tipo);

    return Container(
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: acento.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(tipo.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: Insets.sm),
              Text(
                tipo.label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: acento,
                  fontSize: 9.5,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  entrada.bookTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          Text(
            entrada.activity.prompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            entrada.response.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _SinCreaciones extends StatelessWidget {
  const _SinCreaciones();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.xxl,
        Insets.xl,
        Insets.xxl,
        Insets.huge,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            '✎',
            style: TextStyle(fontSize: 30, color: AppColors.wineSoft),
          ),
          const SizedBox(height: Insets.lg),
          Text(
            'Todavía no has escrito nada',
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Insets.sm),
          Text(
            'Cuando hagas una actividad mientras lees, lo que escribas '
            'aparecerá aquí. Nadie más lo ve.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
