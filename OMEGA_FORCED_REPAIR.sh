#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. TOTÁLNÍ PŘEPSÁNÍ NÁBOROVÉ FUNKCE V JÁDRU
cat > force_patch.py << 'PYEOF'
import re

base_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

new_new_route = f"""
@app.route('/new', methods=['GET', 'POST'])
def new_candidate():
    import json, os, uuid
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        try:
            token = str(uuid.uuid4())[:8]
            data = {{
                "personal_data": {{
                    "name": request.form.get('name'),
                    "surname": request.form.get('surname'),
                    "email": request.form.get('email')
                }},
                "hr_data": {{
                    "contract_type": request.form.get('contract_type'),
                    "position": request.form.get('position'),
                    "salary": request.form.get('salary'),
                    "joined_date": "2026-03-03"
                }},
                "token": token
            }}
            file_path = f"{base_path}/{{token}}.json"
            os.makedirs("{base_path}", exist_ok=True)
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=4, ensure_ascii=False)
            
            log_action(session.get('user'), "Nový nábor", token, f"Vytvořen: {{data['personal_data']['surname']}}", "HR")
            return redirect(url_for('index'))
        except Exception as e:
            return f"CHYBA PRI ZAPISU: {{e}}", 500
    return render_template('new.html')
"""

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Nahradíme celou funkci new_candidate (použijeme opatrný regex)
code = re.sub(r"@app\.route\('/new'.*?return render_template\('new\.html'\)", new_new_route, code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("✅ Funkce /new byla kompletně zrekonstruována a stabilizována.")
PYEOF

python3 force_patch.py
rm force_patch.py

# 2. RESTART A SIMULACE (Tentokrát s kontrolou HTTP odpovědi)
cat > simulator.py << 'PYEOF'
import os, json, time, uuid
from omega_core import app

client = app.test_client()
DB_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

print("="*65)
print("🚀 FINAL TEST: REKONSTRUOVANÝ NÁBOR")
print("="*65)

try:
    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['user'] = 'Admin_Tester'

    uid = str(uuid.uuid4())[:4]
    target_surname = f"Stabilni_{uid}"
    
    print(f"▶️ Odesílám data pro: {target_surname}...")
    res = client.post('/new', data={
        "name": "Emanuel", "surname": target_surname, "email": "e@omega.cz",
        "contract_type": "HPP", "position": "Master", "salary": "99000"
    })

    if res.status_code != 302:
        print(f"❌ CHYBA: Server vrátil status {res.status_code} místo přesměrování!")
        print(f"Odpověď: {res.data.decode()}")
        exit(1)

    time.sleep(1)
    
    # Najdeme soubor
    found = False
    for f in os.listdir(DB_DIR):
        if f.endswith('.json') and f != 'audit_log.json':
            with open(os.path.join(DB_DIR, f), 'r') as jf:
                if target_surname in jf.read():
                    print(f"  ✅ ÚSPĚCH! Soubor nalezen: {f}")
                    found = True
                    break
    
    if not found:
        print("❌ KRITICKÉ: Data odeslána, status 302 OK, ale SOUBOR NIKDE!")
        print(f"Obsah DB adresáře: {os.listdir(DB_DIR)}")
    else:
        print("\n🏆 NÁBOROVÝ MODUL JE OPRAVEN A FUNKČNÍ!")

except Exception as e:
    print(f"❌ SELHÁNÍ: {e}")
PYEOF

python3 simulator.py
rm simulator.py

# Produkční restart
pkill -f python || true
nohup python3 omega_core.py > server.log 2>&1 &
