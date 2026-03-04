#!/data/data/com.termux/files/usr/bin/bash
set -e

TPL="/data/data/com.termux/files/home/OmegaPlatinum_PROD/templates"

echo "📊 HLÁŠENÍ O STAVU STRUKTURY FRONTENDU:"
echo "--------------------------------------------------"
printf "%-25s | %-15s\n" "SOUBOR" "STAV DESIGNU"
echo "--------------------------------------------------"

for file in $TPL/*.html; do
    fname=$(basename "$file")
    if grep -q "{% extends 'layout.html' %}" "$file"; then
        status="💎 UNIFIKOVÁNO"
    elif [ "$fname" == "layout.html" ]; then
        status="🏛️ MASTER LAYOUT"
    else
        status="⚠️ STARÝ STYL"
    fi
    printf "%-25s | %-15s\n" "$fname" "$status"
done
echo "--------------------------------------------------"
