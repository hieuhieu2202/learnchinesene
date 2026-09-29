#!/usr/bin/env python3
import json
import re
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DBS = [
    ROOT / "assets/database/app_chinese_ordered.db",
    ROOT / "assets/database/chinese_v2_sheet1_only.db",
]
OUT = ROOT / "build/sqlite_inventory"
OUT.mkdir(parents=True, exist_ok=True)

dart_files = list((ROOT / "lib").rglob("*.dart"))
dart_text = {}
for p in dart_files:
    try:
        dart_text[p] = p.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        pass

inventory = {"databases": []}

for db_path in DBS:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    table_rows = cur.execute(
        """
        select name, sql
        from sqlite_master
        where type = 'table'
          and name not like 'sqlite_%'
        order by name
        """
    ).fetchall()

    db_info = {
        "path": str(db_path.relative_to(ROOT)),
        "tables": [],
    }
    db_out = OUT / db_path.stem
    db_out.mkdir(parents=True, exist_ok=True)

    for table_row in table_rows:
        table = table_row["name"]
        schema_sql = table_row["sql"] or ""
        quoted = table.replace('"', '""')
        columns = [
            dict(row)
            for row in cur.execute(f'pragma table_info("{quoted}")').fetchall()
        ]
        count = cur.execute(
            f'select count(*) as c from "{quoted}"'
        ).fetchone()["c"]

        refs = []
        word = re.compile(rf'(?<![A-Za-z0-9_]){re.escape(table)}(?![A-Za-z0-9_])', re.I)
        for path, text in dart_text.items():
            if word.search(text):
                refs.append(str(path.relative_to(ROOT)))

        rows = [
            dict(row)
            for row in cur.execute(f'select * from "{quoted}"').fetchall()
        ]
        with (db_out / f"{table}.json").open("w", encoding="utf-8") as f:
            json.dump(rows, f, ensure_ascii=False)

        db_info["tables"].append({
            "name": table,
            "row_count": count,
            "schema_sql": schema_sql,
            "columns": columns,
            "referenced_by_dart": sorted(refs),
            "used_in_app": bool(refs),
        })

    inventory["databases"].append(db_info)
    conn.close()

with (OUT / "inventory.json").open("w", encoding="utf-8") as f:
    json.dump(inventory, f, ensure_ascii=False, indent=2)

print(json.dumps(inventory, ensure_ascii=False, indent=2))
