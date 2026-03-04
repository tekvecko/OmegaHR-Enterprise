#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "☢️ Zahajuji totální obnovu systémových vrstev..."

# 1. Instalace chybějících komponent
pkg install openssl-tool -y || true

# 2. Rozšíření databáze o chybějící struktury
python3 << 'PYEOF'
import sqlite3, os
db_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db"
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Tabulka pro Auditní logy
c.execute('''CREATE TABLE IF NOT EXISTS audit_logs 
             (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, 
              user TEXT, action TEXT, details TEXT)''')

# Tabulka pro Milníky (Kariérní růst)
c.execute('''CREATE TABLE IF NOT EXISTS milestones 
             (id INTEGER PRIMARY KEY AUTOINCREMENT, token TEXT, title TEXT, 
              achieved_at DATE, type TEXT)''')

# Přidání sloupců pokud chybí (Pojistka)
try: c.execute("ALTER TABLE candidates ADD COLUMN role TEXT DEFAULT 'Junior'")
except: pass
try: c.execute("ALTER TABLE candidates ADD COLUMN last_login DATETIME")
except: pass

conn.commit()
conn.close()
PYEOF

# 3. Vytvoření Backup Enginu
mkdir -p backups
cat > omega_backup.sh << 'BEOF'
#!/data/data/com.termux/files/usr/bin/bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
cp /data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/backup_$TIMESTAMP.db
echo "[$(date)] Backup completed: backup_$TIMESTAMP.db" >> /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/log.txt
# Udržovat pouze posledních 10 záloh
ls -t /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/backup_*.db | tail -n +11 | xargs rm -f -- 2>/dev/null || true
BEOF
chmod +x omega_backup.sh

# 4. Integrace Audit Logování do Jádra
python3 << 'PYEOF'
path = "omega_core.py"
with open(path, 'r') as f: content = f.read()

log_func = """
def log_action(user, action, details):
    query_db("INSERT INTO audit_logs (user, action, details) VALUES (?, ?, ?)", (user, action, details))
"""

if "def log_action" not in content:
    content = content.replace("def query_db", log_func + "\ndef query_db")
    content = content.replace("session['logged_in'] = True", "session['logged_in'] = True; log_action('admin', 'LOGIN', 'Successfull admin login')")
    with open(path, 'w') as f: f.write(content)
PYEOF

echo "✅ Fáze 1 dokončena. Audit logy jsou aktivní a zálohování připraveno."
