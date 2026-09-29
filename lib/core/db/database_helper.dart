import 'package:supabase_flutter/supabase_flutter.dart';

@Deprecated('SQLite runtime was removed. Use Supabase.instance.client.')
class DatabaseHelperVer1Ne {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<SupabaseClient> get database async => client;
}
