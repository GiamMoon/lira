import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'network_policy.dart';

/// Abre una sesión anónima para las políticas RLS; si falla, mantiene el almacenamiento local.
Future<bool> asegurarSesion() async {
  final auth = Supabase.instance.client.auth;

  if (auth.currentSession != null) return true;

  try {
    await auth.signInAnonymously().timeout(NetworkPolicy.sessionTimeout);
    return auth.currentSession != null;
  } on Object catch (error, stackTrace) {
    developer.log(
      'Sin sesión: el progreso se guardará sólo en este dispositivo. '
      'Actívalas en Authentication → Sign In / Providers → Anonymous.',
      name: 'Lira.sesion',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

bool get haySesion =>
    Supabase.instance.isInitialized &&
    Supabase.instance.client.auth.currentUser != null;
