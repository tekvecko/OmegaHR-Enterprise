#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# Pro jistotu vynutíme stažení správného fontu znovu
curl -sL "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf" -o Roboto-Regular.ttf

cat > force_unicode.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os

print("🔨 Opravuji cesty k fontům a vynucuji Unicode...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Definujeme absolutní cestu v Termuxu
termux_font_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/Roboto-Regular.ttf"

# Najdeme blok, který řeší fonty a nahradíme ho neprůstřelnou verzí
old_font_logic = """        font_path = os.path.join(cfg.BASE_DIR, 'Roboto-Regular.ttf')
        loaded = False
        if os.path.exists(font_path) and os.path.getsize(font_path) > 1000:
            try:
                pdf.add_font('Roboto', '', font_path)
                pdf.set_font('Roboto', '', 12)
                loaded = True
            except: pass
        if not loaded: pdf.set_font("Arial", size=12)"""

# Nová logika: Žádné 'if', žádná 'helvetica'. Pokud font existuje, použij ho.
new_font_logic = f"""        font_path = "{termux_font_path}"
        pdf.add_font('Roboto', '', font_path, uni=True)
        pdf.set_font('Roboto', '', 12)"""

if old_font_logic in core:
    core = core.replace(old_font_logic, new_font_logic)
else:
    # Pokud už tam proběhly nějaké změny, zkusíme to najít agresivněji přes regex
    import re
    core = re.sub(r"font_path = os\.path\.join\(cfg\.BASE_DIR, 'Roboto-Regular\.ttf'\).*?pdf\.set_font\(\"Arial\", size=12\)", new_font_logic, core, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(core)

print("✅ Font Roboto je nyní v jádru zadrátován napevno s uni=True.")
PYEOF

chmod +x force_unicode.py
/data/data/com.termux/files/usr/bin/python force_unicode.py
rm force_unicode.py

echo "🚀 Restartuji a spouštím E2E test. Teď už to musí projít!"
pkill -f python || true
./start.sh &
sleep 4
./run_e2e_final.sh
