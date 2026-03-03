import json, os, uuid
from omega_core import app

# Cesta k DB
base_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

with app.test_request_context():
    # Simulujeme data, která by přišla z formuláře
    token = str(uuid.uuid4())[:8]
    data = {
        "personal_data": {"name": "Injekce", "surname": "Uspesna", "email": "test@omega.cz"},
        "hr_data": {"position": "System", "salary": "100000"},
        "token": token
    }
    
    path = f"{base_path}/{token}.json"
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"✅ INJEKCE OK: Vytvořen soubor {token}.json")
    except Exception as e:
        print(f"❌ INJEKCE SELHALA: {e}")
