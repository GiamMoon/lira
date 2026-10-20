import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Cliente de Supabase ya inicializado.
///
/// Sólo debe leerse cuando `AppConfig.hasRemoteBackend` es verdadero; si no,
/// `Supabase.instance` aún no existe. Exponerlo como provider permite
/// sustituirlo por un doble en tests de integración.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
