import 'package:flutter/foundation.dart';

import '../../domain/start_destination.dart';

enum SplashPhase { preparing, ready, failed }

/// Estado inmutable del splash. Un solo objeto describe toda la pantalla.
@immutable
class SplashState {
  const SplashState({required this.phase, this.destination, this.errorMessage});

  const SplashState.preparing() : this(phase: SplashPhase.preparing);

  const SplashState.ready(StartDestination destination)
    : this(phase: SplashPhase.ready, destination: destination);

  const SplashState.failed(String message)
    : this(phase: SplashPhase.failed, errorMessage: message);

  final SplashPhase phase;

  /// Sólo tiene valor cuando [phase] es [SplashPhase.ready].
  final StartDestination? destination;

  /// Sólo tiene valor cuando [phase] es [SplashPhase.failed].
  final String? errorMessage;

  bool get isPreparing => phase == SplashPhase.preparing;
  bool get hasFailed => phase == SplashPhase.failed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashState &&
          other.phase == phase &&
          other.destination == destination &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(phase, destination, errorMessage);

  @override
  String toString() =>
      'SplashState(phase: $phase, destination: $destination, '
      'errorMessage: $errorMessage)';
}
