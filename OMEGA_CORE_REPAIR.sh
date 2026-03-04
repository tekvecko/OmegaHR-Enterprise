#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"

echo "🧹 Čistím jádro od duplicitních endpointů..."

# Vytvoříme zálohu pro jistotu
cp "$CORE" "${CORE}.bak"

# Použijeme Python k inteligentnímu odstranění duplicitních definic funkcí
python3 << 'PYEOF'
import re

path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"
with open(path, 'r') as f:
    lines = f.readlines()

new_lines = []
seen_functions = set()
skip_mode = False

# Jednoduchý parser pro detekci duplicitních dekorátorů a funkcí
for i, line in enumerate(lines):
    # Detekce definice funkce
    match = re.search(r'def\s+([a-zA-Z0-9_]+)\s*\(', line)
    if match:
        func_name = match.group(1)
        if func_name in seen_functions and func_name not in ['query_db', 'log_action']: # Základní utility ponecháme
            print(f"🚫 Odstraňuji duplicitní funkci: {func_name}")
            skip_mode = True
            # Odstraníme i dekorátor nad tím, pokud tam je
            if new_lines and "@app.route" in new_lines[-1]:
                new_lines.pop()
            continue
        else:
            seen_functions.add(func_name)
            skip_mode = False
    
    if not skip_mode:
        new_lines.append(line)
    
    # Ukončení skip módu (předpokládáme prázdný řádek nebo další dekorátor)
    if skip_mode and (line.strip() == "" or (i+1 < len(lines) and "@app.route" in lines[i+1])):
        skip_mode = False

with open(path, 'w') as f:
    f.writelines(new_lines)
PYEOF

echo "✅ Jádro bylo vyčištěno."
echo "🚀 Spouštím systém na portu 8080..."
pkill -f "omega_core.py" || true
python3 "$CORE"
