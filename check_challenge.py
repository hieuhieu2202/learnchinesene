import sqlite3
import json

db_path = r"F:\2026\Chinese\app_chinese_ordered.db"
conn = sqlite3.connect(db_path)
cur = conn.cursor()

cur.execute("SELECT * FROM challenges WHERE id='4ffd260c4be24f44bb57d2c6d76744bc'")
print(cur.fetchone())
