import 'package:supabase_flutter/supabase_flutter.dart';

/// Application-facing access to the cloud backend.
///
/// Learning content and learning state are cloud-only. Supabase Auth persists
/// only the session needed to identify the current user.
class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  GoTrueClient get auth => client.auth;

  User? get currentUser => auth.currentUser;

  Session? get currentSession => auth.currentSession;

  bool get isSignedIn => currentSession != null;
}
