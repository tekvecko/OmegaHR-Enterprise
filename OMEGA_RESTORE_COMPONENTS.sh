#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🛠️ Obnovuji chybějící systémové komponenty..."

# 1. Vytvoření kompletní stromové struktury
mkdir -p static/css static/img modules db/mojeid_vault db/ard_logs contracts templates

# 2. Obnova chybějícího CSS (Vizuální komponenta)
cat > static/css/style.css << 'CSSOF'
:root { --main: #3498db; --bg: #0a0a0a; --card: #111; }
body { background: var(--bg); color: #eee; font-family: sans-serif; }
.card { background: var(--card); border-left: 5px solid var(--main); padding: 15px; margin: 10px 0; }
.status-active { color: #2ecc71; font-weight: bold; }
CSSOF

# 3. Obnova Helper modulu (Logická komponenta)
cat > modules/helpers.py << 'PYOF'
import uuid
def generate_mojeid():
    return f"ID-{str(uuid.uuid4())[:8].upper()}"

def format_salary(val):
    return "{:,} CZK".format(int(val)).replace(",", " ")
PYOF

# 4. Oprava oprávnění
chmod -R 755 static modules templates

echo "✅ Komponenty obnoveny. Systém je nyní strukturálně kompletní."
