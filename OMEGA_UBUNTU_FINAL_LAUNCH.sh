#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🛠️ Konfiguruji Flask pro Ubuntu + Zrok (Port 8080)..."

# Oprava jádra: Vynutíme spuštění na portu 8080
cat > final_ubuntu_config.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Najdeme volání app.run a přepíšeme ho na port 8080
if "app.run" in code:
    code = re.sub(r"app\.run\(.*?\)", "app.run(host='127.0.0.1', port=8080)", code)
else:
    code += "\nif __name__ == '__main__':\n    app.run(host='127.0.0.1', port=8080)"

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 final_ubuntu_config.py

# Restart procesů v Ubuntu
echo "♻️ Zabíjím staré instance v Ubuntu..."
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true"

echo "🚀 Startuji Flask v Ubuntu na portu 8080..."
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 3
echo "🔍 Kontrola logu serveru v Ubuntu:"
proot-distro login ubuntu -- bash -c "tail -n 5 /data/data/com.termux/files/home/OmegaPlatinum_PROD/server_ubuntu.log"

echo "============================================================"
echo "✅ HOTOVO. Flask nyní běží v Ubuntu na portu 8080."
echo "Teď v druhém okně (kde máš zrok) uvidíš, že spojení ožilo."
echo "Poté spusť znovu: ./OMEGA_FINAL_ZROK_TEST.sh"
echo "============================================================"
