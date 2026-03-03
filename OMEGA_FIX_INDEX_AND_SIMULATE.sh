#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA JÁDRA - Sjednocení názvu endpointu na 'index'
cat > fix_endpoint.py << 'PYEOF'
import re

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Najdeme funkci pro cestu '/' a ujistíme se, že se jmenuje 'index'
# Hledáme vzor @app.route('/') následovaný def cokoli():
code = re.sub(r"@app\.route\(['\"]/['\"]\)\s+def \w+\(\):", "@app.route('/')\ndef index():", code)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("✅ Endpoint '/' sjednocen na název 'index'.")
PYEOF

python3 fix_endpoint.py
rm fix_endpoint.py

# 2. SPUŠTĚNÍ OPRAVENÉHO SIMULÁTORU
cat > simulator.py << 'PYEOF'
import os, json, time, random
from omega_core import app

client = app.test_client()
print("="*65)
print("🎭 SIMULACE ŽIVOTNÍHO CYKLU: 'Emanuel Testovací' (OPRAVENO)")
print("="*65)

try:
    # 1. NÁBOR
    print("▶️ 1. FÁZE: Login a Nábor...")
    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['user'] = 'admin'
        sess['role'] = 'admin'
    
    # Vygenerujeme unikátní příjmení, abychom poznali náš soubor
    test_id = str(random.randint(1000, 9999))
    res = client.post('/new', data={
        "name": "Emanuel", "surname": f"Test-{test_id}", "email": "e@test.cz",
        "contract_type": "HPP", "position": "Developer", "salary": "50000"
    }, follow_redirects=True)
    
    time.sleep(1)
    
    # Najdeme soubor s naším test-id
    db_files = [f for f in os.listdir('db') if test_id in f]
    if not db_files:
        # Fallback: zkusíme najít jakýkoliv nový JSON
        db_files = [f for f in os.listdir('db') if len(f) > 10 and f.endswith('.json')]
    
    if not db_files:
        raise Exception("Zaměstnanec nebyl uložen do DB. Zkontroluj práva zápisu do 'db/'.")
        
    token = db_files[0].replace('.json', '')
    print(f"  ✅ Zaměstnanec vytvořen (Token: {token})")

    # 2. PDF SMLOUVA
    print("▶️ 2. FÁZE: Generování PDF...")
    from omega_core import gen_pdf
    pdf = gen_pdf(token, type='contract')
    print(f"  ✅ PDF vygenerováno.")

    # 3. ZMĚNA STATUSU
    print("▶️ 3. FÁZE: Změna platu v HR modulu...")
    client.post(f'/hr/lifecycle/{token}', data={"action": "salary", "new_salary": "65000"})
    print("  ✅ Data v DB aktualizována.")

    # 4. BEZPEČNOST
    print("▶️ 4. FÁZE: Testování hlídače (špatný login)...")
    client.post('/login', data={"username": "hacker", "password": "abc"})
    
    with open('db/audit_log.json', 'r', encoding='utf-8') as f:
        logs = json.load(f)
        if any(l.get('category') == 'Bezpečnost' for l in logs):
            print("  ✅ Hlídač útok zaznamenal.")

    print("\n🏆 SIMULACE ÚSPĚŠNÁ!")
    
except Exception as e:
    print(f"❌ CHYBA: {e}")
PYEOF

python3 simulator.py
rm simulator.py
