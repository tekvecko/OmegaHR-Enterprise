#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🔧 Rekonstrukce chybějících DB komponent dle diagnostiky..."

python3 << 'PYEOF'
import sqlite3
import json

db_path = "omega_database.db"
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Vytvoření tabulek dle nalezené struktury
c.executescript('''
CREATE TABLE IF NOT EXISTS candidates (
    token TEXT PRIMARY KEY, name TEXT, full_name_mojeid TEXT,
    address_mojeid TEXT, birthdate_mojeid TEXT, status TEXT,
    created_at TEXT, hr_data TEXT, contract_file TEXT,
    stage TEXT DEFAULT 'new', notes TEXT DEFAULT '', 
    onboarding TEXT DEFAULT '{}', mojeid_sub TEXT, 
    start_date TEXT, bankid_sub TEXT, is_verified INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS sys_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT, module TEXT, 
    message TEXT, timestamp TEXT
);
CREATE TABLE IF NOT EXISTS assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, 
    serial TEXT, type TEXT, owner_token TEXT, 
    status TEXT DEFAULT 'available', assigned_date TEXT
);
''')

# Automatické vytvoření company.json pokud chybí
company_data = {"company_name": "OMEGA PLATINUM CORE", "version": "PROD 2026"}
with open('company.json', 'w') as f:
    json.dump(company_data, f)

conn.commit()
conn.close()
PYEOF

echo "✅ Databázové komponenty a company.json byly obnoveny."
