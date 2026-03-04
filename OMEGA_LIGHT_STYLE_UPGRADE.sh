#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

cat > templates/index.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OMEGA PLATINUM | Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg: #f8f9fa;
            --card-bg: #ffffff;
            --primary: #007bff;
            --secondary: #6c757d;
            --text: #212529;
            --border: #dee2e6;
        }

        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: 'Inter', -apple-system, sans-serif;
            margin: 0;
            padding: 15px;
            line-height: 1.5;
        }

        .header {
            display: flex;
            flex-direction: column;
            gap: 15px;
            padding: 20px;
            background: var(--card-bg);
            border-bottom: 2px solid var(--primary);
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }

        @media (min-width: 768px) {
            .header { flex-direction: row; justify-content: space-between; align-items: center; }
        }

        .logo { font-size: 1.25rem; font-weight: 700; color: var(--primary); text-transform: uppercase; letter-spacing: 1px; }

        .nav-buttons { display: flex; flex-wrap: wrap; gap: 10px; }

        .grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
        }

        @media (min-width: 992px) {
            .grid { grid-template-columns: repeat(3, 1fr); }
        }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
        }

        .card h2 {
            font-size: 0.85rem;
            text-transform: uppercase;
            color: var(--secondary);
            margin-top: 0;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 10px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 15px;
            background: white;
            border: 1px solid var(--border);
            border-radius: 6px;
            color: var(--text);
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 500;
            transition: all 0.2s;
        }

        .btn:hover { background: #f1f3f5; border-color: var(--primary); color: var(--primary); }

        .btn-primary { background: var(--primary); color: white; border-color: var(--primary); }
        .btn-primary:hover { background: #0056b3; color: white; }

        .list { list-style: none; padding: 0; margin: 0; }
        .list-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f1f3f5;
        }

        .status-dot { height: 8px; width: 8px; border-radius: 50%; display: inline-block; background: #28a745; margin-right: 5px; }

    </style>
</head>
<body>
    <div class="header">
        <div class="logo"><i class="fa-solid fa-gem"></i> OMEGA PLATINUM</div>
        <div class="nav-buttons">
            <a href="/agenda" class="btn"><i class="fa-solid fa-calendar"></i> AGENDA</a>
            <a href="/assets" class="btn"><i class="fa-solid fa-box"></i> SKLAD</a>
            <a href="/audit" class="btn"><i class="fa-solid fa-shield"></i> AUDIT</a>
            <a href="/logout" class="btn" style="color: #dc3545;"><i class="fa-solid fa-power-off"></i></a>
        </div>
    </div>

    <div class="grid">
        <div class="card">
            <h2><i class="fa-solid fa-users"></i> AKTIVNÍ PERSONÁL</h2>
            <ul class="list">
                {% for e in employees %}
                <li class="list-item">
                    <div>
                        <div style="font-weight: 600;">{{ e.name }}</div>
                        <div style="font-size: 0.75rem; color: var(--secondary);">{{ e.token }}</div>
                    </div>
                    <div style="display:flex; gap:5px;">
                        <a href="/generate_verified_contract/{{ e.token }}" class="btn" title="Smlouva"><i class="fa-solid fa-file-signature"></i></a>
                        <a href="/generate_doc/protokol/{{ e.token }}" class="btn" title="Protokol"><i class="fa-solid fa-laptop"></i></a>
                    </div>
                </li>
                {% endfor %}
            </ul>
        </div>

        <div class="card">
            <h2><i class="fa-solid fa-warehouse"></i> STAV SKLADU</h2>
            <div id="asset-list">
                <div style="font-size: 0.9rem; color: var(--secondary);">Načítám inventář...</div>
            </div>
        </div>

        <div class="card">
            <h2><i class="fa-solid fa-network-wired"></i> NETWORK MONITOR</h2>
            <div id="net-nodes" style="font-size: 0.85rem;">
                Hledám aktivní uzly...
            </div>
        </div>
    </div>

    <script>
        function refreshData() {
            fetch('/api/network_scan').then(r => r.json()).then(data => {
                const div = document.getElementById('net-nodes');
                div.innerHTML = data.map(ip => `<div class="list-item"><span class="status-dot"></span> ${ip}</div>`).join('') || 'Žádná zařízení';
            });
        }
        setInterval(refreshData, 30000);
        refreshData();
    </script>
</body>
</html>
HOF

echo "🚀 Restartuji elegantní systém..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
echo "💎 STYL DOKONČEN. Systém je nyní světlý, elegantní a responzivní."
