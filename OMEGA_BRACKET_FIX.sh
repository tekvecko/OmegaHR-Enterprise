#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "🎯 Provádím chirurgickou opravu závorek..."

python3 << 'PYEOF'
import re

path = "omega_core.py"
with open(path, 'r') as f:
    content = f.read()

# Najdeme celou sekci index() a nahradíme ji čistou verzí
pattern = r"@app\.route\('/')\ndef index\(\):.*?return render_template\(.*?\)\s*\n"
replacement = """@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    assets_raw = query_db("SELECT * FROM assets")
    asset_map = {}
    for a in assets_raw:
        token = a['owner_token']
        if token:
            if token not in asset_map: asset_map[token] = []
            asset_map[token].append(a)
    return render_template('index.html', employees=employees, stock=stock, asset_map=asset_map, count=len(employees))
"""

# Použijeme re.DOTALL aby regex prošel přes více řádků
new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(new_content)
print("✅ Funkce index() byla kompletně rekonstruována.")
PYEOF

echo "🚀 Startuji vyčištěné jádro..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
sleep 2

if pgrep -f "omega_core.py" > /dev/null; then
    echo -e "\033[0;32m[SUCCESS]\033[0m Jádro běží stabilně."
    echo "Sleduj logy: tail -f dev_server.log"
else
    echo -e "\033[0;31m[ERROR]\033[0m Jádro stále nestartuje. Zkontroluj 'python3 omega_core.py' ručně."
fi
