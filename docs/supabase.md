# Supabase integration

Project ref: `hrlahralknhijnkypjix`

The Flutter app initializes Supabase before GetX dependency registration.

Runtime configuration can be overridden without changing source:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

Only the public/publishable key belongs in the client app. Never commit a
Supabase secret key or service-role key.

The app remains offline-first: the bundled SQLite learning-content database is
still the source for local learning content. Supabase is intended for account,
sync, progress, economy, server-authoritative rewards, and cloud features.

At the time this integration was added the Supabase project's `public` schema
contained no application tables, so no production schema was created as part of
this connection commit.
