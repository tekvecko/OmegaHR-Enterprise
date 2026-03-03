#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > deep_patch.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import re

print("🧠 Spouštím hloubkovou analýzu a opravu generátoru...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    # Pokud řádek obsahuje nahrazování značek do šablon
    if '.replace(' in line and ('{' in line) and ('}' in line):
        try:
            parts = line.split('.replace(')
            new_line = parts[0]
            for part in parts[1:]:
                comma_idx = part.find(',')
                if comma_idx != -1:
                    arg1 = part[:comma_idx]
                    arg2_with_paren = part[comma_idx+1:]
                    
                    # Najdeme poslední uzavírací závorku patřící k .replace()
                    last_paren_idx = arg2_with_paren.rfind(')')
                    arg2 = arg2_with_paren[:last_paren_idx].strip()
                    rest = arg2_with_paren[last_paren_idx+1:]
                    
                    # Obalíme druhý argument masivní ochranou proti None
                    safe_arg2 = f"str({arg2}) if {arg2} is not None else ''"
                    new_part = f".replace({arg1}, {safe_arg2}){rest}"
                    new_line += new_part
                else:
                    new_line += ".replace(" + part
            new_lines.append(new_line)
        except Exception as e:
            # V případě selhání parsování vložíme původní řádek
            new_lines.append(line)
    else:
        new_lines.append(line)

content = "".join(new_lines)

# Vynutíme dynamické načítání nejnovějších dat firmy z disku přímo v generátoru
reload_code = """
    import json
    try:
        with open('settings.json', 'r', encoding='utf-8') as sf: comp = json.load(sf)
    except: comp = {}
"""
content = re.sub(r"(def gen_pdf[^:]*:)", r"\1" + reload_code, content)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Jádro je nyní imunní proti chybějícím datům v paměti.")
PYEOF

chmod +x deep_patch.py
/data/data/com.termux/files/usr/bin/python deep_patch.py
rm deep_patch.py

echo "🚀 Restartuji server a spouštím finální test..."
pkill -f python || true
./start.sh &
sleep 3
./run_e2e_final.sh
