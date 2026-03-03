#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
BACKUP_DIR="/data/data/com.termux/files/home/storage/downloads/OMEGA_BACKUPS"
mkdir -p $BACKUP_DIR

echo "🛡️ Inicializuji Disaster Recovery & Integrity Suite..."

# 1. GENERÁTOR ZÁLOHY (Backup Engine)
cat > $PROJECT_DIR/omega_backup.sh << 'BKP'
#!/data/data/com.termux/files/usr/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="/data/data/com.termux/files/home/storage/downloads/OMEGA_BACKUPS"
PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"

echo "📦 Vytvářím snapshot systému OMEGA..."
tar -czf $BACKUP_PATH/OMEGA_SNAP_$TIMESTAMP.tar.gz -C $PROJECT_DIR omega_database.db contracts/ static/qr/
echo "✅ Snapshot uložen: OMEGA_SNAP_$TIMESTAMP.tar.gz"
BKP
chmod +x $PROJECT_DIR/omega_backup.sh

# 2. INTEGRITY CHECKER (Forenzní modul)
cat > $PROJECT_DIR/omega_check.py << 'CHKO'
import sqlite3, os
DB_FILE = "omega_database.db"
CONTRACTS_DIR = "contracts/"

def check_integrity():
    print("🔍 Prověřuji integritu dokumentace...")
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("SELECT token, name FROM candidates WHERE status='ACTIVE'")
    employees = c.fetchall()
    
    issues = 0
    for token, name in employees:
        pdf_name = f"SMLOUVA_{token}_{name}.pdf"
        if not os.path.exists(os.path.join(CONTRACTS_DIR, pdf_name)):
            print(f"⚠️ KRITICKÁ CHYBA: Chybí PDF pro {name} (Token: {token})")
            issues += 1
    
    if issues == 0:
        print("✅ Všechny aktivní entity mají platnou dokumentaci.")
    conn.close()

if __name__ == "__main__":
    check_integrity()
CHKO

# 3. KONTROLA BĚHU (Watchdog)
cat > $PROJECT_DIR/omega_watchdog.sh << 'WDC'
#!/data/data/com.termux/files/usr/bin/bash
if ! pgrep -f "omega_core.py" > /dev/null; then
    echo "⚠️ Omega Core neběží! Restartuji..."
    cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && python3 omega_core.py > /dev/null 2>&1 &
fi
WDC
chmod +x $PROJECT_DIR/omega_watchdog.sh

echo "🚀 Všechny ochranné systémy jsou připraveny."
echo "💡 Tip: Pro ruční zálohu spusť ./omega_backup.sh"
