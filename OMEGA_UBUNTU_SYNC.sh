#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔄 Synchronizuji kód do Ubuntu prostředí..."

# 1. ZABIJEME VŠECHNO V UBUNTU (z Termuxu)
proot-distro login ubuntu -- bash -c "pkill -f python3 || true"

# 2. VYNUTÍME ABSOLUTNÍ CESTY V JÁDRU (Pro Ubuntu context)
# Ubuntu v proot vidí /home/ jako /data/data/com.termux/files/home/
cat > patch_ubuntu.py << 'PYEOF'
import os
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Oprava cest pro Ubuntu environment
base = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
code = code.replace("db/", f"{base}/")

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 patch_ubuntu.py

# 3. RESTART SERVERU UVNITŘ UBUNTU
echo "🚀 Startuji server v Ubuntu přes nohup..."
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 5
echo "✅ Synchronizace hotova. Zkus nyní znovu: ./OMEGA_ZROK_VERIFICATION.sh"
