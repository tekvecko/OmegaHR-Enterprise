#!/data/data/com.termux/files/usr/bin/bash

echo "🕵️ Zahajuji forenzní skenování disku..."
PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
SEARCH_PATHS=("/data/data/com.termux/files/home" "/data/data/com.termux/files/usr/lib/python3.12/site-packages")

# 1. Hledání zapomenutých .py, .db a .json souborů s klíčovými slovy
echo "📂 Hledám fragmenty kódu (Omega, Platinum, MojeID)..."
grep -rE "Omega|Platinum|mojeid|fpdf" "${SEARCH_PATHS[@]}" --include="*.py" --include="*.json" --include="*.sh" 2>/dev/null | grep -v "$PROJ" > found_fragments.txt || true

# 2. Hledání sirotčích databází
echo "🗄️ Hledám sirotčí databázové soubory..."
find /data/data/com.termux/files/home -name "*.db" -not -path "$PROJ/*" >> found_fragments.txt || true

# 3. Analýza výsledků
echo "📊 --- ANALÝZA NÁLEZŮ ---"
if [ -s found_fragments.txt ]; then
    echo -e "\033[0;33mNalezeny potenciálně užitečné fragmenty:\033[0m"
    cat found_fragments.txt
    
    echo -e "\n\033[0;36m[DOPORUČENÍ]\033[0m"
    if grep -q "Pillow" found_fragments.txt; then
        echo "- Nalezena knihovna Pillow: Můžeme oživit generování FOTO-ID karet."
    fi
    if grep -q "qrcode" found_fragments.txt; then
        echo "- Nalezena knihovna QRCode: Můžeme generovat dynamické QR kódy přímo do PDF."
    fi
    if grep -q "backup" found_fragments.txt; then
        echo "- Nalezeny starší zálohy: Můžeme zkusit obnovit historická data."
    fi
else
    echo "✅ Disk je čistý. Všechny aktivní součásti jsou v $PROJ."
fi

rm found_fragments.txt
echo "🏁 Sken dokončen."
