#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

DB_SUFFIXES = {".db", ".sqlite", ".sqlite3"}
FORBIDDEN_PUBSPEC = (
    "sqflite:",
    "sqlite3:",
    "assets/database/",
    "assets/db/",
)
FORBIDDEN_DART = (
    "package:sqflite/",
    "package:sqlite3/",
    "openDatabase(",
    "sqlite3.open(",
)

problems: list[str] = []

assets = ROOT / "assets"
if assets.exists():
    for path in assets.rglob("*"):
        if path.is_file() and path.suffix.lower() in DB_SUFFIXES:
            problems.append(
                f"Bundled SQLite file is not allowed in cloud-only builds: "
                f"{path.relative_to(ROOT)}"
            )

pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
for needle in FORBIDDEN_PUBSPEC:
    if needle in pubspec:
        problems.append(f"pubspec.yaml still references offline SQLite: {needle}")

for path in (ROOT / "lib").rglob("*.dart"):
    text = path.read_text(encoding="utf-8", errors="ignore")
    for needle in FORBIDDEN_DART:
        if needle in text:
            problems.append(
                f"{path.relative_to(ROOT)} still contains SQLite runtime usage: {needle}"
            )

    if re.search(r"rootBundle\.(?:load|loadString)\([^\n]*\.db", text):
        problems.append(
            f"{path.relative_to(ROOT)} still loads a bundled .db asset"
        )

if problems:
    print("Cloud-only guard failed:")
    for problem in problems:
        print(f" - {problem}")
    sys.exit(1)

print("Cloud-only guard passed: no bundled SQLite content or SQLite runtime usage.")
