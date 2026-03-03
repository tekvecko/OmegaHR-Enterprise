#!/data/data/com.termux/files/usr/bin/bash
set -e

# TVOJE VEŘEJNÁ ADRESA
URL="https://p3085t3mscgc.share.zrok.io"
DB_PATH="/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

echo "🌐 TESTUJI PŘES ZROK: $URL"
echo "============================================================"

# 1. NÁBOR (Cez veřejné URL)
echo "▶️ 1. Odesílám nábor přes zrok..."
curl -s -X POST -d "name=Emanuel&surname=ZrokTest&email=z@test.cz&position=Master&salary=85000" $URL/new > /dev/null

# 2. NAJDEME TOKEN (Musíme v Termuxu, kde vidíme na soubory)
sleep 2
TOKEN=$(grep -l "ZrokTest" $DB_PATH/*.json | xargs basename | sed 's/\.json//')

if [ -z "$TOKEN" ]; then
    echo "❌ CHYBA: Zaměstnanec se přes zrok neuložil do DB!"
    exit 1
fi
echo "  ✅ Token nalezen: $TOKEN"

# 3. ZMĚNA PLATU (Cez veřejné URL)
echo "▶️ 2. Změna platu na 95000 přes zrok..."
curl -s -X POST -d "action=salary&new_salary=95000" $URL/hr/lifecycle/$TOKEN > /dev/null

# 4. KONTROLA VÝSLEDKU
sleep 1
echo -e "\n🔍 FYZICKÁ KONTROLA SOUBORU V TERMUXU:"
grep "salary" $DB_PATH/$TOKEN.json

echo -e "\n📜 KONTROLA AUDIT LOGU:"
grep "$TOKEN" $DB_PATH/audit_log.json || echo "❌ V logu nic není."
echo "============================================================"
