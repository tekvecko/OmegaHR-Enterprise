#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🔧 Spouštím DB Migraci: Přidávání chybějících sloupců..."

python3 << 'PYEOF'
import sqlite3

conn = sqlite3.connect("omega_database.db")
c = conn.cursor()

# Funkce pro bezpečné přidání sloupce
def add_column(table, column, type):
    try:
        c.execute(f"ALTER TABLE {table} ADD COLUMN {column} {type}")
        print(f"✅ Sloupec '{column}' přidán do tabulky '{table}'.")
    except sqlite3.OperationalError:
        print(f"ℹ️ Sloupec '{column}' již v tabulce '{table}' existuje.")

# Oprava schématu candidates
add_column("candidates", "hired_at", "TEXT")
add_column("candidates", "is_verified", "INTEGER DEFAULT 0")

conn.commit()
conn.close()
PYEOF

echo "✅ Hotfix aplikován. Zkouším znovu spustit test..."
./OMEGA_SYSTEM_TEST.sh
