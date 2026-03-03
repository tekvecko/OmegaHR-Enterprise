#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
BASHRC="/data/data/com.termux/files/home/.bashrc"

echo "💎 Upgraduji alias 'omegahr' na Enterprise Command Center..."

# Odstranění starého aliasu, pokud existuje
sed -i '/alias omegahr=/d' "$BASHRC"
# Odstranění staré funkce, pokud existuje (prevence duplicity)
sed -i '/function omegahr()/,/}/d' "$BASHRC"

# Vložení nové inteligentní funkce
cat >> "$BASHRC" << 'FUNC_EOF'

function omegahr() {
    local PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
    local G='\033[0;32m'
    local B='\033[0;34m'
    local Y='\033[1;33m'
    local NC='\033[0m'

    clear
    echo -e "${B}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${B}│${NC}  ${G}OMEGA PLATINUM CORE${NC} v.2.6 - ${Y}ENTERPRISE SHELL${NC}   ${B}│${NC}"
    echo -e "${B}└──────────────────────────────────────────────────┘${NC}"

    # 1. Rychlá kontrola běhu
    if pgrep -f "omega_core.py" > /dev/null; then
        echo -e "  [${G}ONLINE${NC}] Jádro systému je aktivní."
        echo -e "  [${Y}LINK${NC}] URL: http://127.0.0.1:8080"
        echo -e ""
        python3 "$PROJ/omega_hud.py"
        echo -e ""
        echo -e "${Y}Příkazy:${NC}"
        echo -e "  - Pro restart:  pkill -f 'omega_core.py' && omegahr"
        echo -e "  - Pro logy:     tail -f $PROJ/dev_server.log"
        echo -e "  - Pro audit:    $PROJ/OMEGA_INTEGRITY_AUDITOR.sh"
    else
        echo -e "  [${B}OFFLINE${NC}] Systém spí. Zahajuji startovací sekvenci..."
        sleep 1
        bash "$PROJ/omega_dev_launcher.sh"
    fi
}
FUNC_EOF

echo "✅ Alias upgradován na funkci."
echo "🔄 Aplikuji změny (source)..."
# Musíme použít tečku pro source v aktuálním shellu
source "$BASHRC" 2>/dev/null || true

echo -e "\n🎉 ${G}HOTOVO!${NC} Zkus napsat: ${Y}omegahr${NC}"
