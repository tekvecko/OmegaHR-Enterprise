#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"

echo "⚙️ Přepínám Omega Core do Produkčního (Enterprise) režimu..."

# Vypnutí Flask Debuggeru (který shazuje Termux)
sed -i "s/debug=True/debug=False/g" "$CORE"

echo "🚀 Startuji stabilní, multiprocesově nezávislé jádro..."
pkill -f "omega_core.py" || true
nohup python3 "$CORE" > "$PROJ/dev_server.log" 2>&1 &

echo "--------------------------------------------------"
echo "💎 SYSTÉM BĚŽÍ V PRODUKČNÍM REŽIMU."
echo "URL: http://127.0.0.1:8080"
echo "--------------------------------------------------"
