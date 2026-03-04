#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "🔧 Odstraňuji duplicitní argumenty z jádra..."

python3 << 'PYEOF'
path = "omega_core.py"
with open(path, 'r') as f:
    content = f.read()

# Oprava duplicity: Najdeme ten dlouhý řádek a nahradíme ho čistou verzí
old_line = "return render_template('index.html', employees=employees, stock=stock, asset_map=asset_map, count=len(employees), asset_map=asset_map, stock=stock)"
new_line = "return render_template('index.html', employees=employees, stock=stock, asset_map=asset_map, count=len(employees))"

if old_line in content:
    content = content.replace(old_line, new_line)
    with open(path, 'w') as f:
        f.write(content)
    print("✅ Řádek 59 opraven.")
else:
    # Pokud by tam byla jiná varianta duplicity, uděláme agresivnější fix
    import re
    content = re.sub(r"return render_template\('index.html',.*?\)", new_line, content)
    with open(path, 'w') as f:
        f.write(content)
    print("✅ Jádro vyčištěno regulárním výrazem.")
PYEOF

echo "🚀 Startuji opravené jádro..."
pkill -f "omega_core.py" || true
# Spustíme to přímo v konzoli, abys viděl, že už nejsou ERRORY
python3 omega_core.py
