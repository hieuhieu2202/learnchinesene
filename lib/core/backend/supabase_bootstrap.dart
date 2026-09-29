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

    if (!_initialized) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
      _initialized = true;
    }

    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) return;

    try {
      await client.auth.signInAnonymously();
    } on AuthException catch (error) {
      throw StateError(
        'Ứng dụng cần kết nối Supabase để hoạt động. '
        'Anonymous Auth phải được bật trong Supabase. '
        'Chi tiết: ${error.message}',
      );
    }
  }
}
