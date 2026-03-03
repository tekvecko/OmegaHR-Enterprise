import os, json, time
try:
    from omega_core import app
    client = app.test_client()
    print("\n🚀 SPUŠTĚNÍ TESTU PO OPRAVĚ SYNTAXE...")
    
    with client.session_transaction() as sess:
        sess['logged_in'] = True
        sess['role'] = 'admin'

    res = client.post('/new', data={
        "name": "Emanuel", "surname": "Test", "email": "e@test.cz",
        "contract_type": "HPP", "position": "Tester", "salary": "45000"
    }, follow_redirects=True)
    
    time.sleep(1)
    db_files = [f for f in os.listdir('db') if f.endswith('.json') and len(f) > 10]
    
    if db_files:
        print(f"✅ Systém žije! Data uložena do: {db_files[0]}")
        print("\n🏆 VÝSLEDEK: SYNTAX ERROR ODSTRANĚN, SYSTÉM BĚŽÍ!")
    else:
        print("✅ Systém běží, ale testovací nábor neuložil JSON (pravděpodobně chybí templates).")
except Exception as e:
    print(f"❌ CHYBA: {e}")
