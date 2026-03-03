#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. VLOŽENÍ DIAGNOSTIKY PŘÍMO DO FUNKCE
cat > inject_debug.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Vložíme zápis debug souboru hned na začátek funkce hr_lifecycle
debug_trigger = """
@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    with open('DEBUG_HIT.txt', 'a') as f:
        f.write(f"Hit for {token} with data {request.form}\\n")
"""
code = re.sub(r"@app\.route\('/hr/lifecycle/.*?def hr_lifecycle\(token\):", debug_trigger, code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 inject_debug.py

# 2. RESTART V UBUNTU
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true; cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"
sleep 3

# 3. TEST PŘES ZROK
echo "📡 Posílám signál přes zrok..."
curl -s -X POST -d "action=salary&new_salary=99999" https://p3085t3mscgc.share.zrok.io/hr/lifecycle/9b9c49e5 > /dev/null

# 4. KONTROLA
echo "🔎 Výsledek diagnostiky:"
if [ -f DEBUG_HIT.txt ]; then
    echo "✅ ZÁSAH POTVRZEN! (Server požadavek přijal, ale selhal v zápisu do DB)"
    cat DEBUG_HIT.txt
else
    echo "❌ Ticho po pěšině. Požadavek přes zrok k funkci vůbec nedorazil."
    echo "Zkontroluj, zda zrok share skutečně míří na port 5000."
fi
