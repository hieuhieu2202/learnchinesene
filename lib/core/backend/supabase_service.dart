import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin application-facing wrapper around Supabase.
///
/// Keep feature code depending on this service (or feature repositories),
/// instead of reaching for [Supabase.instance] directly. This makes future
/// offline sync, testing, and backend migrations easier.
class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  GoTrueClient get auth => client.auth;

  User? get currentUser => auth.currentUser;

  Session? get currentSession => auth.currentSession;

  bool get isSignedIn => currentSession != null;
}
