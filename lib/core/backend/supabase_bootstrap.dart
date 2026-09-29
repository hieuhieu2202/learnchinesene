import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

abstract final class SupabaseBootstrap {
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase configuration is invalid. '
        'Provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY with --dart-define.',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
    );
  }
}
