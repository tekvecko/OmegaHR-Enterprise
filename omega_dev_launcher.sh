#!/data/data/com.termux/files/usr/bin/bash
set -e

# KONFIGURACE CEST
PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
LOG_FILE="$PROJECT_DIR/dev_server.log"

# BARVY PRO TERMINÁL
G='\033[0;32m'
B='\033[0;34m'
Y='\033[1;33m'
NC='\033[0m'

cd $PROJECT_DIR

echo -e "${B}--------------------------------------------------${NC}"
echo -e "${B}   OMEGA PLATINUM | ENTERPRISE DEVELOPER STACK    ${NC}"
echo -e "${B}--------------------------------------------------${NC}"

# 1. KONTROLA INTEGRITY PŘED STARTEM
echo -n "[1/4] Prověřuji Integritní Engine... "
python3 omega_check.py > /dev/null 2>&1
echo -e "${G}PASSED${NC}"

# 2. CLEANUP STALE PROCESSES
echo -n "[2/4] Čištění starých instancí... "
pkill -f "omega_core.py" || true
echo -e "${G}CLEAN${NC}"

# 3. KONTROLA DATABÁZE
echo -n "[3/4] Validace SQL schématu... "
sqlite3 omega_database.db "PRAGMA integrity_check;" > /dev/null
echo -e "${G}VERIFIED${NC}"

# 4. SPUŠTĚNÍ WATCHDOGU A SERVERU
echo -e "[4/4] Startuji Application Core v režimu LOGGING..."
echo -e "${Y}Port: 8080 | Logs: $LOG_FILE${NC}"
echo -e "${B}--------------------------------------------------${NC}"

# Spuštění serveru na pozadí s přesměrováním do logu
export FLASK_ENV=development
python3 omega_core.py > "$LOG_FILE" 2>&1 &

# Malá pauza na inicializaci
sleep 2

if pgrep -f "omega_core.py" > /dev/null; then
    echo -e "${G}🚀 SYSTÉM BĚŽÍ: http://127.0.0.1:8080${NC}"
    echo -e "Pro sledování logů v reálném čase použij: ${Y}tail -f $LOG_FILE${NC}"
else
    echo -e "${R}❌ START SELHAL! Zkontroluj logy: $LOG_FILE${NC}"
fi
