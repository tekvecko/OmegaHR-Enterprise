#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🌉 Propojuji Ubuntu Flask se zrokem (Port 8080, IP 0.0.0.0)..."

# 1. OPRAVA JÁDRA PRO UBUNTU
cat > fix_core_final.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Vynutíme host='0.0.0.0' a port=8080
if "app.run" in code:
    code = re.sub(r"app\.run\(.*?\)", "app.run(host='0.0.0.0', port=8080)", code)
else:
    code += "\nif __name__ == '__main__': app.run(host='0.0.0.0', port=8080)"

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 fix_core_final.py

# 2. TVRDÝ RESTART V UBUNTU
echo "♻️ Restartuji Python v Ubuntu..."
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true"
sleep 2
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

echo "⏳ Čekám 5 sekund na stabilizaci zroku..."
sleep 5

# 3. KONTROLA, ZDA PORT SKUTEČNĚ ŽIJE (v Ubuntu)
echo "🔍 Kontrola portu 8080 v Ubuntu:"
proot-distro login ubuntu -- bash -c "netstat -tuln | grep 8080" || echo "⚠️ Port 8080 není aktivní!"

echo "✅ Hotovo. Zkus nyní znovu: ./OMEGA_FINAL_ZROK_TEST.sh"
