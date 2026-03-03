#!/data/data/com.termux/files/usr/bin/bash
set -e

# 1. OPRAVA PRÁV UVNITŘ UBUNTU
echo "🔐 Opravuji přístupová práva v Ubuntu..."
proot-distro login ubuntu -- bash -c "chmod -R 777 /data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

# 2. ÚPRAVA JÁDRA PRO TOTÁLNÍ PŘEPSÁNÍ (Vynucení změn)
cat > force_write.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Vynutíme, aby log_action i lifecycle používaly absolutní cesty Ubuntu
ubuntu_db = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
code = code.replace('db/audit_log.json', f'{ubuntu_db}/audit_log.json')

# Oprava logiky zápisu - přidáme explicitní zavírání souborů
write_fix = f"""
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.flush()
        os.fsync(f.fileno())
"""
# Nahradíme standardní json.dump touto bezpečnou verzí
code = re.sub(r"with open\(path, 'w'.*?json\.dump\(data, f, indent=4\)", f"with open(path, 'w', encoding='utf-8') as f:{write_fix}", code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 force_write.py

# 3. TVRDÝ RESTART V UBUNTU
echo "♻️ Restartuji server v Ubuntu..."
proot-distro login ubuntu -- bash -c "pkill -f python3 || true; cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 3
echo "🚀 Hotovo. Zkus nyní: ./OMEGA_ZROK_VERIFICATION.sh"
