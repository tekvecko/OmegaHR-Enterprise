#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📦 Instaluji chybějící Enterprise knihovny..."
pip install fpdf2

echo "🖼️ Generuji systémové ikony a favicon..."
mkdir -p static/img
# Vytvoření jednoduchého placeholderu pro logo
echo "OMEGA PLATINUM" > static/img/logo_text.txt

echo "🔍 Přidávám Search Engine do Dashboardu..."
# Úprava index.html - přidání Search Baru a JS logiky
sed -i '/<div class="dashboard-grid">/i \
        <div class="glass-card" style="margin-bottom:20px; padding:1rem;"> \
            <div style="display:flex; align-items:center; gap:15px;"> \
                <i class="fa-solid fa-magnifying-glass" style="color:var(--main)"></i> \
                <input type="text" id="omegaSearch" placeholder="Hledat podle jména, tokenu nebo MojeID..." \
                       style="width:100%; background:transparent; border:none; color:var(--text-main); outline:none; font-size:1rem;"> \
            </div> \
        </div>' templates/index.html

# Přidání Search JS před koncový </body>
sed -i '/<\/script>/i \
    document.getElementById("omegaSearch").addEventListener("keyup", function() { \
        let val = this.value.toLowerCase(); \
        let rows = document.querySelectorAll("tbody tr"); \
        rows.forEach(row => { \
            row.style.display = row.innerText.toLowerCase().includes(val) ? "" : "none"; \
        }); \
    });' templates/index.html

echo "🛡️ Vytvářím chybové stránky (404)..."
cat > templates/404.html << 'HOF'
<!DOCTYPE html>
<html lang="cs" data-theme="dark">
<head><meta charset="UTF-8"><title>404 | OMEGA</title>
<style>
    body { background:#030708; color:#fff; font-family:sans-serif; display:flex; justify-content:center; align-items:center; height:100vh; margin:0; }
    .box { text-align:center; border:1px solid #3498db; padding:50px; border-radius:20px; }
    h1 { color:#3498db; font-size:4rem; margin:0; }
</style></head>
<body><div class="box"><h1>404</h1><p>IDENTITA NENALEZENA V SYSTÉMU</p><a href="/" style="color:#3498db;">Zpět do jádra</a></div></body>
</html>
HOF

echo "📝 Aktualizuji omega_core.py pro ošetření chyb..."
cat >> omega_core.py << 'PYEOF'

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404
PYEOF

echo "✅ Finální doladění hotovo."
