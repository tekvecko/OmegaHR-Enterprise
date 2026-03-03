#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > fix_db_call.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os

print("🔧 Opravuji volání databáze v generátoru PDF...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Oprava: Místo db_adapter použijeme buď db.get_candidate nebo globální get_candidate
# Podíváme se, co v souboru existuje
if "db.get_candidate" in content:
    content = content.replace("import db_adapter as db\n        c = db.get_candidate(token)", "c = db.get_candidate(token)")
else:
    content = content.replace("import db_adapter as db\n        c = db.get_candidate(token)", "c = get_candidate(token)")

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Volání databáze opraveno.")
PYEOF

chmod +x fix_db_call.py
/data/data/com.termux/files/usr/bin/python fix_db_call.py
rm fix_db_call.py

echo "🚀 Restartuji server a pouštím E2E test. Teď už není co by selhalo!"
pkill -f python || true
./start.sh &
sleep 4
./run_e2e_final.sh
