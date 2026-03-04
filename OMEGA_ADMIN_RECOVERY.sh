#!/data/data/com.termux/files/usr/bin/bash
set -e

DB="/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db"

echo "🔑 Resetuji administrátorský přístup..."

python3 << 'PYEOF'
import sqlite3
import hashlib

db_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db"
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Vytvoření tabulky users pokud by náhodou chyběla
c.execute('''CREATE TABLE IF NOT EXISTS users 
             (id INTEGER PRIMARY KEY AUTOINCREMENT, 
              username TEXT UNIQUE, 
              password_hash TEXT, 
              role TEXT, 
              failed_attempts INTEGER DEFAULT 0)''')

# Příprava údajů
username = "admin"
password = "omega2026"
# Vytvoření SHA-256 hashu (systém v7.1 používá pro hesla hashování)
password_hash = hashlib.sha256(password.encode()).hexdigest()

# Injekce Admina
c.execute("INSERT OR REPLACE INTO users (username, password_hash, role, failed_attempts) VALUES (?, ?, ?, 0)", 
          (username, password_hash, "SUPERADMIN"))

conn.commit()
conn.close()
print("✅ Administrátor 'admin' s heslem 'omega2026' byl aktivován.")
PYEOF

echo "--------------------------------------------------"
echo "🚀 Nyní se můžeš přihlásit na http://127.0.0.1:5000"
echo "--------------------------------------------------"
