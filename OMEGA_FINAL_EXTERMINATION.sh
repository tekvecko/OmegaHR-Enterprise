#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🧹 Čistím cache a staré procesy..."
find . -name "*.pyc" -delete
find . -name "__pycache__" -delete
pkill -f python || true
sleep 1

# 1. POSLEDNÍ REVIZE JÁDRA (Vynucení jednoduchosti)
cat > final_check.py << 'PYEOF'
import os
path = "omega_core.py"
with open(path, 'r') as f:
    code = f.read()
# Ujistíme se, že session nepotřebuje tajný klíč pro tento test
if "app.secret_key" not in code:
    code = "from flask import Flask, request, session, redirect, url_for, render_template\napp = Flask(__name__)\napp.secret_key='test'\n" + code
with open(path, 'w') as f:
    f.write(code)
PYEOF
python3 final_check.py

# 2. START SERVERU NA POZADÍ
nohup python3 omega_core.py > server.log 2>&1 &
echo "⏳ Čekám na start serveru..."
sleep 5

# 3. TEST PŘES CURL (Simulace skutečného světa)
echo -e "\n============================================================"
echo "           🌐 EXTERNÍ VERIFIKACE PŘES PORT 5000"
echo "============================================================"

# A. Nábor
TOKEN_FILE="last_token.txt"
curl -s -X POST -d "name=Emanuel&surname=FinalTest&email=f@test.cz&position=Dev&salary=85000" http://127.0.0.1:5000/new > /dev/null

# Najdeme token nového souboru
TOKEN=$(ls -t db/ | grep -v "audit" | head -n 1 | sed 's/\.json//')
echo "▶️ Vytvořen zaměstnanec: $TOKEN"

# B. Změna platu (Simulace HR akce)
echo "▶️ Odesílám příkaz ke změně platu na 95000..."
curl -s -X POST -d "action=salary&new_salary=95000" http://127.0.0.1:5000/hr/lifecycle/$TOKEN > /dev/null
sleep 1

# C. Fyzická kontrola na disku
echo -e "\n🔍 KONTROLA SOUBORU NA DISKU:"
grep "salary" db/$TOKEN.json

echo -e "\n📜 KONTROLA AUDIT LOGU:"
grep "$TOKEN" db/audit_log.json || echo "❌ Token v logu nenalezen."

echo -e "\n============================================================"
pkill -f python || true
