#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR/templates

echo "🎨 Přepisuji Dashboard na verzi 2026 (Full Visual Suite)..."

cat > index.html << 'HOF'
<!DOCTYPE html>
<html lang="cs" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OMEGA | Core Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --bg: #030708; --card: rgba(16,22,26,0.8); --main: #00a2ff; --accent: #00ff9d; --danger: #ff3e3e; --text: #eee; }
        body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; padding: 20px; }
        .nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid #111; padding-bottom: 15px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: var(--card); border: 1px solid rgba(0,162,255,0.1); padding: 20px; border-radius: 15px; position: relative; }
        .card h2 { margin: 0; font-size: 2.5rem; color: var(--main); }
        .card p { margin: 5px 0; color: #777; font-size: 0.8rem; text-transform: uppercase; }
        
        table { width: 100%; border-collapse: collapse; background: var(--card); border-radius: 15px; overflow: hidden; }
        th { text-align: left; padding: 15px; background: rgba(0,162,255,0.05); color: #555; font-size: 0.75rem; }
        td { padding: 15px; border-bottom: 1px solid #111; }
        
        .btn { padding: 8px 12px; border-radius: 8px; text-decoration: none; font-size: 0.75rem; font-weight: bold; transition: 0.3s; display: inline-block; }
        .btn-main { background: var(--main); color: white; }
        .btn-accent { background: var(--accent); color: black; }
        .btn-ghost { border: 1px solid #333; color: #888; }
        .btn:hover { transform: translateY(-2px); opacity: 0.9; }

        .pulse-dot { width: 8px; height: 8px; background: var(--accent); border-radius: 50%; display: inline-block; margin-right: 5px; box-shadow: 0 0 10px var(--accent); animation: pulse 2s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.3; } 100% { opacity: 1; } }
        
        .stock-item { display: flex; justify-content: space-between; font-size: 0.85rem; padding: 5px 0; border-bottom: 1px solid #222; }
    </style>
</head>
<body>
    <div class="nav">
        <div><span style="font-weight:900; letter-spacing:-1px; font-size:1.5rem;">OMEGA</span> <span style="color:var(--main)">PLATINUM</span></div>
        <div style="display:flex; gap:15px; align-items:center;">
            <a href="/analytics" class="btn btn-ghost"><i class="fa-solid fa-chart-line"></i> ANALYTICS</a>
            <a href="/new" class="btn btn-main"><i class="fa-solid fa-plus"></i> NOVÝ NÁBOR</a>
            <a href="/logout" class="btn btn-ghost"><i class="fa-solid fa-power-off"></i></a>
        </div>
    </div>

    <div class="stats-grid">
        <div class="card">
            <p>Aktivní Personál</p>
            <h2 id="live-count">{{ count }}</h2>
        </div>
        <div class="card">
            <p>Skladový Stav</p>
            <div class="stock-list">
                {% for item in stock %}
                <div class="stock-item"><span>{{ item.name }}</span> <span style="color:var(--main)">{{ item.count }} ks</span></div>
                {% endfor %}
            </div>
        </div>
        <div class="card" style="border-color: var(--accent);">
            <p>System Health</p>
            <div style="margin-top:10px;"><span class="pulse-dot"></span> <span style="color:var(--accent); font-weight:bold;">LIVE PULSE ACTIVE</span></div>
        </div>
    </div>

    <div class="card" style="padding:0;">
        <table>
            <thead>
                <tr>
                    <th>ZAMĚSTNANEC</th>
                    <th>HARDWARE</th>
                    <th>LEVEL</th>
                    <th>AKCE</th>
                </tr>
            </thead>
            <tbody id="employee-table">
                {% for e in employees %}
                <tr>
                    <td>
                        <div style="font-weight:bold;">{{ e.name }}</div>
                        <div style="font-size:0.7rem; color:#555;">{{ e.token }}</div>
                    </td>
                    <td>
                        {% if asset_map[e.token] %}
                            {% for a in asset_map[e.token] %}
                                <span style="font-size:0.75rem; color:var(--main)">{{ a.name }}</span>{% if not loop.last %}, {% endif %}
                            {% endfor %}
                        {% else %}
                            <span style="color:#333;">Žádný asset</span>
                        {% endif %}
                    </td>
                    <td><span style="background:#111; padding:3px 8px; border-radius:5px; font-size:0.7rem;">{{ e.career_level or 'Junior' }}</span></td>
                    <td style="display:flex; gap:10px;">
                        <a href="/welcome/{{ e.token }}" target="_blank" class="btn btn-accent">PORTÁL</a>
                        <button onclick="simulateLife('{{ e.token }}')" class="btn btn-ghost">SIMULATE</button>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>

    <script>
        function simulateLife(token) {
            fetch('/api/simulate_milestone/' + token)
                .then(r => r.json())
                .then(data => {
                    alert("Kariérní milníky nasimulovány!");
                    location.reload();
                });
        }

        function updateStats() {
            fetch("/api/stats")
                .then(r => r.json())
                .then(data => {
                    if(data.active_personnel !== undefined) {
                        document.getElementById("live-count").innerText = data.active_personnel;
                        // Zde by šla doplnit i live aktualizace tabulky
                    }
                });
        }
        setInterval(updateStats, 5000);
    </script>
</body>
</html>
HOF

echo "🚀 Restartuji systém pro aktivaci vizuálů..."
cd ..
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &

echo "✅ HOTOVO. Teď už to TAM MUSÍ BÝT."
echo "💡 Otevři anonymní okno a uvidíš tlačítka PORTÁL a SIMULATE."
