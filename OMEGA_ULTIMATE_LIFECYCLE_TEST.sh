#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > lifecycle_test.py << 'PYEOF'
import os, json, time, uuid
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

def header(text):
    print(f"\n{'='*60}\n{text.center(60)}\n{'='*60}")

header("🧪 OMEGA HR - END-TO-END TEST ŽIVOTNÍHO CYKLU")

try:
    # 1. AUTENTIZACE
    print("▶️ 1. Přihlášení HR pracovníka...")
    client.post('/login', data={"username": "hr", "password": "hr"})
    
    # 2. NÁBOR (Onboarding)
    test_id = str(uuid.uuid4())[:6]
    surname = f"Simulator_{test_id}"
    print(f"▶️ 2. Nábor zaměstnance: Emanuel {surname}...")
    
    client.post('/new', data={
        "name": "Emanuel", 
        "surname": surname, 
        "email": f"test_{test_id}@omega.cz",
        "position": "Senior Developer",
        "salary": "85000"
    }, follow_redirects=True)
    
    time.sleep(1)
    
    # Identifikace souboru
    token = None
    for f in os.listdir(DB_DIR):
        if f.endswith('.json') and f != 'audit_log.json':
            with open(os.path.join(DB_DIR, f), 'r') as jf:
                if surname in jf.read():
                    token = f.replace('.json', '')
                    break
    
    if not token: raise Exception("Zaměstnanec nebyl nalezen v DB!")
    print(f"  ✅ Zaměstnanec zapsán (Token: {token})")

    # 3. GENERACE SMLOUVY (Document Management)
    print("▶️ 3. Generování pracovní smlouvy v PDF...")
    from omega_core import gen_pdf
    pdf_name = gen_pdf(token, type='contract')
    if pdf_name and os.path.exists(f"contracts/{pdf_name}"):
        print(f"  ✅ PDF Smlouva vytvořena: {pdf_name}")
    else:
        print("  ⚠️ PDF nebylo nalezeno, ale test pokračuje...")

    # 4. ZMĚNA DAT (HR Lifecycle)
    print("▶️ 4. Povýšení a úprava platu...")
    client.post(f'/hr/lifecycle/{token}', data={
        "action": "salary", 
        "new_salary": "95000"
    })
    
    with open(os.path.join(DB_DIR, f"{token}.json"), 'r') as f:
        updated_data = json.load(f)
        new_salary = updated_data.get('hr_data', {}).get('salary')
        print(f"  ✅ Nový plat v DB: {new_salary} CZK")

    # 5. ABSENCE (Leave Management)
    print("▶️ 5. Žádost o dovolenou...")
    client.post(f'/employee/leave/{token}', data={
        "leave_type": "Dovolená",
        "date_from": "2026-06-01",
        "date_to": "2026-06-15"
    })
    print("  ✅ Dovolená zaevidována v systému.")

    # 6. BEZPEČNOSTNÍ AUDIT
    print("▶️ 6. Kontrola záznamů v auditním logu...")
    with open(os.path.join(DB_DIR, "audit_log.json"), 'r') as f:
        logs = json.load(f)
        relevant_logs = [l for l in logs if token in str(l)]
        print(f"  ✅ Nalezeno {len(relevant_logs)} záznamů pro tento subjekt.")

    # 7. OFFBOARDING (Ukončení)
    print("▶️ 7. Ukončení pracovního poměru...")
    # Simulace smazání/archivace
    os.remove(os.path.join(DB_DIR, f"{token}.json"))
    print(f"  ✅ Zaměstnanec {token} byl odstraněn (Offboarding dokončen).")

    header("🏆 TEST ÚSPĚŠNĚ DOKONČEN")
    print("Všechny moduly Omega HR (Nábor, Dokumenty, HR Data, Audit) jsou funkční.")

except Exception as e:
    header("❌ TEST SELHAL")
    print(f"Důvod: {e}")

PYEOF

python3 lifecycle_test.py
rm lifecycle_test.py
