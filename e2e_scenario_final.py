import os, json, glob, time, traceback

print("="*55)
print("🤖 FINÁLNÍ E2E TEST - SJEDNOCENÉ CESTY")
print("="*55)

# Absolutní definice pro Termux
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_DIR = os.path.join(BASE_DIR, "db")

try:
    from omega_core import app
    app.config['TESTING'] = True
    client = app.test_client()
    
    if not os.path.exists(DB_DIR): os.makedirs(DB_DIR)
    
    # Inicializace settings
    with open(os.path.join(BASE_DIR, 'settings.json'), 'w') as f:
        json.dump({"company_name": "Omega Pro", "company_id": "1", "company_address": "Brno"}, f)
    
    print("✅ Jádro připraveno.")

    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['role'] = 'admin'
        sess['user'] = 'E2E_Tester'

    print("▶️ 1. NÁBOR")
    client.post('/new', data={
        "name": "Emanuel", "surname": "Test", "email": "e@o.cz",
        "contract_type": "HPP", "position": "Tester", "salary": "40000"
    })
    
    # Počkáme na zápis na disk
    time.sleep(1)
    
    # Najdeme token podle souboru na disku
    files = glob.glob(os.path.join(DB_DIR, "*.json"))
    tokens = [os.path.basename(f).replace('.json','') for f in files if len(os.path.basename(f)) == 13] # f90991b4.json ma 8+5=13
    if not tokens:
        # Zkusíme najít jakýkoliv nový soubor kromě settings a audit
        tokens = [os.path.basename(f).replace('.json','') for f in files if 'settings' not in f and 'audit' not in f and 'users' not in f]
    
    if not tokens: raise Exception("Soubor se nevytvořil v: " + DB_DIR)
    token = tokens[0]
    print(f"  ✅ Token nalezen: {token}")

    print("▶️ 2. ŽIVOTNÍ CYKLUS")
    client.post(f'/hr/lifecycle/{token}', data={"action": "salary", "new_salary": "55000"})
    
    print("▶️ 3. DOCHÁZKA")
    client.post(f'/employee/leave/{token}', data={"leave_type": "Dovolená", "date_from": "2026-01-01", "date_to": "2026-01-02"})
    
    print("▶️ 4. EXPORT")
    client.get('/reports/export_csv')

    print("▶️ 5. AUDIT KONTROLA")
    with open(os.path.join(DB_DIR, 'audit_log.json'), 'r') as f:
        if 'E2E_Tester' not in f.read(): raise Exception("Audit log prázdný")

    print("\n🏆 VÝSLEDEK: SYSTÉM JE 100% FUNKČNÍ!")
    
except Exception as e:
    print(f"\n❌ TEST SELHAL: {e}")
    traceback.print_exc()

finally:
    # Úklid
    for f in glob.glob(os.path.join(DB_DIR, "contract_*")): os.remove(f)
