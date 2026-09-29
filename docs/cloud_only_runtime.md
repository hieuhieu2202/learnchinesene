# Cloud-only runtime

The application runtime is cloud-first and does not bundle SQLite learning
databases. Learning content comes from Supabase, including vocabulary, HSK,
examples, Duolingo-style challenge content, flashcards, Boss Battle questions,
and writing data.

User learning state is also stored in Supabase:

- `lexicon_user_progress`
- `lexicon_speaking_practice`
- `lexicon_hanzi_progress`
- `app_user_stats`

Supabase Auth identifies the current learner. When there is no existing session,
the Flutter bootstrap attempts anonymous sign-in so a first-time user can start
immediately without a registration form.

There is intentionally no offline learning-data fallback. If Supabase cannot be
reached, cloud-backed learning features cannot load.

The CI cloud-only guard rejects accidental reintroduction of bundled SQLite
content or SQLite runtime dependencies.

Android CI produces release APKs split by ABI. This avoids shipping native
libraries for every CPU architecture to every device and gives a more realistic
per-device install package than a universal debug APK.
