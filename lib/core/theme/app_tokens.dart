import 'package:flutter/animation.dart';

abstract final class AppLayout {
  static const double expandedBreakpoint = 840;
  static const double libraryMaxWidth = 1200;
  static const double readingMaxWidth = 680;
  static const double formMaxWidth = 560;
  static const double modalMaxWidth = 640;
  static const double bookMaxWidth = 210;
  static const double bookDetailsHeight = 108;
  static const double focusBorderWidth = 2;
  static const double desktopBreakpoint = 1100;
  static const double desktopMaxWidth = 1440;
  static const double sidebarWidth = 232;
  static const double heroHeight = 330;
  static const double heroCoverWidth = 142;
  static const double desktopCardWidth = 220;
  static const double readerIndexWidth = 272;
  static const double desktopTitleSize = 48;
  static const double hoverOffset = 4;
  static const double searchWidth = 320;
  static const double rowCoverWidth = 52;
  static const double emptyIconSize = 48;
  static const double indexCoverWidth = 72;
}

/// Escala de espaciado (base 4).
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

abstract final class Radii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 650);
  static const Duration splash = Duration(milliseconds: 2600);
  static const Duration aurora = Duration(seconds: 22);

  /// Evita el parpadeo del splash cuando el arranque termina antes.
  static const Duration minimumSplash = Duration(milliseconds: 2200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve overshoot = Curves.easeOutBack;
}
