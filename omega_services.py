#!/data/data/com.termux/files/usr/bin/python
import sqlite3
import json
import os
import datetime
import uuid

# --- KONFIGURACE ---
DB_PATH = "omega_database.db"
CONTRACTS_PATH = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/contracts"
ARD_LOG_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db/ard_logs"

os.makedirs(CONTRACTS_PATH, exist_ok=True)

def generate_verified_contract(token, name, hr_data_raw):
    try:
        hr_data = json.loads(hr_data_raw)
        filename = f"FINAL_CONTRACT_{token}.txt"
        path = os.path.join(CONTRACTS_PATH, filename)
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(f"=== OFICIÁLNÍ SMLOUVA OMEGA PLATINUM (VERIFIED) ===\n")
            f.write(f"ID/TOKEN: {token}\n")
            f.write(f"ZAMĚSTNANEC: {name}\n")
            f.write(f"POZICE: {hr_data.get('position', 'N/A')}\n")
            f.write(f"PLAT: {hr_data.get('salary', 'N/A')} CZK\n")
            f.write(f"STATUS IDENTITY: VALIDATED VIA MOJEID\n")
            f.write(f"DATUM GENERACE: {datetime.datetime.now()}\n")
            f.write(f"ARD VALIDATOR: {uuid.uuid4().hex.upper()}\n")
        return filename
    except:
        return None

def run_services():
    print("⚙️ Spouštím Omega Services: Monitoring a Automatizace...")
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Najít ověřené kandidáty, kteří ještě nemají vygenerovanou smlouvu
    c.execute("SELECT token, name, hr_data FROM candidates WHERE is_verified = 1 AND contract_file IS NULL")
    verified_queue = c.fetchall()
    
    if not verified_queue:
        print("📭 Žádné nové identity k procesování.")
        return

    for token, name, hr_data in verified_queue:
        print(f"📄 Generuji finální dokumentaci pro: {name}...")
        fname = generate_verified_contract(token, name, hr_data)
        
        if fname:
            c.execute("UPDATE candidates SET contract_file = ?, stage = 'contract_ready' WHERE token = ?", (fname, token))
            print(f"✅ Hotovo: {fname}")
            
    conn.commit()
    conn.close()
    print("🏁 Služby dokončily aktuální cyklus.")

if __name__ == "__main__":
    run_services()
