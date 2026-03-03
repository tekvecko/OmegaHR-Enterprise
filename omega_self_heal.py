#!/data/data/com.termux/files/usr/bin/python
import os, sqlite3, subprocess, glob, tarfile

# Konfigurace
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
BACKUP_DIR = "/data/data/com.termux/files/home/storage/downloads/OMEGA_BACKUPS"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
DIRS = ["contracts", "static/qr", "db/ard_logs", "templates", "static/css"]

def ghost_recovery():
    print("👻 [GHOST-RECOVERY] Detekována ztráta dat. Hledám snapshots...")
    if not os.path.exists(BACKUP_DIR):
        print("❌ Recovery selhalo: Backup složka neexistuje.")
        return False
    
    # Najde nejnovější zálohu (.tar.gz)
    backups = glob.glob(os.path.join(BACKUP_DIR, "OMEGA_SNAP_*.tar.gz"))
    if not backups:
        print("❌ Recovery selhalo: Žádné snapshots nenalezeny.")
        return False
    
    latest_backup = max(backups, key=os.path.getctime)
    print(f"📦 Nalezen snapshot: {os.path.basename(latest_backup)}")
    
    try:
        with tarfile.open(latest_backup, "r:gz") as tar:
            tar.extractall(path=BASE_DIR)
        print("✅ [GHOST-RECOVERY] Data byla úspěšně obnovena ze zálohy.")
        return True
    except Exception as e:
        print(f"❌ Chyba při extrakci: {e}")
        return False

def heal():
    print("🩹 [SELF-HEAL] Zahajuji diagnostiku...")
    
    # 1. Kontrola existence kritické DB
    if not os.path.exists(DB_FILE):
        if not ghost_recovery():
            print("🛠️ Inicializuji prázdnou DB (není co obnovit)...")
            conn = sqlite3.connect(DB_FILE)
            conn.close()

    # 2. Kontrola integrity složek
    for d in DIRS:
        path = os.path.join(BASE_DIR, d)
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)

    # 3. Validace DB schématu po případné obnově
    try:
        conn = sqlite3.connect(DB_FILE)
        conn.execute("PRAGMA integrity_check")
        # Kontrola, zda máme tabulky, pokud ne, vytvoříme je
        conn.execute("CREATE TABLE IF NOT EXISTS sys_logs (id INTEGER PRIMARY KEY, message TEXT, timestamp TEXT)")
        conn.close()
    except:
        print("⚠️ DB je poškozená, spouštím nouzový wipe/reset...")
        os.remove(DB_FILE)
        sqlite3.connect(DB_FILE).close()

    # 4. Permissions Lockdown
    os.chmod(os.path.join(BASE_DIR, "omega_core.py"), 0o755)
    print("✅ Prostředí je stabilizováno.")

if __name__ == "__main__":
    heal()
