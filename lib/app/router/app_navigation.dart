import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_route.dart';

extension AppNavigation on BuildContext {
  /// Un enlace abierto en otra pestaña no tiene una pantalla anterior.
  void backToLibrary() {
    if (canPop()) {
      pop();
    } else {
      goNamed(AppRoute.library.routeName);
    }
  }
}
