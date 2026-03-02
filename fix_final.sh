#!/data/data/com.termux/files/usr/bin/bash
set -e

cat > patch_nulls.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import re

print("🛠️ Aplikuji bezpečnostní 'neprůstřelnou' vrstvu do PDF generátoru...")
with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Zabráníme pádu, pokud má kandidát v databázi prázdná data (null)
core = core.replace("c.get('hr_data', {}).get", "(c.get('hr_data') or {}).get")
core = core.replace("c.get('personal_data', {}).get", "(c.get('personal_data') or {}).get")
core = core.replace("c['hr_data'].get", "(c.get('hr_data') or {}).get")
core = core.replace("c['personal_data'].get", "(c.get('personal_data') or {}).get")

# Zabráníme pádu, pokud by chybělo IČO nebo nastavení firmy
core = core.replace("comp.get", "(comp or {}).get")

# Pojistka pro načítání z admin panelu
if "def load_settings():" in core:
    core = core.replace("return json.load(f)", "data = json.load(f)\n        return data if data else {}")

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(core)
print("✅ Kód PDF generátoru bezpečně zazáplatován.")
PYEOF

chmod +x patch_nulls.py
/data/data/com.termux/files/usr/bin/python patch_nulls.py
rm patch_nulls.py

echo "🚀 Restartuji opravený server..."
pkill -f python || true
./start.sh

echo "🔄 Spouštím vynucené přegenerování VŠECH smluv..."
/data/data/com.termux/files/usr/bin/python force_regenerate.py
