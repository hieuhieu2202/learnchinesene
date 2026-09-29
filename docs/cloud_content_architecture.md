# Cloud content architecture

The production app is cloud-first. Learning content is read from Supabase and is
not bundled as SQLite assets in the APK.

Supabase project: `hrlahralknhijnkypjix`.

Boss Battle reads `duo_challenges` through the `random_boss_questions` RPC.
HSK, vocabulary, examples, speaking content, and Hanzi writing content are read
from the `lexicon_*` tables.

The old SQLite files are migration/source snapshots only. They must not be
declared as Flutter assets in production builds.

Small per-device learning state currently uses SharedPreferences. It does not
contain the learning-content database and has negligible APK/storage cost.
