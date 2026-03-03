#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > simulator.py << 'PYEOF'
import os, json, time, random
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

print("="*65)
print("🔍 DETEKTIVNÍ SIMULACE: HLEDÁNÍ ZTRACENÉHO DATA")
print("="*65)

try:
    with client.session_transaction() as sess:
        sess['logged_in'], sess['user'], sess['role'] = True, 'admin', 'admin'
    
    # 1. Snímek stavu PŘED náborem
    files_before = set(os.listdir(DB_DIR))
    
    # 2. Nábor
    suffix = str(random.randint(1000, 9999))
    print(f"▶️ 1. Nábor Emanuel_{suffix}...")
    client.post('/new', data={
        "name": "Emanuel", "surname": f"Detektiv_{suffix}", "email": "e@test.cz",
        "contract_type": "HPP", "position": "Tester", "salary": "50000"
    })
    
    time.sleep(1.5)
    
    # 3. Snímek stavu PO náboru a porovnání
    files_after = set(os.listdir(DB_DIR))
    new_files = list(files_after - files_before)
    
    # Odfiltrujeme logy a settings, pokud se změnily
    token_files = [f for f in new_files if f.endswith('.json') and 'audit' not in f and 'settings' not in f]
    
    if not token_files:
        print("❌ CHYBA: Žádný nový JSON soubor se neobjevil!")
        print(f"DEBUG: Seznam souborů v DB: {os.listdir(DB_DIR)}")
        raise Exception("Aplikace nevytvořila soubor na disku.")
    
    token = token_files[0].replace('.json', '')
    print(f"  ✅ Detekován nový soubor: {token_files[0]}")
    print(f"  ✅ Token pro operace: {token}")

    # 4. HR Operace
    print(f"▶️ 2. Změna platu pro token {token}...")
    res = client.post(f'/hr/lifecycle/{token}', data={"action": "salary", "new_salary": "72000"})
    
    if res.status_code == 200:
        print("  ✅ Změna platu úspěšně zapsána.")
        
        # Kontrola, zda se data v souboru opravdu změnila
        with open(os.path.join(DB_DIR, token_files[0]), 'r') as f:
            data = json.load(f)
            new_val = data.get('hr_data', {}).get('salary')
            print(f"  📊 Ověření dat v souboru: Plat = {new_val}")
    else:
        print(f"  ❌ Server vrátil chybu {res.status_code}")

    print("\n🏆 DETEKTIVNÍ SIMULACE DOKONČENA!")
    
except Exception as e:
    print(f"❌ KRITICKÉ SELHÁNÍ: {e}")
PYEOF

python3 simulator.py
rm simulator.py
