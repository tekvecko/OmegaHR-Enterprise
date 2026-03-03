#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📥 Stahuji font Roboto pro plnou podporu české diakritiky (UTF-8)..."
curl -sL "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf" -o Roboto-Regular.ttf

cat > patch_font_uni.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import re

print("🛠️ Nastavuji PDF generátor na Unicode režim...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Zajištění, že FPDF (pokud jde o starší verzi) správně načte UTF-8
if "uni=True" not in core and "add_font('Roboto'" in core:
    core = core.replace("pdf.add_font('Roboto', '', font_path)", "pdf.add_font('Roboto', '', font_path, uni=True)")
    with open('omega_core.py', 'w', encoding='utf-8') as f:
        f.write(core)
        print("✅ Režim uni=True aktivován.")

PYEOF

chmod +x patch_font_uni.py
/data/data/com.termux/files/usr/bin/python patch_font_uni.py
rm patch_font_uni.py

echo "🚀 Restartuji server a pouštím finální test..."
pkill -f python || true
./start.sh &
sleep 3
./run_e2e_final.sh
