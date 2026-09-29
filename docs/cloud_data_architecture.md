# Cloud-only data architecture

The app is intentionally **online-first and Supabase-backed**.

## Source of truth

Learning content is managed in Supabase:

- HSK levels, units, topics, words and examples: `lexicon_*`
- Duolingo-style paths and challenges: `duo_*`
- Boss Battle questions: Supabase RPC `random_boss_questions`

The Flutter app does not package or open a learning-content SQLite database.

## Why

Removing bundled SQLite content:

- makes the APK materially smaller;
- lets content be updated from Supabase without publishing a new APK;
- avoids schema/data drift between the app bundle and the cloud;
- gives one place to inspect and manage content.

## Runtime behavior

The splash screen verifies Supabase connectivity before entering the app. If the
learning backend is unavailable, the app shows a retryable connection error
instead of silently switching to stale offline content.

Small device preferences may still be used for lightweight UX/session state.
They are not a copy of the learning corpus and are not an offline content
database.

## CI guarantee

`tool/verify_cloud_only.py` is executed by GitHub Actions on every push to
`hieu`. The build fails if a SQLite database is added back under `assets/`,
if SQLite runtime packages are reintroduced, or if Flutter source starts opening
SQLite again.
