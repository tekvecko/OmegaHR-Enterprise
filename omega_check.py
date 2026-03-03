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
