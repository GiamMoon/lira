import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lira/app/lira_app.dart';
import 'package:lira/app/router/app_route.dart';
import 'package:lira/app/router/app_router.dart';
import 'package:lira/core/di/core_providers.dart';
import 'package:lira/core/theme/app_theme.dart';
import 'package:lira/core/theme/app_tokens.dart';
import 'package:lira/core/theme/app_typography.dart';
import 'package:lira/core/widgets/pressable.dart';
import 'package:lira/features/library/presentation/widgets/book_tile.dart';
import 'package:lira/features/reader/presentation/view/reader_screen.dart';
import 'package:lira/features/settings/presentation/view_model/preferences_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bookId = 'las-aventuras-de-tom-sawyer';

Future<ProviderContainer> _open(
  WidgetTester tester,
  AppRoute route, {
  Size size = const Size(1440, 900),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  // Las fuentes reales empaquetadas se cargan fuera del reloj simulado.
  final prefs = await tester.runAsync(() async {
    AppTheme.light;
    AppTypography.readingSerif(Colors.black);
    AppTypography.readingSans(Colors.black);
    AppTypography.readingLegible(Colors.black);
    await GoogleFonts.pendingFonts();
    return SharedPreferences.getInstance();
  });
  final container = ProviderContainer.test(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs!)],
  );
  final router = container.read(appRouterProvider);
  router.goNamed(
    route.routeName,
    pathParameters: route == AppRoute.reader
        ? {AppRoute.bookIdParam: _bookId}
        : const {},
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LiraApp()),
  );
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    GoRouter.optionURLReflectsImperativeAPIs = true;
  });

  for (final size in [
    const Size(360, 800),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('biblioteca usable a ${size.width} píxeles', (tester) async {
      await _open(tester, AppRoute.library, size: size);
      expect(find.text('¿Qué vas a leer hoy?'), findsOneWidget);
      expect(find.byType(BookTile), findsWidgets);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('Todos'),
                matching: find.byType(Pressable),
              ),
            )
            .width,
        lessThan(200),
      );
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), 'Tom Sawyer');
      await tester.pumpAndSettle();
      expect(find.byType(BookTile), findsOneWidget);
      await tester.tap(find.byType(BookTile));
      await tester.pumpAndSettle();
      expect(find.text('Empezar a leer'), findsOneWidget);
      expect(
        find.byType(Dialog),
        size.width >= AppLayout.expandedBreakpoint
            ? findsOneWidget
            : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rejilla sin desbordes con letra ampliada', (tester) async {
    await _open(
      tester,
      AppRoute.library,
      size: const Size(360, 800),
      textScale: 1.5,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(1100, 768),
    const Size(1920, 1080),
    const Size(2560, 1440),
  ]) {
    testWidgets('escritorio diseñado para ${size.width} píxeles', (
      tester,
    ) async {
      await _open(tester, AppRoute.library, size: size);
      expect(find.text('Haz espacio para\nuna historia.'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Biblioteca'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('búsqueda con teclado, vista de lista y navegación lateral', (
    tester,
  ) async {
    await _open(tester, AppRoute.library);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField), 'Tom Sawyer');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ver lista'));
    await tester.pumpAndSettle();
    expect(find.byType(BookTile), findsNothing);
    expect(find.text('Las aventuras de Tom Sawyer'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Aspecto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final route in [
    AppRoute.settings,
    AppRoute.creations,
    AppRoute.reader,
  ]) {
    testWidgets('enlace directo a ${route.routeName} permite volver', (
      tester,
    ) async {
      final container = await _open(tester, route);
      expect(container.read(appRouterProvider).canPop(), isFalse);
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('¿Qué vas a leer hoy?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('una dirección desconocida ofrece volver a la biblioteca', (
    tester,
  ) async {
    final container = await _open(tester, AppRoute.settings);
    container.read(appRouterProvider).go('/pagina-inexistente');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ir a la biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué vas a leer hoy?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el lector selecciona texto y termina con el teclado', (
    tester,
  ) async {
    await _open(tester, AppRoute.reader);
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('TERMINASTE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los ajustes sobreviven al reconstruir la aplicación', (
    tester,
  ) async {
    final first = await _open(tester, AppRoute.settings);
    await tester.enterText(find.byType(TextField), 'Lectora');
    await tester.pumpAndSettle();
    expect(first.read(preferencesProvider).name, 'Lectora');
    await tester.pumpWidget(const SizedBox.shrink());
    final second = await _open(tester, AppRoute.settings);
    expect(second.read(preferencesProvider).name, 'Lectora');
    expect(find.text('Lectora'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los controles propios responden a Tab, Enter y espacio', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pressable(
            onTap: () => presses++,
            child: const Text('Abrir libro'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 2);
    expect(tester.takeException(), isNull);
  });
}
