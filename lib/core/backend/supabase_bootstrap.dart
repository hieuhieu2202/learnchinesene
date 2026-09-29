import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

abstract final class SupabaseBootstrap {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase configuration is invalid. '
        'Provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY with --dart-define.',
      );
    }

    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    _initialized = true;

    // Static learning content is readable with the publishable key.
    // Do not block app startup on Anonymous Auth because this project currently
    // has anonymous sign-ins disabled. User-scoped progress features gracefully
    // stay in guest mode until a real authenticated session exists.
  }
}
