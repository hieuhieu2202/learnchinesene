import sqlite3
import json

db_path = r"F:\2026\Chinese\app_chinese_ordered.db"
conn = sqlite3.connect(db_path)
cur = conn.cursor()

with open("schema.txt", "w", encoding="utf-8") as f:
    cur.execute("SELECT name, sql FROM sqlite_master WHERE type='table'")
    tables = cur.fetchall()
    for name, sql in tables:
        f.write(f"Table: {name}\n")
        f.write(f"SQL: {sql}\n\n")
