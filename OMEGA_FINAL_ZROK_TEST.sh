#!/data/data/com.termux/files/usr/bin/bash
set -e

# KONFIGURACE
URL="https://p3085t3mscgc.share.zrok.io"
DB_PATH="/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

echo "============================================================"
echo "🚀 STARTUJI FINÁLNÍ TEST PŘES ZROK (PORT 8080)"
echo "============================================================"

# 1. ČIŠTĚNÍ STARÝCH DAT (pro čistý test)
rm -f DEBUG_HIT.txt

# 2. NÁBOR NOVÉHO ZAMĚSTNANCE
TEST_ID=$(date +%s | tail -c 4)
SURNAME="ZrokPort_$TEST_ID"
echo "▶️ 1. Nábor zaměstnance: Emanuel $SURNAME..."

# Posíláme POST přes zrok
curl -s -X POST \
     -d "name=Emanuel" \
     -d "surname=$SURNAME" \
     -d "email=port8080@test.cz" \
     -d "position=PortExpert" \
     -d "salary=85000" \
     $URL/new > /dev/null

sleep 2

# Vyhledáme token vytvořeného souboru
TOKEN=$(grep -l "$SURNAME" $DB_PATH/*.json | xargs basename | sed 's/\.json//' || echo "")

if [ -z "$TOKEN" ]; then
    echo "❌ CHYBA: Nábor selhal. Zkontroluj, zda server v Ubuntu skutečně běží na portu 8080."
    exit 1
fi
echo "  ✅ Zaměstnanec vytvořen s tokenem: $TOKEN"

# 3. ZMĚNA PLATU (Kritický bod)
echo "▶️ 2. Pokus o změnu platu na 99000..."
curl -s -X POST \
     -d "action=salary" \
     -d "new_salary=99000" \
     $URL/hr/lifecycle/$TOKEN > /dev/null

sleep 2

# 4. VERIFIKACE VÝSLEDKŮ
echo -e "\n📊 VÝSLEDEK TESTU:"
echo "------------------------------------------------------------"

# Kontrola platu v JSONu
ACTUAL_SALARY=$(grep "salary" $DB_PATH/$TOKEN.json | cut -d '"' -f 4)
if [ "$ACTUAL_SALARY" == "99000" ]; then
    echo "✅ PLAT: Úspěšně změněn na 99000 CZK"
else
    echo "❌ PLAT: Selhalo (Aktuální hodnota: $ACTUAL_SALARY)"
fi

# Kontrola debugu (pokud jsme ho tam nechali)
if [ -f DEBUG_HIT.txt ]; then
    echo "✅ KOMUNIKACE: Server potvrdil příjem požadavku (DEBUG_HIT existuje)."
fi

# Kontrola auditu
if grep -q "$TOKEN" $DB_PATH/audit_log.json; then
    echo "✅ AUDIT: Záznam o změně byl nalezen v logu."
else
    echo "❌ AUDIT: Záznam v logu chybí."
fi

echo "============================================================"
