import json, os
path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db/users.json"
users = {
    "admin": {"password": "admin", "role": "admin"},
    "hr": {"password": "hr", "role": "hr"}
}
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w', encoding='utf-8') as f:
    json.dump(users, f, indent=4)
print("✅ Uživatel hr/hr byl nastaven.")
