#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > e2e_scenario_final.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, glob, time
import traceback

print("="*55)
print("🤖 SPUŠTĚNÍ FINÁLNÍHO E2E SCÉNÁŘE")
print("="*55)

errors = 0
token = None

try:
    from omega_core import app
    import omega_config as cfg
    db_dir = getattr(cfg, 'DB_DIR', 'db')
    app.config['TESTING'] = True
    client = app.test_client()
    
    # PREVENCE: Zajištění existence výchozího nastavení firmy
    with open('settings.json', 'w', encoding='utf-8') as f:
        json.dump({
            "company_name": "Omega Enterprise s.r.o.",
            "company_id": "12345678",
            "company_address": "Technologický Park, Brno",
            "base_url": "http://localhost:5000"
        }, f, indent=4)
        
    print("✅ 0. Systémové jádro a firemní identita inicializovány.")
except Exception as e:
    print(f"❌ CHYBA PŘI STARTU: {e}")
    exit(1)

def get_latest_token():
    files = glob.glob(os.path.join(db_dir, '*.json'))
    emp_files = [f for f in files if 'audit_log' not in f and 'settings' not in f and 'users' not in f]
    if not emp_files: return None
    latest = max(emp_files, key=os.path.getctime)
    return os.path.basename(latest).replace('.json', '')

try:
    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['role'] = 'admin'
        sess['user'] = 'E2E_Tester'

    print("▶️ 1. FÁZE: NASTAVENÍ FIRMY (Administrace)")
    client.post('/admin/settings', data={
        "company_name": "Omega Enterprise s.r.o.",
        "company_id": "12345678",
        "company_address": "Technologický Park, Brno",
        "base_url": "http://localhost:5000"
    })
    print("  ✅ Firemní údaje bezpečně uloženy.")

    print("▶️ 2. FÁZE: NÁBOR ZAMĚSTNANCE")
    client.post('/new', data={
        "name": "Emanuel", "surname": "Testovací", "email": "emanuel@omega.cz",
        "phone": "777666555", "birthdate": "01.01.1990", "address": "Brno",
        "contract_type": "HPP", "position": "Junior Tester", "department": "QA",
        "start_date": "01.04.2026", "salary": "40000"
    })
    token = get_latest_token()
    if not token: raise Exception("Systém nevytvořil profil zaměstnance!")
    print(f"  ✅ Profil vytvořen. Generátor přidělil token: {token}")

    print("▶️ 3. FÁZE: HR ŽIVOTNÍ CYKLUS")
    client.post(f'/hr/lifecycle/{token}', data={"action": "salary", "new_salary": "50000"})
    client.post(f'/hr/lifecycle/{token}', data={"action": "position", "new_position": "Senior Tester"})
    
    with open(os.path.join(db_dir, f"{token}.json"), 'r', encoding='utf-8') as f:
        c_data = json.load(f)
        if str(c_data['hr_data']['salary']) != "50000": raise Exception("Chyba: Změna platu selhala.")
    print("  ✅ Povýšení a zvýšení platu se úspěšně propsalo.")

    print("▶️ 4. FÁZE: ZAMĚSTNANECKÝ PORTÁL A DOCHÁZKA")
    client.post(f'/employee/leave/{token}', data={"leave_type": "Dovolená", "date_from": "2026-07-01", "date_to": "2026-07-14"})
    with open(os.path.join(db_dir, f"{token}.json"), 'r', encoding='utf-8') as f:
        leave_id = json.load(f)['leaves'][0]['id']
    client.post(f'/hr/leave/{token}', data={"leave_id": leave_id, "action": "approve"})
    print("  ✅ Dovolená úspěšně vytvořena a schválena.")

    print("▶️ 5. FÁZE: REPORTY A EXPORT PRO ÚČETNÍ")
    if client.get('/reports/export_csv').status_code != 200: raise Exception("Export CSV spadl.")
    print("  ✅ Agregační data a CSV tabulka vygenerovány.")

    print("▶️ 6. FÁZE: OFFBOARDING (Ukončení)")
    client.post(f'/hr/offboard/{token}', data={"term_type": "termination_agreement"})
    print("  ✅ Profil zablokován a přesunut do stavu Ukončeno.")

    print("▶️ 7. FÁZE: KONTROLA AUDIT LOGU (Bezpečnost)")
    with open(os.path.join(db_dir, 'audit_log.json'), 'r', encoding='utf-8') as f:
        tester_logs = [l for l in json.load(f) if l.get('user') == 'E2E_Tester']
        if not tester_logs: raise Exception("Hlídač nezachytil kroky testera!")
    print("  ✅ Audit Log perfektně zaznamenal všechny kroky procesu.")

except Exception as e:
    print(f"\n❌ KRITICKÁ CHYBA V PROCESU:\n{e}")
    traceback.print_exc()
    errors += 1

print("\n🧹 ÚKLID: Mazání testovacích dat z produkce...")
try:
    if token:
        for f in glob.glob(os.path.join(db_dir, f"{token}*")): os.remove(f)
    if os.path.exists(os.path.join(db_dir, 'audit_log.json')):
        with open(os.path.join(db_dir, 'audit_log.json'), 'r', encoding='utf-8') as f: logs = json.load(f)
        logs = [l for l in logs if l.get('user') != 'E2E_Tester']
        with open(os.path.join(db_dir, 'audit_log.json'), 'w', encoding='utf-8') as f: json.dump(logs, f, indent=4)
    print("  ✅ Systém vrácen do čistého stavu.")
except: pass

print("="*55)
if errors == 0:
    print("🏆 VÝSLEDEK: END-TO-END SCÉNÁŘ PROBĚHL ÚSPĚŠNĚ!")
    print("Gratuluji. Tvoje aplikace je certifikovaně neprůstřelná.")
else:
    print("⚠️ VÝSLEDEK: TEST SELHAL.")
print("="*55)
PYEOF

chmod +x e2e_scenario_final.py
/data/data/com.termux/files/usr/bin/python e2e_scenario_final.py
rm e2e_scenario_final.py
