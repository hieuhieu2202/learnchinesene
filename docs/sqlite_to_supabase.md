# SQLite -> Supabase migration helper

`tool/sqlite_inventory.py` inspects the bundled SQLite databases, lists their
schemas and row counts, scans Dart source for direct table-name references, and
exports each table as JSON.

The generated artifact is used to decide which bundled tables are actively
consumed by the app before creating cloud equivalents in Supabase. This avoids
copying obsolete or unused SQLite tables blindly.

SQLite remains the offline/cache source during migration. Supabase becomes the
cloud source of truth only after each feature has a repository layer and an
offline fallback.
