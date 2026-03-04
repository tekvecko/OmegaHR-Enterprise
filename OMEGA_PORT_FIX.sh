#!/data/data/com.termux/files/usr/bin/bash
set -e

CORE="/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"

echo "🔌 Přepínám systém Omega na port 8080..."

# Oprava portu přímo v kódu (změna app.run)
sed -i 's/app.run(.*)/app.run(host="0.0.0.0", port=8080)/' "$CORE"
# Pokud tam app.run ještě nebyl specifikován s portem:
if ! grep -q "port=8080" "$CORE"; then
    sed -i 's/app.run()/app.run(host="0.0.0.0", port=8080)/' "$CORE"
fi

echo "🚀 Restartuji server na novém portu..."
pkill -f "omega_core.py" || true
nohup python3 "$CORE" > /data/data/com.termux/files/home/OmegaPlatinum_PROD/dev_server.log 2>&1 &

echo "--------------------------------------------------"
echo "💎 SYSTÉM BĚŽÍ NA: http://127.0.0.1:8080"
echo "--------------------------------------------------"
