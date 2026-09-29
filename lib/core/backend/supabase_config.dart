abstract final class SupabaseConfig {
  static const projectRef = 'hrlahralknhijnkypjix';

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hrlahralknhijnkypjix.supabase.co',
  );

  // Supabase publishable keys are intended for client applications.
  // Security still depends on Auth + RLS; never place a service-role/secret
  // key in this Flutter project.
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_9n5qfIMFqZELqlmJFUrg-A_7IJJebRy',
  );

  static bool get isConfigured =>
      url.startsWith('https://') &&
      publishableKey.startsWith('sb_publishable_');
}
