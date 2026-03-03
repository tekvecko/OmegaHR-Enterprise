#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔧 Opravuji odsazení (IndentationError) v omega_core.py..."

cat > final_indent_repair.py << 'PYEOF'
import re

path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    # Oprava: Pokud řádek obsahuje smazání souboru, zajistíme, aby byl PŘED 'with' a správně odsazen
    if "if os.path.exists(path): os.remove(path)" in line:
        indent = line[:line.find("if")]
        # Vložíme smazání před 'with' a samotný 'with' necháme na dalším řádku
        new_lines.append(f"{indent}if os.path.exists(path): os.remove(path)\n")
    elif "with open(path, 'w', encoding='utf-8') as f:" in line:
        indent = line[:line.find("with")]
        new_lines.append(f"{indent}with open(path, 'w', encoding='utf-8') as f:\n")
        # Následující řádek s json.dump musí být odsazen o další úroveň
        # (Tento skript předpokládá, že json.dump následuje v původním kódu)
    else:
        new_lines.append(line)

# Druhá fáze: Oprava json.dump odsazení
final_code = "".join(new_lines)
final_code = re.sub(
    r"(with open\(path, 'w', encoding='utf-8'\) as f:\n)\s*(json\.dump\(data, f, indent=4, ensure_ascii=False\))",
    r"\1        \2", 
    final_code
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(final_code)
PYEOF

python3 final_indent_repair.py
rm final_indent_repair.py

echo "♻️ Restartuji server v Ubuntu..."
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true"
sleep 1
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 4
echo "📊 Kontrola startu:"
if proot-distro login ubuntu -- bash -c "grep -q 'Running on' /data/data/com.termux/files/home/OmegaPlatinum_PROD/server_ubuntu.log"; then
    echo "✅ SERVER BĚŽÍ!"
    tail -n 2 server_ubuntu.log
else
    echo "❌ Server stále nenaběhl. Obsah logu:"
    cat server_ubuntu.log
fi
