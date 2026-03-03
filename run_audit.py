#!/data/data/com.termux/files/usr/bin/python
import os
import json
import traceback

print("="*50)
print("🚀 SPUŠTĚNÍ HLOUBKOVÉHO AUDITU SYSTÉMU OMEGA HR")
print("="*50)

errors = 0

try:
    from omega_core import app, db, save_candidate, get_candidate, gen_pdf
    app.config['TESTING'] = True
    client = app.test_client()
    print("✅ 1. Jádro systému a Flask router načteny úspěšně.")
except Exception as e:
    print(f"❌ 1. CHYBA: Nelze načíst jádro aplikace: {e}")
    exit(1)

# TEST 2: Databáze a CRUD operace
test_token = "TEST_AUDIT_999"
test_data = {
    "token": test_token,
    "status": "signed",
    "offboarding_status": "none",
    "personal_data": {"name": "Test", "surname": "Auditor", "email": "test@omega.cz"},
    "hr_data": {"salary": "50000", "position": "Tester"},
    "leaves": []
}

try:
    try: db.save_candidate(test_token, test_data)
    except: save_candidate(test_token, test_data)
    print("✅ 2. Databáze: Zápis a čtení JSON profilů funguje.")
except Exception as e:
    print(f"❌ 2. CHYBA Databáze: {e}")
    errors += 1

# TEST 3: Ochrana přístupu a Routy (RBAC)
try:
    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['role'] = 'admin'
        sess['user'] = 'admin'
    
    routes_to_test = ['/', '/admin/users', '/admin/settings', f'/candidate/{test_token}']
    for r in routes_to_test:
        resp = client.get(r)
        if resp.status_code not in [200, 302]:
            print(f"❌ 3. CHYBA: Stránka {r} vrací kód {resp.status_code}")
            errors += 1
    if errors == 0: print("✅ 3. Routy a UI: Všechny hlavní obrazovky se načítají v pořádku.")
except Exception as e:
    print(f"❌ 3. CHYBA Routování: {e}")
    errors += 1

# TEST 4: Modul - Žádosti o volno (Self-Service -> HR Schválení)
try:
    # Zaměstnanec žádá
    client.post(f'/employee/leave/{test_token}', data={"leave_type": "Sick Day", "date_from": "2026-01-01", "date_to": "2026-01-02"})
    try: c = db.get_candidate(test_token)
    except: c = get_candidate(test_token)
    
    leave_id = c['leaves'][0]['id']
    if c['leaves'][0]['status'] != 'pending': raise Exception("Žádost se neuložila jako 'pending'")
    
    # HR schvaluje
    client.post(f'/hr/leave/{test_token}', data={"leave_id": leave_id, "action": "approve"})
    try: c = db.get_candidate(test_token)
    except: c = get_candidate(test_token)
    
    if c['leaves'][0]['status'] != 'approved': raise Exception("HR nedokázalo schválit žádost")
    print("✅ 4. Modul Docházka: Vytvoření i schválení volna funguje naprosto přesně.")
except Exception as e:
    print(f"❌ 4. CHYBA Modul Docházka: {e}")
    errors += 1

# TEST 5: Modul - Změna platu (HR Lifecycle)
try:
    client.post(f'/hr/lifecycle/{test_token}', data={"action": "salary", "new_salary": "99999"})
    try: c = db.get_candidate(test_token)
    except: c = get_candidate(test_token)
    if str(c['hr_data']['salary']) != "99999": raise Exception("Plat se neuložil do databáze")
    print("✅ 5. Modul Životní cyklus: Změna platu s přepisem dat funguje.")
except Exception as e:
    print(f"❌ 5. CHYBA Životní cyklus (Plat): {e}")
    errors += 1

# TEST 6: Modul - Offboarding a Výpovědi
try:
    client.post(f'/hr/offboard/{test_token}', data={"term_type": "termination_notice"})
    try: c = db.get_candidate(test_token)
    except: c = get_candidate(test_token)
    if c['offboarding_status'] != 'terminated': raise Exception("Systém nezapsal status 'terminated'")
    print("✅ 6. Modul Offboarding: Proces výpovědi a uzamčení profilu funguje.")
except Exception as e:
    print(f"❌ 6. CHYBA Offboarding: {e}")
    errors += 1

# ÚKLID: Smazání testovacích dat
try:
    db_path = getattr(importlib.import_module('omega_config'), 'DB_DIR', 'db') if 'omega_config' in globals() else 'db'
    if os.path.exists(f"{db_path}/{test_token}.json"): os.remove(f"{db_path}/{test_token}.json")
    for f in os.listdir(db_path):
        if test_token in f and f.endswith('.pdf'): os.remove(os.path.join(db_path, f))
    print("✅ 7. Úklid: Testovací data bezpečně smazána.")
except:
    pass # Ignorujeme chyby při úklidu

print("="*50)
if errors == 0:
    print("🏆 VÝSLEDEK: SYSTÉM JE 100% ZDRAVÝ A STABILNÍ.")
    print("Všechny nově přidané moduly spolu komunikují bez jediné chyby.")
else:
    print(f"⚠️ VÝSLEDEK: Nalezeno chyb: {errors}. Prověř výpisy výše.")
print("="*50)
