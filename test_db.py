import sqlite3
import json

db_path = r"F:\2026\Chinese\app_chinese_ordered.db"
conn = sqlite3.connect(db_path)
cur = conn.cursor()

with open("test_db.txt", "w", encoding="utf-8") as f:
    cur.execute('SELECT id, section_number, title FROM sections LIMIT 3')
    f.write('SECTIONS: ' + str(cur.fetchall()) + '\n')
    cur.execute('SELECT id, section_id, unit_number, title FROM units LIMIT 3')
    f.write('UNITS: ' + str(cur.fetchall()) + '\n')
    cur.execute('SELECT id, unit_id, level_index, total_sessions FROM levels LIMIT 3')
    f.write('LEVELS: ' + str(cur.fetchall()) + '\n')
