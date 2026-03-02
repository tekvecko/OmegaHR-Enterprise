#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔧 Přidávám funkci pro hromadné generování PDF..."
cat > patch_bulk.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os

core_path = 'omega_core.py'
try:
    with open(core_path, 'r', encoding='utf-8') as f:
        core = f.read()
except Exception as e:
    print(f"Chyba cteni core: {e}")

new_route = """
@app.route('/hr/regenerate_pdfs', methods=['POST'])
def hr_regenerate_pdfs():
    try:
        import os
        import glob
        import omega_config as cfg
        
        # Projdeme databázi kandidátů a vynutíme generování
        if hasattr(cfg, 'DB_DIR') and os.path.exists(cfg.DB_DIR):
            for filepath in glob.glob(os.path.join(cfg.DB_DIR, '*.json')):
                token = os.path.basename(filepath).replace('.json', '')
                gen_pdf(token, 'contract')
                gen_pdf(token, 'nda')
                gen_pdf(token, 'handover')
    except Exception as e:
        print(f"Hromadna chyba PDF: {e}")
        
    from flask import redirect
    return redirect('/dashboard')
"""

if '/hr/regenerate_pdfs' not in core:
    core = core + "\n" + new_route
    try:
        with open(core_path, 'w', encoding='utf-8') as f:
            f.write(core)
    except Exception as e:
        print(f"Chyba zapisu core: {e}")
    print("   ✅ Trasa pro hromadné generování přidána do jádra.")

dash_path = 'templates/dashboard.html'
try:
    with open(dash_path, 'r', encoding='utf-8') as f:
        dash = f.read()
except Exception as e:
    print(f"Chyba cteni dash: {e}")

btn_html = """
    <form action="/hr/regenerate_pdfs" method="POST" class="mt-4 mb-6">
        <button type="submit" class="bg-gray-800 text-white px-4 py-3 rounded-xl text-sm font-bold w-full hover:bg-gray-700 transition shadow-sm flex items-center justify-center">
            <i class="ri-refresh-line mr-2"></i>Přegenerovat chybějící PDF dokumenty
        </button>
    </form>
"""

if '/hr/regenerate_pdfs' not in dash:
    # Bezpečné vložení tlačítka hned pod hlavní nadpis (nebo tag h1)
    dash = dash.replace('</h1>', '</h1>\n' + btn_html, 1)
    try:
        with open(dash_path, 'w', encoding='utf-8') as f:
            f.write(dash)
    except Exception as e:
        print(f"Chyba zapisu dash: {e}")
    print("   ✅ Tlačítko přidáno na HR Nástěnku.")
PYEOF

chmod +x patch_bulk.py
/data/data/com.termux/files/usr/bin/python patch_bulk.py
rm patch_bulk.py

echo "🚀 Restartuji systém s novou funkcí..."
pkill -f python || true
./start.sh
