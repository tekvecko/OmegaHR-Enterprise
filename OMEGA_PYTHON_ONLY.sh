#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
BASHRC="/data/data/com.termux/files/home/.bashrc"

# Odstraníme staré definice funkce omegahr
sed -i '/function omegahr()/,/}/d' "$BASHRC"

# Vložíme čistý Python-centric startér
cat >> "$BASHRC" << 'FUNC_EOF'
function omegahr() {
    local PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
    local G='\033[0;32m'
    local Y='\033[1;33m'
    local NC='\033[0m'

    cd "$PROJ"

    # Kontrola, zda už server běží
    if pgrep -f "omega_core.py" > /dev/null; then
        echo -e "${G}✅ OMEGA Server již běží.${NC}"
        echo -e "${Y}URL: http://127.0.0.1:8080${NC}"
        echo ""
        python3 "$PROJ/omega_hud.py"
    else
        echo -e "${Y}🚀 Startuji OMEGA Python Core...${NC}"
        # Spuštění self-heal pro jistotu integrity před startem
        python3 "$PROJ/omega_self_heal.py" > /dev/null 2>&1
        
        # Spuštění serveru na pozadí
        nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
        
        sleep 2
        echo -e "${G}✅ Server nastartován na http://127.0.0.1:8080${NC}"
        python3 "$PROJ/omega_hud.py"
    fi
}
FUNC_EOF

echo "✅ Alias 'omegahr' byl upraven pro čistý start Python serveru."
echo "💡 Teď stačí napsat: omegahr"
