#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR

echo "📡 Integruji Live-Pulse API a AJAX interface..."

# 1. PŘIDÁNÍ API ENDPOINTU DO JÁDRA (omega_core.py)
# Využijeme python pro čistou injekci kódu před spuštění app.run
python3 << 'PYEOF'
path = "omega_core.py"
with open(path, "r") as f:
    lines = f.readlines()

# Najdeme místo před __main__ pro vložení API
new_lines = []
api_code = """
@app.route('/api/stats')
def get_stats():
    if not session.get('logged_in'): return jsonify({"error": "unauthorized"}), 401
    try:
        count = query_db("SELECT count(*) as count FROM candidates WHERE status='ACTIVE'", one=True)['count']
        stock = [dict(row) for row in query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")]
        return jsonify({
            "active_personnel": count, 
            "stock": stock, 
            "timestamp": datetime.datetime.now().strftime("%H:%M:%S")
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
"""

for line in lines:
    if "if __name__ == '__main__':" in line:
        new_lines.append(api_code)
    new_lines.append(line)

with open(path, "w") as f:
    f.writelines(new_lines)
PYEOF

# 2. INJEKCE OMEGA-PULSE SKRIPTU DO INDEX.HTML
# Přidáme vizuální indikátor pulsu a JS logiku
sed -i '/<\/body>/i \
<div id="pulse-indicator" style="position:fixed; bottom:10px; right:10px; width:10px; height:10px; background:#00ff9d; border-radius:50%; opacity:0.5; transition:0.3s;"></div> \
<script> \
    function updateStats() { \
        const indicator = document.getElementById("pulse-indicator"); \
        indicator.style.opacity = "1"; \
        fetch("/api/stats") \
            .then(response => response.json()) \
            .then(data => { \
                if(data.active_personnel !== undefined) { \
                    /* Update počtu zaměstnanců - cílíme na první kartu statistik */ \
                    const countElem = document.querySelector(".card h2"); \
                    if(countElem) countElem.innerText = data.active_personnel; \
                    \
                    /* Update výpisu skladu */ \
                    const stockContainer = document.querySelector(".stock-list"); \
                    if(stockContainer && data.stock) { \
                        stockContainer.innerHTML = data.stock.map(item => ` \
                            <div style="display:flex; justify-content:space-between; padding:5px; border-bottom:1px solid #222;"> \
                                <span>${item.name}</span> \
                                <span style="color:#00a2ff;">${item.count} ks</span> \
                            </div>`).join("") || "Sklad je prázdný"; \
                    } \
                } \
                setTimeout(() => { indicator.style.opacity = "0.3"; }, 500); \
            }) \
            .catch(err => console.error("Pulse Error:", err)); \
    } \
    setInterval(updateStats, 5000); \
    updateStats(); \
</script>' templates/index.html

echo "✅ Live-Pulse je aktivní (Interval: 5s)."
echo "🚀 Restartuji jádro pro aplikaci změn..."
pkill -f "omega_core.py" || true
# Spuštění přes dev launcher pro zachování konzistence
./omega_dev_launcher.sh &
