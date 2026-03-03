#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔌 Přepínám Flask na port 8080..."

cat > port_fix.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Změna portu v app.run
if "port=" in code:
    code = re.sub(r"port=\d+", "port=8080", code)
else:
    code = code.replace("app.run(", "app.run(port=8080, ")

# Zajištění hostu 127.0.0.1 pro zrok
if "host=" not in code:
    code = code.replace("app.run(", "app.run(host='127.0.0.1', ")

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF

python3 port_fix.py
rm port_fix.py

# Tvrdý restart v Ubuntu (kde běží zrok)
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true; cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

echo "✅ Flask nyní běží na portu 8080. Sleduj log zroku, ERROR by měl zmizet."
