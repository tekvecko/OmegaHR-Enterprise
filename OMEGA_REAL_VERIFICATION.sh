#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA TESTOVACÍHO SKRIPTU (Přidání striktních kontrol)
cat > lifecycle_test.py << 'PYEOF'
import os, json, time, uuid
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

def header(text):
    print(f"\n{'='*60}\n{text.center(60)}\n{'='*60}")

header("🧪 OMEGA HR - STRIKTNÍ VERIFIKACE CYKLU")

try:
    # 1. AUTH
    print("▶️ 1. Login HR...")
    client.post('/login', data={"username": "hr", "password": "hr"})
    
    # 2. NÁBOR
    test_id = str(uuid.uuid4())[:6]
    surname = f"Sim_{test_id}"
    print(f"▶️ 2. Nábor: Emanuel {surname}...")
    res = client.post('/new', data={
        "name": "Emanuel", "surname": surname, "email": "e@test.cz",
        "position": "Dev", "salary": "85000"
    }, follow_redirects=True)
    
    # Najít token
    token = None
    for f in os.listdir(DB_DIR):
        if surname in open(os.path.join(DB_DIR, f), 'r').read():
            token = f.replace('.json', '')
            break
    if not token: raise Exception("Nábor selhal - soubor nevytvořen!")
    print(f"  ✅ Token: {token}")

    # 3. ZMĚNA PLATU (Tady byla chyba!)
    print(f"▶️ 3. Úprava platu na 95000...")
    # Musíme poslat data přesně tak, jak je očekává hr_lifecycle v omega_core
    res = client.post(f'/hr/lifecycle/{token}', data={
        "action": "salary", 
        "new_salary": "95000"
    }, follow_redirects=True)
    
    # Fyzická kontrola souboru
    with open(os.path.join(DB_DIR, f"{token}.json"), 'r') as f:
        data = json.load(f)
        current_salary = str(data.get('hr_data', {}).get('salary'))
        if current_salary == "95000":
            print(f"  ✅ Změna platu v DB potvrzena: {current_salary} CZK")
        else:
            print(f"  ❌ CHYBA: Plat v DB je stále {current_salary}!")

    # 4. AUDIT LOG
    print("▶️ 4. Verifikace Audit Logu...")
    with open(os.path.join(DB_DIR, "audit_log.json"), 'r') as f:
        log_content = f.read()
        if token in log_content:
            print(f"  ✅ Auditní stopa pro {token} nalezena.")
        else:
            print(f"  ❌ CHYBA: Audit log o tokenu {token} mlčí!")

    # 5. CLEANUP
    os.remove(os.path.join(DB_DIR, f"{token}.json"))
    print("\n🏁 Simulace dokončena.")

except Exception as e:
    print(f"\n❌ KRITICKÁ CHYBA TESTU: {e}")

PYEOF

# 2. SPUŠTĚNÍ
python3 lifecycle_test.py
rm lifecycle_test.py
