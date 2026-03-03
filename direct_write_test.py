import json, os, uuid
base_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
token = "DIRECT_" + str(uuid.uuid4())[:4]
data = {"name": "Test", "surname": "Direct", "token": token}
try:
    with open(f"{base_path}/{token}.json", 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
    print(f"✅ Přímý zápis OK: {token}.json")
except Exception as e:
    print(f"❌ Přímý zápis SELHAL: {e}")
