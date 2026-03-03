#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📥 Stahuji font Roboto (TrueType) z ověřeného zdroje..."
# Použijeme wget pro lepší manipulaci s přesměrováním nebo curl s -L
curl -L "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf" -o Roboto-Regular.ttf

# Kontrola, zda soubor není příliš malý (HTML chybová stránka má obvykle pár KB, font má ~160KB)
FILESIZE=$(stat -c%s "Roboto-Regular.ttf")
if [ $FILESIZE -lt 50000 ]; then
    echo "❌ Font se nepodařilo stáhnout správně (soubor je příliš malý). Zkouším záložní zdroj..."
    curl -L "https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxK.ttf" -o Roboto-Regular.ttf
fi

echo "🚀 Restartuji server a pouštím E2E test. Teď už ten font musí být v pořádku!"
pkill -f python || true
./start.sh &
sleep 5
./run_e2e_final.sh
