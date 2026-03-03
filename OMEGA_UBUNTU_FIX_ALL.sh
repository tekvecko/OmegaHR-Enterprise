#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📦 KROK 1: Instalace závislostí přímo v Ubuntu..."
proot-distro login ubuntu -- bash -c "apt update && apt install -y python3-pip python3-flask python3-requests"

echo "⚙️ KROK 2: Čištění a příprava jádra..."
pkill -9 python3 || true

# Oprava jádra na port 8080 a host 0.0.0.0 (nejstabilnější pro tunely)
cat > fix_for_ubuntu.py << 'PYEOF'
import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Pokud v souboru chybí import Flask, přidáme ho (pro jistotu)
if "from flask import" not in code:
    code = "from flask import Flask, request, session, redirect, url_for, render_template\n" + code

# Vynucení spuštění na portu 8080
run_cmd = "app.run(host='0.0.0.0', port=8080)"
if "app.run" in code:
    code = re.sub(r"app\.run\(.*?\)", run_cmd, code)
else:
    code += f"\nif __name__ == '__main__':\n    {run_cmd}"

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF
python3 fix_for_ubuntu.py

echo "🚀 KROK 3: Startování serveru v Ubuntu..."
# Spustíme to tak, aby log vznikl tam, kde ho Termux uvidí
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 5
echo "📊 KROK 4: Kontrola, zda server žije..."
if [ -f server_ubuntu.log ]; then
    echo "--- POSLEDNÍCH 5 ŘÁDKŮ LOGU ---"
    cat server_ubuntu.log | tail -n 5
else
    echo "⚠️ Log nebyl vytvořen. Zkouším přímý výpis chyb..."
    proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && python3 omega_core.py 2>&1 | head -n 10"
fi

echo "============================================================"
echo "✅ Pokud vidíš 'Running on http://0.0.0.0:8080', zrok už funguje!"
echo "Nyní znovu: ./OMEGA_FINAL_ZROK_TEST.sh"
echo "============================================================"
