#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "📈 Obnovuji Analytics a Milestone Engine..."

# Update Analytics šablony
cat > templates/analytics.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <title>OMEGA | Advanced Analytics</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background: #05080a; color: white; font-family: sans-serif; padding: 40px; }
        .chart-container { background: #0d1216; padding: 20px; border-radius: 12px; border: 1px solid #1a2228; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>STRATEGICKÁ ANALYTIKA</h1>
    <div class="chart-container">
        <canvas id="assetChart"></canvas>
    </div>
    <script>
        fetch('/api/stats_full').then(r => r.json()).then(data => {
            const ctx = document.getElementById('assetChart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Vydáno', 'Skladem'],
                    datasets: [{
                        data: [data.assigned, data.available],
                        backgroundColor: ['#00d2ff', '#1a2228']
                    }]
                }
            });
        });
    </script>
    <p><a href="/" style="color: #00d2ff;">← Zpět do Command Center</a></p>
</body>
</html>
HOF

# Přidání API pro grafy do omega_core.py
python3 << 'PYEOF'
path = "omega_core.py"
with open(path, 'r') as f: content = f.read()

analytics_api = """
@app.route('/api/stats_full')
def stats_full():
    assigned = query_db("SELECT count(*) as c FROM assets WHERE owner_token IS NOT NULL", one=True)['c']
    available = query_db("SELECT count(*) as c FROM assets WHERE owner_token IS NULL", one=True)['c']
    return jsonify({"assigned": assigned, "available": available})

@app.route('/analytics')
def analytics_page():
    if not session.get('logged_in'): return redirect(url_for('login'))
    return render_template('analytics.html')
"""

if "@app.route('/api/stats_full')" not in content:
    content = content.replace("if __name__ == '__main__':", analytics_api + "\nif __name__ == '__main__':")
    with open(path, 'w') as f: f.write(content)
PYEOF

echo "🚀 Restartuji systém s plnou analytikou..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
echo "💎 FÁZE 2 HOTOVA. Analytics jsou online."
