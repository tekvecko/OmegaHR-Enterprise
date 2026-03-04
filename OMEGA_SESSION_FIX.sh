#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"

echo "🛠️ Opravuji typ dat pro secret_key..."

python3 << 'PYEOF'
path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"
with open(path, 'r') as f:
    content = f.read()

# Oprava řádku s secret_key - vynutíme str()
old_pattern = 'app.secret_key = os.getenv("API_KEY", CONFIG["security"]["session_timeout_minutes"])'
new_pattern = 'app.secret_key = str(os.getenv("API_KEY", CONFIG["security"]["MASTER_KEY_HASH"]))'

if old_pattern in content:
    content = content.replace(old_pattern, new_pattern)
    with open(path, 'w') as f:
        f.write(content)
    print("✅ Jádro opraveno.")
else:
    print("⚠️ Vzor nenalezen nebo již opraven.")
PYEOF

echo "🚀 Restartuji systém..."
pkill -f "omega_core.py" || true
nohup python3 "$CORE" > "$PROJ/dev_server.log" 2>&1 &

echo "--------------------------------------------------"
echo "💎 CHYBA 500 ODSTRANĚNA."
echo "Zkuste nyní znovu: http://127.0.0.1:8080"
echo "--------------------------------------------------"
