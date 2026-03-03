#!/data/data/com.termux/files/usr/bin/bash
set -e

# --- KONFIGURACE ---
PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE="$PROJECT_DIR/omega_database.db"

# Barvy
G='\033[0;32m'
R='\033[0;31m'
Y='\033[1;33m'
B='\033[0;34m'
NC='\033[0m'

echo -e "${B}======================================================${NC}"
echo -e "${B}       OMEGA PLATINUM | DEEP INTEGRITY AUDIT          ${NC}"
echo -e "${B}======================================================${NC}"

cd $PROJECT_DIR

# 1. FILESYSTEM CHECK
echo -e "\n${Y}[1/5] Prověřuji souborový systém...${NC}"
FILES=("omega_core.py" "omega_self_heal.py" "omega_dev_launcher.sh")
DIRS=("templates" "static/qr" "contracts" "static/css")

for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then echo -e "  [${G}OK${NC}] Soubor: $f"; else echo -e "  [${R}!!${NC}] CHYBÍ: $f"; fi
done

for d in "${DIRS[@]}"; do
    if [ -d "$d" ]; then echo -e "  [${G}OK${NC}] Složka: $d"; else echo -e "  [${R}!!${NC}] CHYBÍ: $d"; fi
done

# 2. DATABASE DEEP SCAN
echo -e "\n${Y}[2/5] Prověřuji databázi a schémata...${NC}"
python3 << 'PYEOF'
import sqlite3, sys
try:
    conn = sqlite3.connect("omega_database.db")
    c = conn.cursor()
    # Integrity check
    res = c.execute("PRAGMA integrity_check").fetchone()
    if res[0] == "ok":
        print(f"  [\033[0;32mOK\033[0m] SQLite Integrity: PASS")
    
    # Check tables
    tables = ["candidates", "assets", "audit_logs", "milestones"]
    for t in tables:
        exists = c.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{t}'").fetchone()
        if exists:
            count = c.execute(f"SELECT count(*) FROM {t}").fetchone()[0]
            print(f"  [\033[0;32mOK\033[0m] Tabulka: {t:<12} | Records: {count}")
        else:
            print(f"  [\033[0;31m!!\033[0m] CHYBÍ TABULKA: {t}")
    conn.close()
except Exception as e:
    print(f"  [\033[0;31m!!\033[0m] DB ERROR: {e}")
PYEOF

# 3. ROUTING & LOGIC VALIDATION
echo -e "\n${Y}[3/5] Prověřuji Flask routování a logiku...${NC}"
python3 << 'PYEOF'
import ast
try:
    with open("omega_core.py", "r") as f:
        tree = ast.parse(f.read())
    
    routes = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and hasattr(node.func, 'attr') and node.func.attr == 'route':
            routes.append(node.args[0].value if hasattr(node.args[0], 'value') else node.args[0].s)
    
    print(f"  [\033[0;32mOK\033[0m] Detekováno {len(routes)} aktivních endpointů.")
    for r in sorted(routes):
        print(f"    -> {r}")
except Exception as e:
    print(f"  [\033[0;31m!!\033[0m] SYNTAX ERROR v omega_core.py: {e}")
PYEOF

# 4. TEMPLATE BINDING CHECK
echo -e "\n${Y}[4/5] Kontroluji vazbu na HTML templates...${NC}"
python3 << 'PYEOF'
import os, re
try:
    with open("omega_core.py", "r") as f:
        core_content = f.read()
    
    templates = [f for f in os.listdir("templates") if f.endswith(".html")]
    for t in templates:
        if t in core_content:
            print(f"  [\033[0;32mOK\033[0m] Template: {t:<15} | Propojeno s jádrem")
        else:
            print(f"  [\033[1;33m??\033[0m] Template: {t:<15} | Orphaned (Nepoužito v jádru)")
except Exception as e:
    print(f"  [\033[0;31m!!\033[0m] ERROR: {e}")
PYEOF

# 5. ENVIRONMENT & SECURITY
echo -e "\n${Y}[5/5] Prověřuji prostředí a zabezpečení...${NC}"
# Port check
if netstat -tuln | grep -q ":8080 "; then
    echo -e "  [${Y}WARN${NC}] Port 8080 je již obsazen (Možná jiná instance OMEGY)."
else
    echo -e "  [${G}OK${NC}] Port 8080 volný."
fi

# Permissions
if [ -x "omega_core.py" ]; then echo -e "  [${G}OK${NC}] Oprávnění k jádru: EXECUTE"; else echo -e "  [${R}!!${NC}] CHYBA: omega_core.py není spustitelný"; fi

echo -e "\n${B}======================================================${NC}"
echo -e "${G}AUDIT DOKONČEN.${NC}"
echo -e "${B}======================================================${NC}"
