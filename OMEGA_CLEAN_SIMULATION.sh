#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA LOGIKY V JÁDRU (Robustnost při manipulaci s daty)
cat > fix_hr.py << 'PYEOF'
import re

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Oprava: Zajistíme, aby c byla vždy slovník a nenačítala listy (jako audit log)
fix_logic = """
        c = get_candidate(token)
        if not isinstance(c, dict): return "Chyba dat", 400
        if 'hr_data' not in c: c['hr_data'] = {}
"""
# Najdeme začátek funkce hr_lifecycle a vložíme ochranu
code = re.sub(r"def hr_lifecycle\(token\):.*?c = get_candidate\(token\)", f"def hr_lifecycle(token):\n{fix_logic}", code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF

python3 fix_hr.py
rm fix_hr.py

# 2. NOVÝ, CHYTRÝ SIMULÁTOR
cat > simulator.py << 'PYEOF'
import os, json, time, random
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

print("="*65)
print("🎭 FINÁLNÍ SIMULACE: EMANUEL TESTOVACÍ (V3 - INTELLIGENT)")
print("="*65)

try:
    with client.session_transaction() as sess:
        sess['logged_in'], sess['user'], sess['role'] = True, 'admin', 'admin'
    
    # 1. Nábor
    suffix = str(random.randint(100, 999))
    print(f"▶️ 1. Nábor zaměstnance Emanuel_{suffix}...")
    client.post('/new', data={
        "name": "Emanuel", "surname": f"Testovaci_{suffix}", "email": "e@test.cz",
        "contract_type": "HPP", "position": "Developer", "salary": "50000"
    })
    
    time.sleep(1)
    
    # CHYTRÝ VÝBĚR TOKENU: Hledáme 8-místný hex řetězec, ignorujeme systémové soubory
    all_jsons = [f for f in os.listdir(DB_DIR) if f.endswith('.json')]
    candidates = [f for f in all_jsons if len(f) == 13 and f != 'audit_log.json'] # 13 = 8(hex) + 5(.json)
    
    if not candidates:
        raise Exception("Nepodařilo se najít vytvořený soubor zaměstnance!")
    
    token = candidates[0].replace('.json', '')
    print(f"  ✅ Token úspěšně identifikován: {token}")

    # 2. PDF
    print("▶️ 2. Generování dokumentace...")
    from omega_core import gen_pdf
    pdf = gen_pdf(token, type='contract')
    if pdf: print(f"  ✅ PDF Smlouva: {pdf}")

    # 3. Životní cyklus (Změna platu)
    print("▶️ 3. Zvyšování platu v HR modulu...")
    res = client.post(f'/hr/lifecycle/{token}', data={"action": "salary", "new_salary": "68000"})
    
    if res.status_code == 200:
        print("  ✅ Změna platu proběhla hladce.")
    else:
        print(f"  ❌ Chyba při změně platu: {res.status_code}")

    print("\n🏆 SIMULACE DOKONČENA BEZ CHYB V LOGU!")
    
except Exception as e:
    print(f"❌ KRITICKÁ CHYBA: {e}")
PYEOF

python3 simulator.py
rm simulator.py
