#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA JÁDRA - ABSOLUTNÍ CESTY PRO DB
cat > path_repair.py << 'PYEOF'
import re, os

base_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Nahrazení všech 'db/{token}.json' za absolutní cestu
code = code.replace("f'db/{token}.json'", f"f'{base_path}/{{token}}.json'")
code = code.replace("'db/audit_log.json'", f"'{base_path}/audit_log.json'")
code = code.replace("'db/users.json'", f"'{base_path}/users.json'")

# Oprava funkce get_candidate, aby také používala absolutní cestu
if 'def get_candidate(token):' in code:
    get_cand_fix = f"""
def get_candidate(token):
    import json, os
    p = f"{base_path}/{{token}}.json"
    if os.path.exists(p):
        with open(p, 'r', encoding='utf-8') as f: return json.load(f)
    return None
"""
    code = re.sub(r"def get_candidate\(token\):.*?return None", get_cand_fix, code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("📍 Všechny cesty k DB byly zafixovány na absolutní adresy.")
PYEOF

python3 path_repair.py
rm path_repair.py

# 2. NOVÁ DETEKTIVNÍ SIMULACE
cat > simulator.py << 'PYEOF'
import os, json, time, uuid
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

print("="*65)
print("🚀 ULTIMÁTNÍ SIMULACE S ABSOLUTNÍMI CESTAMI")
print("="*65)

try:
    with client.session_transaction() as sess:
        sess['logged_in'], sess['user'], sess['role'] = True, 'admin', 'admin'
    
    # 1. Nábor (vytvoříme unikátní příjmení)
    uid = str(uuid.uuid4())[:8]
    print(f"▶️ 1. Nábor Emanuel_{uid}...")
    
    res = client.post('/new', data={
        "name": "Emanuel", "surname": f"Final_{uid}", "email": "e@omega.cz",
        "contract_type": "HPP", "position": "Master", "salary": "99000"
    }, follow_redirects=True)
    
    time.sleep(2) # Počkáme na disk
    
    # 2. Hledání souboru (podle obsahu, ne podle jména)
    found_token = None
    for f in os.listdir(DB_DIR):
        if f.endswith('.json') and f != 'audit_log.json':
            with open(os.path.join(DB_DIR, f), 'r') as jf:
                if f"Final_{uid}" in jf.read():
                    found_token = f.replace('.json', '')
                    break
    
    if not found_token:
        print(f"❌ CHYBA: Soubor pro Emanuel_{uid} stále nebyl nalezen v {DB_DIR}!")
        print(f"DEBUG DB: {os.listdir(DB_DIR)}")
        raise Exception("Zápis selhal i s absolutní cestou.")
    
    print(f"  ✅ Soubor nalezen! Token: {found_token}")

    # 3. HR Operace (Změna platu)
    print(f"▶️ 2. Změna platu pro {found_token}...")
    client.post(f'/hr/lifecycle/{found_token}', data={"action": "salary", "new_salary": "120000"})
    
    with open(os.path.join(DB_DIR, f"{found_token}.json"), 'r') as f:
        data = json.load(f)
        val = data.get('hr_data', {}).get('salary')
        print(f"  📊 Kontrola v DB: Nový plat = {val}")

    print("\n🏆 VÍTĚZNÁ SIMULACE DOKONČENA!")
    
except Exception as e:
    print(f"❌ SELHÁNÍ: {e}")
PYEOF

python3 simulator.py
rm simulator.py
