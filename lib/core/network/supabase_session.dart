import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Garantiza que haya una sesión antes de que arranque la app.
///
/// Se usa **sesión anónima** a propósito: pedirle a un estudiante que se
/// registre para leer un cuento es exactamente la fricción que Lira intenta
/// quitar. Con una sesión anónima no escribe ni un correo, y aun así sus datos
/// quedan protegidos: las políticas RLS exigen `auth.uid()`, así que nadie más
/// puede leer su progreso ni lo que escribe en las dinámicas.
///
/// Limitación honesta: la sesión vive en este dispositivo. Si desinstala la
/// app, empieza de cero. Enlazar luego esa cuenta con un correo es lo que
/// permitiría llevarse el avance a otro teléfono, y se puede hacer sin
/// perder nada de lo ya guardado.
///
/// Si falla —porque el proyecto no tiene activadas las sesiones anónimas, o
/// no hay red— la app sigue funcionando: el progreso se queda en local.
Future<bool> asegurarSesion() async {
  final auth = Supabase.instance.client.auth;

  if (auth.currentSession != null) return true;

  try {
    await auth.signInAnonymously();
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

/// Hay sesión abierta y por tanto se puede escribir en las tablas del alumno.
bool get haySesion =>
    Supabase.instance.isInitialized &&
    Supabase.instance.client.auth.currentUser != null;
