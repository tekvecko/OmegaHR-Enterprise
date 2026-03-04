#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
OLD_DB_SRC="/data/data/com.termux/files/home/OmegaPlatinum_7_1/omega_db.py"

echo "🏺 Extrahuji zapomenuté technologie z verze 7.1..."

# 1. Rozšíření aktuální databáze o Enterprise sloupce nalezené skenem
python3 << 'PYEOF'
import sqlite3
db_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db"
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Přidání pokročilých polí z verze 7.1
columns = [
    ("full_name_mojeid", "TEXT"),
    ("birthdate_mojeid", "TEXT"),
    ("address_mojeid", "TEXT"),
    ("bankid_sub", "TEXT"),
    ("is_verified", "INTEGER DEFAULT 0"),
    ("exit_date", "TEXT")
]

for col, dtype in columns:
    try:
        c.execute(f"ALTER TABLE candidates ADD COLUMN {col} {dtype}")
        print(f"✅ Sloupec {col} obnoven.")
    except:
        pass # Sloupec už existuje

conn.commit()
conn.close()
PYEOF

# 2. Obnova Enterprise Company identity
if [ -f "/data/data/com.termux/files/home/OmegaPlatinum_7_1/company.json" ]; then
    cp "/data/data/com.termux/files/home/OmegaPlatinum_7_1/company.json" "$PROJ/company.json"
    echo "🏢 Identita 'Omega Enterprise s.r.o.' obnovena."
fi

# 3. Instalace Authlib (nutné pro oživení nalezeného MojeID kódu)
echo "📦 Instaluji chybějící moduly pro OIDC..."
pip install Authlib requests_oauthlib

echo "🚀 Restartuji systém s rozšířeným schématem..."
pkill -f "omega_core.py" || true
nohup python3 $PROJ/omega_core.py > $PROJ/dev_server.log 2>&1 &

echo "💎 RECOVERY KOMPLETNÍ. Systém má nyní DNA verze 7.1."
