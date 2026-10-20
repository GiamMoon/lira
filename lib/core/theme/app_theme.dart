import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Construcción de los `ThemeData` de Lira.
///
/// Se define una sola vez y se consume vía `Theme.of(context)`; los widgets no
/// conocen colores literales.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.wine,
      onPrimary: AppColors.creamLight,
      primaryContainer: AppColors.wineMist,
      onPrimaryContainer: AppColors.wineDeep,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      tertiary: AppColors.sage,
      onTertiary: AppColors.creamLight,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.creamDeep,
      outline: AppColors.wineMist,
      error: AppColors.danger,
      onError: AppColors.creamLight,
    ),
    muted: AppColors.inkMuted,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.wineMist,
      onPrimary: AppColors.wineDeep,
      primaryContainer: AppColors.wine,
      onPrimaryContainer: AppColors.creamLight,
      secondary: AppColors.gold,
      onSecondary: AppColors.night,
      tertiary: AppColors.sage,
      onTertiary: AppColors.night,
      surface: AppColors.night,
      onSurface: AppColors.creamLight,
      surfaceContainerHighest: AppColors.nightElevated,
      outline: AppColors.nightBorder,
      error: AppColors.danger,
      onError: AppColors.creamLight,
    ),
    muted: AppColors.inkFaint,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color muted,
  }) {
    final text = AppTypography.textTheme(scheme.onSurface, muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      // Los menús y diálogos toman sus colores del tema. Cuando se fijaban a
      // mano en crema, en modo oscuro salía texto claro sobre fondo claro: un
      // rectángulo blanco ilegible.
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        textStyle: text.bodyLarge?.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.headlineMedium?.copyWith(fontSize: 20),
        contentTextStyle: text.bodyLarge?.copyWith(color: muted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? AppColors.ink
            : AppColors.creamDeep,
        contentTextStyle: text.bodyLarge?.copyWith(
          fontSize: 14,
          color: brightness == Brightness.light
              ? AppColors.creamLight
              : AppColors.ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
